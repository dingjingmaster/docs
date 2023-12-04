# 文件拖拽协议

## 背景说明

当前，拖放(DND)被认为是商业质量应用程序的需求。在大多数操作系统上，对DND的支持是内置的，因此每个人都使用它，所有程序都可以相互通信。

然而，在X上，没有标准，所以不同的小组开发了他们自己的协议，结果是为一种协议编写的程序不能与为另一种协议编写的程序通信。显然，这不能满足DND允许用户将数据从任何程序拖到任何其他程序的基本要求。

我们需要的是一个每个人都可以使用的单一协议，这样所有的程序都可以通过DND交换数据。(X选择机制确保每个人都可以通过剪贴板交换数据)

这种协议的基本要求是，它在拖动过程中向用户提供视觉反馈，并允许目标从源提供的所有格式中选择自己喜欢的任何数据格式。此外，它必须是高效的，这样视觉反馈才不会落后于用户的操作，并且它必须能够避免死锁、竞争条件和异步系统中固有的其他危险。

> 最新版本:第五版，最后更新于2003年4月5日

## 术语解释

- 源窗口：表示提供数据的窗口
- 目标窗口：表示鼠标光标所在的窗口，当鼠标按键释放时候，此窗口将接收源窗口的数据

## 拖放过程

> 注：黑体字括号内的数字是发送到服务器或从服务器发出的数据包数。

**窗口（源窗口和目标窗口）通过创建 XdndAware 属性来说明它们是支持 XDND（拖放）协议的**。

### 第零步

Windows通过创建一个窗口属性XdndAware来声明支持xnd协议

### 第一步

开始拖放时候，源窗口获得 XdndSelection 的所有权。

当鼠标进入一个支持 XDND 的窗口时候，先检测此窗口是否支持拖放协议，如果支持则此时源窗口发送一个 XdndEnter 类型的 ClientMessage，这个数据包里包含了要使用的协议版本、源窗口支持拖放的数据类型（一般是mime数据类型）

### 第二步

目标窗口接收到 XdndEnter

因为 ClientMessage 数据包只能保存三种数据类型，因此源如果支持的拖放数据类型超过三种，则目标窗口必须从源窗口检索 XdndTypeList 属性，以便获得可用类型的列表。

### 第三步

源窗口发送类型为 XdndPosition 的 ClientMessage。

这个数据包会告诉目标鼠标的位置和用户请求的动作（比如：移动还是复制）

### 第四步

目标接收到 XdndPosition

目标窗口必须确定鼠标所在的widget（窗口部件：比如输入框），并询问它是否能接受鼠标拖拽信息的放置（为了提高效率，在进入不同widget或操作改变时候才会询问一次），一旦widget表示它可以接收放置，那么此widget就可以获得所有的 XdndPosition 信息，以便它可以重新绘制自己（向用户显示要插入数据的位置、鼠标的状态...）

- 如果目标窗口不能执行请求的操作，他可以返回 `XdndActionCopy` 或者 `XdndActionPrivate`，否则就要执行XDND的拒绝放置操作。
- 如果目标窗口需要查看数据本身，则需要调用 `XConvertSelection()` 来获取 `XdndSelection`。
- 如果目标窗口接受XDND的放置操作，则它应该缓存要拖放的数据，这样即使数据被删除了仍然可以在需要时再次使用

### 第五步

目标窗口发送类型为 XdndStatus 的 ClientMessage。

这个数据包告诉源窗口是否接收XDND的放置，如果接收，将采取什么操作，这个数据包里还包含一个矩形区域的信息，告诉源窗口，当鼠标没有移出此矩形范围前不要再发送任何 XdndPosition 消息。

### 第六步

源窗口接收到 XdndStatus ，它可以使用该操作来改变光标，以显示是否执行用户请求的操作

当鼠标移出给定的矩形窗口之时，转到步骤4

XdndPosition消息通常由 MotionNotify 事件触发。但是，如果在源窗口等待 XdndStatus 消息时候鼠标移动，源窗口必须缓存新的鼠标位置，并在接收到 XdndStatus 消息后立即生成另一个 XdndPosition 消息（当服务器与目标窗口连接 比 服务器与源窗口连接 慢很多时候，这么做是必要的）。

### 第七步

当鼠标离开窗口，源窗口发送 XdndLeave 类型的 ClientMessage。

如果在目标窗口中释放鼠标按钮，则源窗口等待最后一个 XdndStatus 消息（如果需要），然后根据最后一个 XdndStatus 中是否接收发送类型给目标窗口发送 XdndLeave 或 XdndDrop 的 ClientMessage 数据包。

