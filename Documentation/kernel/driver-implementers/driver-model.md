# 驱动模型

## 驱动绑定

驱动绑定是将设备与可控制设备的设备驱动程序相关联的过程。因为有特定于总线的结构来表示设备和驱动程序，这个问题通常由总线驱动程序处理。对于通用设备和设备驱动程序结构，大多数绑定都可以使用公共代码进行。

### Bus

总线类型结构包含了系统中该总线类型上的所有设备的列表。当为一个设备调用`device_register`时，它被插入到这个列表的末尾。
总线对象还包含该总线类型的所有驱动程序的列表。当为一个驱动程序调用`driver_register`时，它被插入到这个列表的末尾。这是触发驱动绑定的两个事件。

### device_register

当添加新设备时，将遍历总线的驱动程序列表以找到支持该设备的驱动程序。为了确保这一点，设备的设备ID必须与驱动程序支持的设备ID之一匹配。比较id的格式和语义是特定于总线的。不是尝试派生复杂的状态机和匹配算法，而是由总线驱动程序提供回调以将设备与驱动程序的id进行比较。如果找到，则 `match` 返回1；否则返回0。

```c
int match(struct device* dev, struct device_driver* drv);
```

如果找到匹配，设备的驱动字段被设置为驱动程序，并调用驱动程序的探测回调。这给了驱动程序一个机会来验证它是否真的支持硬件，并且它处于工作状态。

### Device Class

在探测成功完成后，设备被注册到它所属的类。设备驱动程序属于且仅属于一个类，这在驱动程序的`devclass`字段中设置。调用`devclass_add_device`枚举类中的设备，并实际将其注册到类中，这与类的`register_dev`回调一起发生。

### Driver

当驱动程序附加到设备时，该设备被插入到设备的驱动程序列表中。

### sysfs

在总线的“devices”目录中创建一个符号链接，该目录指向物理层次结构中的设备目录。

在驱动程序的“devices”目录中创建一个符号链接，该目录指向物理层次结构中的设备目录。

在类的目录中创建设备的目录。在该目录中创建一个符号链接，它指向设备在sysfs树中的物理位置。

可以在设备的物理目录中创建一个符号链接(尽管还没有这样做)，链接到它的类目录或类的顶级目录。也可以创建一个来指向它的驱动程序目录。

### driver_register

当添加一个新驱动程序时，这个过程几乎相同。遍历总线的设备列表以查找匹配项。已经有驱动程序的设备将被跳过。所有的设备都经过迭代，以便将尽可能多的设备绑定到驱动程序。

### removal

当一个设备被移除时，它的引用计数最终将变为0。当它这样做时，将调用驱动程序的remove回调。它从驱动程序的设备列表中删除，并且驱动程序的引用计数减少。两者之间的所有符号链接都被删除。

当一个驱动程序被移除时，它所支持的设备列表将被迭代，并且每个驱动程序的remove回调都会被调用。该设备将从该列表中删除，符号链接也将删除。

## 总线类型(Bus Types)

### 定义方法

```c
int bus_register(struct bus_type * bus);
```

### 声明

内核中的每种总线类型（PCI、USB等）都应该声明一个这种类型的静态对象。它们必须初始化 name 字段，并且可以选择初始化 match 回调：

```c
struct bus_type pci_bus_type = {
       .name  = "pci",
       .match = pci_bus_match,
};
```

该结构应该在头文件中导出到驱动程序：

```c
extern struct bus_type pci_bus_type;
```

### 注册

当总线驱动程序初始化时，它调用`bus_register`。这将初始化总线对象中的其余字段，并将其插入总线类型的全局列表中。一旦注册了总线对象，总线驱动程序就可以使用其中的字段。

### 回调

#### `match()`将驱动程序绑定到驱动

设备ID结构的格式和比较它们的语义本质上是特定于总线的。驱动程序通常声明一个它们支持的设备id数组，这些设备位于特定于总线的驱动程序结构中。

