# replacing printk's

在开头(第1章)，我说过X和内核模块编程不能混在一起。在开发内核模块时确实如此，但是在实际使用中，您希望能够将消息发送到向模块发出命令的tty9.1。这对于在内核模块发布之后识别错误非常重要，因为它将在所有内核模块中使用。

实现的方法是使用current(一个指向当前运行任务的指针)来获取当前任务的tty结构。然后，在tty结构中查找指向字符串写入函数的指针，使用该函数将字符串写入tty。

printk.c
```c
/* printk.c - send textual output to the tty you're 
 * running on, regardless of whether it's passed 
 * through X11, telnet, etc. */


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

/* Necessary here */
#include <linux/sched.h>    /* For current */
#include <linux/tty.h>      /* For the tty declarations */


/* Print the string to the appropriate tty, the one 
 * the current task uses */
void print_string(char *str)
{
  struct tty_struct *my_tty;

  /* The tty for the current task */
  my_tty = current->tty;

  /* If my_tty is NULL, it means that the current task 
   * has no tty you can print to (this is possible, for 
   * example, if it's a daemon). In this case, there's 
   * nothing we can do. */ 
  if (my_tty != NULL) { 

    /* my_tty->driver is a struct which holds the tty's 
     * functions, one of which (write) is used to 
     * write strings to the tty. It can be used to take 
     * a string either from the user's memory segment 
     * or the kernel's memory segment. 
     *
     * The function's first parameter is the tty to 
     * write to, because the  same function would 
     * normally be used for all tty's of a certain type.
     * The second parameter controls whether the 
     * function receives a string from kernel memory 
     * (false, 0) or from user memory (true, non zero). 
     * The third parameter is a pointer to a string, 
     * and the fourth parameter is the length of 
     * the string.
     */
    (*(my_tty->driver).write)(
        my_tty, /* The tty itself */
        0, /* We don't take the string from user space */
        str, /* String */
        strlen(str));  /* Length */

    /* ttys were originally hardware devices, which 
     * (usually) adhered strictly to the ASCII standard. 
     * According to ASCII, to move to a new line you 
     * need two characters, a carriage return and a 
     * line feed. In Unix, on the other hand, the 
     * ASCII line feed is used for both purposes - so 
     * we can't just use \n, because it wouldn't have 
     * a carriage return and the next line will 
     * start at the column right
     *                          after the line feed. 
     *
     * BTW, this is the reason why the text file 
     *  is different between Unix and Windows. 
     * In CP/M and its derivatives, such as MS-DOS and 
     * Windows, the ASCII standard was strictly 
     * adhered to, and therefore a new line requires 
     * both a line feed and a carriage return. 
     */
    (*(my_tty->driver).write)(
      my_tty,  
      0,
      "\015\012",
      2);
  }
}


/* Module initialization and cleanup ****************** */


/* Initialize the module - register the proc file */
int init_module()
{
  print_string("Module Inserted");

  return 0;
}


/* Cleanup - unregister our file from /proc */
void cleanup_module()
{
  print_string("Module Removed");
}

```