如果源窗口没有收到任何 XdndStatus 消息，它应该发送 XdndLeave，而不需要等待。

如果源窗口在合理的时间段内没有收到预期的 XdndStatus，它应该发送 XdndLeave。在等待 XdndStatus 期间，源窗口可以阻塞，但它必须至少处理 SelectionRequest 事件，以便目标可以检查数据。

### 第八步

如果目标窗口接收到 `XdndLeave`，它将释放所有缓存的数据并忘记整个事件。

如果目标窗口接收到 `XdndDrop` 并接收它，那么它首先使用 XConvertSelection() 使用给定的时间戳检索数据（如果它还没有缓存数据）。然后，它将数据与通过 `XdndStatus` 确认的最后一个动作和鼠标位置结合使用。

一旦完成拖拽操作，目标窗口将发送 `XdndFinished`。

## 补充说明

### XdndAware

为了使用户使用 XDND 将源窗口数据拖拽到目标窗口，程序如果支持 XDND 的最高版本是 N，那么也必须支持以前的（3 到 N-1）版本。

XdndAware 属性提供了目标窗口支持的最大版本。如果源窗口支持的 XDND 版本大于 目标窗口，那么使用时候取二者最小版本。

### X Selection

通过使用 `XConvertSelection()`，可以对剪贴板和拖放操作使用相同的数据转换代码。如果目标请求类型为 `MULTIPLE`，或者源强制以增量方式发送数据（类型为：`INCR`），那么这将节省大量数据传输量。当`XdndStatus`第一次报告"`yes`"或"`no`"时候，它还使检查数据独立于消息的主序列。

通过使用 `XdndSelection`，删除的数据不会干扰 `XA_PRIMARY` 中存储的剪贴板数据。

使用 `XConvertSelection()` 存在这个一个问题：当用户可能在数据传输完成之前开始拖动其它数据时候开始拖动其它内容，那么拖动信息会被覆盖掉，同样的问题在X剪贴板上也有。

### Actions

在 XDND 中将操作与数据类型分开指定，可以避免为 N 个数据类型 和 M 个操作定义 $N * M$ 个Atom。由于用户必须完全控制将要发生的事情，因此源窗口只指定一个操作。这是在 XdndPosition 消息中传递的，以允许在拖动过程中更改它。目标窗口接收的动作会在 `XdndStatus` 消息中传递回来，以允许源窗口在光标中提供反馈。

特殊动作 `XdndActionAsk` 告诉目标窗口，它应该询问用户在放置发生后要做什么操作，这样就可以实现通过右键拖动后询问用户是执行移动？复制？或者是创建链接？或者是取消。

操作列表从 `XdndActionList` 属性中检索，显示给用户的每个操作的描述从 `XdndActionDescription` 属性中检索，两者都位于源窗口上。

注意，在检索数据之前或者发送 `XdndFinished` 之前可以使用 `XdndActionAsk` 属性询问用户到底执行啥操作。

特殊操作 `XdndActionPrivate` 告诉源窗口，目标窗口将执行无法理解的操作，并且除了数据副本之外，不需要源窗口提供任何其它操作。

### Messages

`XdndEnter` 消息启动了 XDND 会话，并给目标一个机会来设置局部变量，比如从根窗口坐标到目标窗口坐标的转换。它还提供了一个受支持的数据类型列表，这样目标就不必为 `XdndSelection`、`TARGETS` 调用 `XConvertSelection()`。

`XdndPosition` 消息提供鼠标位置，以便目标窗口不需要检查 X 服务器就可以正确的重新绘制自己。目标窗口没有其它可靠的方法来获取鼠标位置，因为 X 将强制源窗口抓取光标因此只有源窗口将接收事件。目标需要鼠标位置，因为它必须更新自己以显示将插入数据的位置，这在文本编辑器、电子表格和文件管理器中使用比较多。必须将 `XdndPosition` 消息中的时间戳传递给 `XConvertSelection()`，以确保接收到正确的数据。

`XdndStatus` 消息向源窗口反馈一些信息（比如：可能需要修改鼠标状态），并确保 XdndPosition 消息在网络连接慢时候不会堆积。
`XdndLeave` 消息将取消 XDND 会话。
`XdndDrop` 消息告诉目标窗口需要处理放置操作。必须将时间戳传递给 XConvertSelection()，以确保接收到正确的数据
`XdndFinished` 消息告诉源窗口，目标窗口已经结束并且不再需要数据。这允许源窗口实现以下三种不同行为中的一种：
- 阻塞直到消息被接收。在这种情况下，源窗口必须准备好在目标窗口发生故障时候超时，并且拒绝过时的请求。
- 不要通过比较最后获得选择的时间和选择请求中的时间戳来阻塞和拒绝过时的请求。
- 不要阻塞，要保留以前数据的历史记录。这可能很难实现，但从用户的角度来看，这显然是理想的行为，因为它允许他放弃一些东西，然后继续工作，并确保无论网络连接有多慢，目标窗口将获得数据。当源接收到 `XdndFinished` 时，它可以从其历史记录中删除该项目，从而防止它变得太大。源窗口还必须准备好在目标窗口发生故障时丢弃极其旧的数据。

