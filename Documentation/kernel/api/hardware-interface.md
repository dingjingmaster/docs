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

## 块设备

### bio_advance

函数签名：
```c
void bio_advance(struct bio *bio, unsigned int nbytes);
```

### struct folio_iter

定义：
```c
struct folio_iter 
{
  struct folio *folio;
  size_t offset;
  size_t length;
};
```

### bio_for_each_folio_all

函数签名：
```c
bio_for_each_folio_all (fi, bio);
```

### bio_next_split

函数签名：
```c
struct bio *bio_next_split(struct bio *bio, int sectors, gfp_t gfp, struct bio_set *bs);
```

### blk_queue_flag_set

函数签名：
```c
void blk_queue_flag_set(unsigned int flag, struct request_queue *q);
```

### blk_queue_flag_clear

函数签名：
```c
void blk_queue_flag_clear(unsigned int flag, struct request_queue *q);
```

### blk_queue_flag_test_and_set

函数签名：
```c
bool blk_queue_flag_test_and_set(unsigned int flag, struct request_queue *q);
```

### blk_op_str

函数签名：
```c
const char *blk_op_str(enum req_op op);
```

### blk_sync_queue

函数签名：
```c
void blk_sync_queue(struct request_queue *q);
```

### blk_set_pm_only

函数签名：
```c
void blk_set_pm_only(struct request_queue *q);
```

### blk_put_queue

函数签名：
```c
void blk_put_queue(struct request_queue *q);
```

### blk_get_queue

函数签名：
```c
bool blk_get_queue(struct request_queue *q);
```

### submit_bio_noacct

函数签名：
```c
void submit_bio_noacct(struct bio *bio);
```

### submit_bio

函数签名：
```c
void submit_bio(struct bio *bio);
```

### bio_poll

函数签名：
```c
int bio_poll(struct bio *bio, struct io_comp_batch *iob, unsigned int flags);
```

### bio_start_io_acct_time

函数签名：
```c
void bio_start_io_acct_time(struct bio *bio, unsigned long start_time);
```

### bio_start_io_acct

函数签名：
```c
unsigned long bio_start_io_acct(struct bio *bio);
```

### blk_lld_busy

函数签名：
```c
int blk_lld_busy(struct request_queue *q);
```

### blk_start_plug

函数签名：
```c
void blk_start_plug(struct blk_plug *plug);
```

### blk_finish_plug

函数签名：
```c
void blk_finish_plug(struct blk_plug *plug);
```

### blk_queue_enter

函数签名：
```c
int blk_queue_enter(struct request_queue *q, blk_mq_req_flags_t flags);
```

### blk_rq_map_user_iov

函数签名：
```c
int blk_rq_map_user_iov(struct request_queue *q, struct request *rq, struct rq_map_data *map_data, const struct iov_iter *iter, gfp_t gfp_mask);
```

### blk_rq_unmap_user

函数签名：
```c
int blk_rq_unmap_user(struct bio *bio);
```

### blk_rq_map_kern

函数签名：
```c
int blk_rq_map_kern(struct request_queue *q, struct request *rq, void *kbuf, unsigned int len, gfp_t gfp_mask);
```

### blk_release_queue

函数签名：
```c
void blk_release_queue(struct kobject *kobj);
```

### blk_register_queue

函数签名：
```c
int blk_register_queue(struct gendisk *disk);
```

### blk_unregister_queue

函数签名：
```c
void blk_unregister_queue(struct gendisk *disk);
```

### blk_set_stacking_limits

函数签名：
```c
void blk_set_stacking_limits(struct queue_limits *lim);
```

### blk_queue_bounce_limit

函数签名：
```c
void blk_queue_bounce_limit(struct request_queue *q, enum blk_bounce bounce);
```

### blk_queue_max_hw_sectors

函数签名：
```c
void blk_queue_max_hw_sectors(struct request_queue *q, unsigned int max_hw_sectors);
```

### blk_queue_chunk_sectors

函数签名：
```c
void blk_queue_chunk_sectors(struct request_queue *q, unsigned int chunk_sectors);
```

### blk_queue_max_discard_sectors

函数签名：
```c
void blk_queue_max_discard_sectors(struct request_queue *q, unsigned int max_discard_sectors);
```

### blk_queue_max_secure_erase_sectors

函数签名：
```c
void blk_queue_max_secure_erase_sectors(struct request_queue *q, unsigned int max_sectors);
```

### blk_queue_max_write_zeroes_sectors

