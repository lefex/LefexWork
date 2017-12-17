### 说明
本文是作者[Lefe](http://www.jianshu.com/p/88957fad1226)所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。
### 正文
对于客户端开发者来说，对于HTTP或HTTPS请求都非常熟悉。但是对于HTTP请求我们真的了解吗？

### 报文格式

![屏幕快照 2016-12-25 下午7.29.06.png](http://upload-images.jianshu.io/upload_images/1664496-42c5894a2f0ac952.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


###MIME(Multipurpose Internet Mail Extensions) 多用途互联网邮件扩展
> 最早的[HTTP协议](https://wapbaike.baidu.com/item/HTTP%E5%8D%8F%E8%AE%AE)中，并没有附加的[数据类型](https://wapbaike.baidu.com/item/%E6%95%B0%E6%8D%AE%E7%B1%BB%E5%9E%8B)信息，所有传送的数据都被客户程序解释为[超文本标记语言](https://wapbaike.baidu.com/item/%E8%B6%85%E6%96%87%E6%9C%AC%E6%A0%87%E8%AE%B0%E8%AF%AD%E8%A8%80)HTML 文档，而为了支持多媒体数据类型，HTTP协议中就使用了附加在文档之前的MIME数据类型信息来标识数据类型。
MIME意为多功能Internet邮件扩展，它设计的最初目的是为了在发送[电子邮件](https://wapbaike.baidu.com/item/%E7%94%B5%E5%AD%90%E9%82%AE%E4%BB%B6)时附加多媒体数据，让邮件客户程序能根据其类型进行处理。然而当它被HTTP协议支持之后，它的意义就更为显著了。它使得HTTP传输的不仅是普通的文本，而变得丰富多彩。

说的直白一点就是表示文件的一个类型，这样比如浏览器就可以知道用什么插件打开某个文件。比如上传一个Excel，那么浏览器就会找到WPS打开这个文件。

###参考
https://imququ.com/post/four-ways-to-post-data-in-http.html
https://wapbaike.baidu.com/item/MIME

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
