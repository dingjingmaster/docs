# void start_kernel(void)

```c
asmlinkage __visible __init __no_sanitize_address __noreturn __no_stack_protector
void start_kernel(void)
{
    char *command_line;
    char *after_dashes;

    /**
     * 在进程的内核栈末尾设置一个特殊标记值（用于内核栈溢出检测）
     *  用于进程创建或者切换
     */
    set_task_stack_end_magic(&init_task);       

    /**
     * 为对称多处理器(SMP)系统设置处理器ID，每个处理器核心都有唯一ID
     *  用于启动阶段调用，并在每个处理器上执行以下操作：
     *    1. 读取处理器特定寄存器或其它硬件信息来获取处理器唯一标识符
     *    2. 将该标识符作为处理器ID分配给当前处理器
     *    3. 更新内核数据结构，将处理器ID与当前处理器相关联
     *  内核能区分处理器后就可以正确进行调度、进行处理器间的通信。
     *  这在很多地方有重要作用，比如：进程调度、中断处理、锁机制等
     */
    smp_setup_processor_id();

    /**
     * 启动初始化阶段为内核的调试对象子系统进行初始化
     * 调试对象子系统用于跟踪和调试内核对象的分配和释放情况，以帮助发现和修复内存泄漏等问题
     * 主要完成以下功能：
     *   1. 初始化调试对象子系统的数据结构：函数会初始化调试对象子系统的数据结构
     *   2. 设置调试对象的初始状态：调试对象的初始状态一般是未分配或者未使用
     *   3. 注册调试对象的分配和释放回调函数：函数会注册回调函数，用于在对象分配和释放时候执行相应的操作，
     */
    debug_objects_early_init();

    /**
     * 初始化内核的构建标识(Build ID)
     * 构建ID是用于唯一标识特定
     * 主要用于：
     *   1. 调试和故障排查时候比较不同版本的内核
     */
    init_vmlinux_build_id();

    /**
     * 早期初始化阶段初始化控制组（cgroup）子系统
     *  控制组是Linux内核中的一个特性，用于对进程和资源进行分类和管理。
     *  它提供了一种机制，可以限制、监控和分配进程的资源使用，例如：
     *  CPU、内存、磁盘I/O等。
     * cgroup_init_early()在内核早期初始化阶段调用，主要完成以下功能：
     *   1. 初始化控制子系统的数据结构
     *   2. 注册控制组子系统
     *   3. 进行子系统特定的初始化
     */
    cgroup_init_early();

    /**
     * 主要功能是禁用本地中断
     *  多处理器中，每个处理器（或核心）都有自己的中断控制系统，可以独立的处理中断。
     *  禁用本地中断意味着阻止中断处理程序的执行
     * 主要功能：
     *   1. 禁用本地中断
     *   2. 防止中断嵌套：此函数在禁用中断之前保存当前的中断状态，并在启用本地中断时候恢复之前的状态。
     *      这样避免了中断嵌套问题，确保中断处理程序的正确执行。
     * 另外，通过禁用本地中断，内核可以在某些关键代码段或临界区域保持原子性操作，防止中断干扰和并发问题。
     */
    local_irq_disable();
    early_boot_irqs_disabled = true;

    /**
     * 在引导阶段对引导处理器（CPU）进行初始化
     * 引导处理器是在系统启动时候首先启动的处理器，它负责执行引导代码和初始化内核的一些基本设置
     * 主要功能：
     *   1. 初始化引导处理器的核心数据结构
     *   2. 设置引导处理器的标识和状态：函数会设置引导处理器的标识符，通常将其ID设置为0，标识它是第一个启动的处理器
     *   3. 执行处理器特定的初始化操作：比如：设置处理器的初始频率、启用处理器缓存等。
     */
    boot_cpu_init();

    /**
     * 主要负责初始化页框的地址映射
     *  在Linux中，虚拟内存通常对应物理内存中一个个的页框，每个页框通常对应物理内存中的一个页。
     *  这个函数主要功能是为每个页框建立虚拟地址和物理地址之间的映射关系
     * 主要功能：
     *   1. 为每个页框分配虚拟地址，这些虚拟地址用于访问对应的物理页。
     *   2. 建立页框的虚拟地址映射，函数会将每个页框的虚拟地址与其对应的物理地址进行映射。这样当访问虚拟地址时候内核可以通过映射关系找到对应物理地址
     *   3. 初始化页框相关的数据结构，函数还会初始化与页框相关的数据结构，例如：页表项、内存描述符等，以便内核可以正确管理和操作这些页框。
     */
    page_address_init();
    pr_notice("%s", linux_banner);

    /**
     * 在早期初始化阶段执行安全相关的初始化操作
     * 主要功能：
     *   1. 启用基本的安全功能
     *   2. 初始化安全子系统：访问控制、身份验证、安全策略
     *   3. 加载安全策略：
     */
    early_security_init();

    /**
     * 在系统启动过程中设置体系结构相关的初始化参数和操作
     * 主要功能：
     *   1. 设置体系结构相关的参数
     *   2. 初始化体系结构特定的数据结构
     *   3. 注册体系结构特定的回调函数：中断处理程序、内存管理操作、设备初始化等
     */
    setup_arch(&command_line);
    /**
     * 
     *
     */
    setup_boot_config();

    /**
     * 解析和处理启动命令行参数
     *  在Linux中，启动命令行参数是通过 boot loader传递给内核的。
     * 具体功能：
     *   1. 解析命令行参数
     *   2. 存储命令行参数
     *   3. 处理特定的命令行选项
     */
    setup_command_line(command_line);

    /**
     * 设置系统中可用的CPU（核心）数量
     *  在Linux启动过程中，对于多和系统，内核需要知道系统中有多少个CPU可用于进行正确的初始化和调度。
     * 具体功能：
     *   1. 检测可用的CPU数量：涉及读取和解析BIOS/ACPI表、处理器拓扑信息等
     *   2. 设置内核中的CPU数量：这将影响内核对CPU管理和调度策略
     *   3. 分配相关数据结构：函数会根据可用的CPU数量分配和初始化内核中与CPU相关的数据结构
     */
    setup_nr_cpu_ids();

    /**
     * 为每个CPU分配和初始化per-CPU区域。
     *  多和系统中，每个CPU都需要一些独立的内存区域，用于存储与该CPU相关的数据结构和状态信息，这些区域称per-CPU区域。
     * 具体功能：
     *   1. 分配per-CPU区域
     *   2. 初始化per-CPU区域：将区域的内存清零、设置初始值、建立指针关系等
     *   3. 关联per-CPU数据结构：这些数据结构可以是，与CPU相关的计数器、指针、状态变量等，用于管理和跟踪每个CPU状态和资源。
     */
    setup_per_cpu_areas();

    /**
     * 为引导CPU进行多处理器（SMP）系统的准备工作
     *  引导CPU是最早启动的cpu，其任务是初始化系统并启动其它CPU。
     * 具体功能：
     *   1. 设置CPU的表示
     *   2. 初始化引导CPU的per-CPU区域
     *   3. 启动其它CPU，调用其它函数来启动CPU。这可能涉及设置CPU的状态、加载初始代码、设置堆栈等，以便其它CPU可以开始执行
     */
    smp_prepare_boot_cpu(); /* arch-specific boot-cpu hooks */

    /**
     * 初始化引导CPU的热插拔功能
     *  热插拔是指在系统运行时候动态添加或移出硬件设备或资源的能力。在多处理系统中，热插拔功能可以用于在系统运行时候添加或移出CPU
     * 具体功能：
     *   1. 初始化引导CPU的热插拔功能。包括分配和初始化热插拔相关的数据结构、设置回调函数、注册事件处理程序等
     *   2. 启用引导CPU的热插拔功能。这可能涉及设置标志位、启动事件监听等操作。
     *   3. 处理引导CPU的热插拔事件。这可能会注册回调函数或事件处理程序，用于处理引导CPU的热插拔事件。
     */
    boot_cpu_hotplug_init();

    pr_notice("Kernel command line: %s\n", saved_command_line);
    /* parameters may set static keys */
    /**
     * 初始化跳转标签机制
     *  跳转标签是一种优化机制，用于在内核中进行快速的条件分支和函数跳转。它可以用于在运行时候根据条件或配置来选择不同的代码路径，
     *  从而提高代码执行的效率。
     * 具体功能：
     *   1. 初始化跳转标签数据结构：初始化跳转标签相关的数据结构，包括跳转表、标签状态等。这些数据结构用于跟踪和管理跳转标签的状态和配置
     *   2. 注册跳转标签：函数会注册跳转标签，将其与相关的代码位置或函数关联起来。这样，当跳转标签被激活时候，可以快速跳转到指定代码位置或函数
     *   3. 配置跳转标签：函数可能会根据系统配置、编译选项或其它因素来配置跳转标签的行为。这可以包括启用或禁用特定的跳转标签、设置默认的跳转目标等。
     */
    jump_label_init();
    parse_early_param();
    after_dashes = parse_args("Booting kernel",
                  static_command_line, __start___param,
                  __stop___param - __start___param,
                  -1, -1, NULL, &unknown_bootoption);
    print_unknown_bootoptions();
    if (!IS_ERR_OR_NULL(after_dashes))
        parse_args("Setting init args", after_dashes, NULL, 0, -1, -1,
               NULL, set_init_arg);
    if (extra_init_args)
        parse_args("Setting extra init args", extra_init_args,
               NULL, 0, -1, -1, NULL, set_init_arg);

    /* Architectural and non-timekeeping rng init, before allocator init */
    /**
     * 在内核的早期阶段初始化早期随机数生成器。
     * 随机数生成器常用语密码学、安全性、模拟等方面
     */
    random_init_early(command_line);

    /*
     * These use large bootmem allocations and must precede
     * initalization of page allocator
     */
    /**
     * 内核日志缓存其是用于存储内核打印信息和日志消息的一块内存区域
     * 主要功能如下：
     *   1. 分配日志缓存区内存
     *   2. 设置日志缓存区指针：函数将日志缓存区的起始地址设置到相应的指针变量中，以便内核可以访问和写入日志消息
     *   3. 初始化日志缓存区：例如将内存清零、设置初始值等操作，以确保日志缓存区处于可用状态。
     */
    setup_log_buf(0);

    /**
     * 在内核早期初始化阶段，初始化虚拟文件系统(VFS)缓存
     *  虚拟文件系统是Linux内核中的一个子系统，负责管理和操作文件系统的抽象接口。
     *  缓存是为了提高文件系统访问性能而引入的一种机制，可以缓存文件系统中的元数据和数据块，以减少对底层存储设备的访问
     * 具体功能如下：
     *   1. 初始化VFS缓存数据结构：包括inode缓存、dentry缓存等。这些数据用于管理和存储文件系统的元数据和数据
     *   2. 分配和初始化缓存空间：函数会为VFS缓存分配一定的内存空间，并进行初始化，这可能涉及到内存的分配、初始化链表或哈希表等数据结构，以及设置缓存的初始状态
     *   3. 注册缓存管理函数：函数会注册相应的回调函数或管理函数，用于管理和操作VFS缓存。这些函数可以包含缓存的分配、释放、查找等。
     */
    vfs_caches_init_early();

    /**
     * 异常处理表的排序
     */
    sort_main_extable();

    /**
     * 初始化中断和异常处理机制
     * 功能如下：
     *   1. 设置中断向量表
     *   2. 设置中断处理函数
     *   3. 初始化异常处理机制：设置异常处理函数、异常堆栈、异常处理标志等。异常处理机制用于在出现错误或异常情况时候进行相应的处理和恢复
     */
    trap_init();

    /**
     * 初始化内存管理子系统的核心部分
     *  内存管理子系统负责管理系统中的物理内存和虚拟内存，包括内存分配、映射、回收、页面置换等操作。主要在初始化早期阶段被调用
     * 功能如下：
     *   1. 初始化内存描述符
     *   2. 建立内核虚拟地址空间
     *   3. 初始化页表和页框管理
     *   4. 初始化内存分配器
     */
    mm_core_init();
    poking_init();

    /**
     * ftrace 是Linux内核中的一种跟踪工具，用于分析和调试内核中的函数调用关系和性能瓶颈。
     * 具体功能如下：
     *   1. 初始化ftrace相关数据结构
     *   2. 注册ftrace回调函数
     *   3. 配置ftrace 参数
     *   4. 启用ftrace功能
     */
    ftrace_init();

    /* trace_printk can be enabled here */
    /**
     * 初始化 trace 机制
     *  trace在内核启动早期就开始手机跟踪信息
     * 具体操作：
     *   1. 初始化早期跟踪缓存区
     *   2. 注册早期跟踪处理函数
     *   3. 配置早期跟踪函数：跟踪级别、输出格式、缓存区大小等
     */
    early_trace_init();

    /**
     * 初始化调度器子系统
     *  负责决定进程或线程的执行顺序和资源分配
     * 具体功能如下：
     *   1. 初始化调度器数据结构：初始化调度器所需的数据结构，例如就绪队列、等待队列、调度策略等。这些数据结构主要用于跟踪和管理系统中的线程和调度顺序
     *   2. 设置系统默认调度策略：如：FIFO、轮转(Round Robin)、实时（Real-time）等
     *   3. 注册调度器相关函数：函数会注册调度器相关的函数，包括进程调度函数、上下文切换函数、时间片更新函数等。这些函数用于实现具体的调度算法和调度行为
     *   4. 初始化调度器定时器：函数会初始化调度器定时器，用于触发系统定期进行进程或线程调度。
     */
    sched_init();

    if (WARN(!irqs_disabled(),
         "Interrupts were enabled *very* early, fixing it\n"))
        local_irq_disable();

    /**
     * 初始化基数树（Radix Tree）数据结构
     *  基数树是一种高效的数据结构，用于在内核中进行键值对的存储和查找。
     * 具体功能如下：
     *   1. 初始基数树的根节点：函数会创建并初始化基数树的根节点，作为基数树数据结构的起始点
     *   2. 设置技术处的参数：函数会设置和配置基数树的参数，例如节点大小、键值对的最大数量等。这些值决定了基数树的容量和性能
     *   3. 初始化基数树的锁：函数会初始化用于并发访问的基数树锁，以确保在多环境下对基数树的安全访问。
     */
    radix_tree_init();

    /**
     *
     */
    maple_tree_init();

    /*
     * Set up housekeeping before setting up workqueues to allow the unbound
     * workqueue to take non-housekeeping into account.
     */
    /**
     * 初始化系统的后台任务管理
     *  Linux中后台任务是一些周期性执行或处理系统资源的任务，例如：垃圾回收、定时器管理、资源清理等。
     * 其具体功能如下：
     *   1. 注册后台任务
     *   2. 设置后台任务的执行周期：例如任务的执行周期
     *   3. 初始化后台任务相关的数据结构：例如任务控制块、计时器等
     */
    housekeeping_init();

    /**
     * 在内核早期阶段初始化工作队列
     *  工作队列是一种异步执行机制，用于在后台线程中处理一些延迟执行的工作
     * 具体功能如下：
     *   1. 创建工作队列
     *   2. 初始化工作队列相关的数据结构：队列头、锁、计数器等
     *   3. 注册工作队列：函数会将工作队列注册到内核中，以便其它部分的代码可以使用该任务队列来提交工作项
     */
    workqueue_init_early();

    /**
     * 初始化读-复制更新机制
     *  RCU是一种用于多线程环境下的数据同步机制，用于实现高效且无所的读取操作和并发更新操作。
     * 具体功能如下：
     *   1. 初始化RCU相关的数据结构，函数会初始化RCU所需的数据结构，例如RCU状态变量、读取者数据结构、更新者数据结构等。这些数据结构用于跟踪和管理RCU状态和参与者
     *   2. 注册RCU的回调函数，函数会注册RCU的回调函数，用于处理读取者和更新者的相关操作。这些回调函数在RCU机制中起到了关键作用，确保数据的一致性和并发访问的正确性
     *   3. 设置 RCU 的参数和配置，函数会设置和配置RCU的参数，例如读取者的优先级、回调函数的调度策略等，这些参数决定了RCU的行为和性能
     */
    rcu_init();

    /* Trace events are available after this */
    trace_init();

    if (initcall_debug)
        initcall_debug_enable();

    /**
     * 初始化上下文跟踪机制
     *  上下文跟踪是一种用于跟踪和记录任务上下文切换的机制，用于分析和优化系统的调度行为和性能
     * 具体功能如下：
     *   1. 初始化上下文跟踪相关的数据结构
     *   2. 注册上下文跟踪的回调函数
     *   3. 配置上下文跟踪的参数和选项
     */
    context_tracking_init();
    /* init some links before init_ISA_irqs() */
    early_irq_init();
    init_IRQ();
    tick_init();
    rcu_init_nohz();
    init_timers();
    srcu_init();
    hrtimers_init();
    softirq_init();
    timekeeping_init();
    time_init();

    /* This must be after timekeeping is initialized */
    random_init();

    /* These make use of the fully initialized rng */
    kfence_init();
    boot_init_stack_canary();

    perf_event_init();
    profile_init();
    call_function_init();
    WARN(!irqs_disabled(), "Interrupts were enabled early\n");

    early_boot_irqs_disabled = false;
    local_irq_enable();

    kmem_cache_init_late();

    /*
     * HACK ALERT! This is early. We're enabling the console before
     * we've done PCI setups etc, and console_init() must be aware of
     * this. But we do want output early, in case something goes wrong.
     */
    console_init();
    if (panic_later)
        panic("Too many boot %s vars at `%s'", panic_later,
              panic_param);

    lockdep_init();

    /*
     * Need to run this when irqs are enabled, because it wants
     * to self-test [hard/soft]-irqs on/off lock inversion bugs
     * too:
     */
    locking_selftest();

