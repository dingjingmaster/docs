# ccmakedep

> 使用C编译器在makefiles中创建依赖关系

ccmakedeep程序调用C编译器对每个源文件进行预处理，并使用输出构建描述它们的依赖关系的makefile规则。这些规则指示make(1)，当依赖项发生变化时，必须在哪个目标文件上重新编译。


默认情况下，ccmakedeep将其输出放在名为makefile的文件中(如果存在的话)，否则放在makefile中。可以使用−f选项指定另一个makefile。它首先在makefile中搜索以

```
# DO NOT DELETE
```

或者一个带有`-s`选项的，作为依赖项输出的分隔符。如果它找到它，它将删除它之后的所有内容，直到makefile的末尾，并将输出放在该行之后。如果没有找到，程序将把字符串附加到makefile中，并将输出放在后面。
