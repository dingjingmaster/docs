# 位操作

## `set_bit`

函数签名：
```c
void set_bit(long nr, volatile unsigned long *addr);
```

说明：
在内存中设置指定位

返回值：

参数：
- `nr`: 要设置的位
- `addr`: 要设置位的开始地址

## `clear_bit`

函数签名：
```c
void clear_bit(long nr, volatile unsigned long *addr);
```

说明：
清空内存中的指定位

返回值：

参数：
- `nr`:
- `addr`:

## `change_bit`

函数签名：
```c
void change_bit(long nr, volatile unsigned long *addr);
```

说明：

返回值：

参数：
- `nr`:
- `addr`:

## `test_and_set_bit`

函数签名：
```c
bool test_and_set_bit(long nr, volatile unsigned long *addr);
```

说明：
设置值并返回原始值

返回值：
原始值

参数：
- `nr`:
- `addr`:

## `test_and_clear_bit`

函数签名：
```c
bool test_and_clear_bit(long nr, volatile unsigned long *addr);
```

说明：

返回值：

参数：
- `nr`:
- `addr`:

## `test_and_change_bit`

函数签名：
```c
bool test_and_change_bit(long nr, volatile unsigned long *addr);
```

说明：

返回值：

参数：
- `nr`:
- `addr`:

## `__clear_bit`

函数签名：
```c
void ___clear_bit(unsigned long nr, volatile unsigned long *addr);
```

说明：

返回值：

参数：
- `nr`:
- `addr`:

## `__change_bit`

函数签名：
```c
void ___change_bit(unsigned long nr, volatile unsigned long *addr);
```

说明：

返回值：

参数：
- `nr`:
- `addr`:

## `__test_and_set_bit`

函数签名：
```c
bool ___test_and_set_bit(unsigned long nr, volatile unsigned long *addr);
```

说明：

返回值：

参数：
- `nr`:
- `addr`:

## `__test_and_clear_bit`

函数签名：
```c
bool ___test_and_clear_bit(unsigned long nr, volatile unsigned long *addr);
```

说明：

返回值：

参数：
- `nr`:
- `addr`:

## `__test_and_change_bit`

函数签名：
```c
bool ___test_and_change_bit(unsigned long nr, volatile unsigned long *addr)
```

说明：

返回值：

参数：
- `nr`:
- `addr`:

## `_test_bit`

函数签名：
```c
bool _test_bit(unsigned long nr, volatile const unsigned long *addr);
```

说明：

返回值：

参数：
- `nr`:
- `addr`:

## `_test_bit_acquire`

函数签名：
```c
bool _test_bit_acquire(unsigned long nr, volatile const unsigned long *addr);
```

说明：
检测指定位是否被设置

返回值：

参数：
- `nr`:
- `addr`:

## `clear_bit_unlock`

函数签名：
```c
void clear_bit_unlock(long nr, volatile unsigned long *addr);
```

说明：
原子性的，并且释放屏障原语

返回值：

参数：
- `nr`:
- `addr`:

## `__clear_bit_unlock`

函数签名：
```c
void __clear_bit_unlock(long nr, volatile unsigned long *addr);
```

说明：

返回值：

参数：
- `nr`:
- `addr`:

## `test_and_set_bit_lock`

函数签名：
```c
bool test_and_set_bit_lock(long nr, volatile unsigned long *addr);
```

说明：

返回值：

参数：
- `nr`:
- `addr`:

## `clear_bit_unlock_is_negative_byte`

函数签名：
```c
bool clear_bit_unlock_is_negative_byte(long nr, volatile unsigned long *addr);
```

说明：
清除内存中的一个位，并测试底部字节是否为负，用于解锁。

返回值：

参数：
- `nr`:
- `addr`:


