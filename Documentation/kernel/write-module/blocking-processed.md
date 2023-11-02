# 阻塞进程

当有人要求你做一些你不能马上做的事情时，你会怎么做?如果你是一个人，你被一个人打扰了，你唯一能说的就是:‘现在不行，我很忙。走开! '。但是如果你是一个内核模块，你被一个进程所困扰，你有另一种可能。您可以将该进程置于睡眠状态，直到可以对其进行服务。毕竟，进程一直被内核置于睡眠状态并被唤醒(这就是在单个CPU上同时运行多个进程的方式)。

这个内核模块就是一个例子。该文件(称为`/proc/sleep`)一次只能由单个进程打开。如果文件已经打开，内核模块调用`module_interruptible_sleep_on8.1`。这个函数将任务的状态(任务是保存进程和系统调用信息的内核数据结构，如果有的话)更改为`TASK_INTERRUPTIBLE`，这意味着任务在以某种方式被唤醒之前不会运行，并将其添加到WaitQ，等待访问文件的任务队列。然后，该函数调用调度器将上下文切换到另一个进程，该进程对CPU有一定的使用。

当一个进程处理完文件后，它会关闭文件，并调用`module_close`。该函数唤醒队列中的所有进程(没有机制只唤醒其中一个进程)。然后它返回，刚刚关闭文件的进程可以继续运行。随着时间的推移，调度器决定该进程已经够用了，并将CPU的控制权交给另一个进程。最终，调度程序将把队列中的一个进程的CPU控制权交给调度程序。它从调用`module_interruptible_sleep_on` 8.2之后的点开始。然后，它可以继续设置一个全局变量，告诉所有其他进程该文件仍处于打开状态，并继续其生命周期。当其他进程获得CPU时，它们将看到该全局变量并返回睡眠状态。

`module_close`并没有独占唤醒等待访问文件的进程。一个信号，比如Ctrl-C (SIGINT)也可以唤醒进程8.3。在这种情况下，我们希望立即返回-EINTR。这很重要，例如，用户可以在进程接收到文件之前终止它。

还有一点要记住。有时候进程不想sleep，它们要么想立即得到它们想要的，要么被告知不能完成。这些进程在打开文件时使用`O_NONBLOCK`标志。内核应该通过从操作中返回错误码`-EAGAIN`来响应，否则这些操作将会阻塞，例如在本例中打开文件。`cat_noblock`程序可以在本章的源目录中找到，它可以用`O_NONBLOCK`打开一个文件。

sleep.c

