# IPC

## ipc_init

函数签名：
```c
int ipc_init(void);
```

说明：
初始化 ipc 子系统。初始化各种sysv ipc 资源（信号量、消息和共享内存）

返回值：

参数：

## ipc_init_ids

函数签名：
```c
void ipc_init_ids(struct ipc_ids* ids);
```

说明：
初始化IPC标识符

返回值：

参数：
- `ids`：ipc标识符集合

## ipc_init_proc_interface

函数签名：
```c
void ipc_init_proc_interface(const char *path, const char *header, int ids, int (*show)(struct seq_file*, void*));
```

说明：
使用 seq_file 接口为 sysipc 类型创建一个进程接口

返回值：
无

参数：
- `path`：procfs 中的路径
- `header`：要打印在文件开头的提示语
- `ids`：ipc id表的位置
- `show`：显示程序

## ipc_findkey

函数签名：
```c
struct kern_ipc_perm *ipc_findkey(struct ipc_ids *ids, key_t key);
```

说明：
在 ipc 描述符集合中查找一个 key。如果找到，返回ipc结构的锁定指针，否则返回NULL。如果找到了key, ipc指向所属的ipc结构。

返回值：

参数：
- `ids`：ipc 描述符集合
- `key`：要查找的key

## ipc_addid

函数签名：
```c
int ipc_addid(struct ipc_ids *ids, struct kern_ipc_perm *new, int limit);
```

说明：
在 ipc 描述符集合中添加一个描述符

返回值：

参数：
- `ids`：描述符集合
- `new`：要加入的描述符
- `limit`：使用id的数量限制

## ipcget_new

函数签名：
```c
int ipcget_new(struct ipc_namespace *ns, struct ipc_ids *ids, const struct ipc_ops *ops, struct ipc_params *params);
```

说明：
创建一个新的 ipc 对象。

当key为`IPC_PRIVATE`时，这个例程由`sys_msgget`、`sys_semget()`和`sys_shmget()`调用。

返回值：

参数：
- `ns`：ipc命名空间
- `ids`：ipc 描述符集合
- `ops`：由创建例程调用
- `params`：参数

## ipc_check_perms

函数签名：
```c
int ipc_check_perms(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp, const struct ipc_ops *ops, struct ipc_params *params);
```

说明：
检查 ipc 对象的安全性和权限

当key不是`IPC_PRIVATE`并且该key已经存在于`ds IDR`中时，`sys_msgget()`、`sys_semget()`和`sys_shmget()`调用这个例程。

返回值：
如果成功，则返回ipc id。

参数：
- `ns`：ipc命名空间
- `ipcp`：ipc权限集合
- `ops`：安全检查例程调用
- `params`：参数

## ipcget_public

函数签名：
```c
int ipcget_public(struct ipc_namespace *ns, struct ipc_ids *ids, const struct ipc_ops *ops, struct ipc_params *params);
```

说明：
获取ipc对象或者创建一个新对象

当key不是`IPC_PRIVATE`时，这个例程由`sys_msgget`、`sys_semget()`和`sys_shmget()`调用。如果没有找到密钥，则添加一个新条目，如果找到密钥，则执行一些权限/安全检查。

返回值：
如果成功，则返回ipc id。

返回值：

参数：
- `ns`：ipc命名空间
- `ids`：ipc描述符集合
- `ops`：创建例程将调用
- `params`：参数

## ipc_kht_remove

函数签名：
```c
void ipc_kht_remove(struct ipc_ids *ids, struct kern_ipc_perm *ipcp);
```

说明：
从key hashtable中删除一个ipc

返回值：

参数：
- `ids`：ipc描述符集合
- `ipcp`：包含要删除的key的ipc权限结构体

## ipc_search_maxidx

函数签名：
```c
int ipc_search_maxidx(struct ipc_ids *ids, int limit);
```

说明：
搜索分配的最高索引

返回值：

参数：
- `ids`：ipc描述符集合
- `limit`：已分配索引最大值

## ipc_rmid

函数签名：
```c
void ipc_rmid(struct ipc_ids *ids, struct kern_ipc_perm *ipcp);
```

说明：
删除一个ipc描述符

返回值：

参数：
- `ids`：ipc描述符集合
- `ipcp`：包含要删除的标识符的结构

