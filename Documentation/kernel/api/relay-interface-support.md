# 中继接口(relay interface support)

中继接口支持旨在为提供一种有效的机制，以便将大量数据从内核空间中继到用户空间。

## relay_buf_full

函数签名：
```c
int relay_buf_full(struct rchan_buf *buf);
```

说明：

返回值：
返回channel buffer 是否满
- 满了，返回1
- 不满，返回0

参数：
- `buf`：channel buffer

## relay_reset

函数签名：
```c
void relay_reset(struct rchan *chan);
```

## relay_open

函数签名：
```c
struct rchan *relay_open(const char *base_filename, struct dentry *parent, size_t subbuf_size, size_t n_subbufs, const struct rchan_callbacks *cb, void *private_data);
```

说明：

返回值：

参数：
- `base_filename`：要创建的文件的基本名称，NULL表示使用缓存
- `parent`：父目录的入口，NULL表示根目录或使用缓存
- `subbuf_size`：子buffer的大小
- `n_subbufs`：子buffer 的大小
- `cb`：客户端回调函数
- `private_data`：用户定义的数据

## relay_late_setup_files

函数签名：
```c
int relay_late_setup_files(struct rchan *chan, const char *base_filename, struct dentry *parent);
```

说明：

返回值：

参数：
- `chan`：
- `base_filename`：要创建的文件名
- `parent`：父目录入口，如果是NULL则表示根目录

## relay_switch_subbuf

函数签名：
```c
size_t relay_switch_subbuf(struct rchan_buf *buf, size_t length);
```

说明：

返回值：

参数：
- `buf`：
- `length`：

## relay_subbufs_consumed

函数签名：
```c
void relay_subbufs_consumed(struct rchan *chan, unsigned int cpu, size_t subbufs_consumed);
```

说明：

返回值：

参数：
- `chan`：
- `cpu`：
- `subbufs_consumed`：

## relay_close

函数签名：
```c
void relay_close(struct rchan *chan);
```

说明：

返回值：

参数：
- `chan`：

## relay_flush

函数签名：

```c
void relay_flush(struct rchan *chan);
```

## relay_mmap_buf

函数签名：
```c
int relay_mmap_buf(struct rchan_buf *buf, struct vm_area_struct *vma);
```

## relay_alloc_buf

函数签名：
```c
void *relay_alloc_buf(struct rchan_buf *buf, size_t *size);
```

## relay_create_buf

函数签名：
```c
struct rchan_buf *relay_create_buf(struct rchan *chan);
```

## relay_destory_channel

函数签名：
```c
void relay_destroy_channel(struct kref *kref);
```

## relay_destroy_buf

函数签名：
```c
void relay_destroy_buf(struct rchan_buf *buf);
```

## relay_remove_buf

函数签名：
```c
void relay_remove_buf(struct kref *kref);
```

## relay_buf_empty

函数签名：
```c
int relay_buf_empty(struct rchan_buf *buf);
```

## wakeup_readers

函数签名：
```c
void wakeup_readers(struct irq_work *work);
```

## __relay_reset

函数签名：
```c
void __relay_reset(struct rchan_buf *buf, unsigned int init);
```

## __relay_close_buf

函数签名：
```c
void relay_close_buf(struct rchan_buf *buf);
```

## relay_file_open

函数签名：
```c
int relay_file_open(struct inode *inode, struct file *filp);
```

## relay_file_mmap

函数签名：
```c
int relay_file_mmap(struct file *filp, struct vm_area_struct *vma);
```

说明：
为中继文件映射文件op

参数：
- `filp`：文件
- `vma`：描述映射内容的vma

## relay_file_poll

函数签名：
```c
__poll_t relay_file_poll(struct file *filp, poll_table *wait);
```

## relay_file_release

函数签名：
```c
int relay_file_release(struct inode *inode, struct file *filp);
```

## relay_file_read_subbuf_avail

函数签名：
```c
size_t relay_file_read_subbuf_avail(size_t read_pos, struct rchan_buf *buf);
```

## relay_file_read_start_pos

函数签名：
```c
size_t relay_file_read_start_pos(struct rchan_buf *buf);
```

## relay_file_read_end_pos

函数签名：
```c
size_t relay_file_read_end_pos(struct rchan_buf *buf, size_t read_pos, size_t count);
```



