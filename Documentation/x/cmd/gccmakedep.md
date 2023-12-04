# gccmakedep

> 在Makefile中使用 `gcc -M` 生成依赖

gccmakedep程序调用'gcc -M'来输出描述每个源文件的依赖关系的makefile规则，以便make知道当依赖关系发生变化时，哪些目标文件必须重新编译。

默认情况下，gccmakedeep将其输出放在名为makefile的文件中(如果存在的话)，否则放在makefile中。可以使用−f选项指定另一个makefile。它首先在makefile中搜索以

```
# DO NOT DELETE
```

或者一个带有-s选项的，作为依赖项输出的分隔符。如果它找到它，它将删除它之后的所有内容，直到makefile的末尾，并将输出放在该行之后。如果没有找到，程序将把字符串附加到makefile中，并将输出放在后面。