函数签名：
```c
void blk_queue_max_write_zeroes_sectors(struct request_queue *q, unsigned int max_write_zeroes_sectors);
```

### blk_queue_max_zone_append_sectors

函数签名：
```c
void blk_queue_max_zone_append_sectors(struct request_queue *q, unsigned int max_zone_append_sectors);
```

### blk_queue_max_segments

函数签名：
```c
void blk_queue_max_segments(struct request_queue *q, unsigned short max_segments);
```

### blk_queue_max_discard_segments

函数签名：
```c
void blk_queue_max_discard_segments(struct request_queue *q, unsigned short max_segments);
```

### blk_queue_max_segment_size

函数签名：
```c
void blk_queue_max_segment_size(struct request_queue *q, unsigned int max_size);
```

### blk_queue_logical_block_size

函数签名：
```c
void blk_queue_logical_block_size(struct request_queue *q, unsigned int size);
```

### blk_queue_physical_block_size

函数签名：
```c
void blk_queue_physical_block_size(struct request_queue *q, unsigned int size);
```

### blk_queue_zone_write_granularity

函数签名：
```c
void blk_queue_zone_write_granularity(struct request_queue *q, unsigned int size);
```

### blk_queue_alignment_offset

函数签名：
```c
void blk_queue_alignment_offset(struct request_queue *q, unsigned int offset);
```

### blk_limits_io_min

函数签名：
```c
void blk_limits_io_min(struct queue_limits *limits, unsigned int min);
```

### blk_queue_io_min

函数签名：
```c
void blk_queue_io_min(struct request_queue *q, unsigned int min);
```

### blk_limits_io_opt

函数签名：
```c
void blk_limits_io_opt(struct queue_limits *limits, unsigned int opt);
```

### blk_queue_io_opt

函数签名：
```c
void blk_queue_io_opt(struct request_queue *q, unsigned int opt);
```

### blk_stack_limits

函数签名：
```c
int blk_stack_limits(struct queue_limits *t, struct queue_limits *b, sector_t start);
```

### disk_stack_limits

函数签名：
```c
void disk_stack_limits(struct gendisk *disk, struct block_device *bdev, sector_t offset);
```

### blk_queue_update_dma_pad

函数签名：
```c
void blk_queue_update_dma_pad(struct request_queue *q, unsigned int mask);
```

### blk_queue_segment_boundary

函数签名：
```c
void blk_queue_segment_boundary(struct request_queue *q, unsigned long mask);
```

### blk_queue_virt_boundary

函数签名：
```c
void blk_queue_virt_boundary(struct request_queue *q, unsigned long mask);
```

### blk_queue_dma_alignment

函数签名：
```c
void blk_queue_dma_alignment(struct request_queue *q, int mask);
```

### blk_queue_update_dma_alignment

函数签名：
```c
void blk_queue_update_dma_alignment(struct request_queue *q, int mask);
```

### blk_set_queue_depth

函数签名：
```c
void blk_set_queue_depth(struct request_queue *q, unsigned int depth);
```

### blk_queue_write_cache

函数签名：
```c
void blk_queue_write_cache(struct request_queue *q, bool wc, bool fua);
```

### blk_queue_required_elevator_features

函数签名：
```c
void blk_queue_required_elevator_features(struct request_queue *q, unsigned int features);
```

### blk_queue_can_use_dma_merging

函数签名：
```c
bool blk_queue_can_use_dma_map_merging(struct request_queue *q, struct device *dev);
```

### disk_set_zoned

函数签名：
```c
void disk_set_zoned(struct gendisk *disk, enum blk_zoned_model model);
```

### blkdev_issue_flush

函数签名：
```c
int blkdev_issue_flush(struct block_device *bdev);
```

### blkdev_issue_discard

函数签名：
```c
int blkdev_issue_discard(struct block_device *bdev, sector_t sector, sector_t nr_sects, gfp_t gfp_mask);
```

### __blkdev_issue_zeroout

函数签名：
```c
int __blkdev_issue_zeroout(struct block_device *bdev, sector_t sector, sector_t nr_sects, gfp_t gfp_mask, struct bio **biop, unsigned flags);
```

### blkdev_issue_zeroout

函数签名：
```c
int blkdev_issue_zeroout(struct block_device *bdev, sector_t sector, sector_t nr_sects, gfp_t gfp_mask, unsigned flags);
```

### blk_rq_count_integrity_sg

函数签名：
```c
int blk_rq_count_integrity_sg(struct request_queue *q, struct bio *bio);
```