match回调的目的是让总线有机会通过比较驱动程序支持的设备ID与特定设备的设备ID来确定特定驱动程序是否支持特定设备，而不会牺牲总线特定的功能或类型安全。

当一个驱动程序注册到总线上时，总线的设备列表将被迭代，并且为每个没有与之关联的驱动程序的设备调用匹配回调。

### 设备与驱动程序列表

设备和驱动程序的列表旨在取代许多总线保留的本地列表。它们分别是`struct devices`和`struct device_drivers`的列表。Bus 驱动程序可以随意使用列表，但可能需要转换为Bus专用类型。

LDM核心提供了迭代每个列表的辅助函数:
```c
int bus_for_each_dev(
        struct bus_type* bus,
        struct device * start,
        void * data,
        int (*fn)(struct device*, void*));

int bus_for_each_drv(
        struct bus_type* bus,
        struct device_driver* start,
        void* data,
        int (*fn)(struct device_driver*, void*));
```
这些帮助程序遍历各自的列表，并为列表中的每个设备或驱动程序调用回调。所有的列表访问都是通过获取总线的锁(当前读取)来同步的。在调用回调之前，列表中每个对象的引用计数递增;在获得下一个对象后递减。调用回调时不持有锁。

#### sysfs

sysfs 中有一个叫做 `bus` 的顶级目录。每个总线都属于 `bus` 目录下的子目录；每个总线中都有两个默认的目录：`devices`和`drivers`，具体如下：
```
/sys/
  |--bus
      |--pci
          |--devices
          |--drivers
```
在总线上注册的驱动程序将在总线的驱动程序目录中获得一个目录:

```
/sys/bus/pci/
|-- devices
`-- drivers
    |-- Intel ICH
    |-- Intel ICH Joystick
    |-- agpgart
    `-- e100
```

在这种类型的总线上发现的每个设备在总线的设备目录中获得一个符号链接到物理层次结构中的设备目录:

```
/sys/bus/pci/
|-- devices
|   |-- 00:00.0 -> ../../../root/pci0/00:00.0
|   |-- 00:01.0 -> ../../../root/pci0/00:01.0
|   `-- 00:02.0 -> ../../../root/pci0/00:02.0
`-- drivers
```

### 导出属性

```c
struct bus_attribute 
{
      struct attribute attr;
      ssize_t (*show)(struct bus_type*, char* buf);
      ssize_t (*store)(struct bus_type*, const char* buf, size_t count);
};
```

总线驱动程序可以使用`BUS_ATTR_RW`宏导出属性，该宏的工作方式类似于设备的`DEVICE_ATTR_RW`宏。例如，像这样的定义:
```c
static BUS_ATTR_RW(debug);
```

等价于以下声明：
```c
static bus_attribute bus_attr_debug;
```
然后可以使用以下命令从总线的sysfs目录中添加和删除该属性:

```c
int  bus_create_file(struct bus_type*, struct bus_attribute*);
void bus_remove_file(struct bus_type*, struct bus_attribute*);
```

## 设备驱动程序设计模式

本文档描述了在设备驱动程序中发现的一些常见设计模式。子系统维护者很可能会要求驱动程序开发人员遵循这些设计模式。

1. State Container
2. container_of()

### 状态容器(State Container)

内核包含一些设备驱动程序，假设它们只在某个系统(单例)上被`probed()`一次，但通常假设驱动程序绑定的设备将在多个实例中出现。这意味着probe()函数和所有回调都需要是可重入的。

实现这一点的最常见方法是使用状态容器设计模式。它通常有这种形式:

```c
struct foo 
{
    spinlock_t lock; /* Example member */
    (...)
};

static int foo_probe(...)
{
    struct foo *foo;

    foo = devm_kzalloc(dev, sizeof(*foo), GFP_KERNEL);
    if (!foo)
        return -ENOMEM;
    spin_lock_init(&foo->lock);
    (...)
}
```
这将在每次调用probe()时在内存中创建一个结构体foo的实例。这是设备驱动程序实例的状态容器。当然，有必要总是将状态的这个实例传递给需要访问状态及其成员的所有函数。