## 防止拖拽出错的方法

如果XdndEnter消息中的版本号高于目标所能支持的版本号，则目标应该忽略该拖拽源。

当源和目标相互接收来自对方的xnd消息时，它们应该忽略来自其他窗口的所有xnd消息。

如果任何一个应用程序在DND活动时崩溃，另一个应用程序必须避免因`BadWindow`错误而崩溃。唯一安全的方法是通过使用`XSetErrorHandler()`安装错误处理程序来捕获错误。此外，目标还必须侦听`DestroyNotify`事件，这样如果源在接收`XdndStatus`和发送`XdndPosition`之间崩溃，它就不会永远等待另一个`XdndPosition`。
- 如果目标崩溃，源将自动接收另一个`EnterNotify`事件，就好像鼠标已经移动一样。网络中的任何`XdndPosition`都将生成`BadWindow`错误。
- 如果源崩溃，目标应该像对待`XdndLeave`一样对待它。如上所述，如果目标不发送`XdndFinished`，则源必须小心避免卡死。

## 实现细节——Atoms 和 属性

> 下面提到的所有常量都是 X Atoms 的字符串名

### XdndAware

此窗口属性必须为 `XA_ATOM` 类型，并且必须包含目标支持的协议的最高版本号。(版本号从0开始。最大版本号是0xFF，因为在`XdndEnter`消息中只为它分配了一个字节。每三个月就有一个新版本，这是一个非常快速的更新，它将持续64年)；必须在每个顶级X窗口上设置该属性，这个顶级X窗口中包含可以接受放置的Widget。(3新版功能)不应该在子窗口上设置该属性。目标窗口必须将消息分派到适当的小Widget。由于窗口管理器经常插入额外的窗口层，这需要使用 `XTranslateCoordinates()` 向下搜索子窗口树。

### XdndSelection

当目标窗口希望在拖放阶段检查数据以及在拖放之后检索数据时，将使用它。

### Data types

所有数据类型都由其相应的X原子引用。原子名是对应的MIME类型，全部小写。(MIME的RFC: 2045, 2047, 2048, 2049)

### XdndTypeList

如果源窗口支持超过3种数据类型，则必须在源窗口上设置此窗口属性，必须为 `XA_ATOM` 类型，并且必须包含所有支持的数据类型的列表。

### Actions

所有的动作都由对应的X Atom指代。预定义的操作有：`XdndActionCopy`、 `XdndActionMove`、 `XdndActionLink`、 `XdndActionAsk`、 `XdndActionPrivate`

### XdndActionList

如果源窗口发送 `XdndActionAsk`，则必须在源窗口上设置此窗口属性，必须为 `XA_ATOM` 类型，并且必须包含所有支持的操作的列表。列表中第一项是默认的操作。

### XdndActionDescription

如果源发送`XdndActionAsk`，这个窗口属性必须在源窗口上设置，必须是`XA_STRING`类型，并且必须包含一个以NULL分隔的ASCII字符串列表，目标在向用户描述选择时应该显示这些字符串。这些字符串的顺序必须与XdndActionList属性中的原子顺序相同。

### XdndProxy

如果这个窗口属性存在，它的类型必须是`XA_WINDOW`，并且必须包含代理窗口的ID，该代理窗口应该检查`XdndAware`，并且应该接收所有客户端消息，等等。为了使代理窗口正确地工作，客户端消息、窗口或数据的适当字段。`l[0]`必须包含鼠标所在窗口的ID，而不是正在接收消息的代理窗口。应该使用代理窗口的唯一地方是在检查`XdndAware`和调用`XSendEvent()`时。代理窗口必须将`XdndProxy`属性设置为指向自身。如果它不存在或者代理窗口根本不存在，则应该忽略`XdndProxy`。

## 实现细节——ClientMessage

> 注意：所有未使用的标志必须在每个消息中设置为零。这样就可以在不增加版本号的情况下定义新的标志。

### XdndEnter

当鼠标进入支持xnd的窗口时从源窗口发送到目标窗口。