### blk_rq_map_integrity_sg

函数签名：
```c
int blk_rq_map_integrity_sg(struct request_queue *q, struct bio *bio, struct scatterlist *sglist);
```

### blk_integrity_compare

函数签名：
```c
int blk_integrity_compare(struct gendisk *gd1, struct gendisk *gd2);
```

### blk_integrity_register

函数签名：
```c
void blk_integrity_register(struct gendisk *disk, struct blk_integrity *template);
```

### blk_integrity_unregister

函数签名：
```c
void blk_integrity_unregister(struct gendisk *disk);
```

### blk_trace_ioctl

函数签名：
```c
int blk_trace_ioctl(struct block_device *bdev, unsigned cmd, char __user *arg);
```

### blk_trace_shutdown

函数签名：
```c
void blk_trace_shutdown(struct request_queue *q);
```

### blk_add_trace_rq

函数签名：
```c
void blk_add_trace_rq(struct request *rq, blk_status_t error, unsigned int nr_bytes, u32 what, u64 cgid);
```

### blk_add_trace_bio

函数签名：
```c
void blk_add_trace_bio(struct request_queue *q, struct bio *bio, u32 what, int error);
```

### blk_add_trace_bio_remap

函数签名：
```c
void blk_add_trace_bio_remap(void *ignore, struct bio *bio, dev_t dev, sector_t from);
```

### blk_add_trace_rq_remap

函数签名：
```c
void blk_add_trace_rq_remap(void *ignore, struct request *rq, dev_t dev, sector_t from);
```

### disk_release

函数签名：
```c
void disk_release(struct device *dev);
```

### __register_blkdev

函数签名：
```c
int __register_blkdev(unsigned int major, const char *name, void (*probe)(dev_t devt));
```

### device_add_disk

函数签名：
```c
int device_add_disk(struct device *parent, struct gendisk *disk, const struct attribute_group **groups);
```

### blk_mark_disk_dead

函数签名：
```c
void blk_mark_disk_dead(struct gendisk *disk);
```

### del_gendisk

函数签名：
```c
void del_gendisk(struct gendisk *disk);
```

### invalidate_disk

函数签名：
```c
void invalidate_disk(struct gendisk *disk);
```

### put_disk

函数签名：
```c
void put_disk(struct gendisk *disk);
```

### set_disk_ro

函数签名：
```c
void set_disk_ro(struct gendisk *disk, bool read_only);
```

### freeze_bdev

函数签名：
```c
int freeze_bdev(struct block_device *bdev);
```

### thaw_bdev

函数签名：
```c
int thaw_bdev(struct block_device *bdev);
```

### bd_prepare_to_claim

函数签名：
```c
int bd_prepare_to_claim(struct block_device *bdev, void *holder);
```

### bd_abort_claiming

函数签名：
```c
void bd_abort_claiming(struct block_device *bdev, void *holder);
```

### blkdev_get_by_dev

函数签名：
```c
struct block_device *blkdev_get_by_dev(dev_t dev, fmode_t mode, void *holder);
```

### blkdev_get_by_path

函数签名：
```c
struct block_device *blkdev_get_by_path(const char *path, fmode_t mode, void *holder);
```

### lookup_bdev

函数签名：
```c
int lookup_bdev(const char *pathname, dev_t *dev);
```

## 字符设备(Char devices)

### register_chrdev_region

函数签名：
```c
int register_chrdev_region(dev_t from, unsigned count, const char *name);
```

### alloc_chrdev_region

函数签名：
```c
int alloc_chrdev_region(dev_t *dev, unsigned baseminor, unsigned count, const char *name);
```

### __register_chrdev

函数签名：
```c
int __register_chrdev(unsigned int major, unsigned int baseminor, unsigned int count, const char *name, const struct file_operations *fops);
```

### unregister_chrdev_region

函数签名：
```c
void unregister_chrdev_region(dev_t from, unsigned count);
```

### __unregister_chrdev

函数签名：
```c
void __unregister_chrdev(unsigned int major, unsigned int baseminor, unsigned int count, const char *name);
```

### chdev_add

函数签名：
```c
int cdev_add(struct cdev *p, dev_t dev, unsigned count);
```

### chdev_set_parent

函数签名：
```c
void cdev_set_parent(struct cdev *p, struct kobject *kobj);
```

### cdev_device_add

函数签名：
```c
int cdev_device_add(struct cdev *cdev, struct device *dev);
```