例如，如果驱动程序正在注册一个中断处理程序，你可以像这样传递一个指向foo结构体的指针:
```c
static irqreturn_t foo_handler(int irq, void *arg)
{
    struct foo *foo = arg;
    (...)
}

static int foo_probe(...)
{
    struct foo *foo;

    (...)
    ret = request_irq(irq, foo_handler, 0, "foo", foo);
}
```
这样，您总是可以在中断处理程序中获得指向foo的正确实例的指针。

### `container_of()`

继续上面的例子，我们添加一个卸载的工作:

```c
struct foo 
{
    spinlock_t lock;
    struct workqueue_struct *wq;
    struct work_struct offload;
    (...)
};

static void foo_work(struct work_struct *work)
{
    struct foo *foo = container_of(work, struct foo, offload);

    (...)
}

static irqreturn_t foo_handler(int irq, void *arg)
{
    struct foo *foo = arg;

    queue_work(foo->wq, &foo->offload);
    (...)
}

static int foo_probe(...)
{
    struct foo *foo;

    foo->wq = create_singlethread_workqueue("foo-wq");
    INIT_WORK(&foo->offload, foo_work);
    (...)
}
```

对于hrtimer或类似的东西来说，设计模式是相同的，它将返回一个参数，该参数是回调中指向结构成员的指针。

`container_of()`是在<linux/kernel.h>中定义的宏

`container_of()`所做的是使用标准C中的`offsetof()`宏从指向成员的指针中通过简单的减法获得指向包含结构的指针，这允许类似于面向对象的行为。注意，所包含的成员不能是指针，而必须是实际的成员。

在这里我们可以看到，通过这种方式，我们避免了使用指向结构体`foo*`实例的全局指针，同时仍然保持传递给工作函数的参数数量为单个指针。

## 设备的基本结构

### 编程接口

发现设备的总线驱动程序使用此命令向内核注册设备：

```c
int device_register(struct device* dev);
```
bus 需要初始化以下字段：
- parent
- name
- `bus_id`
- bus

当一个器件的引用计数变为0时，该器件将从内核中移除。引用计数可以使用以下方法进行调整:
```c
struct device * get_device(struct device * dev);
void put_device(struct device * dev);
```
如果引用不为0(如果它已经在被删除的过程中)，`get_device()`将返回一个指向传递给它的`struct device`的指针。

驱动程序可以使用以下命令访问设备结构中的锁：
```c
void lock_device(struct device* dev);
void unlock_device(struct device* dev);
```

### 属性

```c
struct device_attribute 
{
    struct attribute  attr;

    ssize_t (*show)(struct device* dev,
            struct device_attribute* attr,
            char *buf);

    ssize_t (*store)(struct device* dev,
            struct device_attribute* attr,
            const char* buf,
            size_t count);
};
```
设备的属性可以通过设备驱动程序通过sysfs导出。

正如您永远不想知道的关于kobjects、kset和ktypes的所有内容中所解释的，必须在生成`KOBJ_ADD`事件之前创建设备属性。实现这一点的唯一方法是定义一个属性组。

属性是使用一个名为`DEVICE_ATTR`的宏声明的:

```c
#define DEVICE_ATTR(name,mode,show,store)
```

例子：
```c
static DEVICE_ATTR(type, 0444, type_show, NULL);
static DEVICE_ATTR(power, 0644, power_show, power_store);
```

Helper宏可用于mode的常用值，因此上面的示例可以简化为：
```
static DEVICE_ATTR_RO(type);
static DEVICE_ATTR_RW(power);
```

