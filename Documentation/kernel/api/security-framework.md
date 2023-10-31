# Security Framework

## security_init

函数签名：
```c
int security_init(void);
```

说明：

## security_add_hooks

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

## lsm_cred_alloc

函数签名：
```c
int lsm_cred_alloc(struct cred *cred, gfp_t gfp);
```

说明：
分配一个 struct cred 块

参数：
- `cred`：
- `gfp`：

## lsm_early_cred

函数签名：
```c
void lsm_early_cred(struct cred *cred);
```

说明：
在初始化中分配一个 `struct cred`

参数：
- `cred`

## lsm_file_alloc

函数签名：
```c
int lsm_file_alloc(struct file *file);
```

说明：

参数：
- `file`：

## lsm_inode_alloc

函数签名：
```c
int lsm_inode_alloc(struct inode *inode);
```

说明：

参数：
- `inode`：

## lsm_task_alloc

函数签名：
```c
int lsm_task_alloc(struct task_struct *task);
```

## lsm_ipc_alloc

函数签名：
```c
int lsm_ipc_alloc(struct kern_ipc_perm *kip);
```

## lsm_msg_msg_alloc

函数签名：
```c
int lsm_msg_msg_alloc(struct msg_msg *mp);
```

## lsm_early_task

函数签名：
```c
void lsm_early_task(struct task_struct *task);
```

## lsm_superblock_alloc

函数签名：
```c
int lsm_superblock_alloc(struct super_block *sb);
```

## security_fs_context_submount

函数签名：
```c
int security_fs_context_submount(struct fs_context *fc, struct super_block *reference);
```

参数：
- `fc`：
- `reference`：

## securityfs_create_file

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

## securityfs_create_dir

函数签名：
```c
struct dentry *securityfs_create_dir(const char *name, struct dentry *parent);
```

参数：
- `name`：
- `parent`：

## securityfs_create_symlink

函数签名：
```c
struct dentry *securityfs_create_symlink(const char *name, struct dentry *parent, const char *target, const struct inode_operations *iops);
```

参数：
- `name`：
- `parent`：
- `target`：
- `iops`：

## securityfs_remove

函数签名：
```c
void securityfs_remove(struct dentry *dentry);
```

参数：
- `dentry`：