## ipc_set_key_private

函数签名：
```c
void ipc_set_key_private(struct ipc_ids *ids, struct kern_ipc_perm *ipcp);
```

说明：
将现有 ipc 的key转换为 `IPC_PRIVATE`

返回值：

参数：
- `ids`：ipc描述符集合
- `ipcp`：要修改的ipc

## ipcperms

函数签名：
```c
int ipcperms(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp, short flag);
```

说明：
检查ipc权限

返回值：

参数：
- `ns`：ipc 命名空间
- `ipcp`：要设置的权限
- `flag`：要设置什么权限

检查用户、组和其他访问ipc资源的权限。如果允许，返回0。

## kernel_to_ipc64_perm

函数签名：
```c
void kernel_to_ipc64_perm(struct kern_ipc_perm *in, struct ipc64_perm *out);
```

说明：
将内核 ipc 权限转换到用户空间权限

将内核对象in转换为一组权限描述，用于返回用户空间(out)。

返回值：

参数：
- `in`：内核 ipc 权限
- `out`：新式的ipc权限

## ipc64_perm_to_ipc_perm

函数签名：
```c
void ipc64_perm_to_ipc_perm(struct ipc64_perm *in, struct ipc_perm *out);
```

说明：
将新权限对象转换为兼容的就权限对象

返回值：

参数：
- `in`：新式的ipc权限
- `out`：旧式的ipc权限

## ipc_obtain_object_idr

函数签名：
```c
struct kern_ipc_perm *ipc_obtain_object_idr(struct ipc_ids *ids, int id);
```

说明：
在ipc id idr中查找id并返回相关的ipc对象。

在RCU临界区内调用。ipc对象在退出时不被锁定。

返回值：

参数：
- `ids`：ipc描述符集合
- `id`：要查找的ipc

## ipc_obtain_object_check

函数签名：
```c
struct kern_ipc_perm *ipc_obtain_object_check(struct ipc_ids *ids, int id);
```

说明：
类似 `ipc_obtain_object_idr()`，在次基础上还要检查id

返回值：

参数：
- `ids`：ipc描述符集合
- `id`：要查找的ipc id

## ipcget

函数签名：
```c
int ipcget(struct ipc_namespace *ns, struct ipc_ids *ids, const struct ipc_ops *ops, struct ipc_params *params);
```

说明：
在 `sys_msgget()`、`sys_semget()`、`sys_shmget()`调用时候被调用

返回值：

参数：
- `ns`：命名空间
- `ids`：ipc描述符集合
- `ops`：在ipc对象创建、权限检查和进一步检查时候调用的操作
- `params`：上述操作所需的参数

## ipc_update_perm

函数签名：
```c
int ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out);
```

说明：
更新 ipc 对象的权限信息

返回值：

参数：
- `in`：输入的参数
- `out`：要设置的ipc

## ipcctl_obtain_check

函数签名：
```c
struct kern_ipc_perm *ipcctl_obtain_check(struct ipc_namespace *ns, struct ipc_ids *ids, int id, int cmd, struct ipc64_perm *perm, int extra_perm);
```

说明：
检索ipc对象并检查权限

返回值：

参数：
- `ns`：ipc命名空间
- `ids`：要查找ipc的ipc描述符表
- `id`：要查找的id
- `cmd`：要检查的cmd
- `perm`：要设置的权限
- `extra_perm`：msq使用的额外权限参数

## ipc_parse_version

函数签名：
```c
int ipc_parse_version(int *cmd);
```

说明：
ipc版本

参数：
- `cmd`：

## `sysvipc_find_ipc`

函数签名：
```c
struct kern_ipc_perm *sysvipc_find_ipc(struct ipc_ids *ids, loff_t *pos);
```

说明：
根据顺序查找和锁定ipc结构

该函数根据序列文件位置查找ipc结构，如果`pos`位置没有ipc结构，则向后查找。如果找到一个结构，那么它将被锁定(`rcu_read_lock()`和`ipc_lock_object()`)，并且pos被设置为找到ipc结构所需的位置。如果没有找到(即EOF)，则不修改`pos`。

该函数返回找到的ipc结构，或者在EOF时返回NULL。

返回值：

参数：
- `ids`：ipc描述符集合
- `pos`：预期的位置

