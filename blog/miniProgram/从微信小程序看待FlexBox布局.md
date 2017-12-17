### 说明
本文是作者[Lefe](http://www.jianshu.com/p/88957fad1226)所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。
### 正文
开始学习微信小程序时，需要掌握最基本的UI布局，有了UI的布局才是一个开始。下面主要通过一些例子来聊聊FlexBox布局，其实它和ReactNative大同小异。所以学习一门技术，其它的也就不愁了。下面主要通过一些例子来说明FlexBox是如何布局的。
#### FlexBox概述

![1.png](http://upload-images.jianshu.io/upload_images/1664496-dd9f81642cc50381.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- Flex container（容器）
承载子视图的一个容器，也就是说一个视图，如果设置成`display: flex;`，那么它就是作为一个Flex container。其中它的子视图，称为FlexItem。

![2.png](http://upload-images.jianshu.io/upload_images/1664496-12101c7171d7c2b4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![3.png](http://upload-images.jianshu.io/upload_images/1664496-ec5957665f70cac5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 主轴（Main axis）:
主轴也就是水平轴，它决定了Flex item的布局的方向。也就是子视图的布局方向是从水平方向开始。
- main-start | main-end 
主轴的起点和结束点。
- main size
Flex container占主轴的空间。
- 纵轴（cross axis）
垂直于主轴的轴成为纵轴，也叫交叉轴。
- cross-start | cross-end
纵轴的起点和结束点。
- cross size
Flex container占纵轴的空间。

#### 一、容器属性介绍
- **display**：flex
如果想采用FlexBox布局，必须设置 `.container { display: flex; }`,这样这个视图将作为一个Flex container。
- **flex-direction**：row | row-reverse | column | column-reverse;
它决定了子视图的布局方向，默认的布局方向是`row`。
**me.wxml文件**
```
<view class="container">
    <view class="children1"></view>
    <view class="children2"></view>
    <view class="children3"></view>
</view>
```
**me.wxss文件**
```
.container {
    display: flex;
    background-color: lightblue;
}
.children1 {
    width: 100rpx;
    height: 100rpx;
    background-color: red;
}
.children2 {
    width: 100rpx;
    height: 100rpx;
    background-color: yellow;
}
.children3 {
    width: 100rpx;
    height: 100rpx;
    background-color: purple;
}
```
**flex-direction:column**，垂直方向布局，从上到下布局

![4.png](http://upload-images.jianshu.io/upload_images/1664496-9fe9f452a4789dac.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**flex-direction: column-reverse;**，垂直方向布局，从下到上布局
![column.png](http://upload-images.jianshu.io/upload_images/1664496-143210a0f7dc2d3a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**flex-direction: row;**，默认，水平方向布局，从左到右布局
```
.container {
    display: flex;
    flex-direction: row;
    background-color: lightblue;
}
```

![row.png](http://upload-images.jianshu.io/upload_images/1664496-8c06da566cd7aab0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**flex-direction: row-reverse;**，水平方向布局，从右到左布局
![row-reverse.png](http://upload-images.jianshu.io/upload_images/1664496-cbc25f60539e408f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- **flex-wrap**：nowrap | wrap | wrap-reverse；
默认情况下flex items是在一行进行布局，使用`flex-wrap`可以改变flex items进行多行布局。默认情况微信小程序是采用的`nowrap`,它试图采用一行对flex items进行布局。
```
.container {
    display: flex;
    flex-direction: row;
    flex-wrap: nowrap;
    background-color: lightblue;
}
```
![norwrap.png](http://upload-images.jianshu.io/upload_images/1664496-c99575c7f7d3f259.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```
.container {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    background-color: lightblue;
}
```

![wrap.png](http://upload-images.jianshu.io/upload_images/1664496-86483d128dca5a8f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- **flex-flow**: 是flex-direction 和 flex-wrap属性的简写，你可以这样定义。
```
.container {
    display: flex;
    flex-flow: row wrap;
    background-color: lightblue;
}
```
- **justify-content**:flex-start | flex-end | center | space-between | space-around;
flex items 在主轴上的对其方式。`flex-start`从主轴开始位置开始布局；`flex-end`从主轴结束位置开始布局；`center`居中布局；`space-between`第一个flex item在主轴的main-start，最后一个flex item在主轴的main-end位置；`space-around`:开始于结束的flex item所占的空间是中间flexItem直接距离的一半，中间flexItem之间的间距一样。

```
.container {
    display: flex;
    flex-flow: row wrap;
    justify-content: space-around;
    background-color: lightblue;
}
```
![space-around.png](http://upload-images.jianshu.io/upload_images/1664496-bcf84d964bdb88e1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```
.container {
    display: flex;
    flex-flow: row wrap;
    justify-content: space-between;
    background-color: lightblue;
}
```

![space-between.png](http://upload-images.jianshu.io/upload_images/1664496-c26caac7ca9537b3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- **align-items**：flex-start | flex-end | center | baseline | stretch; flex item在纵轴方向的对其方式。与主轴的布局大同小异。`flex-start`:布局的起点为cross-start；`flex-end`:布局的起点为cross-end；`center`:居中布局；`baseline`:与基线对其；
**stretch**:默认的属性，但是它依据flex item 的min-height和max-height
```
.flex-container {
    height: 400rpx;
    display: flex;
    flex-direction: row;
    justify-content: space-around;
    align-items: stretch;
    background-color: lightblue;
}
.children1 {
    width: 100rpx;
    min-height: 100rpx;
    background-color: red;
}
```

![stretch.png](http://upload-images.jianshu.io/upload_images/1664496-c3021ff3a288895a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- **align-content**:flex-start | flex-end | center | space-between | space-around | stretch;。多行时，纵轴的对齐方式，如果只有一行，它是没有作用的。
```
.flex-container {
    height: 400rpx;
    display: flex;
    flex-direction: row;
    justify-content: space-around;
    align-items: stretch;
    flex-wrap: wrap;
    align-content: flex-end;
    background-color: lightblue;
}
.children1 {
    width: 600rpx;
    height: 100rpx;
    background-color: red;
}
.children2 {
    width: 600rpx;
    height: 100rpx;
    background-color: yellow;
}
.children3 {
    width: 600rpx;
    height: 100rpx;
    background-color: purple;
}
```

![align-content.png](http://upload-images.jianshu.io/upload_images/1664496-a3e3458c2562af5f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 二、Flex item属性介绍
- **order**：控制Flex item的顺序
```
.children1 {
    width: 100rpx;
    height: 100rpx;
    order: 3;
    background-color: red;
}
```
- **flex-grow**: 它必须是一个整数，它表示如何分配剩余的空间，只越大他所分配的剩余空间就越大。
```
.children1 {
    width: 20rpx;
    flex-grow: 1;
    height: 100rpx;
    background-color: red;
}
.children2 {
    width: 100rpx;
    height: 100rpx;
    background-color: yellow;
}
.children3 {
    width: 100rpx;
    flex-grow: 2;
    height: 100rpx;
    background-color: purple;
}
```

![flex-grow.png](http://upload-images.jianshu.io/upload_images/1664496-c5413989c95a4e09.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- **flex-shrink**: 它必须是一个整数，它表示如何缩小Flex item，当空间不足时，是否要缩小。
```
.children1 {
    width: 1000rpx;
    flex-shrink: 2;
    height: 100rpx;
    background-color: red;
}
.children2 {
    width: 100rpx;
    height: 100rpx;
    flex-shrink: 0;
    background-color: yellow;
}
.children3 {
    width: 1000rpx;
    flex-shrink: 3;
    height: 100rpx;
    background-color: purple;
}
```

![flex-shrink.png](http://upload-images.jianshu.io/upload_images/1664496-8d1b1a0499b7fa7c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- **flex-basis**:属性定义了在分配多余空间之前，项目占据的主轴空间（main size）,他可以是固定的宽度，也可以是百分比。
```
.children1 {
    height: 100rpx;
    flex-basis: 50%;
    background-color: red;
}
```

- **flex**: 它是`flex-grow`, `flex-shrink` 和`flex-basis`的缩写。默认值为`0 1 auto`。

- **align-self**:auto | flex-start | flex-end | center | baseline | stretch;表示单独一个Flex item的对其方式。

###参考：
[阮一峰](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)
[Flex box guide](https://css-tricks.com/snippets/css/a-guide-to-flexbox/)

[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
