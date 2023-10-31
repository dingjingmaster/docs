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

## MTRR Handling

MTRR(Memory Type Range Registers)。是指处理内存类型范围寄存器的机制。

MTRR 是 x86 架构中的一组寄存器，用于定义系统内存的访问类型。

MTRR 提供了一种机制，可以为系统内存的不同区域指定不同的访问类型，例如写回缓存（write-back cache）、写直达（write-through）或者禁止缓存（uncached）。这些访问类型可以影响内存的性能和一致性。

Linux 内核通过 MTRR handling 机制来管理和配置 MTRR 寄存器。这个机制允许内核在启动过程中读取和设置 MTRR 寄存器的值，以定义内存区域的访问类型。

MTRR handling 在Linux内核中的主要任务包括：
- 读取和解析系统中的MTRR寄存器的当前配置
- 提供接口和工具，使用户能够查询和修改 MTRR 寄存器的值
- 根据系统的需求，根据硬件限制和用户配置来自动配置MTRR寄存器
- 与其它内核子系统（如缓存管理）进行协调，以确保内存访问类型的一致性和正确性

通过适当配置MTRR寄存器，Linux内核可以优化系统的内存性能，特别是对于一些需要频繁访问的内存区域，如显存或者设备I/O区域。这些优化可以提高系统的响应速度和整体性能。

> 注意：MTRR Handling 主要适用于 x86 架构的系统，而其它架构可能采用不同的内存访问类型管理机制。

### arch_phys_wc_add

函数签名：
```c
int arch_phys_wc_add(unsigned long base, unsigned long size);
```

说明：

参数：
- `base`：
- `size`：

## Security Framework

### security_init

函数签名：
```c
int security_init(void);
```

说明：

### security_add_hooks

函数签名：
```c
void security_add_hooks(struct security_hook_list *hooks, int count, const char *lsm);
```

说明：
向hook列表中添加一个模块hook

每个LSM都必须注册它的hook

参数：
- `hooks`：hook列表
- `count`：要添加的hook数量
- `lsm`：安全模块的名字

### lsm_cred_alloc

函数签名：
```c
int lsm_cred_alloc(struct cred *cred, gfp_t gfp);
```

说明：
分配一个 struct cred 块

参数：
- `cred`：
- `gfp`：

### lsm_early_cred

函数签名：
```c
void lsm_early_cred(struct cred *cred);
```

说明：
在初始化中分配一个 `struct cred`

参数：
- `cred`

### lsm_file_alloc

函数签名：
```c
int lsm_file_alloc(struct file *file);
```

说明：

参数：
- `file`：

### lsm_inode_alloc

函数签名：
```c
int lsm_inode_alloc(struct inode *inode);
```

说明：

参数：
- `inode`：

### lsm_task_alloc

函数签名：
```c
int lsm_task_alloc(struct task_struct *task);
```

### lsm_ipc_alloc

函数签名：
```c
int lsm_ipc_alloc(struct kern_ipc_perm *kip);
```

### lsm_msg_msg_alloc

函数签名：
```c
int lsm_msg_msg_alloc(struct msg_msg *mp);
```

### lsm_early_task

函数签名：
```c
void lsm_early_task(struct task_struct *task);
```

### lsm_superblock_alloc

函数签名：
```c
int lsm_superblock_alloc(struct super_block *sb);
```

### security_fs_context_submount

函数签名：
```c
int security_fs_context_submount(struct fs_context *fc, struct super_block *reference);
```

参数：
- `fc`：
- `reference`：

### securityfs_create_file

函数签名：
```c
struct dentry *securityfs_create_file(const char *name, umode_t mode, struct dentry *parent, void *data, const struct file_operations *fops);
```

参数：
- `name`：
- `mode`：
- `parent`：
- `data`：
- `fops`：

### securityfs_create_dir

函数签名：
```c
struct dentry *securityfs_create_dir(const char *name, struct dentry *parent);
```

参数：
- `name`：
- `parent`：

### securityfs_create_symlink

函数签名：
```c
struct dentry *securityfs_create_symlink(const char *name, struct dentry *parent, const char *target, const struct inode_operations *iops);
```

参数：
- `name`：
- `parent`：
- `target`：
- `iops`：

### securityfs_remove

函数签名：
```c
void securityfs_remove(struct dentry *dentry);
```

参数：
- `dentry`：

## 审计接口

### audit_log_start

函数签名：
```c
struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask, int type);
```

说明：
成功时返回audit_buffer指针，错误时返回NULL。

获取审计缓冲区。这个例程锁定以获取审计缓冲区，但是对audit_log_\*format的调用不需要锁定。如果任务(ctx)是当前处于系统调用中的任务，则将该系统调用标记为可审计的，并在系统调用退出时写入审计记录。如果没有关联的任务，那么任务上下文(ctx)应该为NULL。

参数：
- `ctx`：审计上下文
- `gfp_mask`：
- `type`：审计的消息类型

### audit_log_format

函数签名：
```c
void audit_log_format(struct audit_buffer *ab, const char *fmt, ...);
```

说明：

参数：
- `ab`：
- `fmt`：
- `...`：

### audit_log_end

函数签名：
```c
void audit_log_end(struct audit_buffer *ab);
```

说明：

参数：
- `ab`：

