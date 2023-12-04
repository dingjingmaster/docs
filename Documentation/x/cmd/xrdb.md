# xrdb

> x 服务资源数据库工具

Xrdb用于获取或设置屏幕0的根窗口上的`RESOURCE_MANAGER`属性的内容，或任何或所有屏幕的根窗口上的`SCREEN_RESOURCES`属性的内容，或所有内容的组合。您通常会从X启动文件运行此程序。

大多数X客户机使用`RESOURCE_MANAGER`和`SCREEN_RESOURCES`属性来获取用户关于应用程序的颜色、字体等的首选项。将这些信息保存在服务器(对所有客户机都可用)而不是磁盘上，解决了X以前版本中要求您在可能使用的每台机器上维护默认文件的问题。它还允许在不编辑文件的情况下动态更改默认值。

`RESOURCE_MANAGER`属性用于应用于显示的所有屏幕的资源。每个屏幕上的`SCREEN_RESOURCES`属性指定用于该屏幕的附加(或重写)资源。(当只有一个屏幕时，通常不使用`SCREEN_RESOURCES`，所有资源都放在`RESOURCE_MANAGER`属性中。)
