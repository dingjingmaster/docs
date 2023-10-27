# 排序

## `sort_r`

函数签名：
```c
void sort_r(void *base, size_t num, size_t size, cmp_r_func_t cmp_func, swap_r_func_t swap_func, const void *priv);
```

说明：
给数组元素排序

返回值：
无

参数：
- `base`: 要排序的数据
- `num`: 数组的元素个数
- `size`: 每个元素的大小
- `cmp_func`: 比较函数
- `swap_func`: 交换函数
- `priv`: 要传入比较函数里的值

## `list_sort`

```c
void list_sort(void *priv, struct list_head *head, list_cmp_func_t cmp);
```

说明：
链表排序

返回值：
无

参数：
- `priv`: 要传递给 cmp 的私有数据
- `head`: 要排序的链表
- `cmp`: 元素比较函数


