**本文由 [iMetalk](https://lefex.github.io/) 团队的成员 `Lefe` 完成，主要帮助读者从iOS的角度入门小程序**。    
对于一名iOS开发者来说，微信小程序的出现，让我们感觉到些许的不安，`Lefe`接触一段时间后，发现其实不然，微信小程序不可能替代原生APP，也没有绝对的优势战胜原生APP。不过，微信小程序固然有它的好处，比如我们需要用到的那些不常用的服务。对于小企业来说，可以更便捷地宣传他们的服务，给顾客一个更好的线下体验。那么对于一个iOS开发的成员来说开发小程序会有哪些挑战呢？
## 回顾iOS的开发过程
最基本的iOS开发，大致会有以下流程:   

- 开发工具，Xcode；
- UI层，页面的搭建；
- 网络层，基本的网络请求；
- 页面跳转及传值；
- 事件；
- 数据层，缓存；

## 小程序开发流程
小程序的开发流程完全可以按照开发一个原生APP的流程，`Lefe`也是按照这个流程入门小程序的。总体感觉没那么复杂，相信只要你静下心来仔细的去研究，开发一款微信小程序是很容易的。

**一：开发工具**

iOS开发我们使用`Xcode`开发，下载直接安装，新建一个项目，即可运行。微信小程序使用官方提供的工具`微信Web开发者工具`，下载安装，即可创建项目，不过创建项目时需要微信授权登录。同样，创建项目的时候微信提供了一个模板，打开项目即可看到实时预览的效果。不过这里有一个比较坑的问题是，预览小程序时不能链接VPN。`Lefe`建议打开`微信Web开发者工具`前关闭VPN，等项目运行起来后再打开VPN。

**二：搭建UI界面**   

对于iOS开发者来说，UI布局可以使用坐标（Frame）来直接布局一个视图，也可以使用自动布局。而对于微信小程序来说，建议使用`Flexbox`布局，它会给你一种不一样的布局方式。`Flexbox`布局，也叫弹性布局，是CSS3提出的一种布局解决方案。说到布局时，必须说明一下`rpx`，这种屏幕适配解决方案让我们羡慕忌妒恨（开玩笑呢）。
> rpx的全称是responsive pixel，它是小程序自己定义的一个尺寸单位，可以根据当前设备屏幕宽度进行自适应。小程序中规定，所有的设备屏幕宽度都为750rpx，根据设备屏幕实际宽度的不同，1rpx所代表的实际像素值也不一样。

比如我们要实现以下布局，仅需要不多的几行代码就可以搞定，关于`Flexbox`布局这里不做更多的解释。有兴趣的同学可以找相关资料。
   

![](http://upload-images.jianshu.io/upload_images/1664496-ca8193fa6e8a202a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**1.简单的Flexbox布局：** 

简单的几行代码：   
**.wxml文件:**

```
// class='xxx',xxx样式，如同CSS样式
<view class="flex-container">
    <view class="children1"></view>
    <view class="children2"></view>
    <view class="children3"></view>
</view>

```

**.wxss文件:**    

```
.flex-container {
    height: 200rpx; // 注意单位 rpx，当然px也可以
    display: flex; // 设置这个属性后，表示为Flexbox布局
    flex-direction: row; // 布局方向为行
    justify-content: space-around; // X轴的对齐方式
    align-items: center; // Y轴的对齐方式
    background-color: lightblue;
}
.children1 {
    height: 100rpx;
    width: 100rpx;
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

**2.微信小程序没有`UITableView`：**  
如果想做一个列表，只能用`scroll-view`，而且特别好用，我们只需要把你将要创建的视图添加到`scroll-view`标签中即可，也不需要计算子视图的高度。比如做一个图文混排的页面。
![图文混排](http://upload-images.jianshu.io/upload_images/1664496-ddadb6e504022c2c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

对于这个页面，OC会咋么实现呢？思考中......，看看小程序的实现吧，看完后，你绝对有想学小程序的冲动，而且它的流畅度也不亚于原生应用，只是第一次进入时稍微慢点。直接上代码：

**.wxml文件:**

```
<view class="promise-container">
    <view class="promise-title-container">
      //goodInfo 是一个Json，存放数据
      <text class="promise-title">{{goodInfo.detail.title}}</text>
      <view class="promise-title-line"></view>
    </view>
   //相当于一个for循环
  <block wx:for="{{goodInfo.detail.data}}">
    //根据不同类型来渲染图片还是文字
    <view wx:if="{{item.type==1}}" class="promise-container">
      <image src="{{item.content}}" class="good-image"></image>
    </view>
    <view wx:if="{{item.type==0}}" class="promise-container">
      <text class="good-content">{{item.content}}</text>
    </view>
</block>
</view>
```

**.wxss文件:** 

```
.promise-container {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-content: center;
}
.promise-title-container {
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    align-content: center;
    margin-top: 40rpx;
    margin-left: 16rpx;
    margin-right: 40rpx;
    margin-bottom: 40rpx;
}
.promise-title-line {
    height: 1rpx;
    background-color: #FF4642;
    margin-top: 6rpx;
    width: 177rpx;
}
.promise-title {
    font-size: 44rpx;
}
.promise-content {
    margin-top: 0rpx;
    margin-left: 16rpx;
    margin-right: 16rpx;
    font-size: 32rpx;
    color: #505050;
    line-height: 40rpx;
}
.good-image {
    margin-top: 8rpx;
    margin-bottom: 8rpx;
}
.good-content {
    margin-top: 8rpx;
    margin-left: 16rpx;
    margin-right: 16rpx;
    font-size: 32rpx;
    color: #505050;
    line-height: 40rpx;
}

```
看到了吗，就需要这么几行代码，而且图片也会自动加载，自动等比缩放。是不是觉得很简单。通过以上的例子，相信读者朋友已经大体上明白了FlexBox布局。更多关于`FlexBox`，可以参考作者早期的一片 [文章](http://www.jianshu.com/p/957d709f5ef4) 。对于UI布局来说，微信小程序的思想值得我们借鉴，主要有以下几点：    

**(1).各个文件分工明确：**

- `.wxml`负责页面的布局，也就是布局文件
- `.wxss`负责每个视图的样式，比如字体大小等样式
- `.js`监听并处理小程序的生命周期函数、声明全局变量，数据都在这里。

**(2).布局简单：**

创建UI的时候，微信小程序更加简单，而且会自动适配屏幕，不过需要使用`rpx`为单位。

**(3).系统提供了常用的控间：**

系统提供了我们常用的控件，这样搭建届面的时候会省很多事。那么既然布局这么简单，iOS方面会不会也有这中布局方式的，果不其然，[Yoga](https://github.com/facebook/yoga) 是`facebook`实现的一个库，有兴趣的读者可以研究一下。

**三：网络层**

对于iOS开发来说，网络层的设计绝对是很重要的一部分，网络层设计的好会直接关系到应用的好坏，及将来的维护成本。不过好在有一些优秀的三方库帮我们解决了很多问题。比如：[AFNetworking](https://github.com/AFNetworking/AFNetworking)， [YTKNetwork](https://github.com/yuantiku/YTKNetwork) 是基于`AFNetworking `的封装。为了简单，微信小程序已经为我们做了网络层的封装，必须是`Https`，不过`Http`也可以请求成功，只是有警告。以下是`Lefe`写的一个网络请求：

**network.js**

```
function network(baseUrl, api, params,  callback){
    var requestUrl = covertUrl(baseUrl, api);
    wx.request({
      url: requestUrl,
      data: params,
      method: 'GET', 
      header: {
      'content-type': 'application/json'
      },
      success: function(res){
        // res.data 网络请求返回的数据
        callback(true, res.data);
      },
      fail: function() {
        // fail
        callback(false);
      },
      complete: function() {
        
      }
    })
}

function covertUrl(baseUrl, params){
    return baseUrl + params;
}

module.exports = {
    network: network
}
```


**四：页面跳转及传值**

iOS中页面跳转常用的有`UINavigationController`与`Modal`形式跳转，而在小程序当中，使用官方提供的接口进行页面跳转，以`wx.navigateTo(OBJECT)`为例来说明。`url`是要跳转到页面的路径，`name`是给下一个页面传递的数据。这样就如同iOS中的`Push`。有了iOS的基础，相信理解起来很容易的。

```
bindMenu: function(event){
   wx.navigateTo({
     url: `category?name=${event.currentTarget.dataset.name}`
   })
}
```

**五：事件**

iOS中可以给视图添加一个事件，比如点击事件。而小程序中也可以给视图添加事件，而且可以携带一些参数。
这里引用微信官方的一段话：
> - 事件是视图层到逻辑层的通讯方式。
- 事件可以将用户的行为反馈到逻辑层进行处理。
- 事件可以绑定在组件上，当达到触发事件，就会执行逻辑层中对应的事件处理函数。
- 事件对象可以携带额外信息，如 id, dataset, touches。


`bindtap`后的`bindMenu`为视图绑定的事件名，`data-name`中的`name`为事件传递的参数。

```
<view bindtap="bindMenu" data-name="{{‘123’}}">
    <image src="{{item.icon}}"/>
</view>

```
我们只需要在`.js`文件中实现函数：

```
 bindMenu: function(event){
   var name = event.currentTarget.dataset.name;
 },
```
这样就形成了一个绑定，点击事件后直接把数据传递到了`.js`文件中，这样大大降低了耦合度，想想iOS中如何这样实现呢？

**六：数据层，缓存：**   
iOS中我们可以使用`Sqlite`、`Realm`、`NSUserDefault`等对数据做缓存处理，而小程序中使用了Storage对数据做缓存处理。
> 每个微信小程序都可以有自己的本地缓存，可以通过 wx.setStorage（wx.setStorageSync）、wx.getStorage（wx.getStorageSync）、wx.clearStorage（wx.clearStorageSync）可以对本地缓存进行设置、获取和清理。本地缓存最大为10MB。

## 总结
这篇文章主要帮助读者了解小程序的开发。小程序的开发过程大体上与iOS的开发过程上一致，当然如果你有`RN`或者前端开发经验，会更容易学习小程序。那么移动端如何学习小程序呢？`Lefe`建议读者先学习一下`JavaScript`、`CSS`和`HTML`。如果您发现有什么问题，欢迎给我们反馈（iMetalk@163.com）。如果您想第一时间看到我们的文章，欢迎关注公众号。

![微信公众号](http://upload-images.jianshu.io/upload_images/1664496-f94c6e4f349a2f74.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 参考
本文主要参考了以下文章：

[微信小程序官网](https://mp.weixin.qq.com/debug/wxadoc/dev/)

[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
