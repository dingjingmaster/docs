# 字符串操作(String Manipulation)

## `strncasecmp`

函数签名：
```c
int strncasecmp(const char *s1, const char *s2, size_t len);
```

说明：
大小写不敏感的大小比较

返回值：

参数：
- `s1`:
- `s2`:
- `s3`: 要比较的最大字符数

## `strcpy`

函数参数：
```c
char *strcpy(char *dest, const char *src);
```

说明：
字符串复制

返回值：

参数：
- `dest`:
- `src`:

## `strncpy`

函数参数：
```c
char *strncpy(char *dest, const char *src, size_t count);
```

说明：
字符串复制

返回值：

参数：
- `dest`:
- `src`:
- `count`:

## `strlcpy`

函数签名：
```c
size_t strlcpy(char *dest, const char *src, size_t size);
```

说明：
将字符串复制到指定大小的缓存区

返回值：

参数：
- `dest`: 要复制到的位置
- `src`: 被复制的字符串
- `size`: 目标位置的大小

## `strscpy`

函数签名：
```c
ssize_t strscpy(char *dest, const char *src, size_t count);
```

说明：
将字符串复制到指定大小的缓存区

返回值：

参数：
- `dest`: 要复制到的位置
- `src`: 被复制的字符串
- `size`: 目标位置的大小

## `stpcpy`

函数签名：
```c
char *stpcpy(char *__restrict__ dest, const char *__restrict__ src);
```

说明：
将字符串从src复制到dest，返回指向dest新结束的指针，包括src的空结束符。可能会溢出。

返回值：

参数：
- `dest`:
- `src`:

## `strcat`

函数签名：
```c
char *strcat(char *dest, const char *src);
```

说明：
将一个以null结尾的字符串追加到另一个字符串

返回值：

参数：
- `dest`:
- `src`:

## `strncat`

函数签名：
```c
char *strncat(char *dest, const char *src, size_t count);
```

说明：
将长度限制为count的字符串追加到另一个字符串末尾

返回值：

参数：
- `dest`: 要追加的位置
- `src`: 被追加的buffer
- `count`: 被复制buffer 的长度

## `strlcat`

函数签名：
```c
size_t strlcat(char *dest, const char *src, size_t count);
```

说明：

返回值：

参数：
- `dest`
- `src`
- `count`

## `strcmp`

函数签名：
```c
int strcmp(const char *cs, const char *ct);
```

说明：
比较两个字符串大小

返回值：

参数：
- `cs`: 字符串1
- `ct`: 字符串2

## `strncmp`

函数签名：
```c
int strncmp(const char *cs, const char *ct, size_t count);
```

说明：
比较两个字符串大小

返回值：

参数：
- `cs`: 字符串1
- `ct`: 字符串2
- `count`: 要比较的字符串的最大长度

## `strchr`

函数签名：
```c
char *strchr(const char *s, int c);
```

说明：
查找字符串中第一次出现字符`c`的地方

返回值：

参数：
- `s`: 被查找的字符串
- `c`: 要查找的字符

## `strchrnul`

函数签名：
```c
char *strchrnul(const char *s, int c);
```

说明：
查找并返回字符串中的字符或字符串的结尾

返回值：

参数：
- `s`: 被查找的字符串
- `c`: 要查找的字符

## `strrchr`

函数签名：
```c
char *strrchr(const char *s, int c)
```

说明：

返回值：

参数：
- `s`:
- `c`:

## `strnchr`

函数签名：
```c
char *strnchr(const char *s, size_t count, int c);
```

说明：

返回值：

参数：
- `s`: 字符串
- `count`: 要搜索的字符数
- `c`: 要查找的字符

## `strlen`

函数签名：
```c
size_t strlen(const char *s);
```

说明：
计算字符串的长度

返回值：

参数：
- s: 要计算长度的字符串

## `strnlen`

函数签名：
```c
size_t strnlen(const char *s, size_t count);
```

说明：
获取字符串长度

返回值：

参数：
- `s`: 要计算长度的字符串
- `count`: 要查找的最大长度（这种应该在s是数组时候使用）

