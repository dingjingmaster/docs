# 硬件接口

## DMA 通道

### request_dma

函数签名：
```c
int request_dma(unsigned int dmanr, const char *device_id);
```

说明：
请求和保留一个系统DMA通道

返回值：

参数：
- `dmanr`：DMA通道编号
- `device_id`：保留设备ID字符串，用于`/proc/dma`

### free_dma

函数签名：
```c
void free_dma(unsigned int dmanr);
```

说明：
释放分配的DMA通道

参数：
- `dmanr`：DMA通道编号

## 资源管理

### request_resource_conflict

函数签名：
```c
struct resource *request_resource_conflict(struct resource *root, struct resource *new);
```

说明：
请求和保留I/O或内存资源

返回值：
- 成功：返回0
- 失败：返回错误码

参数：
- `root`：根资源描述符
- `new`：调用这所需的资源描述符

### find_next_iomem_res

函数签名：
```c
int find_next_iomem_res(resource_size_t start, resource_size_t end, unsigned long flags, unsigned long desc, struct resource *res);
```

说明：
查找覆盖[start..**end**]部分的最低iomem资源。

返回值：
成功：返回0
失败：没找到则返回 -ENODEV，参数错误则返回 -EINVAL

参数：
- `start`：要搜索资源的开始地址
- `end`：要搜索资源的结束地址
- `flags`：资源必须具有的flags
- `desc`：资源必须具有的描述符
- `res`：如果资源找到，则返回它，这个指针指向找到的资源。

### reallocate_resource

函数签名：
```c
int reallocate_resource(struct resource *root, struct resource *old, resource_size_t newsize, struct resource_constraint *constraint);
```

说明：
在给定范围和对齐的资源树中分配一个槽。如果新的大小不能在当前位置重新分配，则资源将被重新定位。

返回值：

参数：
- `root`：根资源描述符
- `old`：调用者需要的资源描述符
- `newsize`：资源描述符的新大小
- `constraint`：要满足的大小和对齐约束

### lookup_resource

函数签名：
```c
struct resource *lookup_resource(struct resource *root, resource_size_t start);
```

说明：
根据资源起始地址查找现有资源

返回值：
- 成功：返回资源指针
- 失败：NULL

参数：
- `root`：根资源描述符
- `start`：资源开始地址

### insert_resource_conflict

函数签名：
```c
struct resource *insert_resource_conflict(struct resource *parent, struct resource *new);
```

说明：
在资源树中插入资源

返回值：

参数：
- `parent`：新资源的parent
- `new`：要插入的新资源

### insert_resource_expand_to_fix

函数签名：
```c
void insert_resource_expand_to_fit(struct resource *root, struct resource *new);
```

说明：
将资源插入到资源树

返回值：

参数：
- `root`：根资源描述符
- `new`：要插入的新资源

### resource_alignment

函数签名：
```c
resource_size_t resource_alignment(struct resource *res);
```

说明：
计算资源的对齐位置

返回值：
- 成功：返回0
- 失败：

参数：
- `res`：资源指针

### release_mem_region_adjustable

函数签名：
```c
void release_mem_region_adjustable(resource_size_t start, resource_size_t size);
```

说明：
释放先前保留的内存区域

参数：
- `start`：资源的起始地址
- `size`：资源区域大小

### merge_system_ram_resource

函数签名：
```c
void merge_system_ram_resource(struct resource *res);
```

说明：
将系统RAM资源标记为可合并的，并尝试将其与相邻的可合并资源合并

参数：
- `res`：资源描述符

### alloc_free_mem_region

函数签名：
```c
struct resource *alloc_free_mem_region(struct resource *base, unsigned long size, unsigned long align, const char *name);
```

说明：
找一个相对于 `base` 的空闲区域

像CXL这样可以动态实例化新内存区域的总线需要一种方法来为这些区域分配物理地址空间。分配并插入一个新资源，以覆盖base空间中一个空闲的、base的后代未占用的范围。

参数：
- `base`：
- `size`：从`base`开始分配的内存大小
- `align`：
- `name`：资源名字

### request_resource

函数签名：
```c
int request_resource(struct resource *root, struct resource *new);
```

说明：
请求和保留I/O或内存资源

