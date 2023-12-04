# sessreg

> 管理非init客户端的utmp/wtmp条目

Sessreg是一个简单的程序，用于管理xdm会话的utmp/wtmp和lastlog条目。

system V有比BSD更好的utmp接口;它在文件中动态分配条目，而不是将它们写入`/etc/ttys`中按位置索引的固定位置。

要管理bsd风格的utmp文件，sessreg有两个策略。与xdm一起使用时，-x选项计算/etc/ttys中的行数，然后加上Xservers文件中指定显示的行数。必须使用-l选项将显示名称指定为“line-name”。这个总和用作将写入该条目的utmp文件中的“槽位号”。在更一般的情况下，-s选项直接指定槽位号。如果由于某些奇怪的原因，您的系统使用了/etc/ttys以外的文件来管理init，那么-t选项可以指示sessreg在其他地方查找终端会话的计数。

相反，System V管理器永远不需要使用这些选项(-x， -s和-t)。为了使程序更容易记录和解释，sessreg接受System V环境中特定于bsd的标志，并忽略它们。

BSD和Linux在utmp文件中也有一个主机名字段，这个字段在System V中不存在。这个选项也被System V版本的sessreg忽略。
