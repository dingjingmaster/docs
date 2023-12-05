# public API

XCB公共API包含辅助X协议的函数。

## 类型

这些类型在 xcb.h 中声明。

### xcb_connection_t

```
typedef struct xcb_connection_t xcb_connection_t;
```

`xcb_connection_t`是一个不透明的结构，包含XCB与X服务器通信所需的所有数据。该结构在`xcbint.h`中定义。

### xcb_extension_t

```
typedef struct xcb_extension_t xcb_extension_t;
```

xcb_extension_t 是一个不透明的结构，用作 xcb_get_extension_data 的键。

### xcb_auth_info_t

```
typedef struct xcb_auth_info_t 
{
    int namelen;
    char *name;       // string containing the authentication protocol name, such as &quot;MIT-MAGIC-COOKIE-1&quot; or &quot;XDM-AUTHORIZATION-1&quot;.
    int datalen;
    char *data;       // interpreted in a protocol-specific manner
} xcb_auth_info_t;
```

一个用于发送授权信息到 X 服务器的容器。

## xcb_connect

```
xcb_connection_t* xcb_connect (const char *display, int *screen );
```

连接到由 display 指定的 X 服务器。如果 display 为 null，则使用 DISPLAY 环境变量的值。如果首选该服务器上的特定屏幕，则 screen 指向的 int（如果非 null）将被设置为该屏幕；否则，屏幕将被设置为 0。

## xcb_connect_to_display_with_auth_info

```
xcb_connection_t* xcb_connect_to_display_with_auth_info (const char *display, xcb_auth_info_t *auth, int *screen );
```

使用给定的授权信息连接到由 display 指定的 X 服务器。如果首选该服务器上的特定屏幕，则 screen 指向的 int（如果非空）将被设置为该屏幕；否则，屏幕将被设置为 0。

## xcb_connect_to_fd

```
xcb_connection_t* xcb_connect_to_fd (
        int fd, // a file descriptor bidirectionally connected to an X server.

        // authentication data, or 0 if the connection should be unauthenticated.
        // xcb_get_auth_info returns appropriate authentication data
        xcb_auth_info_t *auth_info
        );
```
给定一个打开的套接字和合适的 xcb_auth_info_t，连接到 X 服务器。

返回一个 xcb_connection_t。

另请参阅 xcb_connect。

## xcb_disconnect

```
void xcb_disconnect (xcb_connection *c);
```

关闭文件描述符并释放与连接相关的所有内存。只关闭一次连接。

## xcb_parse_display

```
int xcb_parse_display (
        const char *name,// the display name to parse; if null or empty, uses the environment variable DISPLAY.
        char **host,     // a non-null pointer to a pointer which will be set to a malloc&#39;d copy of the hostname.
        int *display,    // a non-null pointer to an int which will be set to the display number
        int *screen );   // a (possibly null) pointer to an int which will be set to the preferred screen number, 
                         //  or set to 0 if the display string does not contain a screen number
```
以 X(7x) 记录的格式解析显示字符串名称。失败时没有副作用。

失败时返回0（可能是名称是null或无法解析，或者malloc失败）；成功时返回非零。

## xcb_get_setup

```
const xcb_setup_t* xcb_get_setup (xcb_connection_t *c);
```

当 xcb_connection_t 初始化时，服务器返回的数据的访问器。
数据包括：
- 服务器对图像的格式要求
- 可用视觉效果的列表
- 可用屏幕的列表
- 服务器的最大请求长度（在没有BIG-REQUESTS扩展的情况下）
- 以及其他各种信息

有关更多详细信息，请参阅 X 协议规范和 xcb_types.h。

此例程返回一个指向连接数据的指针。它不应该被释放，并且在连接被释放时将变为无效。

## xcb_get_file_descriptor

```
int xcb_get_file_descriptor (xcb_connection_t *c);
```

传递给 xcb_connect_to_fd 调用的文件描述符的访问器，该调用返回 c。

## xcb_get_maximum_request_length

```
uint32_t xcb_get_maximum_request_length (xcb_connection_t *c);
```

如果不存在BIG-REQUESTS扩展，则返回连接设置数据中的maximum_request_length字段，该字段最多可达65535。如果服务器支持BIG-REQUESTS，则将返回对“BigRequestsEnable”请求的回复中的maximum_request_length字段。

> 请注意，此长度以四字节为单位进行测量，在不使用BIG-REQUESTS的情况下，理论最大长度约为256kB，在使用BIG-REQUESTS的情况下，理论最大长度约为16GB。

## xcb_wait_for_event

```
xcb_generic_event_t* xcb_wait_for_event (xcb_connection_t *c);
```
从服务器返回下一个事件或错误，或在发生 I/O 错误时返回 null。一直阻塞到事件或错误到达，或发生 I/O 错误。

## xcb_poll_for_event

```
xcb_generic_event_t* xcb_poll_for_event (xcb_connection_t *c);
```

从服务器返回下一个事件或错误（如果有），否则返回 null。如果没有事件可用，可能是因为尝试读取下一个事件时发生了连接关闭等 I/O 错误。您可以使用 xcb_connection_has_error 来检查此情况。

## xcb_connection_has_error

```
int xcb_connection_has_error (xcb_connection_t *c);
```

如果连接有错误，则返回非零值，如果连接仍然有效，则返回零值。如果此值返回非零值，则连接无效，就像已经调用过 xcb_disconnect 一样。

## xcb_flush

```
int xcb_flush (xcb_connection_t *c);
```

强制将任何缓冲的输出写入服务器。在写入完成之前一直阻塞。

返回值：成功返回1，失败返回0

## xcb_get_extension_data

```
const xcb_query_extension_reply_t* xcb_get_extension_data (xcb_connection_t *c, xcb_extension_t *ext );
```

此函数是“扩展缓存”的主要接口，它缓存来自QueryExtension请求的回复信息。调用此函数可能会导致调用xcb_query_extension以从服务器检索扩展信息，并可能阻塞，直到从服务器收到扩展数据为止。

不要释放返回的 xcb_query_extension_reply_t - 这个存储由缓存本身管理。

## xcb_prefetch_extension_data

```
void xcb_prefetch_extension_data (xcb_connection_t *c, xcb_extension_t *ext);
```
此函数允许将扩展数据“预取”到扩展缓存中。调用此函数可能会导致对 xcb_query_extension 的调用，但不会阻止等待回复。 xcb_get_extension_data 将在可能被阻塞后返回预取的数据。

## xcb_generate_id

```
uint32_t xcb_generate_id (xcb_connection *c);
```

此函数在创建新的 X 对象之前分配一个 XID。例如， xcb_create_window

```
xcb_window_t window = xcb_generate_id (connection);
xcb_create_window (connection, depth, window, ... );
```

