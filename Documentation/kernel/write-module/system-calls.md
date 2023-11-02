# 系统调用

到目前为止，我们所做的唯一一件事就是使用定义良好的内核机制来注册/proc文件和设备处理程序。如果您想做一些内核程序员认为您想做的事情，比如编写设备驱动程序，这是很好的。但是如果你想做一些不寻常的事情，以某种方式改变系统的行为呢?然后，你就只能靠自己了。

这就是内核编程变得危险的地方。在编写下面的示例时，我取消了开放系统调用。这意味着我不能打开任何文件，不能运行任何程序，也不能关闭电脑。我不得不拉电源开关。幸运的是，没有文件被破坏。为了确保您不会丢失任何文件，请在执行insmod和rmmod之前运行sync。

忘记/proc文件，忘记设备文件。这些都是次要的细节。真正的进程到内核的通信机制是系统调用，所有进程都使用这种机制。当进程向内核请求服务时(例如打开文件、分支到新进程或请求更多内存)，使用的就是这种机制。如果您想以有趣的方式改变内核的行为，那么这里就是您要做的地方。顺便说一下，如果您想查看某个程序使用了哪些系统调用，可以运行`strace <command> <arguments>`。

一般来说，进程不应该能够访问内核。它不能访问内核内存，也不能调用内核函数。CPU的硬件强制执行这一点(这就是为什么它被称为“保护模式”)。系统调用是这个一般规则的一个例外。所发生的是，进程用适当的值填充寄存器，然后调用一个特殊的指令，该指令跳转到内核中先前定义的位置(当然，该位置对用户进程是可读的，而不是可写的)。在Intel cpu下，这是通过中断0x80完成的。硬件知道，一旦跳转到这个位置，您就不再以受限制的用户模式运行，而是作为操作系统内核运行——因此您可以做任何您想做的事情。

进程在内核中可以跳转到的位置称为`system_call`。该位置的过程检查系统调用号，它告诉内核该进程请求了什么服务。然后，它查看系统调用表(`sys_call_table`)，以查看要调用的内核函数的地址。然后它调用该函数，在它返回后，进行一些系统检查，然后返回到该进程(如果进程时间用完，则返回到另一个进程)。如果您想阅读这段代码，它位于源文件`arch/<architecture>/kernel/entry.S`，在`ENTRY(system_call)`行之后。

因此，如果我们想要改变某个系统调用的工作方式，我们需要做的就是编写我们自己的函数来实现它(通常是通过添加一些我们自己的代码，然后调用原始函数)，然后更改`sys_call_table`的指针，使其指向我们的函数。因为我们以后可能会被删除，而且我们不想让系统处于不稳定的状态，所以`cleanup_module`将表恢复到原始状态非常重要。

这里的源代码是这样一个内核模块的示例。我们想“监视”某个用户，并在该用户打开文件时打印一条消息。为此，我们将打开文件的系统调用替换为我们自己的函数`our_sys_open`。这个函数检查当前进程的uid(用户的id)，如果它等于我们监视的uid，它调用printk来显示要打开的文件的名称。然后，无论采用哪种方式，它都用相同的参数调用原始的open函数，以实际打开文件。

`init_module`函数替换了`sys_call_table`中的适当位置，并将原始指针保留在一个变量中。`cleanup_module`函数使用该变量将一切恢复到正常状态。*这种方法是危险的，因为两个内核模块可能会更改同一个系统调用*。假设我们有两个内核模块A和B, A的开放系统调用将是`A_open`, B的将是`B_open`。现在，当将A插入内核时，系统调用将被`A_open`替换，`A_open`将在完成后调用原始的`sys_open`。接下来，B被插入到内核中，内核用`B_open`替换系统调用，`B_open`在调用完成后会调用它认为是原始系统调用的`A_open`。

现在，如果先删除B，一切都OK——它只会将系统调用恢复到`A_open`, `A_open`调用原来的B。*但是，如果先删除A，然后再删除B，系统将崩溃*。移除A将恢复系统调用到原来的`sys_open`，将B排除在循环之外。然后，当B被删除时，它会将系统调用恢复到它认为是原始的`A_open`, `A_open`不再在内存中。乍一看，我们似乎可以通过检查系统调用是否等于我们的open函数来解决这个特殊的问题，如果是，则根本不改变它(这样B在删除系统调用时就不会改变它)，但这将导致更严重的问题。当删除A时，它看到系统调用被更改为`B_open`，因此它不再指向`A_open`，因此在从内存中删除之前它不会将其恢复为`sys_open`。不幸的是，`B_open`仍然会尝试调用不再存在的`A_open`，因此即使不删除B，系统也会崩溃。

