最近看到各大V转发关于 **唱吧音视频框架 KTVHTTPCache** 的开源消息，首先我非常感谢唱吧 iOS 团队能够无私地把自己的成果开源。我本人对于缓存的设计也比较感兴趣，也喜欢写一些东西，希望能把自己一些小技巧分享给需要的同学，这也是我们 #iOS知识小集# 一直做的事情。抱着好奇的心，想了解一下唱吧是如何设计 [KTVHTTPCache](https://github.com/ChangbaDevs/KTVHTTPCache) 的，没想到越看越难，最后竟然花了将近2天的时间看完了。

## 安装时解读

在进行安装的时候，发现 [KTVHTTPCache](https://github.com/ChangbaDevs/KTVHTTPCache) 主要依赖了 [CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer) 这个库，而 [CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer)  又依赖了 [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) 和 [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)。可以肯定一点 `KTVHTTPCache` 使用 [CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer) 作为 HttpServer。

> CocoaHTTPServer is a small, lightweight, embeddable HTTP server for Mac OS X or iOS applications.
> Sometimes developers need an embedded HTTP server in their app. Perhaps it's a server application with remote monitoring. Or perhaps it's a desktop application using HTTP for the communication backend. Or perhaps it's an iOS app providing over-the-air access to documents. Whatever your reason, CocoaHTTPServer can get the job done 


![](http://upload-images.jianshu.io/upload_images/1664496-98e37bff0a177cf0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

Readme 中提到：

> KTVHTTPCache 由 HTTP Server 和 Data Storage 两大模块组成。

另外一个主要模块就是 `Data Storage`，它主要负责资源加载及缓存处理。从这里可以看出，[KTVHTTPCache](https://github.com/ChangbaDevs/KTVHTTPCache) 主要的工作量是设计 Data Storage 这个模块，也就是它的核心所在。

## 使用

> 其本质是对 HTTP 请求进行缓存，对传输内容并没有限制，因此应用场景不限于音视频在线播放，也可以用于文件下载、图片加载、普通网络请求等场景。 --- KTVHTTPCache

既然这么好使，我们可以试试各种情况，demo 中虽然没有给出其它方式的缓存示例，我们可以探索一下。不过我测试了下载图片的，并没有成功，其它几中情况也就没有试验。我猜测，如果想支持这几种情况，应该需要修改源码（如果作者能看到，忘解答一下，不知道我的猜测是否正确）。

#### 视频缓存（ Demo 中提供，亲测可以）

- 全局启动一次即可，主要用来启动 HttpServer，不理解的话，你可以把它想成手机端的HTTP服务器，当你向HTTP服务器发出 Request 后，服务器会给你一个 Response，后面我们会特意分析一个 HttpServer。

`[KTVHTTPCache proxyStart:&error];`

- 根据原 url 生成一个 proxy url（代理 Url），并使用代理 url 获取数据，这样 HttpServer 就会截获这次请求。比如原 url 为 `http://lzaiuw.changba.com/userdata/video/940071102.mp4` 它对应的 proxy url 为 

```
http://localhost:53112/request-940071102.mp4?requestType=content&originalURL
=http%3A%2F%2Flzaiuw.changba.com%2Fuserdata%2Fvideo%2F940071102.mp4
```

看图会更好理解：

![代理URL](http://upload-images.jianshu.io/upload_images/1664496-41aed5734187fe04.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```
NSString * proxyURLString = [KTVHTTPCache proxyURLStringWithOriginalURLString:URLString];
```

- 播放，注意这里使用的是代理url，进行播放，而不是原url。
`[AVPlayer playerWithURL:[NSURL URLWithString: proxyURLString]];`

#### 图片缓存（本地没能保存）

这次试验结果没能成功，在缓存中找不到缓存图片，或许是我少写了什么。

```
- (void)testImageCache
{
    NSString *imageUrl = @"http://g.hiphotos.baidu.com/image/pic/item/e824b899a9014c08d8614343007b02087af4f4fa.jpg";
    NSString *proxyStr = [KTVHTTPCache proxyURLStringWithOriginalURLString:imageUrl];
    NSURLSessionTask *task2 = [[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:proxyStr]];
    [task2 resume];
}
```

## 框架设计

> KTVHTTPCache 由 HTTP Server 和 Data Storage 两大模块组成。前者负责与 Client 交互，后者负责资源加载及缓存处理。

这句话如果没有看源码，其实很难理解，涉及到如何交互的问题（我是这样认为的，也许你比我聪明，能理解作者的含义）。通俗地讲，HTTP Server 和 Data Storage 是 KTVHTTPCache 两大重要组成部分， HTTP Server 主要负责与用户交互，也就是最顶层，最直接与用户交互（比如下载数据），而 Data Storage 则在后面为 HTTP Server 提供数据，数据主要从 DataSourcer 中获取，如果本地有数据，它会从 KTVHCDataFileSource 中获取，反之会从 KTVHCDataNetworkSource 中读取数据，这里会走下载逻辑（KTVHCDownload）。

![KTVHTTPCache.jpeg](http://upload-images.jianshu.io/upload_images/1664496-5ad7427b651414ca.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### HttpServer

这层设计比较简单，主要是用了 [CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer) 来作为本地的 HttpServer。HttpServer 说白了就是一个手机端的服务器，用来与用户（作者说的 client）交互，用户提出数据加载需求后，它会从不同的地方来获取数据源，如果本地没有会从网络中下载数据。它主要的类如图：

![](http://upload-images.jianshu.io/upload_images/1664496-7976955175eaf00d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- KTVHCHTTPServer：是一个单例，用来管理 HttpServer 服务，负责开启或关闭服务；
- KTVHCHTTPConnection：它继承于 HTTPConnection，表示一个连接，它主要为 HttpServer 提供 Response。
- KTVHCHTTPRequest：一个请求，也就是一个数据模型；
- KTVHCHTTPResponse：一个 Response；
- KTVHCHTTPResponsePing：主要用来 ping 时的 Response；
- KTVHCHTTPURL：主要用来处理 URL，比如把原 Url 生成 proxy url；

其实 HttpServer 的关键点是在 KTVHCHTTPConnection 中下面这个方法，它是连接缓存模块的一个桥梁。使用 `KTVHCDataRequest` 和 `KTVHCHTTPConnection` 来生成 `KTVHCHTTPResponse`，**关键点在于生成这个 Response**。 这段代码仅仅为了说明问题，有删减：

```
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{    
    KTVHCHTTPURL * URL = [KTVHCHTTPURL URLWithServerURIString:path];
    
    switch (URL.type)
    {
        case KTVHCHTTPURLTypePing:
        {
            return [KTVHCHTTPResponsePing responseWithConnection:self];
        }
        case KTVHCHTTPURLTypeContent:
        {
            KTVHCHTTPRequest * currentRequest = [KTVHCHTTPRequest requestWithOriginalURLString:URL.originalURLString];
            
            KTVHCDataRequest * dataRequest = [currentRequest dataRequest];
            KTVHCHTTPResponse * currentResponse = [KTVHCHTTPResponse responseWithConnection:self dataRequest:dataRequest];
            
            return currentResponse;
        }
    }
    return nil;
}
```

![](http://upload-images.jianshu.io/upload_images/1664496-11bedd0b0787dbac.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### DataStroage

主要用来缓存数据，加载数据，也就是提供数据给 HttpServer。上面代码中关键的一句代码 `[KTVHCHTTPResponse responseWithConnection:self dataRequest:dataRequest]`，它会在这个方法的内部使用 `KTVHCDataStorage` 生成一个 `KTVHCDataReader`，负责读取数据。生成 `KTVHCDataReader` 后通过 `[self.reader prepare]` 来准备数据源 `KTVHCDataSourcer`，这里主要有两个数据源，`KTVHCDataFileSource` 和 `KTVHCDataNetworkSource`，它实现了协议 `KTVHCDataSourceProtocol`。`KTVHCDataNetworkSource` 会通过 `KTVHCDownload` 下载数据。

**需要说明一点，缓存是分片处理的**

![](http://upload-images.jianshu.io/upload_images/1664496-f4aac2d957ce935f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- KTVHCDataStorage: 是一个单例，它负责管理整个缓存，比如读取、保存和合并缓存；
- KTVHCDataReader：主要用来读取数据；
- KTVHCDataRequest：用来请求数据，表示一个请求；
- KTVHCDataResponse：一个数据响应；
- KTVHCDataReader：读取数据；
- KTVHCDataCacheItem：缓存数据模型，表一个缓存项；
- KTVHCDataCacheItemZone：缓存区，一个缓存项中会有多个缓存区，比如0-99，100-299 等；
- KTVHCDataSourcer：数据源中心，负责处理不同数据源，它包含有一个数据队列 KTVHCDataSourceQueue；
- KTVHCDataSourceQueue：数据队列；
- KTVHCDataSourceProtocol：一个协议，作为数据源时需要实现这个协议；
- KTVHCDataFileSource：本地数据源，实现了 KTVHCDataSourceProtocol 协议；
- KTVHCDataNetworkSource：网络数据源，实现了 KTVHCDataSourceProtocol 协议；
- KTVHCDataUnit：数据单元，相当于一个缓存目录，比如一个视频的缓存；
- KTVHCDataUnitItem：数据单元项，缓存目录下不同片段的缓存；
- KTVHCDataUnitPool：数据单元池，它是一个单例，含有一个 KTVHCDataUnitQueue；
- KTVHCDataUnitQueue：数据单元队列，保存了多个 KTVHCDataUnit，它会以 archive 的方式缓存到本地；

![沙盒目录](http://upload-images.jianshu.io/upload_images/1664496-746172c98823fe9c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 缓存目录构成

#### 结构
`05f68836443a1535b73bfcf3c2e86d99` 这个是由请求的原 url，md5 后生成的字符串，其中它的子目录下会有多个文件，命名规则为：urlmd5\_offset_数字。

- 05f68836443a1535b73bfcf3c2e86d99
 - 05f68836443a1535b73bfcf3c2e86d99\_0_0
 - 05f68836443a1535b73bfcf3c2e86d99\_196608_0
 - 05f68836443a1535b73bfcf3c2e86d99\_738108_0

沙盒目录：

![](http://upload-images.jianshu.io/upload_images/1664496-801e866ee74d1653.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 缓存策略

> 例如一次请求的 Range 为 0-999，本地缓存中已有 200-499 和 700-799 两段数据。那么会对应生成 5 个 Source，分别是：

- 网络: 0-199
- 本地: 200-499
- 网络: 500-699
- 本地: 700-799
- 网络: 800-999


## 总结

学习这个库总体来说比较耗时，但是能学到作者的思想，这里总结一下：

- 职责明确，每个类的作用定义明确；
- `KTVHCDataFileSource` 和 `KTVHCDataNetworkSource`，使用协议 `KTVHCDataSourceProtocol` 的方式实现不同的 Source，而不用继承，耦合性更低；
- 使用简单，内部定义复杂，环环相扣；
- 使用 NSLock 保证线程安全；
- 日志定义周全，调试更容易；


[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
