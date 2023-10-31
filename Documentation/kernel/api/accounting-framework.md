# Accounting Framework

## sys_acct

函数签名：
```c
long sys_acct(const char __user *name);
```

说明：

参数：
- `name`：

## acct_collect

函数签名：
```c
void acct_collect(long exitcode, int group_dead);
```

## acct_process

函数签名：
```c
void acct_process(void);
```