```
data.l[0];  // 源窗口的 XID
data.l[1];  // 如果源支持3种以上的数据类型，则设置第一位为：0。
            // 高字节包含要使用的协议版本(源和目标的最高支持版本的最小值)。
            // 其余的位保留以备将来使用。
data.l[2, 3, 4]; // 包含源支持的前三种类型。
                 // 未使用的槽位设置为“None”。
                 // 排序是任意的，因为通常情况下，源无法知道目标的偏好。
```

> 如果数据源支持三种以上的数据类型，则数据的第0位。设`l[1]`。这告诉Target检查Source窗口上的属性XdndTypeList，以获得可用类型的列表。此属性应包含所有可用类型。

### XdndPosition

从源窗口发送到目标窗口，以提供鼠标位置。

```
data.l[0]; // 源窗口的 XID
data.l[1]; // 保留字段，未使用
data.l[2]; // 相对于根窗口的鼠标位置座标
           // data.l[2] = (x << 16) | y
           // 高 16 为表示 X 座标，低16位表示 Y 座标
data.l[3]; // 时间戳
data.l[4]; // 用户要执行的操作
```

### XdndStatus

从目标窗口发送到源窗口，以提供是否接受投放的反馈，如果接受，将采取什么行动。

```
data.l[0]; // 目标窗口的 XID
data.l[1]; // 第一位：当前目标窗口接受drop则设置为0
           // 第二位：当鼠标在data.l[2,3]中的矩形内移动时，
           //        如果目标想要XdndPosition消息，则设置位1。
           // 第三位之后：留待备用
data.l[2, 3]; // data.l[2] = (x << 16) | y
              // data.l[3] = (w << 16) | h
data.l[4]; // 包含目标接受的操作。
           // 这通常只允许是XdndPosition消息、XdndActionCopy
           // 或XdndActionPrivate中指定的动作。
           // 如果drop不被接受，则不应发送。
```

### XdndLeave

从源窗口发送到目标窗口，取消放置。

```
data.l[0]; // 源窗口 XID
data.l[1]; // 保留，留待以后使用
```

### XdndDrop

从源窗口发送到目标窗口以完成放置操作

```
data.l[0]; // 源窗口的 XID
data.l[1]; // 留待以后使用
data.l[2]; // 时间戳
```

### XdndFinished

从目标窗口发送到源窗口，表示源窗口可以丢弃数据，因为目标窗口不再需要访问它。

```
data.l[0]; // 目标窗口的 XID
data.l[1]; // 第一位：如果当前目标窗口接收成功并成功执行放置动作，
           //       则设置为0
data.l[2]; // 包含目标窗口要执行的动作。
           // 当拒绝放置，则其为0
```

## 附加：XEvent 结构体

所有事件都包含在 XEvent 结构体中，X 拖放 (XDND) 消息用到的是 XClientMessageEvent

```
typedef union _XEvent 
{
    int type; /* must not be changed; first element */
    XAnyEvent xany;
    XKeyEvent xkey;
    XButtonEvent xbutton;
    XMotionEvent xmotion;
    XCrossingEvent xcrossing;
    XFocusChangeEvent xfocus;
    XExposeEvent xexpose;
    XGraphicsExposeEvent xgraphicsexpose;
    XNoExposeEvent xnoexpose;
    XVisibilityEvent xvisibility;
    XCreateWindowEvent xcreatewindow;
    XDestroyWindowEvent xdestroywindow;
    XUnmapEvent xunmap;
    XMapEvent xmap;
    XMapRequestEvent xmaprequest;
    XReparentEvent xreparent;
    XConfigureEvent xconfigure;
    XGravityEvent xgravity;
    XResizeRequestEvent xresizerequest;
    XConfigureRequestEvent xconfigurerequest;
    XCirculateEvent xcirculate;
    XCirculateRequestEvent xcirculaterequest;
    XPropertyEvent xproperty;
    XSelectionClearEvent xselectionclear;
    XSelectionRequestEvent xselectionrequest;
    XSelectionEvent xselection;
    XColormapEvent xcolormap;
    XClientMessageEvent xclient;
    XMappingEvent xmapping;
    XErrorEvent xerror;
    XKeymapEvent xkeymap;
    XGenericEvent xgeneric;
    XGenericEventCookie xcookie;
    long pad[24];
} XEvent;
```


## 另附：XClientMessageEvent

```
typedef struct 
{
    int type;
    unsigned long serial;   /* # of last request processed by server */
    Bool send_event;        /* true if this came from a SendEvent request */
    Display *display;       /* Display the event was read from */
    Window window;
    Atom message_type;
    int format;
    union {
        char b[20];
        short s[10];
        long l[5];
    } data;
} XClientMessageEvent;
```