## `strspn`

函数签名：
```c
size_t strspn(const char *s, const char *accept);
```

说明：
在 `s` 中搜索 `accept` 子串，返回其在 `s` 中的位置

返回值：

参数：
- `s`: 被搜索的字符串
- `accept`: 要搜索的字符串

## `strcspn`

函数签名：
```c
size_t strcspn(const char *s, const char *reject);
```

说明：
在 `s` 中搜索不包含 `reject` 子串的位置

返回值：

参数：
- `s`: 被搜索的字符串
- `reject`: 要搜索的子串

## `strpbrk`

函数签名：
```c
char *strpbrk(const char *cs, const char *ct);
```

说明：
查找 `ct` 在 `cs` 中第一次出现的位置

返回值：

参数：
- `cs`: 被查找的字符串
- `ct`: 要查找的子串

## `strsep`

函数签名：
```c
char *strsep(char **s, const char *ct);
```

说明：
按 `ct` 切割字符串 `s`

返回值：

参数：
- `s`: 被切割的字符串
- `ct`: 切割符

## `memset`

函数签名：
```c
void *memset(void *s, int c, size_t count);
```

说明：
将首地址为 `s` 长度为 `count` 的内存用字符 `c` 填充

返回值：
无

参数：
- `s`: 被填充的内存首地址
- `c`: 被填充的字符
- `count`: 被填充的内存大小

## `memset16`

函数签名：
```c
void *memset16(uint16_t *s, uint16_t v, size_t count);
```

说明：
同上

返回值：
无

参数：
- `s`: 内存开始区域
- `v`: 要填充的值
- `count`: 内存大小

## `memset32`

函数签名：
```c
void *memset32(uint32_t *s, uint32_t v, size_t count);
```

说明：
同上

返回值：
无

参数：
- `s`: 内存开始区域
- `v`: 要填充的值
- `count`: 内存大小

## `memset64`

函数签名：
```c
void *memset64(uint64_t *s, uint64_t v, size_t count);
```

说明：
同上

返回值：
无

参数：
- `s`: 内存开始区域
- `v`: 要填充的值
- `count`: 内存大小

## `memcpy`

函数签名：
```c
void *memcpy(void *dest, const void *src, size_t count);
```

说明：
同上

返回值：
无

参数：
- `dest`:
- `src`:
- `count`:

## `memmove`

函数签名：
```c
void *memmove(void *dest, const void *src, size_t count);
```

说明：
将一个区域的内存复制到另一个区域

返回值：

参数：
- `dest`:
- `src`:
- `count`:

## `memcmp`

函数签名：
```c
__visible int memcmp(const void *cs, const void *ct, size_t count);
```

说明：

返回值：

参数：
- `cs`:
- `ct`:
- `count`:

## `bcmp`

函数签名：
```c
int bcmp(const void *a, const void *b, size_t len);
```

说明：

返回值：

参数：
- `a`:
- `c`:
- `len`:

## `memscan`

函数签名：
```c
void *memscan(void *addr, int c, size_t size);
```

说明：
在内存 `addr` 中查找字符 `c`

返回值：

参数：
- `addr`: 要查找的内存区域首地址
- `c`: 要查找的字符
- `size`: 内存区域的大小

## `strstr`

函数签名：
```c
char *strstr(const char *s1, const char *s2);
```

说明：

返回值：

参数：
- `s1`:
- `s2`:

## `strnstr`

函数签名：
```c
char *strnstr(const char *s1, const char *s2, size_t len);
```

说明：

返回值：

参数：
- `s1`:
- `s2`:
- `len`:

## `memchr`

函数签名：
```c
void *memchr(const void *s, int c, size_t n);
```

说明：
从内存`s`中查找字符`c`

返回值：

参数：
- `s`:
- `c`:
- `n`: 内存`s`的大小

## `memchr_inv`

函数签名：
```c
void *memchr_inv(const void *start, int c, size_t bytes);
```

说明：
从内存中找到不包含字符`c`的位置

参数：
- `start`: 内存起始地址
- `c`: 内存中查找不包含的字符`c`
- `bytes`: 内存大小

