# smproxy

> Session Manager Proxy

smproxy允许不支持X11R6会话管理的X应用程序参与X11R6会话。

为了使smproxy充当X应用程序的代理，必须满足以下条件之一:

- 应用程序映射一个包含`WM_CLIENT_LEADER`属性的顶层窗口。这个属性提供了一个指向客户端领导窗口的指针，该窗口包含`WM_CLASS`, `WM_NAME`, `WM_COMMAND`和`WM_CLIENT_MACHINE`属性。
- (或)应用程序映射一个不包含`WM_CLIENT_LEADER`属性的顶层窗口。然而，这个顶层窗口包含`WM_CLASS`, `WM_NAME`, `WM_COMMAND`和`WM_CLIENT_MACHINE`属性。

支持`WM_SAVE_YOURSELF`协议的应用程序将在每次会话管理器发出检查点或关闭时收到一个`WM_SAVE_YOURSELF`客户端消息。这允许应用程序保存状态。如果应用程序不支持`WM_SAVE_YOURSELF`协议，那么代理将向会话管理器提供足够的信息来重启应用程序(使用`WM_COMMAND`)，但不会恢复状态。
