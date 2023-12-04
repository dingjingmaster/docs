# mkhtmlindex

> 为HTML man 文档生成索引文件 

mkhtmlindex程序为html格式的手册页面目录生成索引文件。它搜索名称形式为“name.1.html”的文件，并输出索引文件“manindex1.html”、“manindex.2.html”等，每个手工卷对应一个。空索引文件将被删除。通过扫描每个页面的第一个`<H2>`部分找到名称和描述。