## `sysfs_match_string`

函数签名：
```c
sysfs_match_string (_a, _s);
```

说明：
在 `_a` 数组中匹配`_s`字符串

返回值：

参数：
- `_a`: 字符数组
- `_s`: 要查找的字符串

## `strstarts`

函数签名：
```c
bool strstarts(const char *str, const char *prefix);
```

说明：
检测字符串 `str` 是否以子串 `prefix` 开始 

返回值：

参数：
- `str`: 字符串
- `prefix`: 子串

## `memzero_explicit`

函数签名：
```c
void memzero_explicit(void *s, size_t count);
```

说明：
用 0 填充内存区域

返回值：

参数：
- `s`: 要填充的内存首地址
- `count`: 要填充的大小

## `kbasename`

函数签名：
```c
const char *kbasename(const char *path);
```

说明：
返回文件名

返回值：

参数：
- `path`

## `strtomem_pad`

函数签名：
```c
strtomem_pad (dest, src, pad);
```

说明：

返回值：

参数：
- `dest`:
- `src`:
- `pad`:

## `strtomem`

函数签名：
```c
strtomem (dest, src)
```

说明：
复制字符串

返回值：

参数：
- `dest`:
- `src`:

## `memset_after`

函数签名：
```c
memset_after (obj, v, member);
```

说明：
在结构成员之后设置一个值到结构的末尾

返回值：

参数：
- `obj`:
- `v`:
- `member`:

## `memset_startat`

函数签名：
```c
memset_startat (obj, v, member);
```

说明：

返回值：

参数：
- `obj`:
- `v`:
- `member`:

## `str_has_prefix`

函数签名：
```c
size_t str_has_prefix(const char *str, const char *prefix);
```

说明：
检查字符串`str`是否以`prefix`开头

返回值：

参数：
- `str`: 字符串
- `prefix`: 子串

## `kstrdup`

函数签名：
```c
char *kstrdup(const char *s, gfp_t gfp);
```

说明：
复制字符串`s`并返回

返回值：

参数：
- `s`: 要复制的字符串
- `gfp`: kmalloc调用的 GFP flags

## `kstrdup_const`

函数签名：
```c
const char *kstrdup_const(const char *s, gfp_t gfp);
```

说明：
有条件的复制现有的const字符串

返回值：

参数：
- `s`: 同上
- `gfp`: 同上

## `kstrndup`

函数签名：
```c
char *kstrndup(const char *s, size_t max, gfp_t gfp);
```

说明：

返回值：

参数：
- `s`: 要复制字符串的首地址
- `max`: 要复制字符串的大小
- `gfp`:

## `kmemdup`

函数签名：
```c
void *kmemdup(const void *src, size_t len, gfp_t gfp);
```

说明：

返回值：

参数：
- `src`:
- `len`:
- `gfp`:

## `kmemdup_null`

函数签名：
```c
char *kmemdup_nul(const char *s, size_t len, gfp_t gfp);
```

说明：
创建以 nul 结束的字符串

返回值：

参数：
- `s`:
- `len`:
- `gfp`:

## `memdup_user`

函数签名：
```c
void *memdup_user(const void __user *src, size_t len);
```

说明：
从用户空间复制内存

返回值：

参数：
- `src`: 用户空间的指针
- `len`: 要复制的字节数

## `vmemdup_user`

函数签名：
```c
void *vmemdup_user(const void __user *src, size_t len);
```

说明：
从用户空间复制内存

返回值：

参数：
- `src`: 用户空间的指针
- `len`: 要复制的字节数

## `strndup_user`

函数签名：
```c
char *strndup_user(const char __user *s, long n);
```

说明：
从用户空间复制内存，包含字符串结束符

返回值：

参数：
- `s`: 用户空间的指针
- `n`: 要复制的字节数


## `memdup_user_nul`
函数签名：
```c
void *memdup_user_nul(const void __user *src, size_t len);
```

说明：
复制用户空间字符串并且添加结束标志

返回值：

参数：
- `src`: 用户空间的指针
- `len`: 要复制的字节数