它声明了两个`struct device_attribute`类型的结构体，分别名为'`dev_attr_type`'和'`dev_attr_power`'。这两个属性可以按如下方式组织成一个组:
```c
static struct attribute* dev_attrs[] = {
      &dev_attr_type.attr,
      &dev_attr_power.attr,
      NULL,
};

static struct attribute_group dev_group = {
      .attrs = dev_attrs,
};

static const struct attribute_group* dev_groups[] = {
      &dev_group,
      NULL,
};
```
对于单个组的常见情况，可以使用helper宏，因此可以使用::声明上述两个结构:

```c
ATTRIBUTE_GROUPS(dev);
```

在`device_register()`被调用之前，通过在`struct device`中设置组指针，可以将这个组数组与设备关联起来:
```c
dev->groups = dev_groups;
device_register(dev);
```

`device_register()`函数将使用'`groups`'指针来创建设备属性，`device_unregister()`函数将使用该指针来删除设备属性。

警告：虽然内核允许`device_create_file()`和`device_remove_file()`在设备上随时被调用，但用户空间对何时创建属性有严格的期望。当一个新设备在内核中注册时，将生成一个`uevent`来通知用户空间(如udev)有一个新设备可用。如果在设备注册后添加属性，那么用户空间将不会收到通知，并且用户空间将不知道新属性。

这对于需要在驱动程序探测时为设备发布附加属性的设备驱动程序非常重要。如果设备驱动程序只是在传递给它的设备结构上调用`device_create_file()`，那么用户空间将永远不会收到新属性的通知。

## Devres—设备资源管理器

### 说明

Devres在试图将libata转换为使用iomap时出现了。每个映射的地址应该保留，并在驱动分离时取消映射。例如，本机模式下的普通SFF ATA控制器(即老式的PCI IDE)使用5个PCI bar，并且应该维护所有这些bar。

与许多其他设备驱动程序一样，libata低级驱动程序在`->remove` `->probe`失败路径中有足够的错误。这可能是因为libata底层驱动程序开发人员是一群懒惰的人，但不都是底层驱动程序开发人员吗?在花了一天时间摆弄脑损伤的硬件却没有文档或脑损伤的文档之后，如果它终于工作了，那么它就工作了。

由于这样或那样的原因，底层驱动程序没有像核心代码那样受到那么多的关注或测试，并且驱动程序分离或初始化失败的错误不会经常发生，不会引起注意。Init失败路径更糟糕，因为当需要处理多个入口点时，它的传输要少得多。

因此，许多底层驱动最终在驱动分离时泄漏资源，并且在`->probe()`中实现了半破碎的故障路径，这将在发生故障时泄漏资源甚至导致oops。Iomap为这种组合添加了更多内容。msi和m6也是。

### Devres

Devres基本上是与一个struct设备相关联的任意大小的内存区域的链表。每个devres条目都与一个释放函数相关联。A设备可以通过几种方式释放。无论如何，所有的devres条目在驱动分离时被释放。在释放时，调用相关的释放函数，然后释放devres条目。

托管接口是为使用设备的设备驱动程序常用的资源创建的。例如，使用`dma_alloc_coherent()`获取一致的DMA内存。托管版本称为`dmam_alloc_coherent()`。它与`dma_alloc_coherent()`相同，只是使用它分配的DMA内存是受管理的，并且会在驱动程序分离时自动释放。实现如下:
```c
struct dma_devres 
{
      size_t          size;
      void            *vaddr;
      dma_addr_t      dma_handle;
};

static void dmam_coherent_release(struct device *dev, void *res)
{
      struct dma_devres *this = res;

      dma_free_coherent(dev, this->size, this->vaddr, this->dma_handle);
}

dmam_alloc_coherent(dev, size, dma_handle, gfp)
{
      struct dma_devres *dr;
      void *vaddr;

      dr = devres_alloc(dmam_coherent_release, sizeof(*dr), gfp);
      ...

      /* alloc DMA memory as usual */
      vaddr = dma_alloc_coherent(...);
      ...

      /* record size, vaddr, dma_handle in dr */
      dr->vaddr = vaddr;
      ...

      devres_add(dev, dr);

      return vaddr;
}
```

