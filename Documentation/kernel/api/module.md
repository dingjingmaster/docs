# 模块

## __request_module

函数签名：
```c
int __request_module(bool wait, const char *fmt, ...);
```

说明：
尝试加载内核模块

参数：
- `wait`：是否等待操作完成
- `fmt`：模块名称的Printf格式字符串
- `...`：格式字符串中指定的参数

## 内部模块支持

Refer to the files in kernel/module/ for more information.