```c

/* sleep.c - create a /proc file, and if several
 * processes try to open it at the same time, put all
 * but one to sleep */

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

/* Necessary because we use proc fs */
#include <linux/proc_fs.h>

/* For putting processes to sleep and waking them up */
#include <linux/sched.h>
#include <linux/wrapper.h>

/* In 2.2.3 /usr/include/linux/version.h includes a
 * macro for this, but 2.0.35 doesn't - so I add it
 * here if necessary. */
#ifndef KERNEL_VERSION
#define KERNEL_VERSION(a,b,c) ((a)*65536+(b)*256+(c))
#endif

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
#include <asm/uaccess.h>  /* for get_user and put_user */
#endif

/* The module's file functions ********************** */

/* Here we keep the last message received, to prove
 * that we can process our input */
#define MESSAGE_LENGTH 80
static char Message[MESSAGE_LENGTH];

/* Since we use the file operations struct, we can't use
 * the special proc output provisions - we have to use
 * a standard read function, which is this function */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
static ssize_t module_output(
    struct file *file,   /* The file read */
    char *buf, /* The buffer to put data to (in the
                * user segment) */
    size_t len,  /* The length of the buffer */
    loff_t *offset) /* Offset in the file - ignore */
#else
static int module_output(
    struct inode *inode, /* The inode read */
    struct file *file,   /* The file read */
    char *buf, /* The buffer to put data to (in the
                * user segment) */
    int len)  /* The length of the buffer */
#endif
{
  static int finished = 0;
  int i;
  char message[MESSAGE_LENGTH+30];

  /* Return 0 to signify end of file - that we have
   * nothing more to say at this point. */
  if (finished) {
    finished = 0;
    return 0;
  }

  /* If you don't understand this by now, you're
   * hopeless as a kernel  programmer. */
  sprintf(message, "Last input:%s\n", Message);
  for(i=0; i<len && message[i]; i++)
    put_user(message[i], buf+i);

  finished = 1;
  return i;  /* Return the number of bytes "read" */
}


/* This function receives input from the user when
 * the user writes to the /proc file. */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
static ssize_t module_input(
    struct file *file,   /* The file itself */
    const char *buf,     /* The buffer with input */
    size_t length,       /* The buffer's length */
    loff_t *offset)      /* offset to file - ignore */
#else
static int module_input(
    struct inode *inode, /* The file's inode */
    struct file *file,   /* The file itself */
    const char *buf,     /* The buffer with the input */
    int length)          /* The buffer's length */
#endif
{
  int i;

  /* Put the input into Message, where module_output
   * will later be able to use it */
  for(i=0; i<MESSAGE_LENGTH-1 && i<length; i++)
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
     get_user(Message[i], buf+i);
#else
  Message[i] = get_user(buf+i);
#endif
/* we want a standard, zero terminated string */
  Message[i] = '\0';

  /* We need to return the number of input
   * characters used */
  return i;
}

/* 1 if the file is currently open by somebody */
int Already_Open = 0;

/* Queue of processes who want our file */
static struct wait_queue *WaitQ = NULL;


/* Called when the /proc file is opened */
static int module_open(struct inode *inode,
                       struct file *file)
{
  /* If the file's flags include O_NONBLOCK, it means
   * the process doesn't want to wait for the file.
   * In this case, if the file is already open, we
   * should fail with -EAGAIN, meaning "you'll have to
   * try again", instead of blocking a process which
   * would rather stay awake. */
  if ((file->f_flags & O_NONBLOCK) && Already_Open)
    return -EAGAIN;

  /* This is the correct place for MOD_INC_USE_COUNT
   * because if a process is in the loop, which is
   * within the kernel module, the kernel module must
   * not be removed. */
  MOD_INC_USE_COUNT;

  /* If the file is already open, wait until it isn't */
  while (Already_Open)
  {
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
    int i, is_sig=0;
#endif

    /* This function puts the current process,
     * including any system calls, such as us, to sleep.
     * Execution will be resumed right after the function
     * call, either because somebody called
     * wake_up(&WaitQ) (only module_close does that,
     * when the file is closed) or when a signal, such
     * as Ctrl-C, is sent to the process */
    module_interruptible_sleep_on(&WaitQ);

    /* If we woke up because we got a signal we're not
     * blocking, return  -EINTR (fail the system call).
     * This allows processes to be killed or stopped. */



/*
 * Emmanuel Papirakis:
 *
 * This is a little update to work with 2.2.*. Signals
 * now are contained in two words (64 bits) and are
 * stored in a structure that contains an array of two
 * unsigned longs. We now have to make 2 checks in our if.
 *
 * Ori Pomerantz:
 *
 * Nobody promised me they'll never use more than 64
 * bits, or that this book won't be used for a version
 * of Linux with a word size of 16 bits. This code
 * would work in any case.
 */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)

    for(i=0; i<_NSIG_WORDS && !is_sig; i++)
      is_sig = current->signal.sig[i] &
        ~current->blocked.sig[i];
    if (is_sig) {
#else
    if (current->signal & ~current->blocked) {
#endif
      /* It's important to put MOD_DEC_USE_COUNT here,
       * because for processes where the open is
       * interrupted there will never be a corresponding
       * close. If we don't decrement the usage count
       * here, we will be left with a positive usage
       * count which we'll have no way to bring down to
       * zero, giving us an immortal module, which can
       * only be killed by rebooting the machine. */
      MOD_DEC_USE_COUNT;
      return -EINTR;
    }
  }

  /* If we got here, Already_Open must be zero */

  /* Open the file */
  Already_Open = 1;
  return 0;  /* Allow the access */
}



/* Called when the /proc file is closed */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
int module_close(struct inode *inode, struct file *file)
#else
void module_close(struct inode *inode, struct file *file)
#endif
{
  /* Set Already_Open to zero, so one of the processes
   * in the WaitQ will be able to set Already_Open back
   * to one and to open the file. All the other processes
   * will be called when Already_Open is back to one, so
   * they'll go back to sleep. */
  Already_Open = 0;

  /* Wake up all the processes in WaitQ, so if anybody
   * is waiting for the file, they can have it. */
  module_wake_up(&WaitQ);

  MOD_DEC_USE_COUNT;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
  return 0;  /* success */
#endif
}


/* This function decides whether to allow an operation
 * (return zero) or not allow it (return a non-zero
 * which indicates why it is not allowed).
 *
 * The operation can be one of the following values:
 * 0 - Execute (run the "file" - meaningless in our case)
 * 2 - Write (input to the kernel module)
 * 4 - Read (output from the kernel module)
 *
 * This is the real function that checks file
 * permissions. The permissions returned by ls -l are
 * for referece only, and can be overridden here.
 */
static int module_permission(struct inode *inode, int op)
{
  /* We allow everybody to read from our module, but
   * only root (uid 0) may write to it */
  if (op == 4 || (op == 2 && current->euid == 0))
    return 0;

  /* If it's anything else, access is denied */
  return -EACCES;
}


/* Structures to register as the /proc file, with
 * pointers to all the relevant functions. *********** */


/* File operations for our proc file. This is where
 * we place pointers to all the functions called when
 * somebody tries to do something to our file. NULL
 * means we don't want to deal with something. */
static struct file_operations File_Ops_4_Our_Proc_File =
  {
    NULL,  /* lseek */
    module_output,  /* "read" from the file */
    module_input,   /* "write" to the file */
    NULL,  /* readdir */
    NULL,  /* select */
    NULL,  /* ioctl */
    NULL,  /* mmap */
    module_open,/* called when the /proc file is opened */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
    NULL,   /* flush */
#endif
    module_close      /* called when it's classed */
  };



/* Inode operations for our proc file. We need it so
 * we'll have somewhere to specify the file operations
 * structure we want to use, and the function we use for
 * permissions. It's also possible to specify functions
 * to be called for anything else which could be done to an
 * inode (although we don't bother, we just put NULL). */
static struct inode_operations Inode_Ops_4_Our_Proc_File =
  {
    &File_Ops_4_Our_Proc_File,
    NULL, /* create */
    NULL, /* lookup */
    NULL, /* link */
    NULL, /* unlink */
    NULL, /* symlink */
    NULL, /* mkdir */
    NULL, /* rmdir */
    NULL, /* mknod */
    NULL, /* rename */
    NULL, /* readlink */
    NULL, /* follow_link */
    NULL, /* readpage */
    NULL, /* writepage */
    NULL, /* bmap */
    NULL, /* truncate */
    module_permission /* check for permissions */
  };

/* Directory entry */
static struct proc_dir_entry Our_Proc_File =
  {
    0, /* Inode number - ignore, it will be filled by
        * proc_register[_dynamic] */
    5, /* Length of the file name */
    "sleep", /* The file name */
    S_IFREG | S_IRUGO | S_IWUSR,
    /* File mode - this is a regular file which
     * can be read by its owner, its group, and everybody
     * else. Also, its owner can write to it.
     *
     * Actually, this field is just for reference, it's
     * module_permission that does the actual check. It
     * could use this field, but in our implementation it
     * doesn't, for simplicity. */
    1,  /* Number of links (directories where the
         * file is referenced) */
    0, 0,  /* The uid and gid for the file - we give
            * it to root */
    80, /* The size of the file reported by ls. */
    &Inode_Ops_4_Our_Proc_File,
    /* A pointer to the inode structure for
     * the file, if we need it. In our case we
     * do, because we need a write function. */
    NULL  /* The read function for the file.
           * Irrelevant, because we put it
           * in the inode structure above */
  };



/* Module initialization and cleanup **************** */


/* Initialize the module - register the proc file */
int init_module()
{
  /* Success if proc_register_dynamic is a success,
   * failure otherwise */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
  return proc_register(&proc_root, &Our_Proc_File);
#else
  return proc_register_dynamic(&proc_root, &Our_Proc_File);
#endif

  /* proc_root is the root directory for the proc
   * fs (/proc). This is where we want our file to be
   * located.
   */
}


/* Cleanup - unregister our file from /proc. This could
 * get dangerous if there are still processes waiting in
 * WaitQ, because they are inside our open function,
 * which will get unloaded. I'll explain how to avoid
 * removal of a kernel module in such a case in
 * chapter 10. */
void cleanup_module()
{
  proc_unregister(&proc_root, Our_Proc_File.low_ino);
}

```