如果驱动程序使用`dmam_alloc_coherent()`，则无论初始化中途失败或设备被分离，该区域都保证被释放。如果大多数资源是使用托管接口获得的，那么驱动程序可以有更简单的初始化和退出代码。初始化路径基本如下所示:

```c
my_init_one()
{
      struct mydev *d;

      d = devm_kzalloc(dev, sizeof(*d), GFP_KERNEL);
      if (!d)
              return -ENOMEM;

      d->ring = dmam_alloc_coherent(...);
      if (!d->ring)
              return -ENOMEM;

      if (check something)
              return -EINVAL;
      ...

      return register_to_upper_layer(d);
}
```

退出路径如下：
```c
my_remove_one()
{
      unregister_from_upper_layer(d);
      shutdown_my_hardware();
}
```

如上所示，通过使用Dervres可以大大简化低级驱动程序。复杂性从维护较少的低层驱动程序转移到维护较好的高层驱动程序。此外，由于init失败路径与exit路径共享，两者都可以得到更多的测试。

但请注意，在将当前调用或分配转换为托管`devm_*`版本时，由您来检查内部操作(如分配内存)是否失败。托管资源只与这些资源的释放有关——所需的所有其他检查仍然由您负责。在某些情况下，这可能意味着在转移到托管`devm_*`调用之前引入不必要的检查。

### Devres group

可以使用Devres group对Devres条目进行分组。当一个组被释放时，所有包含的正常devres条目和正确嵌套的组都被释放。一种用法是在失败时回滚获取的资源系列。例如:
```c
if (!devres_open_group(dev, NULL, GFP_KERNEL))
       return -ENOMEM;

acquire A;
if (failed)
       goto err;

acquire B;
if (failed)
       goto err;
 ...

devres_remove_group(dev, NULL);
    return 0;

err:
    devres_release_group(dev, NULL);
    return err_code;
```

由于资源获取失败通常意味着探测失败，因此上述结构通常用于中间层驱动程序(例如libata核心层)，在中间层驱动程序中，接口函数不应该对失败产生副作用。对于有限责任域，在大多数情况下只返回错误代码就足够了。

每个组由`void* id`标识。它可以通过`@id`参数显式地指定给`devres_open_group()`，也可以像上面的例子一样通过传递`NULL`作为`@id`来自动创建。在这两种情况下，`devres_open_group()`都返回组的id。返回的id可以传递给其他设备函数来选择目标组。如果为这些函数指定NULL，则选择最近打开的组。

例如，你可以这样做：
```c
int my_midlayer_create_something()
{
      if (!devres_open_group(dev, my_midlayer_create_something, GFP_KERNEL))
              return -ENOMEM;

      ...

      devres_close_group(dev, my_midlayer_create_something);
      return 0;
}

void my_midlayer_destroy_something()
{
      devres_release_group(dev, my_midlayer_create_something);
}
```

### Details

devres条目的生命周期从分配devres时开始，到释放或销毁(删除和释放)时结束——没有引用计数。

Devres核心保证了所有基本设备操作的原子性，并支持单实例设备类型(原子查找和添加-如果没有找到)。除此之外，同步并发访问已分配的设备数据是调用者的责任。这通常不是问题，因为总线操作和资源分配已经完成了这项工作。

对于单实例设备类型的示例，读取`lib/devres.c`中的`pcim_iomap_table()`。

如果给出了正确的gfp掩码，所有的devres接口函数都可以在没有上下文的情况下调用。

### Overhead

每个设备的记账信息与请求的数据区一起分配。当调试选项关闭时，记帐信息在32位机器上占用16字节，在64位机器上占用24字节(三个指针四舍五入到完全对齐)。如果使用单链表，它可以减少到两个指针(32位为8字节，64位为16字节)。

每个devres组占用8个指针。如果使用单链表，它可以减少到6。

经过简单转换后，带有两个端口的ahci控制器在32位机器上的内存空间开销在300到400字节之间(我们当然可以在libata核心层上投入更多的精力)。