### cdev_device_del

函数签名：
```c
void cdev_device_del(struct cdev *cdev, struct device *dev);
```

### cdev_del

函数签名：
```c
void cdev_del(struct cdev *p);
```

### cdev_alloc

函数签名：
```c
struct cdev *cdev_alloc(void);
```

### cdev_init

函数签名：
```c
void cdev_init(struct cdev *cdev, const struct file_operations *fops);
```

## 时钟周期

时钟框架定义了编程接口，以支持系统时钟树的软件管理。该框架广泛应用于片上系统(SOC)平台，以支持电源管理和可能需要自定义时钟速率的各种设备。请注意，这些“时钟”与计时或实时时钟(rtc)无关，它们都有单独的框架。这些struct clock实例可用于管理例如96 MHz信号，该信号用于将位移进和移出外设或总线，或者触发系统硬件中的同步状态机转换。

电源管理由显式软件时钟门控支持:未使用的时钟被禁用，因此系统不会浪费功率来改变不活跃使用的晶体管的状态。在某些系统上，这可能是由硬件时钟门控支持的，其中时钟是门控的，而不是在软件中禁用。有电源但没有时钟的芯片部分可能能够保持它们的最后状态。这种低功耗状态通常被称为保持模式。这种模式仍然会产生漏电流，特别是对于更精细的电路几何形状，但对于CMOS电路，功率主要用于时钟状态变化。

电源感知驱动程序只有在其管理的设备处于活跃使用状态时才启用时钟。此外，系统睡眠状态通常根据哪些时钟域处于活动状态而有所不同:虽然“待机”状态可能允许从几个活动域唤醒，但“mem”(挂起到ram)状态可能需要更大规模地关闭来自更高速度锁相环和振荡器的时钟，从而限制了可能的唤醒事件源的数量。驱动程序的suspend方法可能需要知道目标睡眠状态上的系统特定时钟约束。

一些平台支持可编程时钟生成器。这些可用于各种外部芯片，如其他cpu、多媒体编解码器和对接口时钟有严格要求的设备。

### clk_notifier

定义：
```c
struct clk_notifier 
{
  struct clk                      *clk;
  struct srcu_notifier_head       notifier_head;
  struct list_head                node;
};
```

### clk_notifier_data

定义：
```c
struct clk_notifier_data 
{
  struct clk              *clk;
  unsigned long           old_rate;
  unsigned long           new_rate;
};
```

### clk_bulk_data

定义：
```c
struct clk_bulk_data 
{
  const char              *id;
  struct clk              *clk;
};
```

### clk_notifier_register

函数签名：
```c
int clk_notifier_register(struct clk *clk, struct notifier_block *nb);
```

### clk_notifier_unregister

函数签名：
```c
int clk_notifier_unregister(struct clk *clk, struct notifier_block *nb);
```

### devm_clk_notifier_register

函数签名：
```c
int devm_clk_notifier_register(struct device *dev, struct clk *clk, struct notifier_block *nb);
```

### clk_get_accuracy

函数签名：
```c
long clk_get_accuracy(struct clk *clk);
```

### clk_set_phase

函数签名：
```c
int clk_set_phase(struct clk *clk, int degrees);
```

### clk_get_phase

函数签名：
```c
int clk_get_phase(struct clk *clk);
```

### clk_set_duty_cycle

函数签名：
```c
int clk_set_duty_cycle(struct clk *clk, unsigned int num, unsigned int den);
```

### clk_get_scaled_duty_cycle

函数签名：
```c
int clk_get_scaled_duty_cycle(struct clk *clk, unsigned int scale);
```

### clk_is_match

函数签名：
```c
bool clk_is_match(const struct clk *p, const struct clk *q);
```

### clk_rate_exclusive_get

函数签名：
```c
int clk_rate_exclusive_get(struct clk *clk);
```

### clk_rate_exclusive_put

函数签名：
```c
void clk_rate_exclusive_put(struct clk *clk);
```

### clk_prepare

函数签名：
```c
int clk_prepare(struct clk *clk);
```

### clk_is_enable_when_prepared

函数签名：
```c
bool clk_is_enabled_when_prepared(struct clk *clk);
```

### clk_unprepare

函数签名：
```c
void clk_unprepare(struct clk *clk);
```

### clk_get

函数签名：
```c
struct clk *clk_get(struct device *dev, const char *id);
```

### clk_bulk_get

函数签名：
```c
int clk_bulk_get(struct device *dev, int num_clks, struct clk_bulk_data *clks);
```

