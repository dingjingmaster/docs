# 字符设备

内核模块与进程通信有两种主要方式：
1. 一种是通过设备文件(如/dev目录中的文件)
2. 另一种是使用proc文件系统。

由于在内核中编写内容的主要原因之一是支持某种硬件设备，因此我们将从设备文件开始。

设备文件的最初用途是允许进程与内核中的设备驱动程序通信，并通过它们与物理设备(调制解调器、终端等)通信。实现方法如下。

每个设备驱动程序(负责某种类型的硬件)都被分配了自己的**主编号**。驱动程序列表及其主要编号在`/proc/devices`中由设备驱动程序管理的每个物理设备被分配一个副编号。对于每一个设备（无论它是否真正安装在系统上），`/dev`目录应该包含一个特殊的文件，称为设备文件。

例如，如果执行`ls -l /dev/hd[ab]*`，您将看到可能连接到机器的所有IDE硬盘分区。请注意，它们都使用相同的主号码3，但副号码从一个到另一个变化免责声明。

在安装系统时，所有这些设备文件都是由`mknod`命令创建的。没有技术上的原因，为什么他们必须在`/dev`目录下，这只是一个有用的约定。在为测试目的创建设备文件时，就像这里的练习一样，将其放在编译内核模块的目录中可能更有意义。

设备分为两类：`字符设备`和`块设备`。不同之处在于块设备有一个请求缓冲区，因此它们可以选择响应请求的顺序。这在存储设备的情况下很重要，因为读取或写入彼此靠近的扇区比读取或写入相隔较远的扇区要快。另一个区别是，块设备只能接受输入并以块的形式返回输出(其大小可以根据设备的不同而变化)，而字符设备则允许使用尽可能多或尽可能少的字节。世界上大多数设备都是字符型的，因为它们不需要这种类型的缓冲，而且它们不使用固定的块大小进行操作。您可以通过查看`ls -l`输出中的第一个字符来判断设备文件是用于块设备还是用于字符设备。如果它是`b`那么它是块设备，如果它是`c`那么它是字符设备。

该模块分为两个独立的部分：注册设备的模块部分和设备驱动程序部分。`init_module`函数调用`module_register_chrdev`将设备驱动程序添加到内核的字符设备驱动程序表中。它还会返回要用于驱动程序的主号码。`cleanup_module`函数用于注销设备。

这(注册和取消注册)是这两个函数的一般功能。**内核中的东西不像进程那样主动运行**，而是**由进程通过系统调用来使用**，或者**由硬件设备通过中断调用**，或者**由内核的其他部分调用(只需调用特定的函数)**。因此，当您向内核添加代码时，您应该将其注册为特定类型事件的处理程序，当您删除它时，您应该取消注册它。

**设备驱动程序是由四个`device_<action>`函数组成的，当有人试图对带有我们主设备号的设备文件做一些事情时，就会调用这些函数。内核知道调用它们的方式是通过`file_operations`结构体`fops`，该结构体是在设备注册时给定的，其中包含指向这四个函数的指针**。

通常，当你不想允许某件事时，你会从应该做这件事的函数返回一个错误代码(一个负数)。对于`cleanup_module`，这是不可能的，因为它是一个void函数。一旦`cleanup_module`被调用，这个模块就结束了。但是，有一个使用计数器，用于计算有多少其他内核模块正在使用该内核模块，称为引用计数(这是`/proc/modules`中行的最后一个数字)。如果这个数字不为零，`rmmod`将失败。模块的引用计数在变量`mod_use_count_`中可用。因为已经定义了宏来处理这个变量(`MOD_INC_USE_COUNT`和`MOD_DEC_USE_COUNT`)，我们更喜欢使用它们，而不是直接使用`mod_use_count_`。

> 注意：内核模块并不能由root用户随意卸载掉，因为这个设备可能正在被使用，此时卸载掉模块会导致无法预测的错误，因此内核模块添加了引用计数，当其它模块依赖此模块或者此模块正在被使用时候是不允许被卸载的。

