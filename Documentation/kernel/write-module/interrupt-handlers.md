# 中断处理

除了最后一章，到目前为止，我们在内核中所做的一切都是作为对请求它的进程的响应，或者通过处理一个特殊文件，发送一个ioctl，或者发出一个系统调用。但是内核的工作不仅仅是响应进程请求。另一项同样重要的工作是与连接到机器上的硬件对话。

在CPU和计算机其他硬件之间有两种类型的交互：
1. 第一种是CPU给硬件下命令
2. 另一种是硬件需要告诉CPU一些事情
第二种称为中断，实现起来要困难得多，因为它必须在硬件方便的时候处理，而不是CPU。硬件设备通常具有非常少的ram，如果您在可用时不读取它们的信息，则会丢失这些信息。

在Linux下，硬件中断被称为irq(中断请求的缩写)11.1。irq有两种类型，短的和长的。短IRQ预计会占用很短的时间，在此期间，机器的其余部分将被阻塞，并且不会处理其他中断。一个较长的IRQ可以占用较长的时间，并且在此期间可能会发生其他中断(但不是来自同一设备的中断)。如果可能的话，最好将中断处理程序声明为长。

当CPU接收到一个中断时，它停止它正在做的任何事情(除非它正在处理一个更重要的中断，在这种情况下，它只会在更重要的中断完成时处理这个中断)，在堆栈上保存某些参数并调用中断处理程序。这意味着中断处理程序本身不允许某些事情发生，因为系统处于未知状态。这个问题的解决方案是中断处理程序立即做需要做的事情，通常是从硬件读取一些东西或向硬件发送一些东西，然后在稍后的时间安排处理新信息(这被称为“下半部分”)并返回。然后内核保证尽快调用下半部——当它调用时，内核模块中允许的所有内容都将被允许。

实现这一点的方法是调用`request_irq`，以便在接收到相关的IRQ时调用中断处理程序(在英特尔平台上有16个中断处理程序)。这个函数接收IRQ号、函数名、标志、`/proc/interrupts`的名称和传递给中断处理程序的参数。标志可以包括`SA_SHIRQ`，表示您愿意与其他中断处理程序共享IRQ(通常是因为许多硬件设备位于同一个IRQ上)，`SA_INTERRUPT`表示这是一个快速中断。只有在这个IRQ上还没有处理程序，或者双方都愿意共享时，这个函数才会成功。

然后，在中断处理程序中，我们与硬件通信，然后使用`queue_task_irq`与`tq_immediate`和`mark_bh`(`BH_IMMEDIATE`)来调度下半部分。我们不能在2.0版本中使用标准的`queue_task`的原因是中断可能正好发生在其他人的`queue_task`11.2的中间。我们需要`mark_bh`，因为早期版本的Linux只有32个下半部分的数组，现在其中一个(`BH_IMMEDIATE`)用于驱动程序的下半部分的链表，这些驱动程序没有获得分配给它们的下半部分条目。

## Intel平台上的键盘设备

我在编写本章的示例代码时遇到了一个问题。一方面，作为一个有用的例子，它必须在每个人的计算机上运行并产生有意义的结果。另一方面，内核已经包含了所有常见设备的设备驱动程序，这些设备驱动程序不会与我将要编写的内容共存。我找到的解决方案是为键盘中断编写一些东西，并首先禁用常规键盘中断处理程序。由于它在内核源文件(特别是`drivers/char/keyboardc`)中被定义为静态符号，因此无法恢复它。在运行此代码之前，在另一个终端上执行休眠120;如果您重视您的文件系统，请重新启动。

该代码将自己绑定到IRQ 1，这是在英特尔架构下控制的键盘的IRQ。然后，当它接收到键盘中断时，它读取键盘的状态(这就是inb(0x64)的目的)和扫描码，这是键盘返回的值。然后，一旦内核认为可行，它就运行`got_char`，它给出所使用的键的代码(扫描码的前7位)，以及它是否已被按下(如果第8位是零)或释放(如果是1)。

intrpt.c
```c
/* intrpt.c - An interrupt handler. */


/* Copyright (C) 1998 by Ori Pomerantz */



/* The necessary header files */

/* Standard in kernel modules */
#include <linux/kernel.h>   /* We're doing kernel work */
#include <linux/module.h>   /* Specifically, a module */

/* Deal with CONFIG_MODVERSIONS */
#if CONFIG_MODVERSIONS==1
#define MODVERSIONS
#include <linux/modversions.h>
#endif

#include <linux/sched.h>
#include <linux/tqueue.h>

/* We want an interrupt */
#include <linux/interrupt.h>

#include <asm/io.h>

/* In 2.2.3 /usr/include/linux/version.h includes a
 * macro for this, but 2.0.35 doesn't - so I add it
 * here if necessary. */
#ifndef KERNEL_VERSION
#define KERNEL_VERSION(a,b,c) ((a)*65536+(b)*256+(c))
#endif

/* Bottom Half - this will get called by the kernel
 * as soon as it's safe to do everything normally
 * allowed by kernel modules. */
static void got_char(void *scancode)
{
  printk("Scan Code %x %s.\n",
    (int) *((char *) scancode) & 0x7F,
    *((char *) scancode) & 0x80 ? "Released" : "Pressed");
}

/* This function services keyboard interrupts. It reads
 * the relevant information from the keyboard and then
 * scheduales the bottom half to run when the kernel
 * considers it safe. */
void irq_handler(int irq,
                 void *dev_id,
                 struct pt_regs *regs)
{
  /* This variables are static because they need to be
   * accessible (through pointers) to the bottom
   * half routine. */
  static unsigned char scancode;
  static struct tq_struct task =
        {NULL, 0, got_char, &scancode};
  unsigned char status;

  /* Read keyboard status */
  status = inb(0x64);
  scancode = inb(0x60);

  /* Scheduale bottom half to run */
#if LINUX_VERSION_CODE > KERNEL_VERSION(2,2,0)
  queue_task(&task, &tq_immediate);
#else
  queue_task_irq(&task, &tq_immediate);
#endif
  mark_bh(IMMEDIATE_BH);
}

/* Initialize the module - register the IRQ handler */
int init_module()
{
  /* Since the keyboard handler won't co-exist with
   * another handler, such as us, we have to disable
   * it (free its IRQ) before we do anything. Since we
   * don't know where it is, there's no way to
   * reinstate it later - so the computer will have to
   * be rebooted when we're done.
   */
  free_irq(1, NULL);

  /* Request IRQ 1, the keyboard IRQ, to go to our
   * irq_handler. */
  return request_irq(
    1,  /* The number of the keyboard IRQ on PCs */
    irq_handler,  /* our handler */
    SA_SHIRQ,
    /* SA_SHIRQ means we're willing to have othe
     * handlers on this IRQ.
     *
     * SA_INTERRUPT can be used to make the
     * handler into a fast interrupt.
     */
    "test_keyboard_irq_handler", NULL);
}

/* Cleanup */
void cleanup_module()
{
  /* This is only here for completeness. It's totally
   * irrelevant, since we don't have a way to restore
   * the normal keyboard interrupt so the computer
   * is completely useless and has to be rebooted. */
  free_irq(1, NULL);
}
```
