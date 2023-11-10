# 对称多处理器

提高硬件性能最简单(最便宜)的方法之一是在主板上放置多个CPU。这可以让不同的cpu执行不同的任务(**不对称多处理**)，也可以让它们并行运行，执行相同的任务(**对称多处理，又名SMP**)。有效地进行非对称多处理需要有关计算机应该执行的任务的专门知识，这在Linux等通用操作系统中是不可用的。另一方面，对称多处理相对容易实现。我说的相对简单，是指它确实简单，并不是说它真的很简单。在对称的多处理环境中，CPU共享相同的内存，因此在一个CPU中运行的代码可能会影响另一个CPU使用的内存。您不能再确定在前一行中设置为特定值的变量是否仍然具有该值——其他CPU可能在您不注意的时候对它进行了操作。显然，这样编程是不可能的。
在进程编程的情况下，这通常不是问题，因为一个进程通常一次只在一个CPU上运行。另一方面，内核可以由运行在不同cpu上的不同进程调用。

在2.0版本中。X，这不是问题，因为整个核都在一个大的自旋锁中。这意味着，如果一个CPU在内核中，而另一个CPU想要进入，例如由于系统调用，它必须等待，直到第一个CPU完成。这使得Linux SMP更安全，但效率极低。

在2.2版本中。在x操作系统中，内核中可以同时有多个cpu。这是模块编写者需要注意的。有人给了我一个SMP盒子，所以希望这本书的下一个版本会包含更多的信息。