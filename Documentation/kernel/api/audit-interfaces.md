# 审计接口

## audit_log_start

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

## audit_log_format

函数签名：
```c
void audit_log_format(struct audit_buffer *ab, const char *fmt, ...);
```

说明：

参数：
- `ab`：
- `fmt`：
- `...`：

## audit_log_end

函数签名：
```c
void audit_log_end(struct audit_buffer *ab);
```

说明：

参数：
- `ab`：

## audit_log

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

## audit_filter_uring

函数签名：
```c
void audit_filter_uring(struct task_struct *tsk, struct audit_context *ctx);
```

说明：

参数：
- `tsk`：
- `ctx`：

## audit_reset_context

函数签名：
```c
void audit_reset_context(struct audit_context *ctx);
```

说明：

参数：
- `ctx`：

## audit_alloc

函数签名：
```c
int audit_alloc(struct task_struct *tsk);
```

说明：

参数：
- `tsk`：

## audit_log_uring

函数签名：
```c
void audit_log_uring(struct audit_context *ctx);
```

说明：

参数：
- `ctx`：

## __audit_free

函数签名：
```c
void __audit_free(struct task_struct *tsk);
```

说明：

参数：
- `tsk`：

## audit_return_fixup

函数签名：
```c
void audit_return_fixup(struct audit_context *ctx, int success, long code);
```

说明：

参数：
- `ctx`：
- `success`：
- `code`：

## __audit_uring_entry

函数签名：
```c
void __audit_uring_entry(u8 op);
```

说明：

参数：

## __audit_uring_exit

函数签名：
```c
void __audit_uring_exit(int success, long code);
```

说明：

参数：
- `success`：
- `code`：

## __audit_syscall_entry

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

## __audit_syscall_exit

函数签名：
```c
void __audit_syscall_exit(int success, long return_code);
```

说明：

参数：
- `success`：
- `return_code`：

## __audit_reusename

函数签名：
```c
struct filename *__audit_reusename(__user const char *uptr);
```

说明：

参数：
- `uptr`：

## __audit_getname

函数签名：
```c
void __audit_getname(struct filename *name);
```

说明：

参数：
- `name`：

## __audit_inode

函数签名：
```c
void __audit_inode(struct filename *name, const struct dentry *dentry, unsigned int flags);
```

说明：

参数：
- `name`：
- `dentry`：
- `flags`：

## auditsc_get_stamp

函数签名：
```c
int auditsc_get_stamp(struct audit_context *ctx, struct timespec64 *t, unsigned int *serial);
```

说明：

参数：
- `ctx`：
- `t`：
- `serial`：

## __audit_mq_open

函数签名：
```c
void __audit_mq_open(int oflag, umode_t mode, struct mq_attr *attr);
```

## __audit_mq_sendrecv

函数签名：
```c
void __audit_mq_sendrecv(mqd_t mqdes, size_t msg_len, unsigned int msg_prio, const struct timespec64 *abs_timeout);
```

## __audit_mq_notify

函数签名：
```c
void __audit_mq_notify(mqd_t mqdes, const struct sigevent *notification);
```

## __audit_mq_getsetattr

函数签名：
```c
void __audit_mq_getsetattr(mqd_t mqdes, struct mq_attr *mqstat);
```

## __audit_ipc_obj

函数签名：
```c
void __audit_ipc_obj(struct kern_ipc_perm *ipcp);
```

## __audit_ipc_set_perm

函数签名：
```c
void __audit_ipc_set_perm(unsigned long qbytes, uid_t uid, gid_t gid, umode_t mode);
```

## __audit_socketcall

函数签名：
```c
int __audit_socketcall(int nargs, unsigned long *args);
```

## __audit_fd_pair

函数签名：
```c
void __audit_fd_pair(int fd1, int fd2);
```

## __audit_sockaddr

函数签名：
```c
int __audit_sockaddr(int len, void *a);
```

## audit_signal_info_syscall

函数签名：
```c
int audit_signal_info_syscall(struct task_struct *t);
```

## __audit_log_bprm_fcaps

函数签名：
```c
int __audit_log_bprm_fcaps(struct linux_binprm *bprm, const struct cred *new, const struct cred *old);
```

## __audit_log_capset

函数签名：
```c
void __audit_log_capset(const struct cred *new, const struct cred *old);
```

## audit_core_dumps

函数签名：
```c
void audit_core_dumps(long signr);
```

## audit_seccomp

函数签名：
```c
void audit_seccomp(unsigned long syscall, long signr, int code);
```

## audit_rule_change

函数签名：
```c
int audit_rule_change(int type, int seq, void *data, size_t datasz);
```

## audit_list_rules_send

函数签名：
```c
int audit_list_rules_send(struct sk_buff *request_skb, int seq);
```

## parent_len

函数签名：
```c
int parent_len(const char *path);
```

## audit_compare_dname_path

函数签名：
```c
int audit_compare_dname_path(const struct qstr *dname, const char *path, int parentlen);
```

