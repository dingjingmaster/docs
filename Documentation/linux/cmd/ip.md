# ip

> ip命令位于`iproute2`包中

Linux ip 命令与 ifconfig 命令类似，但比 ifconfig 命令更加强大，主要功能是用于显示或设置网络设备。ip 命令是 Linux 加强版的的网络配置工具，用于代替 ifconfig 命令。

## 语法

```shell
ip [OPTIONS] OBJECT { COMMAND | help }
```

OBJECT为常用对象，值如下：
```shell
OBJECT={ link | addr | addrlabel | route | rule | neigh | ntable | tunnel | maddr | mroute | mrule | monitor | xfrm | token }
```

- link：网络设备配置
- address：设备上的协议（IP或IPv6）地址
- addrlabel：协议地址选择的标签配置
- route：路由表条目
- rule：路由策略数据库中的规则

OPTIONS为常用选项，值可以是以下几种：
```shell
OPTIONS={ -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] | -h[uman-readable] | -iec | -f[amily] { inet | inet6 | ipx | dnet | link } | -o[neline] | -t[imestamp] | -b[atch] [filename] | -rc[vbuf] [size] }
```
常用选项的取值含义如下：
- `-V`：显示命令的版本信息
- `-s`：输出更详细的信息
- `-f`：强制使用指定的协议族
- `-4`：指定使用的网络协议是IPv4协议
- `-6`：指定使用的网络协议是IPv6协议
- `-0`：输出信息每条记录一行，即使内容较多也不做换行显示
- `-r`：显示主机时候，不显示IP地址，而是使用主机的域名

## ip link show

**显示网络接口信息：**
```shell
ip link show
```
显示结果：
```shell
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
9: enp0s20f0u4c4i2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 2a:02:2e:5b:fe:ce brd ff:ff:ff:ff:ff:ff
```
- 数字（1）：表示接口的索引号，系统内部为每个网络接口分配的唯一标识符。网络管理命令中使用索引号来指定特定的接口。比如：配置IP地址、启动或禁用接口
- 网卡名称（lo）：
- 接口状态（<LOOPBACK,UP,LOWER_UP>）：`UP`表示接口处于启动状态；`LOWER_UP`表示链路层连接已建立
- 最大传输单元（mut）：mtu 65536
- 网络队列规则（qdisc）：qdisc noqueue
- 网络接口模式（mode）：mode DEFAULT，表示当前接口的工作模式。（DEFAULT:默认模式，根据系统配置或接口类型自动确定；DORMANT：接口处于休眠模式，即接口已启用但当前未活动；MASTER：表示接口是一个主接口，用于管理和组织其它接口，如网络桥接中的桥接接口；SLAVE：表示接口是一个从接口，与主接口MASTER关联并受其管理，如网络桥接中的桥接接口）
- 网络接口的组标识（group）：group default，默认大多数接口被分配到默认组，标识0
- 接口的队列长度（qlen）：qlen 1000
- MAC地址（link/ether）：linker/ether 2a:02:2e:5b:fe:ce
- 广播地址（brd）：brd ff:ff:ff:ff:ff:ff

## ip link set

- 修改网卡状态
- 修改网卡名称
- 修改网卡 MAC 地址
- 修改网卡 MTU
- 绑定网卡到网络桥接接口

**开启/关闭网卡**
```shell
ip link set eth0 up
ip link set eth0 down
```

**开启/关闭网卡的混合模式**
```shell
ip link set eth0 promisc on
ip link set eth0 promisc off
```

网卡的混合模式：指的是网卡在数据链路层的工作模式。在混合模式下，网络接口可以接收并处理经过它的所有数据包，而不仅仅是它自己的目的地址的数据包。

混合模式在网络分析和检测中非常有用。它允许网络管理员捕获和分析经过网络接口的所有数据包，包括来自其它主机的流量。这对于网络故障排除、数据包分析、网络安全审计和网络流量监控等任务非常有帮助。

**设置网卡队列长度**

```shell
ip link set eth0 txqueuelen 1200
```

默认值是1000

**设置网卡最大传输单元**

```shell
ip link set eth0 mtu 1400
```
最大传输单元可以设置为 65535，默认是1500。

**绑定接口到网络桥接接口**
实现
```shell
ip link set eth0 master br0
```
## ip link add

创建虚拟接口，以便在系统中模拟一个新的网络接口。

**创建虚拟网卡**
```shell
ip link add eth1 type dummy
```

创建一个虚拟网卡eth1，类型为dummy

**创建桥接接口**
```shell
ip link add br0 type bridge
```

桥接接口，用于多个网络接口桥接在一起，以实现网络互通。

**创建VLAN接口**

```shell
# 创建 thn0.10的 VLAN 接口
ip link add link eth0 name thn0.10 type vlan id 10
```

用于在物理接口上创建虚拟局域网（VLAN）。

**创建隧道接口**

```shell
ip link add tun0 type ipip remote <对端IP地址> local <本地IP地址>
```

创建一个隧道接口 tun0，类型为 ipip，并指定远程IP地址和本地IP地址。





**其它网络设备相关配置**
```shell
ip link add ...
ip link delete ...
ip link set ...
ip link show ...
ip link xstats ...
ip link afstats ...
ip link property ...
```
