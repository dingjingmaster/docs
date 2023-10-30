# FIFO Buffer

## DECLARE_KFIFO_PTR

函数签名：
```c
DECLARE_KFIFO_PTR (fifo, type)
```

说明：
声明一个fifo指针结构体

参数：
- `fifo`：声明的fifo结构体名字
- `type`：fifo元素类型

## DECLARE_KFIFO

函数签名：
```c
DECLARE_KFIFO (fifo, type, size)
```

说明：
声明一个fifo结构体

参数：
- `fifo`：声明的fifo结构体名字
- `type`：fifo元素类型
- `size`：fifo中元素个数，必须是2的幂

## INIT_KFIFO

函数签名：
```c
INIT_KFIFO (fifo)
```

说明：
初始化 fifo

参数：
- `fifo`：

## DEFINE_KFIFO

函数签名：
```c
DEFINE_KFIFO (fifo, type, size);
```

说明：
定义并初始化一个fifo

参数：
- `fifo`：声明的fifo数据类型
- `type`：fifo元素类型
- `size`：fifo中元素数量，必须是2的幂

## kfifo_initialized

函数签名：
```c
kfifo_initialized (fifo);
```

说明：
检查fifo是否初始化完成

参数：
- `fifo`：要检查的fifo地址

## kfifo_esize

函数签名：
```c
kfifo_esize (fifo);
```

说明：
返回fifo元素的大小

参数：
- `fifo`

## kfifo_recsize

函数签名：
```c
kfifo_recsize (fifo);
```

说明：
返回fifo中`length`的值，这个值记录了fifo的长度

## kfifo_size

函数签名：
```c
kfifo_size
```

说明：
返回fifo元素的数量

参数：
- `fifo`：

## kfifo_reset

函数签名：
```c
kfifo_reset (fifo);
```

说明：
删除整个fifo内容

使用kfifo_reset()是危险的。它应该只在fifo被排他锁定或没有其他线程访问fifo时被调用。

## kfifo_reset_out

函数签名：
```c
kfifo_reset_out(fifo);
```

说明：
跳过 fifo 内容

参数：
- `fifo`：使用的fifo地址

## kfifo_len

函数签名：
```c
kfifo_len (fifo);
```

说明：
返回fifo中已使用元素的个数

参数：
- `fifo`：fifo地址

## kfifo_is_empty

函数签名：
```c
kfifo_is_empty (fifo);
```

说明：


参数：
- `fifo`：

## kfifo_is_empty_spinlocked

函数签名：
```c
kfifo_is_empty_spinlocked (fifo, lock);
```

说明：

参数：
- `fifo`：fifo地址
- `lock`：自旋锁

## kfifo_is_empty_spinlocked_noirqsave

函数签名：
```c
kfifo_is_empty_spinlocked_noirqsave (fifo, lock);
```

说明：
如果 fifo 为空，使用自旋锁进行锁定，则返回true，不会禁用中断。

参数：
- `fifo`：
- `lock`：锁定 fifo 的自旋锁

## kfifo_is_full

函数签名：
```c
kfifo_is_full (fifo)
```

## kfifo_avail

函数签名：
```c
kfifo_avail (fifo);
```

说明：
返回 fifo 中未使用的元素个数

## kfifo_skip

函数签名：
```c
kfifo_skip (fifo);
```

## kfifo_peek_len

函数签名：
```c
kfifo_peek_len (fifo);
```

说明：
获得下一个fifo的大小

## kfifo_alloc

函数签名：
```c
kfifo_alloc (fifo, size, gfp_mask);
```

说明：
动态分配一个新的fifo buffer

参数：
- `fifo`：fifo指针
- `size`：fifo元素的个数，必须是2的幂
- `gfp_mask`：传递给 kmalloc 的参数

## kfifo_free

函数签名：
```c
kfifo_free (fifo);
```

## kfifo_init

函数签名：
```c
kfifo_init (fifo, buffer, size);
```

说明：
使用预先分配的缓存区创建fifo

## kfifo_put

函数签名：
```c
kfifo_put (fifo, val);
```

说明：
将数据放入到fifo

## kfifo_get

函数签名：
```c
kfifo_get (fifo, val);
```

说明：
从fifo中获取数据

## kfifo_peek

函数签名：
```c
kfifo_peek (fifo, val);
```

说明：
从fifo中获取元素，并不移除获取到的元素

## kfifo_in

函数签名：
```c
kfifo_in (fifo, buf, n);
```

## kfifo_in_spinlocked

函数签名：
```c
kfifo_in_spinlocked (fifo, buf, n, lock);
```

## kfifo_in_spinlocked_noirqsave

函数签名：
```c
kfifo_in_spinlocked_noirqsave (fifo, buf, n, lock);
```

说明：
使用自旋锁将数据放入fifo进行锁定，不会禁用中断。

## kfifo_out

函数签名：
```c
kfifo_out (fifo, buf, n);
```

## kfifo_out_spinlocked

函数签名：
```c
kfifo_out_spinlocked (fifo, buf, n, lock);
```

## kfifo_out_spinlocked_noirqsave

函数签名：
```c
kfifo_out_spinlocked_noirqsave (fifo, buf, n, lock);
```

## kfifo_from_user

函数签名：
```c
kfifo_from_user (fifo, from, len, copied);
```

说明：
将数据从用户空间放到 fifo

## kfifo_to_user

函数签名：
```c
kfifo_to_user (fifo, to, len, copied);
```

## kfifo_dma_in_prepare

函数签名：
```c
kfifo_dma_in_prepare (fifo, sgl, nents, len);
```

## kfifo_dma_in_finish

函数签名：
```c
kfifo_dma_in_finish (fifo, len);
```

## kfifo_dma_out_prepare

函数签名：
```c
kfifo_dma_out_prepare (fifo, sgl, nents, len);
```

## kfifo_dma_out_finish

函数签名：
```c
kfifo_dma_out_finish (fifo, len);
```

## kfifo_out_peek

函数签名：
```c
kfifo_out_peek (fifo, buf, n);
```

说明：
从fifo中获取数据

这个宏从fifo中获取数据并返回复制的元素数量。数据没有从fifo中删除。

注意，只有一个并发读取器和一个并发写入器，您不需要额外的锁定来使用这些宏。

参数：
- `fifo`：
- `buf`：要保存的buffer
- `n`：要获取的元素个数

