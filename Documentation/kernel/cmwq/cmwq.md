# 并发管理工作队列(cmwq)

## 说明

在许多情况下，需要异步进程执行上下文，而工作队列(wq) API是这种情况下最常用的机制。

当需要这样的异步执行上下文时，描述要执行哪个函数的工作项将放在队列中。一个独立的线程充当异步执行上下文。队列称为workqueue，线程称为worker。

当工作队列上有工作项时，worker一个接一个地执行与工作项相关的函数。当工作队列上没有剩余的工作项时，工作线程变为空闲状态。当一个新的工作项进入队列时，worker将再次开始执行。

## why cmwq

在最初的wq实现中，多线程(MT) wq在每个CPU上有一个工作线程，单线程(ST) wq在系统范围内有一个工作线程。单个MT wq需要保持与cpu数量相同的工作线程数量。多年来，内核增加了很多MT wq用户，并且随着CPU内核数量的不断增加，一些系统在启动时就用尽了默认的32k PID空间。

虽然MT wq浪费了大量资源，但提供的并发性水平并不令人满意。这个限制在ST和MT wq中都很常见，尽管在MT中没有那么严重。每个wq都维护自己单独的工作池。MT wq只能为每个CPU提供一个执行上下文，而ST wq可以为整个系统提供一个执行上下文。工作项必须竞争那些非常有限的执行上下文，从而导致各种问题，包括围绕单个执行上下文的死锁倾向。

所提供的并发级别和资源使用之间的紧张关系也迫使其用户做出不必要的权衡，比如libata选择使用ST wq轮询io，并接受一个不必要的限制，即不能同时进行两个轮询io。由于MT wq不能提供更好的并发性，需要更高级别并发性(如async或fscache)的用户必须实现自己的线程池。

并发管理的工作队列(cmwq)是对wq的重新实现，主要关注以下目标：
- 保持与原始工作队列API的兼容性。
- 使用由all wq共享的每个cpu统一的工作池，在不浪费大量资源的情况下按需提供灵活的并发级别。
- 自动调节工作池和并发级别，以便API使用者无需关注这些细节。

## 设计思路

为了简化功能的异步执行，引入了一个新的抽象，即工作项。

工作项是一个简单的结构体，它包含一个指向要异步执行的函数的指针。每当驱动程序或子系统想要异步执行一个函数时，它必须设置一个指向该函数的工作项，并将该工作项放在工作队列上。

特殊用途的线程，称为工作线程，一个接一个地执行队列外的函数。如果没有工作排队，则工作线程变为空闲。这些工作线程在所谓的工作池中进行管理。

cmwq设计区分了面向用户的工作队列(子系统和驱动程序在其上对工作项进行排队)并管理工作池以及处理排队工作项的后端机制。

有两个工作池，一个用于普通工作项，另一个用于高优先级的工作项，用于每个可能的CPU和一些额外的工作池，以服务在未绑定工作队列上排队的工作项——这些后备池的数量是动态的。

子系统和驱动程序可以通过他们认为合适的特殊工作队列API函数创建和排队工作项。他们可以通过在他们放置工作项的工作队列上设置标志来影响工作项执行方式的某些方面。这些标志包括CPU局部性、并发限制、优先级等。要获得详细的概述，请参阅下面alloc_workqueue()的API描述。

当工作项排队到工作队列时，根据队列参数和工作队列属性确定目标工作池，并将其添加到工作池的共享工作列表中。例如，除非特别覆盖，否则绑定工作队列的工作项将在与运行发行者的CPU相关联的普通或高优先级工作池的工作列表中排队。

对于工作池实现，管理并发级别(有多少执行上下文处于活动状态)是一个重要问题。CMWQ试图将并发性保持在最小但足够的级别。最小限度地节省资源，并充分利用系统的全部能力。

绑定到实际CPU的每个工作池通过连接到调度程序来实现并发管理。每当活动的工作线程唤醒或休眠时，工作线程池就会收到通知，并跟踪当前可运行的工作线程的数量。通常，工作项不会占用CPU并消耗很多周期。这意味着保持足够的并发性以防止工作处理停滞应该是最优的。只要CPU上有一个或多个可运行的工作线程，工作线程池就不会开始执行新的工作，但是，当最后一个运行的工作线程进入睡眠状态时，它会立即调度一个新的工作线程，这样CPU就不会在等待工作项时处于空闲状态。这允许在不损失执行带宽的情况下使用最少数量的工作线程。

保持空闲的工作线程除了占用线程的内存空间外，不会占用其他任何开销，因此cmwq会在杀死空闲的工作线程之前保留一段时间。

对于未绑定的工作队列，后备池的数量是动态的。可以使用apply_workqueue_attrs()为未绑定的工作队列分配自定义属性，并且工作队列将自动创建匹配这些属性的后备工作池。用户有责任调节并发级别。还有一个标志可以将绑定wq标记为忽略并发管理。详情请参阅API部分。

向前进度保证依赖于在需要更多执行上下文时可以创建工作人员，这反过来又通过使用救援工作人员来保证。可能在处理内存回收的代码路径上使用的所有工作项都需要在wq上排队，这些wq保留了一个救援工作者，以便在内存压力下执行。否则，工作池可能会死锁，等待执行上下文释放。

## 编程接口(API)

`alloc_workqueue()`分配一个wq。原始的`create_*workqueue()`函数已弃用，并计划删除。`alloc_workqueue()`接受三个参数：`name`， `flags`和`max_active`。`name`是wq的名称，如果有拯救程序线程，也用作拯救程序线程的名称。

wq不再管理执行资源，而是作为向前进度保证、刷新和工作项属性的域。`flags`和`max_active`控制如何分配执行资源、调度和执行工作项。

### flags

**WQ_UNBOUND：**
工作项(Work items)会被加入到`UNBOUND wq`队列，工作池尝试尽快执行加入的工作项。`UNBOUND wq` 会牺牲局部性，但是在以下情况下很有用：
- 如果并发级别需求有很大的波动，使用bound wq可能会在不同的cpu之间创建大量未使用的worker，因为发行者会在不同的cpu之间跳转。
- 可以由系统调度器更好地管理的长时间运行的CPU密集型工作负载。

**WQ_FREEZABLE：**
`freezable wq`参与系统挂起操作的冻结阶段。在解冻之前，wq上的工作项将被清空，没有新的工作项开始执行。

**WQ_MEM_RECLAIM：**
所有可能在内存回收路径中使用的wq必须设置此标志。无论内存压力如何，wq都保证至少有一个执行上下文。

**WQ_HIGHPRI：**
highpri wq的工作项会排队到目标cpu的highpri worker-pool。高等级工作线程池由高nice级别的工作线程提供服务。

注意，普通工作池和高级工作池不会相互交互。每个线程维护其单独的工作线程池，并在其工作线程之间实现并发管理。

**WQ_CPU_INTENSIVE：**
CPU密集型wq的工作项不会影响并发级别。换句话说，可运行的CPU密集型工作项不会阻止同一工作池中的其他工作项开始执行。这对于预期占用CPU周期的绑定工作项非常有用，因此它们的执行由系统调度器调节。
尽管CPU密集型工作项对并发性级别没有贡献，但它们的执行的开始仍然由并发性管理调节，并且可运行的非CPU密集型工作项可以延迟CPU密集型工作项的执行。
这个标志对于未绑定的wq没有意义。

### max_active

@max_active决定每个CPU可以分配给wq工作项的执行上下文的最大数量。例如，如果@max_active为16，则每个CPU最多可以同时执行16个wq的工作项。

目前，对于绑定wq， @max_active的最大限制为512，指定0时的默认值为256。对于未绑定的wq，上限为512和4 * num_possible()。这些值被选得足够高，以至于在失控情况下提供保护时，它们不是限制因素。

wq的活动工作项的数量通常由wq的使用者来调节，更具体地说，由使用者可以同时排队的工作项的数量来调节。除非特别需要限制活动工作项的数量，否则建议指定“0”。

有些用户依赖于ST wq严格的执行顺序。@max_active(1)和WQ_UNBOUND的组合用于实现此行为。这样的wq上的工作项总是排队到未绑定的工作池，并且在任何给定的时间只有一个工作项可以是激活的，从而实现与ST wq相同的排序属性。
在当前的实现中，上述配置仅保证给定NUMA节点内的ST行为。相反，应该使用alloc_ordered_queue()来实现系统范围的ST行为。
