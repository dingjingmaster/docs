# xdmx

> 分布式x服务器

Xdmx是一个代理X服务器，它使用一个或多个其他X服务器作为其显示设备。它为可能位于不同机器上的显示器提供多头X功能。Xdmx充当前端X服务器，充当一组后端X服务器的代理。所有可见呈现都传递给后端X服务器。客户机连接到Xdmx前端，一切都与常规多头配置一样。如果启用了Xinerama(例如，在命令行中使用 +Xinerama)，客户端将看到单个大屏幕。

Xdmx使用标准X11协议以及标准和/或常用的X服务器扩展与后端X服务器通信。
