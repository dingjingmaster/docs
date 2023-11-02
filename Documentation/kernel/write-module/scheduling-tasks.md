# 任务调度

通常情况下，我们有“housekeeping”任务，必须在特定的时间或每隔一段时间完成。如果任务是由进程来完成的，我们可以把它放在crontab文件中。如果任务由内核模块完成，我们有两种可能。第一种方法是在crontab文件中放置一个进程，该进程将在必要时通过系统调用唤醒模块，例如通过打开一个文件。然而，这是非常低效的——我们在crontab上运行一个新进程，将一个新的可执行文件读入内存，所有这些只是为了唤醒内存中的内核模块。

相反，我们可以创建一个函数，在每次计时器中断时调用一次。我们这样做的方法是创建一个任务，保存在结构体`tq_struct`中，该结构体将保存一个指向函数的指针。然后，我们使用`queue_task`将该任务放到一个名为`tq_timer`的任务列表中，该列表是在下一个计时器中断时要执行的任务列表。因为我们希望函数继续被执行，所以我们需要在每次调用它时将它放回到`tq_timer`上，以便下一次计时器中断。

还有一点我们需要记住。当一个模块被rmmod删除时，首先检查它的引用计数。如果为零，则调用`module_cleanup`。然后，从内存中删除模块及其所有功能。没有人检查计时器的任务列表是否碰巧包含指向这些函数之一的指针，而这些函数将不再可用。几年后(从计算机的角度来看，从人类的角度来看，这没什么，不到百分之一秒)，内核有一个计时器中断，并试图调用任务列表中的函数。不幸的是，这个功能已经不复存在了。在大多数情况下，它所在的内存页是未使用的，您会得到一条丑陋的错误消息。但是，如果其他代码现在位于相同的内存位置，事情可能会变得非常糟糕。不幸的是，我们没有一种简单的方法来从任务列表中注销一个任务。

由于`cleanup_module`不能返回错误代码(它是一个void函数)，解决方案是根本不让它返回。相反，它调用`sleep_on`或`module_sleep_on`10.1来使rmmod进程进入睡眠状态。在此之前，它通过设置全局变量通知计时器中断上调用的函数停止附加自身。然后，在下一次计时器中断时，当我们的函数不再在队列中并且可以安全地删除模块时，rmmod进程将被唤醒。

sched.c
```c
/* sched.c - scheduale a function to be called on 
 * every timer interrupt. */



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

/* Necessary because we use the proc fs */
#include <linux/proc_fs.h>

/* We scheduale tasks here */
#include <linux/tqueue.h>

/* We also need the ability to put ourselves to sleep 
 * and wake up later */
#include <linux/sched.h>

/* In 2.2.3 /usr/include/linux/version.h includes a 
 * macro for this, but 2.0.35 doesn't - so I add it 
 * here if necessary. */
#ifndef KERNEL_VERSION
#define KERNEL_VERSION(a,b,c) ((a)*65536+(b)*256+(c))
#endif

/* The number of times the timer interrupt has been 
 * called so far */
static int TimerIntrpt = 0;

/* This is used by cleanup, to prevent the module from 
 * being unloaded while intrpt_routine is still in 
 * the task queue */
static struct wait_queue *WaitQ = NULL;

static void intrpt_routine(void *);

/* The task queue structure for this task, from tqueue.h */
static struct tq_struct Task = {
  NULL,   /* Next item in list - queue_task will do 
           * this for us */
  0,      /* A flag meaning we haven't been inserted 
           * into a task queue yet */
  intrpt_routine, /* The function to run */
  NULL    /* The void* parameter for that function */
};

/* This function will be called on every timer 
 * interrupt. Notice the void* pointer - task functions 
 * can be used for more than one purpose, each time 
 * getting a different parameter. */
static void intrpt_routine(void *irrelevant)
{
  /* Increment the counter */
  TimerIntrpt++;

  /* If cleanup wants us to die */
  if (WaitQ != NULL) 
    wake_up(&WaitQ);   /* Now cleanup_module can return */
  else
    /* Put ourselves back in the task queue */
    queue_task(&Task, &tq_timer);  
}

/* Put data into the proc fs file. */
int procfile_read(char *buffer, 
                  char **buffer_location, off_t offset, 
                  int buffer_length, int zero)
{
  int len;  /* The number of bytes actually used */

  /* This is static so it will still be in memory 
   * when we leave this function */
  static char my_buffer[80];  

  static int count = 1;

  /* We give all of our information in one go, so if 
   * the anybody asks us if we have more information 
   * the answer should always be no. 
   */
  if (offset > 0)
    return 0;

  /* Fill the buffer and get its length */
  len = sprintf(my_buffer, 
                "Timer was called %d times so far\n", 
                TimerIntrpt);
  count++;

  /* Tell the function which called us where the 
   * buffer is */
  *buffer_location = my_buffer;

  /* Return the length */
  return len;
}

struct proc_dir_entry Our_Proc_File = 
  {
    0, /* Inode number - ignore, it will be filled by 
        * proc_register_dynamic */
    5, /* Length of the file name */
    "sched", /* The file name */
    S_IFREG | S_IRUGO, 
    /* File mode - this is a regular file which can
     * be read by its owner, its group, and everybody
     * else */
    1,  /* Number of links (directories where 
         * the file is referenced) */
    0, 0,  /* The uid and gid for the file - we give 
            * it to root */
    80, /* The size of the file reported by ls. */
    NULL, /* functions which can be done on the 
           * inode (linking, removing, etc.) - we don't 
           * support any. */
    procfile_read, 
    /* The read function for this file, the function called
     * when somebody tries to read something from it. */
    NULL 
    /* We could have here a function to fill the 
     * file's inode, to enable us to play with 
     * permissions, ownership, etc. */
  }; 


/* Initialize the module - register the proc file */
int init_module()
{
  /* Put the task in the tq_timer task queue, so it 
   * will be executed at next timer interrupt */
  queue_task(&Task, &tq_timer);

  /* Success if proc_register_dynamic is a success, 
   * failure otherwise */
#if LINUX_VERSION_CODE > KERNEL_VERSION(2,2,0)
  return proc_register(&proc_root, &Our_Proc_File);
#else
  return proc_register_dynamic(&proc_root, &Our_Proc_File);
#endif
}

/* Cleanup */
void cleanup_module()
{
  /* Unregister our /proc file */
  proc_unregister(&proc_root, Our_Proc_File.low_ino);
  
  /* Sleep until intrpt_routine is called one last 
   * time. This is necessary, because otherwise we'll 
   * deallocate the memory holding intrpt_routine and
   * Task while tq_timer still references them. 
   * Notice that here we don't allow signals to 
   * interrupt us. 
   *
   * Since WaitQ is now not NULL, this automatically 
   * tells the interrupt routine it's time to die. */
 sleep_on(&WaitQ);
}
```
