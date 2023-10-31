# 字符设备(Char devices)

## register_chrdev_region

函数签名：
```c
int register_chrdev_region(dev_t from, unsigned count, const char *name);
```

## alloc_chrdev_region

函数签名：
```c
int alloc_chrdev_region(dev_t *dev, unsigned baseminor, unsigned count, const char *name);
```

## __register_chrdev

函数签名：
```c
int __register_chrdev(unsigned int major, unsigned int baseminor, unsigned int count, const char *name, const struct file_operations *fops);
```

## unregister_chrdev_region

函数签名：
```c
void unregister_chrdev_region(dev_t from, unsigned count);
```

## __unregister_chrdev

函数签名：
```c
void __unregister_chrdev(unsigned int major, unsigned int baseminor, unsigned int count, const char *name);
```

## chdev_add

函数签名：
```c
int cdev_add(struct cdev *p, dev_t dev, unsigned count);
```

## chdev_set_parent

函数签名：
```c
void cdev_set_parent(struct cdev *p, struct kobject *kobj);
```

## cdev_device_add

函数签名：
```c
int cdev_device_add(struct cdev *cdev, struct device *dev);
```

## cdev_device_del

函数签名：
```c
void cdev_device_del(struct cdev *cdev, struct device *dev);
```

## cdev_del

函数签名：
```c
void cdev_del(struct cdev *p);
```

## cdev_alloc

函数签名：
```c
struct cdev *cdev_alloc(void);
```

## cdev_init

函数签名：
```c
void cdev_init(struct cdev *cdev, const struct file_operations *fops);
```


