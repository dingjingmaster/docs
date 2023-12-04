# xcmsdb

> 用于X颜色管理系统的设备颜色表征实用程序

xcmsdb用于加载、查询或删除存储在ICCCM第7节“设备颜色表征”中指定的屏幕根窗口属性中的设备颜色表征数据。设备颜色表征数据(也称为设备配置文件)是Xlib的X颜色管理系统(Xcms)的一个组成部分，对于在设备无关和设备相关的形式之间正确转换颜色规范是必要的。Xcms使用存储在XDCCC_LINEAR_RGB_MATRICES属性中的3x3矩阵来转换CIEXYZ和RGB强度(XcmsRGBi，也称为线性RGB)之间的颜色规格。然后Xcms使用存储在XDCCC_LINEAR_RGB_CORRECTION属性中的显示伽马信息在RGBi和RGB设备(XcmsRGB，也称为设备RGB)之间转换颜色规格。

注意，除了为CRT彩色显示器注册内置函数集之外，Xcms还允许客户机注册函数集。其他功能集可以将其设备配置文件信息以功能集特定格式存储在其他属性中。此实用程序不知道这些非标准属性。

如果没有指定- query或- remove选项，则filename的ASCII可读内容(或如果没有给出输入文件的标准输入)将被适当转换以存储在属性中。