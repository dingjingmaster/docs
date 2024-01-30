# DPDK 官方文档学习

## 学习指南

1. 发行日志
2. Linux开始指导
3. 编程指南
4. API手册
5. 简单程序用户指导
6. 驱动开发指南

## DPDK环境

### DPDK编译依赖
- pkg-config
- meson && ninja
- pyelftools
- numactl
- 内核 >= 4.14
- glibc >= 2.7
- 内核配置
    - `HUGETLBFS`
    - `PROC_PAGE_MONITOR`
    - `HPET` 和 `HPET_MMAP` 配置

跨平台编译：
(https://doc.dpdk.org/guides/linux_gsg/cross_build_dpdk_for_arm64.html)[https://doc.dpdk.org/guides/linux_gsg/cross_build_dpdk_for_arm64.html]

### DPDK运行

```shell
echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
echo 1024 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
```

或

```shell
mkdir /mnt/huge
mount -t hugetlbfs pagesize=1GB /mnt/huge
```

### DPDK 源码目录

- doc：DPDK文档
- license：DPDK许可证信息
- lib：DPDK库的源代码
- drivers：DPDK轮询模式驱动程序的源代码
- app：DPDK应用程序（自动测试）的源代码
- examples：DPDK应用程序示例的源代码
- config, buildtools：与框架相关的脚本和配置
- usertools：DPDK应用程序最终用户的实用脚本
- devtools：DPDK开发人员使用的脚本
- kernel：某些操作系统所需的内核模块

### Linux驱动

不同的 PMD 设备可能需要不同的内核驱动程序才能正常工作。根据使用的 PMD 设备，应加载相应的内核驱动程序，并将网络端口绑定到该驱动程序。

#### 内核模块与端口绑定/解绑

大多数设备要求 DPDK 所使用的硬件必须与内核驱动程序解绑，而是在应用程序运行之前绑定到vfio-pci内核模块上。对于这样的PMD，Linux控制下的任何网络端口或其他硬件将被忽略，并且不能被应用程序使用。

为了将端口绑定到用于DPDK的vfio-pci模块，或将端口返回到Linux控制，用户工具子目录中提供了一个名为dpdk-devbind.py的实用程序脚本。此实用程序可用于提供系统上网络端口的当前状态视图，并将这些端口绑定和解除绑定到不同的内核模块，包括VFIO和UIO模块。以下是一些如何使用脚本的示例。通过使用--help或--usage选项调用脚本，可以获得脚本及其参数的完整说明。请注意，在运行dpdk-devbind.py脚本之前，应将UIO或VFIO内核模块加载到内核中。

> 由于VFIO的工作方式，使用VFIO的设备存在某些限制。这主要取决于IOMMU组的工作方式。任何虚拟功能设备通常都可以单独与VFIO一起使用，但物理设备可能需要所有端口都绑定到VFIO，或者其中一些端口绑定到VFIO，而其他端口则不绑定到任何东西。

> 如果您的设备位于PCI-to-PCI桥之后，该桥将成为您的设备所在的IOMMU组的一部分。因此，桥接驱动程序也应该从桥接PCI设备上解绑，以便VFIO与桥接后面的设备一起工作。

> 虽然任何用户都可以运行dpdk-devbind.py脚本来查看网络端口的状况，但是绑定或解绑网络端口需要root权限。

#### VFIO

VFIO 是一个强大且安全的驱动程序，依赖于 IOMMU 保护。要使用 VFIO，必须加载 vfio-pci 模块：
```
sudo modprobe vfio-pci
```

通常所有分发版本都默认包含了 VFIO 内核，但是，请参阅您分发版本的文档，确保如此。

为了使用 VFIO 的全部功能，内核和 BIOS 都必须支持 IO 虚拟化（如 Intel VT-d）并配置为使用 IO 虚拟化。

##### VFIO no-IOMMU 模式

如果系统上没有可用的IOMMU，VFIO仍然可以使用，但它必须加载一个额外的模块参数：

```
modprobe vfio enable_unsafe_noiommu_mode=1
```

另外，也可以在已经加载的内核模块中启用此选项：

```
echo 1 > /sys/module/vfio/parameters/enable_unsafe_noiommu_mode
```

之后，VFIO 可以像往常一样与硬件设备一起使用。

##### VFIO 内存映射限制

对于外部内存还是巨页，DMA映射都使用VFIO接口。VFIO不支持已映射内存的部分卸载。因此，DPDK的内存以巨页粒度或系统页粒度进行映射。DMA映射的数量受内核限制，其中用户锁定进程的系统/巨页内存的内存限制（rlimit）。内核5.1中添加了另一个适用于外部内存和系统内存的每个容器的总体限制已添加，由VFIO模块参数`dma_entry_limit`定义，默认值为64K。当应用程序超出DMA条目时，需要调整这些限制以增加允许的限制。

当使用了 --no-huge 选项时，所使用的页面大小为 4K 或 64K 的较小大小，我们需要增加 `dma_entry_limit`。

要更新`dma_entry_limit`，`vfio_iommu_type1`必须加载额外的模块参数：

```shell
modprobe vfio_iommu_type1 dma_entry_limit=512000
```

另外，还可以在已加载的内核模块中更改此值：

```shell
echo 512000 > /sys/module/vfio_iommu_type1/parameters/dma_entry_limit
```

##### 使用vfio-pci创建虚拟函数

自 Linux 5.7 版本以来，vfio-pci 模块支持创建虚拟功能。将 PF 与 vfio-pci 模块绑定后，用户可以使用 sysfs 接口创建 VFs，这些 VFs 将自动绑定到 vfio-pci 模块。

当 PF 与 vfio-pci 绑定时，默认情况下会有一个随机生成的 VF token。出于安全原因，此令牌只能写入，因此用户无法直接从内核读取它。要访问 VFs，用户需要创建一个新的令牌，并使用它来初始化 VF 和 PF 设备。令牌采用 UUID 格式，因此可以使用任何 UUID 生成工具来创建新令牌。

您可以将这个VF令牌通过使用EAL参数 --vfio-vf-token 传递给DPDK。该令牌将用于应用程序中的所有PF和VF端口。

1. 通过uuid命令生成VF令牌
```
14d63f20-8445-11ea-8900-1f9ce7d5650d
```
2. 使用 enable_sriov 参数加载 vfio-pci 模块
```
sudo modprobe vfio-pci enable_sriov=1
```
另外，如果模块已经加载或已内建，通过sysfs传递enable_sriov参数：
```
echo 1 | sudo tee /sys/module/vfio_pci/parameters/enable_sriov
```
3. 将PCI设备绑定到vfio-pci驱动程序
```
./usertools/dpdk-devbind.py -b vfio-pci 0000:86:00.0
```
4. 创建所需数量的VF设备
```
echo 2 > /sys/bus/pci/devices/0000:86:00.0/sriov_numvfs
```
5. 启动将管理PF设备的应用程序DPDK
```
<build_dir>/app/dpdk-testpmd -l 22-25 -n 4 -a 86:00.0 \
    --vfio-vf-token=14d63f20-8445-11ea-8900-1f9ce7d5650d --file-prefix=pf -- -i
```
6. 启动DPDK应用程序，该程序将管理VF设备
```
<build_dir>/app/dpdk-testpmd -l 26-29 -n 4 -a 86:02.0 \
    --vfio-vf-token=14d63f20-8445-11ea-8900-1f9ce7d5650d --file-prefix=vf0 -- -i
```
##### VFIO问题解决


##### VFIO平台相关

VFIO Platform 是一个内核驱动程序，通过为位于 IOMMU 之后的平台设备添加支持来扩展 VFIO 的功能。与 PCI 设备等内置必要信息的设备不同，Linux 通常在启动阶段直接从设备树中了解平台设备。

要使用VFIO平台，必须首先加载vfio-platform模块：
```
sudo modprobe vfio-platform
```

之后，平台设备需要绑定到 vfio-platform。这是一个需要两步的标准过程。首先，在平台设备目录中，需要将 driver_override 设置为 vfio-platform：

```
sudo echo vfio-platform > /sys/bus/platform/devices/DEV/driver_override
```

下一个开发设备必须绑定到 vfio-platform 驱动程序：

```
sudo echo DEV > /sys/bus/platform/drivers/vfio-platform/bind
```

在应用程序启动时，DPDK平台总线驱动程序会扫描`/sys/bus/platform/devices`目录，查找指向`vfio-platform`驱动程序的设备符号链接。最后，扫描的设备与可用的PMD进行匹配。如果PMD名称或PMD别名与内核驱动程序名称匹配，或者PMD名称与平台设备名称匹配，则匹配成功。

VFIO平台依赖于ARM/ARM64，通常在运行这些系统的发行版上启用。请查阅您的发行版文档，以确保情况如此。

#### Bifurcated 驱动

使用分叉驱动器的PMD与设备内核驱动程序共存。在这样的模型中，NIC由内核控制，而数据路径则由PMD直接在设备上执行。

该模型具有以下优点：
- 它安全且健壮，因为内存管理和隔离是由内核完成的。
- 它使用户能够在同一网络端口上运行DPDK应用程序时使用旧的Linux工具，例如ethtool或ifconfig。
- 它使DPDK应用程序能够仅过滤部分流量，而其余流量将由内核驱动程序进行定向和处理。流分叉由NIC硬件执行。例如，使用Flow隔离模式可以选择在DPDK中接收的内容。

#### UIO

在无法使用 VFIO 的情况下，还有其他可用的驱动程序。在许多情况下，Linux内核中包含的标准uio_pci_generic模块可以用作VFIO的替代品。可以使用以下命令加载此模块：

```
sudo modprobe uio_pci_generic
```
uio_pci_generic模块不支持创建虚拟函数。

除了uio_pci_generic，还有一个名为igb_uio的模块，可以在DPDK仓库dpdk-kmods中找到。它可以通过如下方式加载：

```
sudo modprobe uio
sudo insmod igb_uio.ko
```
对于一些不支持传统中断的设备，例如虚拟功能（VF）设备，可能需要使用igb_uio模块来代替uio_pci_generic。

如果启用了UEFI secure boot，Linux内核可能会禁止在系统上使用UIO。因此，用于DPDK的设备应该绑定到vfio-pci内核模块，而不是任何基于UIO的模块。更多详细信息请参阅以下绑定和取消绑定网络端口到/从内核模块部分。

如果用于DPDK的设备绑定到基于UIO的内核模块，请确保IOMMU被禁用或处于直通模式。可以在x86_64系统上，在GRUB命令行中添加intel_iommu=off或amd_iommu=off或intel_iommu=on iommu=pt，或者在aarch64系统上添加iommu.passthrough=1。

## 运行程序

该章节描述了如何在DPDK环境中编译和运行应用程序。它还提供了一个指向存储示例应用程序的指针。

### 编译程序

### 运行程序

在运行应用程序之前，请确保：
- 大页面的设置已经完成。
- 正在使用的内核驱动程序已经加载。
- 如果需要，应用程序使用的端口应绑定到相应的内核驱动。

该应用程序与DPDK目标环境的环境抽象层（EAL）库相连接，该库为每个DPDK应用程序提供了一些通用选项。

以下是可以提供给EAL的选项列表：
```
./rte-app [-c COREMASK | -l CORELIST] [-n NUM] [-b <domain:bus:devid.func>] \
          [--socket-mem=MB,...] [-d LIB.so|DIR] [-m MB] [-r NUM] [-v] [--file-prefix] \
          [--proc-type <primary|secondary|auto>]
```

EAL选项如下：
- `-c COREMASK` 或 `-l CORELIST`: 用于运行的核的十六进制位掩码。请注意，核的编号在不同的平台之间可能会有所不同，因此应事先确定。corelist 是一组核编号，而不是位图核掩码。
- `-n NUM`: 每个处理器套接字的内存通道数。
- `-b domain:bus:devid.func`: 端口的禁用；防止 EAL 使用指定的 PCI 设备（允许多个 -b 选项）。
- `--use-device`: 只使用指定的以太网设备(s)。使用逗号分隔的 [domain:]bus:devid.func 值。不能与 -b 选项一起使用。
- `--socket-mem`: 在特定套接字上从 hugepages 分配的内存。在动态内存模式下，此内存也将被固定（即，应用程序关闭之前不会释放回系统）。
- `--socket-limit`: 限制每个套接字上可分配的最大内存。不支持传统内存模式。
- `-d`: 添加要加载的驱动程序或驱动程序目录。应用程序应使用此选项来加载作为共享库构建的 PMDs。
- `-m MB`: 从 hugepages 分配的内存，无论处理器套接字如何。建议使用 --socket-mem 而不是此选项。
- `-r NUM`: 内存等级数。
- `-v`: 在启动时显示版本信息。
- `--huge-dir`: hugetlbfs 挂载的目录。
- `--mbuf-pool-ops-name`: 要使用的 mbuf 的池操作名称。
- `--file-prefix`: hugepage 文件名的前缀文本。
- `--proc-type`: 进程实例的类型。
- `--vmware-tsc-map`: 使用 VMware TSC 映射而不是本地 RDTSC。
- `--base-virtaddr`: 指定基本虚拟地址。
- `--vfio-intr`: 指定 VFIO 要使用的中断类型（如果未使用 VFIO，则无效）。
- `--legacy-mem`: 在传统内存模式下运行 DPDK（禁用运行时的内存预留/取消预留，但提供更多 IOVA 连续内存）。
- `--single-file-segments`: 将内存段存储在更少的文件中（仅限动态内存模式 - 不影响传统内存模式）。

-c 或 -l 选项是必须的，其他选项是可选的。

将DPDK应用程序二进制文件复制到目标设备上，然后按以下方式运行应用程序（假设每个处理器套接字有四个内存通道，并且核心0-3存在，并用于运行应用程序）：
```
./dpdk-helloworld -l 0-3 -n 4
```

> --proc-type和--file-prefix EAL选项用于运行多个DPDK进程。更多详细信息请参见DPDK样本应用程序用户指南中的“多进程样本应用程序”章节和DPDK程序员指南。


#### 应用程序的逻辑核心用途

对于DPDK应用程序，coremask（-c 0x0f）或corelist（-l 0-3）参数始终是必需的。首选的corelist选项是一种更清晰的方法来定义要使用的核心。首选的核心列表选项是定义要使用的核心的更清晰的方法。/corelist时考虑每个平台的core布局。下的coremask/corelist时，应考虑每个平台的core布局。

在DPDK应用程序初始化EAL层时，将显示要使用的逻辑核心及其套接字位置。每个处理器列出的物理id属性指示它所属的CPU套接字。当使用其他处理器时，这可能对于理解逻辑核心与套接字的映射很有用。

使用 lstopo Linux 工具可以获得逻辑核心布局的更图形化的视图。在 Fedora 上，可以通过以下命令来安装和运行这个工具：

```shell
sudo yum install hwloc
lstopo
```

这个命令会产生一个相当短的文本输出：

```shell
lstopo-no-graphics --merge
```

逻辑核心布局可以在不同的板布局之间更改，并且应该在选择应用程序 coremask/corelist 之前进行核查。

#### 应用程序使用的 Hugepage 内存

在运行应用程序时，建议使用与为 huge pages 分配的内存量相同的内存。如果运行时没有传递 -m 或 --socket-mem 参数，DPDK 应用程序会在启动时自动执行此操作。

如果用户明确传递了 -m 或 --socket-mem 值来请求更多内存，应用程序将失败。但是，如果用户请求的内存量少于保留的 hugepage-memory 数量，特别是如果使用 -m 选项，应用程序本身也可能失败。原因如下。假设系统在套接字 0 中有 1024 个预留的 2 MB 页面，在套接字 1 中有 1024 个。如果用户请求 128 MB 的内存，这 64 个页面可能不符合约束条件：

- 仅在内核在 socket 1 中为应用程序分配了巨页内存。在这种情况下，如果应用程序试图在 socket 0 中创建对象（例如环形或内存池），它将失败。为了避免这个问题，建议使用 --socket-mem 选项而不是 -m 选项。
- 这些页面可以位于物理内存的任何位置，尽管 DPDK EAL 会尝试分配连续的内存块，但页面可能不会连续。在这种情况下，应用程序无法分配大内存池。

socket-mem 选项可用于为特定套接字请求特定数量的内存。这是通过提供 --socket-mem 标志以及每个套接字上请求的内存量来完成的，例如，提供 --socket-mem=0,512 试图只为套接字 1 保留 512 MB 内存。同样，对于一个四套接字系统，如果只想在套接字 0 和 2 上分配 1 GB 内存，可以使用参数 --socket-mem=1024,0,1024。未明确引用的任何 CPU 套接字上都不会保留内存，例如，在这种情况下为套接字 3。如果 DPDK 在每个套接字上无法分配足够的内存，EAL 初始化将失败。

### 附加样本应用程序

DPDK 示例目录中包含了其他样本应用程序。这些样本应用程序的构建和运行方式可能与本手册前面章节所述的方式类似。此外，请参阅 DPDK 样本应用程序用户指南，以了解应用程序的描述、编译和执行的特定说明以及代码的一些解释。


## EAL参数

这份文档包含所有 EAL 参数的列表。这些参数可以被任何在 Linux 上运行的 DPDK 应用程序使用。

### EAL 通用参数

以下EAL参数是DPDK所支持的所有平台都有的通用参数。

#### Lcore-related options

- `-c <core mask>`：设置要运行的核的十六进制位掩码。
- `-l <core list>`：要运行的核的列表；参数格式为 <c1>[-c2][,c3[-c4],...] 其中 c1、c2 等是介于 0 和 128 之间的核索引。
- `--lcores <core map>`：将 lcore 映射到物理 CPU 集

Lcore 和 CPU 列表通过 ( and ) 进行分组。在组内 `-` 字符用作范围分隔符；`,` 用于分隔单个数字。如果只有一个元素，则可以省略分组 `()`；`@` 可省略。

#### debug 选项

#### 其它选项

### Linux相关 EAL 参数

#### 设备相关选项
#### 多处理器相关选项
#### 内存相关选项
#### 其它选项

## 启用附加功能

### 无须Root权限运行DPDK

以下部分描述了作为非root用户运行DPDK应用程序的通用要求和配置。对于某些驱动程序，可能还有额外的要求。

### Hugepages

在以非root用户身份运行应用程序之前，必须以root用户身份预留Hugepages，例如：
```shell
sudo dpdk-hugepages.py --reserve 1G
```

如果不需要多进程，使用 `--in-memory` 可以绕过访问巨页挂载点和其中的文件的需求。否则，必须使巨页目录对无特权用户可写。管理使用巨页的多个应用程序的好方法是使用组权限挂载文件系统，并向每个应用程序或容器添加一个补充组。

一个选项是使用该项目提供的脚本：

```
export HUGEDIR=$HOME/huge-1G
mkdir -p $HUGEDIR
sudo dpdk-hugepages.py --mount --directory $HUGEDIR --user `id -u` --group `id -g`
```

在生产环境中，操作系统可以管理挂载点（以systemd为例）。

hugetlb文件系统有额外的选项，可以保证或限制使用挂载点分配的内存量。请参阅文档。

> 使用 vf，使用 vfio-pci 内核驱动程序可以消除对物理地址的需求，因此可以消除下文所述的权限要求。

如果驱动程序需要使用物理地址 (PA)，则可执行文件必须获得额外的功能：
- `DAC_READ_SEARCH` and `SYS_ADMIN` to read `/proc/self/pagemaps`
- `IPC_LOCK` to lock hugepages in memory

```
setcap cap_dac_read_search,cap_ipc_lock,cap_sys_admin+ep <executable>
```

如果物理地址不可访问，在EAL初始化过程中将出现以下消息：
```
EAL: rte_mem_virt2phy(): cannot open /proc/self/pagemap: Permission denied
```

### 资源限制

以非root用户身份运行时，系统可能会施加一些额外的资源限制。具体来说，为了确保DPDK的正常运行，可能需要调整以下资源限制：

- `RLIMIT_LOCKS` (number of file locks that can be held by a process)
- `RLIMIT_NOFILE` (number of open file descriptors that can be held open by a process)
- `RLIMIT_MEMLOCK` (amount of pinned pages the process is allowed to have)

The above limits can usually be adjusted by editing /etc/security/limits.conf file, and rebooting.

### 设备控制

If the HPET is to be used, `/dev/hpet` permissions must be adjusted.

对于vfio-pci内核驱动程序，应调整以下Linux文件系统对象的权限：
- VFIO 设备文件，`/dev/vfio/vfio`
- 在 `/dev/vfio` 下与打算由 DPDK 使用的设备的 IOMMU 组号相对应的目录，例如，`/dev/vfio/50`

## 电源管理和节能功能

## 使用Linux核心隔离技术以减少上下文切换

虽然DPDK应用程序使用的线程被固定在系统上的逻辑核心上，但Linux调度器仍有可能在这些核心上运行其他任务。为了防止在这些核心上运行其他工作负载、计时器、RCU处理和IRQ，可以使用Linux内核参数`isolcpus`、`nohz_full`、`irqaffinity`来将它们与Linux调度器的常规任务隔离。

例如，如果给定的 CPU 有 0-7 个核心，而 DPDK 应用程序需要在逻辑核心 2、4 和 6 上运行，那么应将以下内容添加到内核参数列表中：
```
isolcpus=2,4,6 nohz_full=2,4,6 irqaffinity=0,1,3,5,7
```
为了对资源管理和性能调整进行更精细的控制，可以考虑使用“Linux cgroups”、cpusets、cpuset man pages以及systemd CPU亲和性。


## 高精度事件计时器（HPET）功能

DPDK可以支持系统HPET作为计时器源，而不是系统默认的计时器，例如x86系统上的核心时间戳计数器（TSC）。要在DPDK中启用HPET支持：
- 确保在BIOS设置中启用了HPET。
- 在内核配置中启用`HPET_MMAP`支持。请注意，这可能需要重新构建内核，因为许多常见的Linux发行版在其内核构建中默认未启用此设置。
- 通过使用构建时选项`use_hpet`启用DPDK对HPET的支持，例如，使用`meson`配置`-Duse_hpet=true`。

应用程序若要使用`rte_get_hpet_cycles()`和`rte_get_hpet_hz()`这两个API调用，并且可选地让H使 HPET 成为 `rte_timer` 库的默认时间源，应在应用程序初始化时调用 `rte_eal_hpet_init()` API 调用。此 API 调用将确保 HPET 可访问，如果不可访问，则向应用程序返回错误。

对于需要计时 API 但不需要特定 HPET 计时器的应用程序，建议使用 `rte_get_timer_cycles()` 和 `rte_get_timer_hz()` API 调用，而不是使用特定于 HPET 的 API。这些通用 API 可以与 TSC 或 HPET 时间源一起工作，具体取决于应用程序调用 `rte_eal_hpet_init()` 的

## 如何在Intel平台上通过网卡获得最佳性能

本文档是一个逐步指南，用于在Intel平台上从DPDK应用程序中获取高性能。

### 硬件和内存需求

为了获得最佳性能，请使用Ivy Bridge、Haswell或更新版本的Intel Xeon级别服务器系统。

请确保每个内存通道至少插入一个内存DIMM，并且每个通道的内存大小至少为4GB。注意：这对性能的影响最为直接。

您可以使用dmidecode检查内存配置，如下所示：

```
dmidecode -t memory | grep Locator

Locator: DIMM_A1
Bank Locator: NODE 1
Locator: DIMM_A2
Bank Locator: NODE 1
Locator: DIMM_B1
Bank Locator: NODE 1
Locator: DIMM_B2
Bank Locator: NODE 1
...
Locator: DIMM_G1
Bank Locator: NODE 2
Locator: DIMM_G2
Bank Locator: NODE 2
Locator: DIMM_H1
Bank Locator: NODE 2
Locator: DIMM_H2
Bank Locator: NODE 2
```

输出显示的速度为2133 MHz (DDR4)和未知（不存在）。这与先前的输出一致，表明每个通道都有一根内存条。

### 网卡需求

使用DPDK支持的高端网卡，例如Intel XL710 40GbE。

确保每个网卡已经刷入最新版本的NVM/固件。

使用Gen3 PCIe插槽，例如Gen3 x8或Gen3 x16，因为Gen2 PCIe插槽不能为2 x 10GbE和更高提供足够的带宽。您可以使用lspci来检查PCI插槽的速度，如下所示：
```
lspci -s 03:00.1 -vv | grep LnkSta

LnkSta: Speed 8GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- ...
LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete+ ...
```

在将网卡插入PCI插槽时，始终检查标题，例如CPU0或CPU1，以指示它连接到的插槽。

在NUMA方面应该小心。如果您使用来自不同网卡的2个或更多端口，最好确保这些网卡位于相同的CPU插槽上。如何确定这一点的一个示例如下所示。

### BIOS设置

### Linux引导命令行

### 运行DPDK之前的配置

1. 保留大页面。 详细信息请参见前面关于 Linux 环境中 Hugepages 的使用的部分。

```
# Get the hugepage size.
awk '/Hugepagesize/ {print $2}' /proc/meminfo

# Get the total huge page numbers.
awk '/HugePages_Total/ {print $2} ' /proc/meminfo

# Unmount the hugepages.
umount `awk '/hugetlbfs/ {print $2}' /proc/mounts`

# Create the hugepage mount folder.
mkdir -p /mnt/huge

# Mount to the specific folder.
mount -t hugetlbfs nodev /mnt/huge
```

2. 使用DPDK的`cpu_layout`工具检查CPU布局：

```
cd dpdk_folder

usertools/cpu_layout.py
```

Or run lscpu to check the cores on each socket.

3. 检查你的网卡ID和相关套接字ID：

```
# List all the NICs with PCI address and device IDs.
lspci -nn | grep Eth
```
比如，假设你的输出如下：

```
82:00.0 Ethernet [0200]: Intel XL710 for 40GbE QSFP+ [8086:1583]
82:00.1 Ethernet [0200]: Intel XL710 for 40GbE QSFP+ [8086:1583]
85:00.0 Ethernet [0200]: Intel XL710 for 40GbE QSFP+ [8086:1583]
85:00.1 Ethernet [0200]: Intel XL710 for 40GbE QSFP+ [8086:1583]
```

检查与PCI设备相关的numa节点ID：

```
cat /sys/bus/pci/devices/0000\:xx\:00.x/numa_node
```

4. 通常情况下，`0x:00.x`在`socket 0`上，而`8x:00.x`在`socket 1`上。

> 注意：为了获得最佳性能，确保核心和网卡在同一个socket上。在上面的示例中，`85:00.0`在socket 1上，应该由socket 1上的核心使用以获得最佳性能。

检查需要加载哪些内核驱动程序，以及是否有必要将网络端口从其内核驱动程序中解除绑定。有关DPDK设置和Linux内核要求的更多详细信息，请参见从源代码编译DPDK目标与Linux驱动程序。

# 示例应用程序

## DPDK示例应用程序简介

DPDK 示例应用程序是小型独立应用程序，演示了 DPDK 的各种功能。它们可以视为 DPDK 功能的菜谱。对 DPDK 感兴趣的用户可以尝试这些应用程序，尝试这些功能，然后扩展它们以满足自己的需求。

### 运行程序

某些示例应用程序可能在各自指南中描述了其自己的命令行参数，然而，它们也都使用相同的EAL参数。有关可用EAL命令行选项的列表，请参阅EAL参数（Linux）或EAL参数（FreeBSD）。

### DPDK示例程序

在DPDK的示例目录中有许多示例应用程序。这些示例的范围从简单到相当复杂，但大多数示例都是为了演示DPDK的一个特定功能。下面列出了一些更有趣的示例。

- Hello World: 与大多数编程框架的介绍一样，从 Hello World 应用程序开始是一个很好的起点。Hello World 示例设置 DPDK 环境抽象层 (EAL)，并向每个启用了 DPDK 的核心打印一个简单的“Hello World”消息。此应用程序不进行任何数据包转发，但它是一个很好的测试方法，可以检查 DPDK 环境是否已正确编译和设置。
- Basic Forwarding/Skeleton Applicatiopn: 基础转发/骨架（Basic Forwarding/Skeleton）包含启用DPDK基本数据包转发所需的最低代码量。这允许您测试您的网络接口是否与DPDK兼容。
- Network Layer 2 Forwarding: 网络层2转发（l2fwd）应用程序就像一个简单的交换机一样，基于以太网MAC地址进行转发。
- Network Layer 2 forwarding: 网络层2转发或l2fwd-event应用程序基于以太网MAC地址进行转发，就像一个简单的交换机一样。它演示了在单个应用程序下使用轮询和事件模式IO机制。
- Network Layer 3 forwarding: 网络层3转发或l3fwd应用程序像简单的路由器一样基于互联网协议，IPv4或IPv6进行转发。
- Network Layer 3 forwarding Graph: 网络层3转发图（l3fwd_graph）应用程序使用DPDK图框架，基于IPv4进行转发，就像一个简单的路由器一样。
硬件数据包复制：硬件数据包复制（dmafwd）应用程序演示了如何使用DMAdev库在两个线程之间复制数据包。
- Packet Distributor: 数据包分发器演示了如何将到达Rx端口的包分发到不同的核心进行处理和传输。
- Multi-Process Application: 多进程应用程序演示了两个DPDK进程如何使用队列和内存池共享信息并协同工作。
- RX/TX callbacks Application: RX/TX回调示例应用程序是一个数据包转发应用程序，演示了如何在接收和传输数据包上使用用户定义的回调。该应用程序通过在RX（数据包到达）和TX（数据包传输）的数据包处理函数中添加回调来计算数据包之间的延迟。
- IPsec Security Gateway: IPsec 安全网关应用程序是一个更接近现实世界示例的示例。 这也是一个使用 DPDK Cryptodev 框架的应用程序的良好示例。
- Precision Time Protocol(PTP) client: PTP客户端是另一个真实世界应用程序的最小实现。在这个案例中，应用是一个PTP客户端，它通过与PTP主时钟进行通信，使用IEEE1588协议在网络接口卡同步时间。
- Quality of Service(QoS) Scheduler: QoS Scheduler 应用程序演示了如何使用 DPDK 来提供 QoS 调度。

在后续章节中提供了许多其他示例。每个记录的示例应用程序都展示了如何编译、配置和运行应用程序，并解释了代码的主要功能。

