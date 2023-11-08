# 系统集成

## 环境准备

1. syslinux：支持从FAT、ext2/3/4、btrfs文件系统和CD、PXE引导系统。[BIOS](https://wiki.archlinux.org/index.php/Syslinux#Automatic_Install)、[EFI](https://wiki.archlinux.org/index.php/Syslinux#UEFI_Systems)

## syslinux

syslinux是一个启动加载器集合，可以从硬盘、光盘或通过 PXE 的网络引导启动系统。支持的文件系统包括 FAT，ext2，ext3，ext4 和非压缩单设备 Btrfs 文件系统。

### BIOS

#### 启动流程

1. 第一阶段 - 第一部分 - 加载MBR 电脑启动时，BIOS 会先加载磁盘开始的 440 字节 MBR 启动代码 (/usr/lib/syslinux/bios/mbr.bin 或 /usr/lib/syslinux/bios/gptmbr.bin)
2. 第一阶段 - 第二部分 - 寻找活动分区 第一阶段的MBR启动代码会寻找活动分区（设置了可启动标记的 MBR 分区），此处我们假设是 /boot 分区。
3. 第二阶段 - 第一部分 - 执行卷启动记录程序 MBR 启动代码会执行上面找到的 /boot 分区的卷启动记录程序（VBR，volume boot record）。对于 Syslinux 来说，VBR 就是由 extlinux --install 命令创建的 /boot/syslinux/ldlinux.sys 位于开始扇区的部分。请注意 ldlinux.sys 和 ldlinux.c32 是不同的。
4. 第二阶段 - 第二部分 - 执行 /boot/syslinux/ldlinux.sys VBR 会加载 ldlinux.sys 剩余的部分。ldlinux.sys 所处在的扇区位置不可更改，否则 syslinux 无法启动。
5. 第三阶段 - 加载 /boot/syslinux/ldlinux.c32 ldlinux.sys 加载剩下的 syslinux 的核心部分 /boot/syslinux/ldlinux.c32（这部分是因为文件大小限制无法放入 ldlinux.sys 中的核心模块）。ldlinux.c32 文件应该在每一个装有 syslinux 的实例中出现，并且与分区中的 ldlinux.sys 版本相匹配，否则 Syslinux 将无法启动。
6. 第四阶段 - 查找并加载配置文件 当 syslinux 完全加载完毕，它将自动查找配置文件 /boot/syslinux/syslinux.cfg (或某些情况下的 /boot/syslinux/extlinux.conf)，如果找到即加载。否则会进入 Syslinux boot: 的命令提示符。这一步和剩下的非核心 Syslinux 部分(除 `lib*.c32` 和 `ldlinux.c32`的`/boot/syslinux/*.c32` 模块) 需要提供 `/boot/syslinux/lib*.c32` (库)模块。同样，{`ic`|`lib*.c32`}} 库模块和非核心的 `*.c32` 模块需要与分区中的 ldlinux.sys 版本相匹配。

>  对于 btrfs 来说，因为文件不断移动导致ldlinux.sys扇区的位置不断变化，上述的方法将无法工作。因此在 Btrfs 中整个 ldlinux.sys 文件会直接紧接着嵌入卷启动记录程序，而不是像其他文件系统那样保存在 /boot/syslinux/ldlinux.sys 处。

#### 在BIOS上安装

### UEFI

