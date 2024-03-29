# indir

> 创建指向另一个目录树的符号链接的影子目录

lndir程序对fromdir目录树进行影子复制，只不过影子中没有填充真正的文件，而是使用指向fromdir目录树中真正文件的符号链接。这对于维护不同机器体系结构的源代码通常很有用。您将创建一个影子目录，其中包含到实际源的链接，您通常将从远程机器挂载该源。您可以在影子树中构建，目标文件将在影子目录中，而影子目录中的源文件只是到实际文件的符号链接。

这种方案的优点是，如果您更新了源代码，则不需要手动将更改传播到其他体系结构，因为所有影子目录中的所有源代码都是指向实际内容的符号链接:只需cd到影子目录并重新编译即可。

todir参数是可选的，默认为当前目录。fromdir参数可能是相对的(例如，…/src)，并且相对于todir(而不是当前目录)。

注意BitKeeper, CVS, CVS。adm、。git、。hg、RCS、SCCS和。svn目录只有在指定了- withrevinfo标志时才会被遮蔽。文件名以~结尾的文件永远不会被遮蔽。

如果添加了文件，只需再次运行lndir。新文件将被静默添加。将检查旧文件是否具有正确的链接。

删除文件是一个更痛苦的问题;这些符号只会指向永远不会着陆。

如果fromdir中的文件是一个符号链接，那么lndir将在todir中创建相同的链接，而不是链接回fromdir中的(符号链接)条目。- ignorelinks标志改变这种行为。
