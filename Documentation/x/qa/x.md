## x11 相关问答

### Picture 和 Pixmap有啥区别

Pixmap(像素图)：它是一种用于存储图像数据的数据结构。它是一个二维像素数组，通常用于表示窗口的背景、图像、图标等。Pixmap 是基于像素级别的图像表示，可以通过像素操作来修改和绘制图像。Pixmap中的像素数据通常与显示设备的颜色深度和格式相匹配

Picture(图片)：它是 XRender 扩展提供的一种高级图形对象。它是一个可渲染的图形对象，可以用于更复杂和高级的图像操作，如图像合成、阴影、透明度、颜色混合等。Picture 提供了对像素级别之上的渲染操作的支持，可以进行更精细的图像处理和效果，可以使用 XRender 提供的图像格式和属性，可以通过 XRender 函数进行进一步渲染和操作。

需要注意的是：
- 数据存储方式：Pixmap是像素级别的图像数组，直接存储图像数据；Picture是基于 XRender 扩展的高级图像对象，存储了更多的图像渲染相关信息。
- 功能和操作：Pixmap 主要用于基本的图像绘制和像素级别的操作，而 Picture 提供了更丰富和高级的图像操作功能，如：合成、阴影、透明度、颜色混合等。
- 渲染支持：Pixmap的渲染能力相对较弱，主要在像素级别进行操作；而 Picture 通过 XRender 扩展提供了更灵活和高级的图像渲染能力。

### XSetLineAttributes

用于设置绘制直线时候的线条属性

函数原型：
```c
int XSetLineAttributes(Display*, GC, unsigned int lineWidth, int lineStyle, int capStyle, int joinStyle);
```

- lineWidth：线条宽度，以像素为单位
- lineStyle：表示线条的样式，取值如下：
    - LineSolid：实线
    - LineOnOffDash：交替虚线
    - LineDoubleDash：双倍虚线
- capStyle：表示线条的结尾样式，取值如下：
    - CapNotLast：直线的最后一个像素没有特殊处理
    - CapButt：直线的最后一个像素被截断
    - CapRound：直线的最后一个像素被圆角化
    - CapProjectiong：直线的最后一个像素被突出显示
- joinStyle：表示线条的连接样式，取值如下：
    - JoinMiter：以尖角连接线条
    - JoinRound：以圆弧连接线条
    - JoinBevel：以斜角连接线条
