# xmkmf

> 通过 Imakefile 创建 Makefile

xmkmf命令是从第三方软件附带的Imakefile中创建Makefile的常用方法。

当在包含Imakefile的目录中不带参数调用imake程序时，imake程序将使用适合您的系统的参数运行(在构建时配置为imake)并生成Makefile。

当使用-a选项调用时，xmkmf在当前目录中构建Makefile，然后自动执行"make Makefiles"(如果有子目录)，"make includes"和"make depend"。

如果指定了topdir, xmkmf假定系统上没有安装任何文件，并在构建树中查找文件，而不是使用已安装的版本。可选地，curdir可以被指定为从构建树的顶部到当前目录的相对路径名。如果当前目录有子目录，则必须提供curdir，否则Makefile将无法构建子目录。