### audit_log

函数签名：
```c
void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type, const char *fmt, ...);
```

说明：

参数：
- `ctx`：
- `gfp_mask`：
- `type`：
- `fmt`：
- `...`：

### audit_filter_uring

函数签名：
```c
void audit_filter_uring(struct task_struct *tsk, struct audit_context *ctx);
```

说明：

参数：
- `tsk`：
- `ctx`：

### audit_reset_context

函数签名：
```c
void audit_reset_context(struct audit_context *ctx);
```

说明：

参数：
- `ctx`：

### audit_alloc

函数签名：
```c
int audit_alloc(struct task_struct *tsk);
```

说明：

参数：
- `tsk`：

### audit_log_uring

函数签名：
```c
void audit_log_uring(struct audit_context *ctx);
```

说明：

参数：
- `ctx`：

### __audit_free

函数签名：
```c
void __audit_free(struct task_struct *tsk);
```

说明：

参数：
- `tsk`：

### audit_return_fixup

函数签名：
```c
void audit_return_fixup(struct audit_context *ctx, int success, long code);
```

说明：

参数：
- `ctx`：
- `success`：
- `code`：

### __audit_uring_entry

函数签名：
```c
void __audit_uring_entry(u8 op);
```

说明：

参数：

### __audit_uring_exit

函数签名：
```c
void __audit_uring_exit(int success, long code);
```

说明：

参数：
- `success`：
- `code`：

### __audit_syscall_entry

函数签名：
```c
void __audit_syscall_entry(int major, unsigned long a1, unsigned long a2, unsigned long a3, unsigned long a4);
```

说明：

参数：
- `major`：
- `a1`:
- `a2`:
- `a3`:
- `a4`:

### __audit_syscall_exit

函数签名：
```c
void __audit_syscall_exit(int success, long return_code);
```

说明：

参数：
- `success`：
- `return_code`：

### __audit_reusename

函数签名：
```c
struct filename *__audit_reusename(__user const char *uptr);
```

说明：

参数：
- `uptr`：

### __audit_getname

函数签名：
```c
void __audit_getname(struct filename *name);
```

说明：

参数：
- `name`：

### __audit_inode

函数签名：
```c
void __audit_inode(struct filename *name, const struct dentry *dentry, unsigned int flags);
```

说明：

参数：
- `name`：
- `dentry`：
- `flags`：

### auditsc_get_stamp

函数签名：
```c
int auditsc_get_stamp(struct audit_context *ctx, struct timespec64 *t, unsigned int *serial);
```

说明：

参数：
- `ctx`：
- `t`：
- `serial`：

### __audit_mq_open

函数签名：
```c
void __audit_mq_open(int oflag, umode_t mode, struct mq_attr *attr);
```

### __audit_mq_sendrecv

函数签名：
```c
void __audit_mq_sendrecv(mqd_t mqdes, size_t msg_len, unsigned int msg_prio, const struct timespec64 *abs_timeout);
```

### __audit_mq_notify

函数签名：
```c
void __audit_mq_notify(mqd_t mqdes, const struct sigevent *notification);
```

### __audit_mq_getsetattr

函数签名：
```c
void __audit_mq_getsetattr(mqd_t mqdes, struct mq_attr *mqstat);
```

### __audit_ipc_obj

函数签名：
```c
void __audit_ipc_obj(struct kern_ipc_perm *ipcp);
```

### __audit_ipc_set_perm

函数签名：
```c
void __audit_ipc_set_perm(unsigned long qbytes, uid_t uid, gid_t gid, umode_t mode);
```

### __audit_socketcall

函数签名：
```c
int __audit_socketcall(int nargs, unsigned long *args);
```

### __audit_fd_pair

函数签名：
```c
void __audit_fd_pair(int fd1, int fd2);
```

### __audit_sockaddr

函数签名：
```c
int __audit_sockaddr(int len, void *a);
```

### audit_signal_info_syscall

函数签名：
```c
int audit_signal_info_syscall(struct task_struct *t);
```

### __audit_log_bprm_fcaps

函数签名：
```c
int __audit_log_bprm_fcaps(struct linux_binprm *bprm, const struct cred *new, const struct cred *old);
```

### __audit_log_capset

函数签名：
```c
void __audit_log_capset(const struct cred *new, const struct cred *old);
```

### audit_core_dumps

函数签名：
```c
void audit_core_dumps(long signr);
```

### audit_seccomp

函数签名：
```c
void audit_seccomp(unsigned long syscall, long signr, int code);
```

### audit_rule_change

函数签名：
```c
int audit_rule_change(int type, int seq, void *data, size_t datasz);
```

### audit_list_rules_send

函数签名：
```c
int audit_list_rules_send(struct sk_buff *request_skb, int seq);
```

### parent_len

函数签名：
```c
int parent_len(const char *path);
```

### audit_compare_dname_path

函数签名：
```c
int audit_compare_dname_path(const struct qstr *dname, const char *path, int parentlen);
```

## Accounting Framework

### sys_acct

函数签名：
```c
long sys_acct(const char __user *name);
```

说明：

参数：
- `name`：

### acct_collect

函数签名：
```c
void acct_collect(long exitcode, int group_dead);
```

### acct_process

函数签名：
```c
void acct_process(void);
```

