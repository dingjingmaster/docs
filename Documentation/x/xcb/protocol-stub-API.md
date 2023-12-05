# 协议存根API

这些不是单一的函数或类型，而是用于所有扩展的核心协议API和公共API中的命名约定。所有与核心协议相关的声明都在xcb.h中，而每个扩展都在自己的头文件中提供所有声明。

这个API的设计目标之一是，用户应该能够学习这些约定，然后阅读关于核心协议或任何扩展的二进制编码的文档，并立即确定正确的函数名称和参数列表，以生成所需的请求。

大多数X Window Protocol文档位于 `http://www.x.org/releases/x11r7.7/doc/index.html#protocol`。

## 扩展

### xcb_extension_id

```
xcb_extension_t xcb_extension_id
```


