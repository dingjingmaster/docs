# DPDK问答

## 运行DPDK需要做哪些准备

DPDK是一个高性能的网络 I/O 框架，它可以提供高速的数据包处理和转发功能。

1. 安装DPDK
2. DPDK需要具体支持的NIC（网卡） [https://core.dpdk.org/supported/](https://core.dpdk.org/supported/)
3. 配置Huge Pages：DPDK需要大页（Huge Pages）来提供高性能和低延迟。需要在操作系统上配置足够大的大页以供 DPDK 使用。
4. 设置环境变量：为了正确的使用DPDK，您需要设置环境变量。这些变量包括 RTE_SDK（指向DPDK库的安装路径）和 RTE_TARGET （指定目标机器的架构）。您可以通过在shell中设置这些变量或通过脚本来完成
5. 驱动绑定：在运行 DPDK 之前，需要将 NIC 驱动程序与操作系统默认的网络协议栈解绑，并将其绑定到DPDK的驱动程序上。DPKD提供了一些工具，如：`dpdk-devbind.py`，可用于执行此操作
6. 编译和运行应用程序

## 如何确定网卡是否支持DPDK

待整理

## Linux配置Huge Page

1. 使用命令检测是否支持Huge Page（输出包含`HugePages_`说明支持，不支持则需要打开内核对应配置并重新编译内核）
    ```
    grep -i /proc/meminfo
    ```
2. 确定Huge Page 的大小
    ```
    grep -i hugepagesize / proc/meminfo
    ```
3. 配置 Huge Pages：配置 Huge Pages，编译系统的引导参数并重新启动系统
    ```
    sudo vim /etc/default/grub
    ```
    在 `GRUB_CMDLINE_LINUX` 或 `GRUB_CMDLINE_LINUX_DEFAULT`参数中添加 hugepagesz=<大小> hugepages=<大小>。例如：
    ```
    GRUB_CMDLINE_LINUX_DEFAULT="quiet splash hugepagesz=2M hugepages=2048"
    ```
    保存文件并更新GRUB配置
4. 重新启动系统，使之生效，可用 1 中的方法再次查看 HugePage 大小

### Huge Pages用途

配置 HugePage 的主要目的是提高应用程序的性能，尤其是那些需要大量内存的应用程序。下面是主要用途：
1. 提高内存访问效率：传统的内存页面大小通常为4KB，而HugePages的大小通常为2MB或更大。相比较而言，使用HugePage可以减少内存页表的数量，从而减少操作系统跟踪和管理内存页表的开销。这样可以提高内存的访问效率，减少TLB（Translation Lookaside Buffer）缺失的机会，大大提高应用程序的性能。
2. 减少内存碎片化：使用HugePages可以减少内存碎片化的问题。由于HugePages大小较大，分配连续的HugePages不太容易导致分散的内存碎片。这有助于提高内存的连续性，从而减少内存分配和释放的开销。
3. 支持大内存应用程序：对于需要大量内存的应用程序，如内存数据库、虚拟化环境和科学计算应用程序，配置HugePages可以提供更大的内存空间。这对于处理大规模数据集或执行复杂的计算任务非常有用。

### Huge Pages怎么使用

Huge Pages 的使用通常需要应用程序显示支持，因为它涉及到使用特定的系统调用来分配和管理Huge Pages。以下是使用Huge Pages的一般步骤：
1. 分配Huge Pages：应用程序需要使用hugetlbfs文件系统来分配Huge Pages。该文件系统允许应用程序在用户空间访问 Huge Pages。通过 `shmget()` 系统调用或 `mmap()`系统调用与 hugetlbfs 文件系统建立连接，从而分配所需数量的 HugePages。
2. 使用 Huge Pages：一旦Huge Pages被分配，应用程序可以将其用作常规内存区域。应用程序可以使用指针来访问 Huge Pages，并在其中存储数据。与传统内存分配方式相比较，使用Huge Pages可以提供更高效的内存访问和更低的内存碎片化。
3. 释放 Huge Pages：当应用程序不再需要 Huge Pages时候，必须显式释放它们，以便系统可以重新使用这些Huge Pages 应用程序可以使用 `shmctl()`系统调用或 `nunmap()`系统调用来释放 Huge Pages。