### Managed 接口API

#### CLOCK
##### devm_clk_get
##### devm_clk_get_optional
##### devm_clk_put
##### devm_clk_bulk_get
##### devm_clk_bulk_get_all
##### devm_clk_bulk_get_optional
##### devm_get_clk_from_child
##### devm_clk_hw_register
##### devm_of_clk_add_hw_provider
##### devm_clk_hw_register_clkdev

#### DMA
##### dmaenginem_async_device_register
##### dmam_alloc_coherent
##### dmam_alloc_attrs
##### dmam_free_coherent
##### dmam_pool_create
##### dmam_pool_destroy

#### DRM
##### devm_drm_dev_alloc

#### GPIO
##### devm_gpiod_get
##### devm_gpiod_get_array
##### devm_gpiod_get_array_optional
##### devm_gpiod_get_index
##### devm_gpiod_get_index_optional
##### devm_gpiod_get_optional
##### devm_gpiod_put
##### devm_gpiod_unhinge
##### devm_gpiochip_add_data
##### devm_gpio_request
##### devm_gpio_request_one

#### I2C
##### devm_i2c_add_adapter
##### devm_i2c_new_dummy_device

#### IIO
##### devm_iio_device_alloc
##### devm_iio_device_register
##### devm_iio_dmaengine_buffer_setup
##### devm_iio_kfifo_buffer_setup
##### devm_iio_map_array_register
##### devm_iio_triggered_buffer_setup
##### devm_iio_trigger_alloc
##### devm_iio_trigger_register
##### devm_iio_channel_get
##### devm_iio_channel_get_all

#### INPUT
##### devm_input_allocate_device

#### IO region
##### devm_release_mem_region
##### devm_release_region
##### devm_release_resource
##### devm_request_mem_region
##### devm_request_free_mem_region
##### devm_request_region
##### devm_request_resource

#### IOMAP
#### IRQ
#### LED
#### MDIO
#### MEM
#### MFD
#### MUX
#### NET
#### PER-CPU MEM
#### PCI
#### PHY
#### PINCTRL
#### POWER
#### PWM
#### REGULATOR
#### RESET
#### RTC
#### SERDEV
#### SLAVE DMA ENGINE
#### SPI
#### WATCHDOG

## Device Drivers

## 内核设备模型

### 说明

Linux内核驱动模型是以前在内核中使用的所有不同驱动模型的统一。它的目的是通过将一组数据和操作整合到全局可访问的数据结构中来增强桥接和设备的总线特定驱动程序。

传统的驱动模型为它们控制的设备实现了某种树状结构(有时只是一个列表)。不同类型的总线没有任何一致性。

当前的驱动程序模型提供了一个通用的、统一的数据模型，用于描述总线和总线下可能出现的设备。统一总线模型包括所有总线携带的一组公共属性和一组公共回调，例如总线探测期间的设备发现、总线关闭、总线电源管理等。

通用设备和桥接接口体现了现代计算机的目标:即能够做到无缝设备的“即插即用”、电源管理和热插拔。特别是，由Intel和Microsoft(即ACPI)指定的模型确保了x86兼容系统上几乎任何总线上的几乎所有设备都可以在这种范式中工作。当然，不是每个总线都能够支持所有这些操作，尽管大多数总线支持大多数这些操作。

### Downstream Access

公共数据字段已从各个总线层移到公共数据结构中。这些字段仍然必须由总线层访问，有时由特定于设备的驱动程序访问。

鼓励其他总线层完成PCI层所做的工作。`struct pci_dev`现在看起来像这样:
```c
struct pci_dev 
{
      ...

      struct device dev;     /* Generic device interface */
      ...
};
```

首先注意，`struct pci_dev`中的`struct device dev`是静态分配的。这意味着在设备发现时只有一次分配。

还要注意，`struct device dev`不一定在`struct pci_dev`结构体的前面定义。这是为了让人们在总线驱动程序和全局驱动程序之间切换时考虑他们在做什么，并阻止两者之间无意义和不正确的类型转换。