#ifdef CONFIG_BLK_DEV_INITRD
    if (initrd_start && !initrd_below_start_ok &&
        page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
        pr_crit("initrd overwritten (0x%08lx < 0x%08lx) - disabling it.\n",
            page_to_pfn(virt_to_page((void *)initrd_start)),
            min_low_pfn);
        initrd_start = 0;
    }
#endif
    setup_per_cpu_pageset();
    numa_policy_init();
    acpi_early_init();
    if (late_time_init)
        late_time_init();
    sched_clock_init();
    calibrate_delay();

    arch_cpu_finalize_init();

    pid_idr_init();
    anon_vma_init();
#ifdef CONFIG_X86
    if (efi_enabled(EFI_RUNTIME_SERVICES))
        efi_enter_virtual_mode();
#endif
    thread_stack_cache_init();
    cred_init();
    fork_init();
    proc_caches_init();
    uts_ns_init();
    key_init();
    security_init();
    dbg_late_init();
    net_ns_init();
    /**
     *
     */
    vfs_caches_init();
    pagecache_init();
    signals_init();
    seq_file_init();
    /**
     *
     */
    proc_root_init();
    nsfs_init();
    cpuset_init();
    cgroup_init();
    taskstats_init_early();
    delayacct_init();

    acpi_subsystem_init();
    arch_post_acpi_subsys_init();
    kcsan_init();

    /* Do the rest non-__init'ed, we're now alive */
    arch_call_rest_init();

    /*
     * Avoid stack canaries in callers of boot_init_stack_canary for gcc-10
     * and older.
     */
#if !__has_attribute(__no_stack_protector__)
    prevent_tail_call_optimization();
#endif
}
```