chardev.c
```c
/* chardev.c
 * Copyright (C) 1998-1999 by Ori Pomerantz
 *
 * Create a character device (read only)
 */

/* The necessary header files */

/* Standard in kernel modules */
#include <linux/kernel.h>   /* We're doing kernel work */
#include <linux/module.h>   /* Specifically, a module */

/* Deal with CONFIG_MODVERSIONS */
#if CONFIG_MODVERSIONS==1
#define MODVERSIONS
#include <linux/modversions.h>
#endif

/* For character devices */
#include <linux/fs.h>       /* The character device
                             * definitions are here */
#include <linux/wrapper.h>  /* A wrapper which does
                             * next to nothing at
                             * at present, but may
                             * help for compatibility
                             * with future versions
                             * of Linux */


/* In 2.2.3 /usr/include/linux/version.h includes
 * a macro for this, but 2.0.35 doesn't - so I add
 * it here if necessary. */
#ifndef KERNEL_VERSION
#define KERNEL_VERSION(a,b,c) ((a)*65536+(b)*256+(c))
#endif


/* Conditional compilation. LINUX_VERSION_CODE is
 * the code (as per KERNEL_VERSION) of this version. */
#if LINUX_VERSION_CODE > KERNEL_VERSION(2,2,0)
#include <asm/uaccess.h>  /* for put_user */
#endif


#define SUCCESS 0


/* Device Declarations **************************** */

/* The name for our device, as it will appear
 * in /proc/devices */
#define DEVICE_NAME "char_dev"


/* The maximum length of the message from the device */
#define BUF_LEN 80

/**
 * 检测设备是否打开，不允许被打开两次
 */
static int Device_Open = 0;

/* The message the device will give when asked */
static char Message[BUF_LEN];

/* How far did the process reading the message
 * get? Useful if the message is larger than the size
 * of the buffer we get to fill in device_read. */
static char *Message_Ptr;


/* This function is called whenever a process
 * attempts to open the device file */
static int device_open(struct inode *inode, struct file *file)
{
  static int counter = 0;

#ifdef DEBUG
  printk ("device_open(%p,%p)\n", inode, file);
#endif

  /* This is how you get the minor device number in
   * case you have more than one physical device using
   * the driver. */
  printk("Device: %d.%d\n",
         inode->i_rdev >> 8, inode->i_rdev & 0xFF);

  /* We don't want to talk to two processes at the
   * same time */
  if (Device_Open)
    return -EBUSY;

  /* If this was a process, we would have had to be
   * more careful here.
   *
   * In the case of processes, the danger would be
   * that one process might have check Device_Open
   * and then be replaced by the schedualer by another
   * process which runs this function. Then, when the
   * first process was back on the CPU, it would assume
   * the device is still not open.
   *
   * However, Linux guarantees that a process won't be
   * replaced while it is running in kernel context.
   *
   * In the case of SMP, one CPU might increment
   * Device_Open while another CPU is here, right after
   * the check. However, in version 2.0 of the
   * kernel this is not a problem because there's a lock
   * to guarantee only one CPU will be kernel module at
   * the same time. This is bad in  terms of
   * performance, so version 2.2 changed it.
   * Unfortunately, I don't have access to an SMP box
   * to check how it works with SMP.
   */

  Device_Open++;

  /* Initialize the message. */
  sprintf(Message,
    "If I told you once, I told you %d times - %s",
    counter++,
    "Hello, world\n");
  /* The only reason we're allowed to do this sprintf
   * is because the maximum length of the message
   * (assuming 32 bit integers - up to 10 digits
   * with the minus sign) is less than BUF_LEN, which
   * is 80. BE CAREFUL NOT TO OVERFLOW BUFFERS,
   * ESPECIALLY IN THE KERNEL!!!
   */

  Message_Ptr = Message;

  /* Make sure that the module isn't removed while
   * the file is open by incrementing the usage count
   * (the number of opened references to the module, if
   * it's not zero rmmod will fail)
   */
  MOD_INC_USE_COUNT;

  return SUCCESS;
}


/* This function is called when a process closes the
 * device file. It doesn't have a return value in
 * version 2.0.x because it can't fail (you must ALWAYS
 * be able to close a device). In version 2.2.x it is
 * allowed to fail - but we won't let it.
 */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
static int device_release(struct inode *inode,
                          struct file *file)
#else
static void device_release(struct inode *inode,
                           struct file *file)
#endif
{
#ifdef DEBUG
  printk ("device_release(%p,%p)\n", inode, file);
#endif

  /* We're now ready for our next caller */
  Device_Open --;

  /* Decrement the usage count, otherwise once you
   * opened the file you'll never get rid of the module.
   */
  MOD_DEC_USE_COUNT;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
  return 0;
#endif
}


/* This function is called whenever a process which
 * have already opened the device file attempts to
 * read from it. */


#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
static ssize_t device_read(struct file *file,
    char *buffer,    /* The buffer to fill with data */
    size_t length,   /* The length of the buffer */
    loff_t *offset)  /* Our offset in the file */
#else
static int device_read(struct inode *inode,
                       struct file *file,
    char *buffer,   /* The buffer to fill with
                     * the data */
    int length)     /* The length of the buffer
                     * (mustn't write beyond that!) */
#endif
{
  /* Number of bytes actually written to the buffer */
  int bytes_read = 0;

  /* If we're at the end of the message, return 0
   * (which signifies end of file) */
  if (*Message_Ptr == 0)
    return 0;

  /* Actually put the data into the buffer */
  while (length && *Message_Ptr)  {

    /* Because the buffer is in the user data segment,
     * not the kernel data segment, assignment wouldn't
     * work. Instead, we have to use put_user which
     * copies data from the kernel data segment to the
     * user data segment. */
    put_user(*(Message_Ptr++), buffer++);


    length --;
    bytes_read ++;
  }

#ifdef DEBUG
   printk ("Read %d bytes, %d left\n",
     bytes_read, length);
#endif

   /* Read functions are supposed to return the number
    * of bytes actually inserted into the buffer */
  return bytes_read;
}

/* This function is called when somebody tries to write
 * into our device file - unsupported in this example. */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
static ssize_t device_write(struct file *file,
    const char *buffer,    /* The buffer */
    size_t length,   /* The length of the buffer */
    loff_t *offset)  /* Our offset in the file */
#else
static int device_write(struct inode *inode,
                        struct file *file,
                        const char *buffer,
                        int length)
#endif
{
  return -EINVAL;
}


/* Module Declarations ***************************** */

/* The major device number for the device. This is
 * global (well, static, which in this context is global
 * within this file) because it has to be accessible
 * both for registration and for release. */
static int Major;

/* This structure will hold the functions to be
 * called when a process does something to the device
 * we created. Since a pointer to this structure is
 * kept in the devices table, it can't be local to
 * init_module. NULL is for unimplemented functions. */


struct file_operations Fops = {
  NULL,   /* seek */
  device_read,
  device_write,
  NULL,   /* readdir */
  NULL,   /* select */
  NULL,   /* ioctl */
  NULL,   /* mmap */
  device_open,
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
  NULL,   /* flush */
#endif
  device_release  /* a.k.a. close */
};


/* Initialize the module - Register the character device */
int init_module()
{
  /* Register the character device (atleast try) */
  Major = module_register_chrdev(0,
                                 DEVICE_NAME,
                                 &Fops);

  /* Negative values signify an error */
  if (Major < 0) {
    printk ("%s device failed with %d\n",
            "Sorry, registering the character",
            Major);
    return Major;
  }

  printk ("%s The major device number is %d.\n",
          "Registeration is a success.",
          Major);
  printk ("If you want to talk to the device driver,\n");
  printk ("you'll have to create a device file. \n");
  printk ("We suggest you use:\n");
  printk ("mknod <name> c %d <minor>\n", Major);
  printk ("You can try different minor numbers %s",
          "and see what happens.\n");

  return 0;
}

/* Cleanup - unregister the appropriate file from /proc */
void cleanup_module()
{
  int ret;

  /* Unregister the device */
  ret = module_unregister_chrdev(Major, DEVICE_NAME);

  /* If there's an error, report it */
  if (ret < 0)
    printk("Error in unregister_chrdev: %d\n", ret);
}
```

