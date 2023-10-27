# 字符串转换(String Conversions)

## `simple_strtoull`

函数签名：
```c
unsigned long long simple_strtoull(const char *cp, char **endp, unsigned int base);
```

说明：
从字符串`cp`位置开始将字符串转换为 `unsigned long long`，直到字符串无法转换

参数：
- `cp`: 要转换的字符串
- `endp`: 转换停止的位置，如果整个字符串都完成转换则和`cp`指向位置相同
- `base`: 要转换的进制，如果 0 表示自动转换，其它值分别是：2、8、10、16

## `simple_strtoul`

函数签名：
```c
unsigned long simple_strtoul(const char *cp, char **endp, unsigned int base);
```

说明：
同上

参数：
同上

## `simple_strtol`

函数签名：
```c
unsigned long simple_strtol(const char *cp, char **endp, unsigned int base);
```

说明：
同上

参数：
同上

## `simple_strtoll`

函数签名：
```c
unsigned long simple_strtoll(const char *cp, char **endp, unsigned int base);
```

说明：
同上

参数：
同上

## `vsnprintf`

函数签名：
```c
int vsnprintf(char *buf, size_t size, const char *fmt, va_list args);
```

说明：生成格式化字符串，将生成的字符串放入 buf

返回值：返回字符串长度，包含结束符`\0`

参数：
- `buf`: 保存字符串的 buffer
- `size`: 缓存区大小
- `fmt`: 格式化
- `args`: 可变参数

## `vscnprintf`

函数签名：
```c
int vscnprintf(char *buf, size_t size, const char *fmt, va_list args)
```

说明：生成格式化字符串，将生成的字符串放入 buf
返回值：返回字符串长度，不包含结束符`\0`

参数：
- `buf`: 保存字符串的 buffer
- `size`: 缓存区大小
- `fmt`: 格式化
- `args`: 可变参数

## `snprintf`

函数签名：
```c
int snprintf(char *buf, size_t size, const char *fmt, ...)
```

说明：生成格式化字符串，将生成的字符串放入 buf
返回值：返回字符串长度，包含结束符`\0`

参数：
- `buf`: 保存字符串的 buffer
- `size`: 缓存区大小
- `fmt`: 格式化
- `...`: 可变参数

## `scnprintf`

函数签名：
```c
int scnprintf(char *buf, size_t size, const char *fmt, ...)
```

说明：生成格式化字符串，将生成的字符串放入 buf
返回值：返回字符串长度，不包含结束符`\0`

参数：
- `buf`: 保存字符串的 buffer
- `size`: 缓存区大小
- `fmt`: 格式化
- `...`: 可变参数

## `vsprintf`

函数签名：
```c
int vsprintf(char *buf, const char *fmt, va_list args)
```
说明：生成格式化字符串，将生成的字符串放入 buf
返回值：

参数：
- `buf`: 保存字符串的 buffer
- `fmt`: 格式化
- `args`: 可变参数

## `sprintf`

函数签名：
```c
int sprintf(char *buf, const char *fmt, ...);
```

说明：生成格式化字符串，将生成的字符串放入 buf
返回值：

参数：
- `buf`: 保存字符串的 buffer
- `fmt`: 格式化
- `...`: 可变参数

## `vbin_printf`

函数签名：
```c
int vbin_printf(u32 *bin_buf, size_t size, const char *fmt, va_list args);
```

说明：解析格式字符串并将args的二进制值放入缓冲区(`bin_buf`)中
返回值：

参数：
- `bin_buf`: 保存字符串的 buffer
- `size`: 缓存区大小
- `fmt`: 格式化
- `args`: 可变参数
> 如果返回值大于size，则结果`bin_buf`对`bstr_printf`无效。

## `bstr_printf`

函数签名：
```c
int bstr_printf(char *buf, size_t size, const char *fmt, const u32 *bin_buf);
```

说明：
从二进制参数中格式化字符串并将其放入缓冲区中

返回值：

参数：
- `bin_buf`: 保存字符串的 buffer
- `size`: 缓存区大小
- `fmt`: 格式化
- `args`: 可变参数

## `bprintf`

函数签名：
```c
int bprintf(u32 *bin_buf, size_t size, const char *fmt, ...)
```

说明：
解析格式字符串并将args的二进制值放入缓冲区中

返回值：

参数：
- `bin_buf`:
- `size`:
- `fmt`:
- `...`:

## `vsscanf`

函数签名：
```c
int vsscanf(const char *buf, const char *fmt, va_list args)
```

说明：
将缓存区格式化为参数列表

返回值：

参数：
- `buf`:
- `fmt`:
- `args`:

## `sscanf`

函数签名：
```c
int sscanf(const char *buf, const char *fmt, ...);
```

说明：
将缓存区格式化为参数列表

返回值：

参数：
- `buf`:
- `fmt`:
- `...`:

## `kstrtoul`

函数签名：
```c
int kstrtoul(const char *s, unsigned int base, unsigned long *res)
```

说明：
将字符串转为`unsigned long`，

返回值：

参数：
- `s`: 要转换的字符串，字符串第一个字符可以是`+`，决不可以是`-`
- `base`: 要使用的进制
- `res`: 转换结果

## `kstrtol`

函数签名：
```c
int kstrtol(const char *s, unsigned int base, long *res);
```

说明：
将字符串转为`long`，

返回值：

参数：
- `s`: 要转换的字符串，字符串第一个字符可以是`+`，可以是`-`
- `base`: 要使用的进制
- `res`: 转换结果

## `kstrtoull`

函数签名：
```c
int kstrtoull(const char *s, unsigned int base, unsigned long long *res);
```

说明：
将字符串转为`unsigned long long`

返回值：

参数：
- `s`:
- `base`:
- `res`:

## `kstrtoll`

函数签名：
```c
int kstrtoll(const char *s, unsigned int base, long long *res);
```

说明：
将字符串转为`long long`

返回值：

参数：
- `s`:
- `base`:
- `res`:

## `kstrtouint`

函数签名：
```c
int kstrtouint(const char *s, unsigned int base, unsigned int *res);
```

说明：

返回值：

参数：
- `s`:
- `base`:
- `res`:

## `kstrtoint`

函数签名：
```c
int kstrtoint(const char *s, unsigned int base, int *res);
```

说明：

返回值：

参数：
- `s`:
- `base`:
- `res`:

## `kstrtobool`

函数签名：
```c
int kstrtobool(const char *s, bool *res);
```

说明：
将字符串转为 `boolean` 值

返回值：

参数：
- `s`:
- `res`:

## `string_get_size`

函数签名：
```c
void string_get_size(u64 size, u64 blk_size, const enum string_size_units units, char *buf, int len);
```

说明：
获取指定的`units`的大小

返回值：

参数：
- `size`: 以块`size`为单位大小进行转换
- `blk_size`: 块大小(使用1表示以字节为大小)
- `units`: 使用的单位（支持 1000 或 1024）
- `buf`: 格式化输出的缓存区位置
- `len`: 缓存区大小

## `parse_int_array_user`

函数签名：
```c
int parse_int_array_user(const char __user *from, size_t count, int **array);
```

说明：
将字符串切为一系列整数

返回值：

参数：
- `from`:
- `count`:
- `array`:

## `string_unescape`

函数签名：
```c
int string_unescape(char *src, char *dst, size_t size, unsigned int flags);
```

说明：

返回值：

参数：
- `str`:
- `dst`:
- `size`:
- `flags`:

## `string_escape_mem`

函数签名：
```c
int string_escape_mem(const char *src, size_t isz, char *dst, size_t osz, unsigned int flags, const char *only);
```

说明：

返回值：

参数：
- `src`: 要转换的buffer(unescaped)
- `isz`: 要转换buffer的大小
- `dst`: 目标buffer(escaped)
- `osz`: 目标buffer的大小
- `flags`: 
- `only`: 以空结尾的字符串，其中包含用于限制所选转义类的字符。如果字符只包含在标记中选择的类通常不会转义的字符中，则它们将被复制到未转义的字符中。

## `kasprintf_strarray`

函数签名：
```c
char **kasprintf_strarray(gfp_t gfp, const char *prefix, size_t n);
```

说明：

返回值：

参数：
- `gfp`:
- `prefix`:
- `n`:

## `kfree_strarray`

函数签名：
```c
void kfree_strarray(char **array, size_t n);
```

说明：

返回值：

参数：
- `array`:
- `n`:

## `strscpy_pad`

函数签名：
```c
ssize_t strscpy_pad(char *dest, const char *src, size_t count);
```

说明：
将 C string 复制到 buffer

返回值：

参数：
- `dest`: 要复制到的目标 buffer
- `src`: 要复制的 C string 源
- `count`: 目标 buffer 的大小

## `skip_spaces`

函数签名：
```c
char *skip_spaces(const char *str);
```

说明：
删除字符串之前的空格

返回值：
返回删除字符串前空格的字符串

参数：
- `str`: 要处理的字符串

## `strim`

函数签名：
```c
char *strim(char *s);
```

说明：
删除字符串首尾的空格

返回值：

参数：
- `str`: 要处理的字符串

## `sysfs_streq`

函数签名：
```c
bool sysfs_streq(const char *s1, const char *s2);
```

说明：
比较两个字符串（会删除字符串中的换行符）

返回值：
字符串相同则返回`true`

参数：
- `s1`:
- `s2`:

## `match_string`

函数签名：
```c
int match_string(const char *const *array, size_t n, const char *string);
```

说明：
匹配数组中给定的字符串

返回值：
- 如果找到，返回字符串在数组中的索引位置
- 如果没找到，返回 `-EINVAL`

参数：
- `array`: 字符串数组
- `n`: 字符串数组中的值，如果传入 -1，则字符串数组以`NULL`结束
- `string`: 要匹配的字符串

## `__sysfs_match_string`

函数签名：
```c
int __sysfs_match_string(const char *const *array, size_t n, const char *str);
```

说明：
在字符串数组中匹配给定字符串

返回值：

参数：
- `array`: 字符串数组
- `n`: 字符串数组中的值，如果传入 -1，则字符串数组以`NULL`结束
- `string`: 要匹配的字符串

## `strreplace`

函数签名：
```c
char *strreplace(char *s, char old, char new);
```

说明：
替换字符串中出现的所有字符

返回值：

参数：
- `s`: 要操作的字符串
- `old`: 被替换的字符串
- `new`: 要替换`old`的字符串

## `memcpy_and_pad`

函数签名：
```c
void memcpy_and_pad(void *dest, size_t dest_len, const void *src, size_t count, int pad);
```

说明：
字符串复制

返回值：
无

参数：
- `dest`: 目标缓存区
- `dest_len`: 目标缓存区大小
- `src`: 源缓存区
- `cout`: 源缓存区大小
- `pad`: 当有剩余空间时候，要填充的字符
