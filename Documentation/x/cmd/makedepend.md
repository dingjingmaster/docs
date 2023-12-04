# makedepend

> 在 makefile 中创建依赖

makedepend程序按顺序读取每个源文件，并像c预处理器一样对其进行解析，处理所有#include， #define， #undef， #ifdef， #ifndef， #endif， #if， #elif和#else指令，以便它可以正确地判断编译中将使用哪些#include，指令。任何#include，指令都可以引用具有其他#include指令的文件，并且解析也会在这些文件中发生。

源文件直接或间接包含的每个文件都是makedepend所称的依赖项。然后将这些依赖项写入makefile，这样当依赖项发生变化时，make(1)将知道哪些目标文件必须重新编译。

默认情况下，makedepend将其输出放在名为makefile的文件中(如果存在)，否则放在makefile中。可以使用−f选项指定另一个makefile。它首先在makefile中搜索该行

```
# DO NOT DELETE THIS LINE −− make depend depends on it.
```

或者一个带有-s选项的，作为依赖项输出的分隔符。如果找到它，它将删除makefile后面到末尾的所有内容，并将输出放在该行之后。如果没有找到，程序将把字符串附加到makefile的末尾，并将输出放在后面。对于出现在命令行上的每个源文件，makedepend将行放到表单的生成文件中

sourcefile.o: dfile…

sourcefile.o是命令行中的名称，其后缀替换为“.o”。而dfile是在解析源文件或它包含的文件之一时，在#include指令中发现的依赖项