### clk_bulk_get_all

函数签名：
```c
int clk_bulk_get_all(struct device *dev, struct clk_bulk_data **clks);
```

### clk_bulk_get_optional

函数签名：
```c
int clk_bulk_get_optional(struct device *dev, int num_clks, struct clk_bulk_data *clks);
```

### devm_clk_bulk_get

函数签名：
```c
int devm_clk_bulk_get(struct device *dev, int num_clks, struct clk_bulk_data *clks);
```

### devm_clk_bulk_get_optional

函数签名：
```c
int devm_clk_bulk_get_optional(struct device *dev, int num_clks, struct clk_bulk_data *clks);
```

### devm_clk_bulk_get_all

函数签名：
```c
int devm_clk_bulk_get_all(struct device *dev, struct clk_bulk_data **clks);
```

### devm_clk_get

函数签名：
```c
struct clk *devm_clk_get(struct device *dev, const char *id);
```

### devm_clk_get_prepared

函数签名：
```c
struct clk *devm_clk_get_prepared(struct device *dev, const char *id);
```

### devm_clk_get_enabled

函数签名：
```c
struct clk *devm_clk_get_enabled(struct device *dev, const char *id);
```

### devm_clk_get_optional

函数签名：
```c
struct clk *devm_clk_get_optional(struct device *dev, const char *id);
```

### devm_clk_get_optional_prepared

函数签名：
```c
struct clk *devm_clk_get_optional_prepared(struct device *dev, const char *id);
```

### devm_clk_get_optional_enabled

函数签名：
```c
struct clk *devm_clk_get_optional_enabled(struct device *dev, const char *id);
```

### devm_get_clk_from_child

函数签名：
```c
struct clk *devm_get_clk_from_child(struct device *dev, struct device_node *np, const char *con_id);
```

### clk_enable

函数签名：
```c
int clk_enable(struct clk *clk);
```

### clk_bulk_enable

函数签名：
```c
int clk_bulk_enable(int num_clks, const struct clk_bulk_data *clks);
```

### clk_disable

函数签名：
```c
void clk_disable(struct clk *clk);
```

### clk_bulk_disable

函数签名：
```c
void clk_bulk_disable(int num_clks, const struct clk_bulk_data *clks);
```

### clk_get_rate

函数签名：
```c
unsigned long clk_get_rate(struct clk *clk);
```

### clk_put

函数签名：
```c
void clk_put(struct clk *clk);
```

### clk_bulk_put

函数签名：
```c
void clk_bulk_put(int num_clks, struct clk_bulk_data *clks);
```

### clk_bulk_put_all

函数签名：
```c
void clk_bulk_put_all(int num_clks, struct clk_bulk_data *clks);
```

### devm_clk_put

函数签名：
```c
void devm_clk_put(struct device *dev, struct clk *clk);
```

### clk_round_rate

函数签名：
```c
long clk_round_rate(struct clk *clk, unsigned long rate);
```

### clk_set_rate

函数签名：
```c
int clk_set_rate(struct clk *clk, unsigned long rate);
```

### clk_set_rate_exclusive

函数签名：
```c
int clk_set_rate_exclusive(struct clk *clk, unsigned long rate);
```

### clk_has_parent

函数签名：
```c
bool clk_has_parent(const struct clk *clk, const struct clk *parent);
```

### clk_set_rate_range

函数签名：
```c
int clk_set_rate_range(struct clk *clk, unsigned long min, unsigned long max);
```

### clk_set_min_rate

函数签名：
```c
int clk_set_min_rate(struct clk *clk, unsigned long rate)
```

### clk_set_max_rate

函数签名：
```c
int clk_set_max_rate(struct clk *clk, unsigned long rate);
```

### clk_set_parent

函数签名：
```c
int clk_set_parent(struct clk *clk, struct clk *parent);
```

### clk_get_parent

函数签名：
```c
struct clk *clk_get_parent(struct clk *clk);
```

### clk_get_sys

函数签名：
```c
struct clk *clk_get_sys(const char *dev_id, const char *con_id);
```

### clk_save_context

函数签名：
```c
int clk_save_context(void);
```

### clk_restore_context

函数签名：
```c
void clk_restore_context(void);
```

### clk_drop_range

函数签名：
```c
int clk_drop_range(struct clk *clk);
```

### clk_get_optional

函数签名：
```c
struct clk *clk_get_optional(struct device *dev, const char *id);
```