## 支持多个内核版本的源码

系统调用是内核向进程显示的主要接口，在不同版本之间通常保持相同。可能会添加一个新的系统调用，但通常旧的系统调用的行为与以前完全一样。这对于向后兼容性是必要的——一个新的内核版本不应该破坏常规进程。在大多数情况下，设备文件也将保持不变。另一方面，内核中的内部接口可以在不同版本之间发生变化。

Linux内核版本分为稳定版本(n.<偶数>.m)和开发版本(n.<奇数>.m)。开发版本包含了所有很酷的新想法，包括那些会被认为是错误的，或者在下一个版本中重新实现的想法。因此，你不能相信接口在这些版本中保持不变(这就是为什么我不愿意在本书中支持它们的原因，因为这需要太多的工作，而且它会很快过时)。另一方面，在稳定版本中，无论错误修复版本(m号)如何，我们都可以期望接口保持不变。

这个版本的MPG包括对两个2.0版本的支持。X和2.2版本。Linux内核的x.x.x.x。由于两者之间存在差异，因此需要根据内核版本进行条件编译。这样做的方法是使用宏`LINUX_VERSION_CODE`。在内核版本`a.b.c`中，这个宏的值将是`216a+28b+c`。要获取特定内核版本的值，可以使用`KERNEL_VERSION`宏。因为它在`2.0.35`中没有定义，所以如果有必要，我们自己定义它。
