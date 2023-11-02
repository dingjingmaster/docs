# Hello world

内核模块必须至少有两个函数：
- `init_module`在模块插入内核时被调用
- `cleanup_module`在模块被移除之前被调用。

通常，`init_module`要么向内核注册一个处理程序，要么用自己的代码(通常是执行某些操作的代码，然后调用原始函数)替换一个内核函数。`cleanup_module`函数应该撤销`init_module`所做的一切，这样模块就可以安全地卸载了。

> 所以说，用户自定义内核模块主要干两种活：1. 注册处理程序；2. 替换内核某些程序？

hello.c
```c
/* hello.c
 * Copyright (C) 1998 by Ori Pomerantz
 *
 * "Hello, world" - the kernel module version.
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

/* Initialize the module */
int init_module()
{
    printk("Hello, world - this is the kernel speaking\n");

    /* If we return a non zero value, it means that
     * init_module failed and the kernel module
     * can't be loaded */
    return 0;
}


/* Cleanup - undid whatever init_module did */
void cleanup_module()
{
    printk("Short is the life of a kernel module\n");
}
```

初始化函数返回非0表示内核加载失败，需要退出。

Makefile
```
# Makefile for a basic kernel module

CC=gcc
MODCFLAGS := -Wall -DMODULE -D__KERNEL__ -DLINUX

hello.o:        hello.c /usr/include/linux/version.h
                $(CC) $(MODCFLAGS) -c hello.c
                echo insmod hello.o to turn it on
                echo rmmod hello to turn if off
                echo
                echo X and kernel programming do not mix.
                echo Do the insmod and rmmod from outside X.
```
内核模块不是一个独立的可执行文件，而是一个在运行时链接到内核中的目标文件。因此，它们应该使用`-c`标志进行编译。此外，所有内核模块都必须使用定义的某些符号进行编译。

`__KERNEL__`：告诉头文件这段代码将在内核模式下运行，而不是作为用户进程的一部分。
`MODULE`：告诉头文件为内核模块给出适当的定义。
`LINUX`：从技术上讲，这是不必要的。但是，如果您曾经想要编写一个可以在多个操作系统上编译的内核模块，那么您会很高兴这样做。这将允许您对依赖于操作系统的部分进行条件编译。
还有其他必须包含或不包含的符号，这取决于编译内核时使用的标志。如果您不确定内核是如何编译的，请在`/usr/include/linux/config.h`中查找
`__SMP__`：对称多处理。如果内核被编译为支持对称多处理(即使它只在一个CPU上运行)，则必须定义这一点。如果你使用对称多处理，还有其他的事情你需要做(见第12章)。
`CONFIG_MODVERSIONS`：如果`CONFIG_MODVERSIONS`被启用，你需要在编译内核模块和`/usr/include/linux/modversions.h`时定义它。这也可以由代码本身完成。

## 多源文件内核模块

有时将内核模块划分为几个源文件是有意义的。在这种情况下，您需要执行以下操作：
1. 在除一个以外的所有源文件中，添加`#define __NO_VERSION__`行。这很重要，因为module.h通常包含`kernel_version`的定义，这是一个全局变量，包含编译模块的内核版本。如果你需要`version.h`，你需要自己包含它，因为`module.h`不会用`__NO_VERSION__`为你做这件事。
2. 像往常一样编译所有的源文件。
3. 将所有目标文件合并为一个文件。在`x86`下，使用`ld -m elf_i386 -r -o <模块名称>.o <第一个源文件>.o <第二个源文件>.o`

例子：

start.c
```c
/* start.c
 * Copyright (C) 1999 by Ori Pomerantz
 *
 * "Hello, world" - the kernel module version.
 * This file includes just the start routine
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

/* Initialize the module */
int init_module()
{
  printk("Hello, world - this is the kernel speaking\n");

  /* If we return a non zero value, it means that
   * init_module failed and the kernel module
   * can't be loaded */
  return 0;
}
```

stop.c
```c
/* stop.c 
 * Copyright (C) 1999 by Ori Pomerantz
 * 
 * "Hello, world" - the kernel module version. This 
 * file includes just the stop routine.
 */

/* The necessary header files */

/* Standard in kernel modules */
#include <linux/kernel.h>   /* We're doing kernel work */

#define __NO_VERSION__      /* This isn't "the" file 
                             * of the kernel module */
#include <linux/module.h>   /* Specifically, a module */

#include <linux/version.h>   /* Not included by 
                              * module.h because 
                              * of the __NO_VERSION__ */

/* Deal with CONFIG_MODVERSIONS */
#if CONFIG_MODVERSIONS==1
#define MODVERSIONS
#include <linux/modversions.h>
#endif        


/* Cleanup - undid whatever init_module did */
void cleanup_module()
{
  printk("Short is the life of a kernel module\n");
}
```

Makefile
```makefile
# Makefile for a multifile kernel module

CC=gcc
MODCFLAGS := -Wall -DMODULE -D__KERNEL__ -DLINUX

hello.o:        start.o stop.o
                ld -m elf_i386 -r -o hello.o start.o stop.o

start.o:        start.c /usr/include/linux/version.h
                $(CC) $(MODCFLAGS) -c start.c

stop.o:         stop.c /usr/include/linux/version.h
                $(CC) $(MODCFLAGS) -c stop.c
```