参数：
- `root`：根资源描述符
- `new`：被调用这需要的资源描述符

### release_resource

函数签名：
```c
int release_resource(struct resource *old);
```

说明：
释放之前分配的资源

参数：
- `old`：资源指针

### walk_iomem_res_desc

函数签名：
```c
int walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start, u64 end, void *arg, int (*func)(struct resource*, void*));
```

说明：
遍历iomem资源，并使用匹配的资源范围调用func()。

参数：
- `desc`：I/O资源描述符。使用`IORES_DESC_NONE`跳过desc检查
- `flags`：I/O资源标志
- `start`：开始地址
- `end`：结束地址
- `arg`：func回调函数的参数
- `func`：为每个符合条件的资源区域调用的回调函数

### region_intersects

函数签名：
```c
int region_intersects(resource_size_t start, size_t size, unsigned long flags, unsigned long desc);
```

说明：
确定已知资源域的焦点

参数：
- `start`：资源与的起始地址
- `size`：资源域的大小
- `flags`：资源标记
- `desc`：资源的描述符或`IORES_DESC_NONE`

### allocate_resource

函数签名：
```c
int allocate_resource(struct resource *root, struct resource *new, resource_size_t size, resource_size_t min, resource_size_t max, resource_size_t align, resource_size_t (*alignf)(void*, const struct resource*, resource_size_t, resource_size_t), void *alignf_data);
```

说明：
在给定范围和对齐的资源树中分配空槽。如果已经分配了资源，将使用新的大小重新分配资源

参数：
- `root`：根资源描述符
- `new`：被调用这需要的资源描述符
- `size`：资源区域大小
- `min`：分配资源的地址低位
- `max`：分配资源的地址高位
- `align`：请求对齐的单位，以字节为单位
- `alignf`：对齐函数（可选），如果不是NULL则调用
- `alignf_data`：传递给alignf函数的任意数据

### insert_resource

函数签名：
```c
int insert_resource(struct resource *parent, struct resource *new);
```

说明：
在资源树中插入资源

参数：
- `parent`：新资源的父节点
- `new`：要插入的新资源

### remove_resource

函数签名：
```c
int remove_resource(struct resource *old);
```

### adjust_resource

函数签名：
```c
int adjust_resource(struct resource *res, resource_size_t start, resource_size_t size)
```

说明：
修改资源的起始位置和大小

参数：
- `res`：要修改的资源
- `start`：新的开始值
- `size`：新的大小值

### __request_region

函数签名：
```c
struct resource *__request_region(struct resource *parent, resource_size_t start, resource_size_t n, const char *name, int flags);
```

说明：
创建新的资源区域

参数：
- `parent`：
- `start`：资源区域的起始位置
- `n`：资源区域的大小
- `name`：调用者的ID字符串
- `flags`：IO资源flags

### __release_region

函数签名：
```c
void __release_region(struct resource *parent, resource_size_t start, resource_size_t n);
```

说明：
释放之前分配的资源区域

参数：
- `parent`：
- `start`：
- `n`：

### devm_request_resource

函数签名：
```c
int devm_request_resource(struct device *dev, struct resource *root, struct resource *new);
```

说明：
请求和保留一个I/O或者内存资源

这是request_resource()的设备管理版本。通常不需要显式地释放此函数请求的资源，因为当设备与其驱动程序解除绑定时，将会处理这些资源。如果由于某种原因需要显式释放资源，例如由于排序问题，驱动程序必须调用devm_release_resource()而不是常规的release_resource()。

当检测到任何现有资源与新请求的资源之间存在冲突时，将打印一条错误消息。

返回值：
成功时返回0，失败时返回负错误码。

参数：
- `dev`：请求资源的设备
- `root`：资源树的根
- `new`：请求的资源描述符

### devm_release_resource

函数签名：
```c
void devm_release_resource(struct device *dev, struct resource *new);
```

说明：
释放之前分配的资源

参数：
- `dev`：
- `new`：

### devm_request_free_mem_region

函数签名：
```c
struct resource *devm_request_free_mem_region(struct device *dev, struct resource *base, unsigned long size);
```

说明：
为设备私有内存找到空闲区域

参数：
- `dev`：
- `base`：
- `size`：