我能想到两种方法来防止这个问题：
1. 第一种方法是将调用恢复为原始值`sys_open`。不幸的是，`sys_open`不是`/proc/ksyms`中内核系统表的一部分，因此我们无法访问它。
2. 另一种解决方案是使用引用计数来防止root在加载模块后对其进行rmmod。这对于生产模块来说是好的，但是对于例子模块本来说是不好的(会导致内核无法卸载)——这就是我在这里没有这样做的原因。

syscall.c
```c
/* syscall.c
 *
 * System call "stealing" sample
 */

/* Copyright (C) 1998-99 by Ori Pomerantz */

/* The necessary header files */

/* Standard in kernel modules */
#include <linux/kernel.h>   /* We're doing kernel work */
#include <linux/module.h>   /* Specifically, a module */

/* Deal with CONFIG_MODVERSIONS */
#if CONFIG_MODVERSIONS==1
#define MODVERSIONS
#include <linux/modversions.h>
#endif

#include <sys/syscall.h>  /* The list of system calls */

/* For the current (process) structure, we need
 * this to know who the current user is. */
#include <linux/sched.h>


/* In 2.2.3 /usr/include/linux/version.h includes a
 * macro for this, but 2.0.35 doesn't - so I add it
 * here if necessary. */
#ifndef KERNEL_VERSION
#define KERNEL_VERSION(a,b,c) ((a)*65536+(b)*256+(c))
#endif

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
#include <asm/uaccess.h>
#endif

/* The system call table (a table of functions). We
 * just define this as external, and the kernel will
 * fill it up for us when we are insmod'ed
 */
extern void *sys_call_table[];

/* UID we want to spy on - will be filled from the
 * command line */
int uid;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
MODULE_PARM(uid, "i");
#endif

/* A pointer to the original system call. The reason
 * we keep this, rather than call the original function
 * (sys_open), is because somebody else might have
 * replaced the system call before us. Note that this
 * is not 100% safe, because if another module
 * replaced sys_open before us, then when we're inserted
 * we'll call the function in that module - and it
 * might be removed before we are.
 *
 * Another reason for this is that we can't get sys_open.
 * It's a static variable, so it is not exported. */
asmlinkage int (*original_call)(const char *, int, int);

/* For some reason, in 2.2.3 current->uid gave me
 * zero, not the real user ID. I tried to find what went
 * wrong, but I couldn't do it in a short time, and
 * I'm lazy - so I'll just use the system call to get the
 * uid, the way a process would.
 *
 * For some reason, after I recompiled the kernel this
 * problem went away.
 */
asmlinkage int (*getuid_call)();

/* The function we'll replace sys_open (the function
 * called when you call the open system call) with. To
 * find the exact prototype, with the number and type
 * of arguments, we find the original function first
 * (it's at fs/open.c).
 *
 * In theory, this means that we're tied to the
 * current version of the kernel. In practice, the
 * system calls almost never change (it would wreck havoc
 * and require programs to be recompiled, since the system
 * calls are the interface between the kernel and the
 * processes).
 */
asmlinkage int our_sys_open(const char *filename,
                            int flags,
                            int mode)
{
  int i = 0;
  char ch;

  /* Check if this is the user we're spying on */
  if (uid == getuid_call()) {
   /* getuid_call is the getuid system call,
    * which gives the uid of the user who
    * ran the process which called the system
    * call we got */

    /* Report the file, if relevant */
    printk("Opened file by %d: ", uid);
    do {
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
      get_user(ch, filename+i);
#else
      ch = get_user(filename+i);
#endif
      i++;
      printk("%c", ch);
    } while (ch != 0);
    printk("\n");
  }

  /* Call the original sys_open - otherwise, we lose
   * the ability to open files */
  return original_call(filename, flags, mode);
}



/* Initialize the module - replace the system call */
int init_module()
{
  /* Warning - too late for it now, but maybe for
   * next time... */
  printk("I'm dangerous. I hope you did a ");
  printk("sync before you insmod'ed me.\n");
  printk("My counterpart, cleanup_module(), is even");
  printk("more dangerous. If\n");
  printk("you value your file system, it will ");
  printk("be \"sync; rmmod\" \n");
  printk("when you remove this module.\n");

  /* Keep a pointer to the original function in
   * original_call, and then replace the system call
   * in the system call table with our_sys_open */
  original_call = sys_call_table[__NR_open];
  sys_call_table[__NR_open] = our_sys_open;

  /* To get the address of the function for system
   * call foo, go to sys_call_table[__NR_foo]. */

  printk("Spying on UID:%d\n", uid);

  /* Get the system call for getuid */
  getuid_call = sys_call_table[__NR_getuid];

  return 0;
}


/* Cleanup - unregister the appropriate file from /proc */
void cleanup_module()
{
  /* Return the system call back to normal */
  if (sys_call_table[__NR_open] != our_sys_open) {
    printk("Somebody else also played with the ");
    printk("open system call\n");
    printk("The system may be left in ");
    printk("an unstable state.\n");
  }

  sys_call_table[__NR_open] = original_call;
}
```
