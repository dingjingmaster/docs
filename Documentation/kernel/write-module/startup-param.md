# 启动参数

在前面的许多示例中，我们必须将一些东西硬连接到内核模块中，例如`/proc`文件的文件名或设备的主设备号，以便我们可以对其进行`ioctl`。这与Unix和Linux的哲学相悖，**Unix和Linux的哲学是编写用户可以自定义的灵活程序**。

**告诉程序或内核模块在开始工作之前需要什么东西的方法是通过命令行参数**。在内核模块的情况下，我们没有得到argc和argv——相反，我们得到了更好的东西。**我们可以在内核模块中定义全局变量，insmod将给这些变量复制**。

在这个内核模块中，我们定义了其中的两个：str1和str2。您所需要做的就是编译内核模块，然后运行`insmod str1=xxx str2=yyy`。当`init_module`被调用时，`str1`将指向字符串`'xxx'`， `str2`指向字符串`'yyy'`。

在2.0版本中，没有对这些参数进行类型检查。如果str1或str2的第一个字符是数字，内核将用整数的值填充变量，而不是指向字符串的指针。如果在现实生活中你必须检查这个。

另一方面，在2.2版本中，您使用宏`MACRO_PARM`告诉`insmod`您需要一个参数、它的名称和类型。这解决了类型问题，并允许内核模块接收以数字开头的字符串。

param.c
```c
/* param.c
 *
 * Receive command line parameters at module installation
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

#include <stdio.h>  /* I need NULL */

/* In 2.2.3 /usr/include/linux/version.h includes a
 * macro for this, but 2.0.35 doesn't - so I add it
 * here if necessary. */
#ifndef KERNEL_VERSION
#define KERNEL_VERSION(a,b,c) ((a)*65536+(b)*256+(c))
#endif

/* Emmanuel Papirakis:
 *
 * Prameter names are now (2.2) handled in a macro.
 * The kernel doesn't resolve the symbol names
 * like it seems to have once did.
 *
 * To pass parameters to a module, you have to use a macro
 * defined in include/linux/modules.h (line 176).
 * The macro takes two parameters. The parameter's name and
 * it's type. The type is a letter in double quotes.
 * For example, "i" should be an integer and "s" should
 * be a string.
 */

char *str1, *str2;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
MODULE_PARM(str1, "s");
MODULE_PARM(str2, "s");
#endif


/* Initialize the module - show the parameters */
int init_module()
{
  if (str1 == NULL || str2 == NULL) {
    printk("Next time, do insmod param str1=<something>");
    printk("str2=<something>\n");
  } else
    printk("Strings:%s and %s\n", str1, str2);

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
  printk("If you try to insmod this module twice,");
  printk("(without rmmod'ing\n");
  printk("it first), you might get the wrong");
  printk("error message:\n");
  printk("'symbol for parameters str1 not found'.\n");
#endif

  return 0;
}


/* Cleanup */
void cleanup_module()
{
}
```