PCI总线层可以自由访问结构设备的字段。它知道`struct pci_dev`的结构，也应该知道`struct device`的结构。已经转换为当前驱动程序模型的单个PCI设备驱动程序通常不会也不应该触及`struct device`的字段，除非有令人信服的理由这样做。

上面的抽象避免了过渡阶段不必要的痛苦。如果不这样做，那么当一个字段被重命名或删除时，每个下游驱动程序都会中断。另一方面，如果只有总线层(而不是设备层)访问结构设备，则只有总线层需要更改。

### 用户接口

由于拥有系统中所有设备的完整层次视图，将完整的层次视图导出到用户空间变得相对容易。这是通过实现一个名为sysfs的特殊用途虚拟文件系统来实现的。

几乎所有主流Linux发行版都会自动挂载这个文件系统;在“mount”命令的输出中，你可以看到以下一些变化:

```
$ mount
...
none on /sys type sysfs (rw,noexec,nosuid,nodev)
...
$
```

sysfs的自动挂载通常通过/etc/fstab文件中的如下条目来完成:
```shell
none          /sys    sysfs    defaults               0 0
```

每当将一个设备插入到树中，就会为它创建一个目录。这个目录可以在发现的每一层填充——全局层、总线层或设备层。

global层目前创建了两个文件:name和power。前者只报告设备的名称。后者报告设备的当前电源状态。它还将用于设置当前电源状态。

总线层还可以为它在探测总线时发现的设备创建文件。例如，PCI层目前为每个PCI设备创建“irq”和“资源”文件。

特定于设备的驱动程序还可以导出其目录中的文件，以公开特定于设备的数据或可调接口。

关于sysfs目录布局的更多信息可以在该目录下的其他文档和用于导出内核对象的文件sysfs - _The_ filesystem中找到。

## 平台驱动和设备程序

参见<linux/platform_device.h>获取平台总线的驱动模型接口:platform_device和platform_driver。这种伪总线用于在具有最小基础设施的总线上连接设备，例如用于在许多片上系统处理器上集成外围设备的总线，或一些“传统”PC互连;而不是像PCI或USB这样的大型正式指定的标准。

### 平台设备

平台设备通常在系统中作为自治实体出现。这包括传统的基于端口的设备和到外围总线的主机桥接，以及集成到片上系统平台中的大多数控制器。它们的共同点是直接从CPU总线寻址。很少情况下，platform_device将通过其他类型总线的段连接;但是它的寄存器仍然是可直接寻址的。

平台设备被赋予一个名称，用于驱动绑定，以及一个资源列表，如地址和irq:

```c
struct platform_device 
{
      const char      *name;
      u32             id;
      struct device   dev;
      u32             num_resources;
      struct resource *resource;
};
```

### 平台驱动

平台驱动程序遵循标准驱动程序模型约定，其中发现/枚举在驱动程序外部处理，驱动程序提供probe()和remove()方法。它们支持使用标准约定的电源管理和关机通知:

```c
struct platform_driver 
{
      int (*probe)(struct platform_device *);
      int (*remove)(struct platform_device *);
      void (*shutdown)(struct platform_device *);
      int (*suspend)(struct platform_device *, pm_message_t state);
      int (*suspend_late)(struct platform_device *, pm_message_t state);
      int (*resume_early)(struct platform_device *);
      int (*resume)(struct platform_device *);
      struct device_driver driver;
};
```

注意，probe()通常应该验证指定的设备硬件是否确实存在;有时，平台设置代码不能确定。探测可以使用设备资源，包括时钟和设备platform_data。

平台驱动程序以正常方式注册自己:

```c
int platform_driver_register(struct platform_driver *drv);
```
或者，在已知设备不可热插拔的常见情况下，probe()例程可以驻留在init节中以减少驱动程序的运行时内存占用:

```c
int platform_driver_probe(struct platform_driver *drv, int (*probe)(struct platform_device *));
```

内核模块可以由几个平台驱动程序组成。平台核心提供了注册和注销一系列驱动程序的帮助程序:

```c
int __platform_register_drivers(struct platform_driver * const *drivers, unsigned int count, struct module *owner);
void platform_unregister_drivers(struct platform_driver * const *drivers, unsigned int count);
```

如果其中一个驱动程序注册失败，那么到该点为止注册的所有驱动程序将以相反的顺序被取消注册。请注意，有一个方便的宏将`THIS_MODULE`作为所有者参数传递:

```c
#define platform_register_drivers(drivers, count)
```

### 设备枚举

通常，特定于平台(通常是特定于主板)的设置代码将注册平台设备:

```c
int platform_device_register(struct platform_device *pdev);

int platform_add_devices(struct platform_device **pdevs, int ndev);
```
一般规则是只注册那些实际存在的设备，但在某些情况下可能会注册额外的设备。例如，可以将内核配置为与外部网络适配器一起工作，而外部网络适配器可能不会在所有板上都安装，或者同样地，可以将内核配置为与集成控制器一起工作，而某些板可能不会连接到任何外设。

在某些情况下，引导固件将导出描述在给定板上填充的设备的表。如果没有这样的表，系统设置代码设置正确设备的唯一方法通常是为特定的目标板构建内核。这种特定于主板的内核在嵌入式和定制系统开发中很常见。

在许多情况下，与平台设备相关联的内存和IRQ资源不足以让设备的驱动程序工作。电路板设置代码通常会使用设备的`platform_data`字段提供附加信息来保存附加信息。

嵌入式系统经常需要一个或多个时钟用于平台设备，这些时钟通常在需要时才关闭(以节省电力)。系统设置还将这些时钟与设备关联起来，这样调用`clk_get(&pdev->dev, clock_name)`就可以根据需要返回它们。

### 遗留驱动程序:设备探测

有些驱动程序没有完全转换为驱动程序模型，因为它们承担了非驱动程序的角色:驱动程序注册其平台设备，而不是将其留给系统基础设施。这样的驱动程序不能被热插拔或冷插拔，因为这些机制要求设备创建在与驱动程序不同的系统组件中。

这样做的唯一“好”理由是处理旧的系统设计，如原始IBM pc，依赖于容易出错的“探测硬件”模型进行硬件配置。较新的系统已经在很大程度上放弃了这种模式，转而支持总线级对动态配置(PCI、USB)或由引导固件(例如x86上的PNPACPI)提供的设备表的支持。有太多相互冲突的选项，关于什么可能在哪里，甚至一个操作系统的有根据的猜测往往是错误的，足以造成麻烦。

这种风格的驱动是不受鼓励的。如果您正在更新这样的驱动程序，请尝试将设备枚举移动到更合适的位置，在驱动程序之外。这通常是清理，因为这些驱动程序往往已经具有“正常”模式，例如使用由PNP或平台设备设置创建的设备节点的驱动程序。

尽管如此，还是有一些api支持这些遗留驱动程序。避免使用这些调用，除非使用缺乏热插件的驱动程序:

```c
struct platform_device *platform_device_alloc(const char *name, int id);
```

您可以使用`platform_device_alloc()`来动态分配设备，然后使用资源和`platform_device_register()`对设备进行初始化。更好的解决方案通常是:

```c
struct platform_device *platform_device_register_simple(
        const char *name,
        int id,
        struct resource *res,
        unsigned int nres);
```

您可以使用`platform_device_register_simple()`作为一步调用来分配和注册设备。

### 设备命名和驱动绑定

`platform_device.dev.bus_id`是设备的规范名称。它由两个部分组成:
- `Platform_device.name…`也用于驱动程序匹配。
- `platform_device.Id…`设备实例号，否则“-1”表示只有一个。

....

### 早期平台设备和驱动程序

## 将驱动程序移植到新的驱动程序模型
