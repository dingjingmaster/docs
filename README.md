# docs

我一直在找一种好的文档记录方式，它需要满足以下要求：
1. 支持 `Markdown` 语法
2. 内容需要结构化显示
3. 支持在网页上查看+输出本地文档以便分享

我以前一直使用`hugo`以便把`markdown`生成静态页面，长时间使用后发现还是有一些问题————生成的文档太零散，阅读很不方便，因此就有了这个项目...

pandoc --listings -f markdown -t latex -o aa.tex docs/index.md docs/gobject/index.md --pdf-engine=xelatex -V mainfont="Source Han Mono SC" -s
