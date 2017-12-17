**本文由 [iMetalk](https://lefex.github.io/) 团队的成员 Lefe 完成，主要帮助读者深入理解一个第三方库**。

本文不会教你咋么使用SD，而是要告诉你如何读懂SD，掌握SD的原理及架构。可能，你也看过别人的对SD的源码解析，不过 `Lefe` 上网看了一下，大部分都是以一种简单的方式介绍SD。本文主要通过不同的角度来学习SD，主要从以下方面着手：

- 各个文件的作用是什么
- SD 使用的知识点总结
- SD 中的思想
- 时序图
- SD类图
- 使用实例
- 总结

## 各个文件的作用是什么

### 扩展文件（ UIView + ... ）：
这些文件让使用者更简单的使用，基本是傻瓜式的，你可以在不懂 SD 的情况下写出高性能的图片加载。这就是 SD 的优点所在。

- UIView+WebCache.h

这个文件可以说是其它视图加载图片的关键，其它扩展是基于 UIView 扩展的基础上，实现了视图本身加载图片的方式。它和 `UIView+WebCacheOperation.h` 配合使用。这个类主要提供了加载图片的方法和加载图片时显示的 Loading。
加载图片的方法主要是：

```
- (void)sd_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(SDWebImageOptions)options
                      operationKey:(nullable NSString *)operationKey
                     setImageBlock:(nullable SDSetImageBlock)setImageBlock
                          progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                         completed:(nullable SDExternalCompletionBlock)completedBlock;
                         
```
这个方法主要用来加载图片，其实 `UIImageView` 和 `UIButton` 加载图片时最终会调用这个方法。这个方法会异步下载图片并且添加缓存，这样保证下次直接可以从缓存中读取图片。

参数说明：

`url`：图片在服务器上的路径；  
`placeholder`：图片加载时显示的默认图；  
`options`：控制图片的加载方式，关于更多的 SDWebImageOptions 将在下文讲解
`operationKey`：操作（operation）的 key，如果为空时，将使用类名。这个主要使用来取消一个 opetion，结合 `UIView+WebCacheOperation.h` 使用；  
`setImageBlock`：如果不想使用 SD 加载完图片后显示到视图上，可以使用这个 Block 自定义加载图片，这样就可以在调用加载图片的方法中加载图片。它的完整定义是：

```
typedef void(^SDSetImageBlock)(UIImage * _Nullable image, NSData * _Nullable imageData);

```
`progress`：进度回调，它的完整定义是，注意这里有一个 targetURL：

```
typedef void(^SDWebImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);

```

`completed`：图片加载完成后的回调，

```
typedef void(^SDExternalCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL);
```
这里摘录一段代码，简单讲解一些，以下代码主要用到的知识点有：

- 位运算 &
- 使用 NSOperation 下载图片
- 使用 runtime 给扩展添加属性
- 显示加载 Loading

```
// 设置图片时先取消以前的下载任务，这样避免了复用图片错误问题
[self sd_cancelImageLoadOperationWithKey:validOperationKey];
objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            // 设置默认图
            [self sd_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock];
        });
    }
    
    if (url) {
        // check if activityView is enabled or not
        if ([self sd_showActivityIndicatorView]) {
            [self sd_addActivityIndicator];
        }
        
        __weak __typeof(self)wself = self;
        // 加载图片
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager loadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            __strong __typeof (wself) sself = wself;
            [sself sd_removeActivityIndicator];
            if (!sself) {
                return;
            }
            dispatch_main_async_safe(^{
                if (!sself) {
                    return;
                }
                if (image && (options & SDWebImageAvoidAutoSetImage) && completedBlock) {
                    // 如果是自动设置图，直接回调出去
                    completedBlock(image, error, cacheType, url);
                    return;
                } else if (image) {
                    // 设置图片
                    [sself sd_setImage:image imageData:data basedOnClassOrViaCustomSetImageBlock:setImageBlock];
                    [sself sd_setNeedsLayout];
                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        // 如果图片加载失败，加载默认图
                        [sself sd_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock];
                        [sself sd_setNeedsLayout];
                    }
                }
                // 回调出去
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        // 保存当前运行的 operation
        [self sd_setImageLoadOperation:operation forKey:validOperationKey];
    }

```

例子主要展示直接使用 UIView 的扩展加载图片，且使用 setImageBlock 加载图片。只要理解了这个方法，那么关于 UIView 加载图片基本上已经掌握了：

```
[cell.sdimageView sd_internalSetImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil options:SDWebImageLowPriority operationKey:nil setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
        cell.sdimageView.image = image;
  } progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
 }];
        
```


- UIView+WebCacheOperation.h

这个类主要用来记录 UIView 加载 Operation 操作，大多数情况下一个 View 仅拥有
 一个 Operation ，默认的 key 是当前类的类名，如果设置了不同的 key，将
 保存不同个 Operation 。比如一个 UIButton，可以设置不同状态下的图片，那么我需要记录多个 Operation 。它主要采用一个字典来保存所有的 Operation 。
 
```
operations = [NSMutableDictionary dictionary];
objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
```

取消一个 Operation，这里需要注意 SDWebImageOperation。取消当前正在进行的 Operation。

```
- (void)sd_cancelImageLoadOperationWithKey:(nullable NSString *)key {
    // Cancel in progress downloader from queue
    SDOperationsDictionary *operationDictionary = [self operationDictionary];
    id operations = operationDictionary[key];
    if (operations) {
        if ([operations isKindOfClass:[NSArray class]]) {
            for (id <SDWebImageOperation> operation in operations) {
                if (operation) {
                    [operation cancel];
                }
            }
        } else if ([operations conformsToProtocol:@protocol(SDWebImageOperation)]){
            [(id<SDWebImageOperation>) operations cancel];
        }
        [operationDictionary removeObjectForKey:key];
    }
}

```

- UIImageView+WebCache.h
- UIImageView+HighlightedWebCache.h
- UIButton+WebCache.h

这几个类主要是基于以下方法的进一步封装，方便实用，这里就不做介绍了。

```
- (void)sd_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(SDWebImageOptions)options
                      operationKey:(nullable NSString *)operationKey
                     setImageBlock:(nullable SDSetImageBlock)setImageBlock
                          progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                         completed:(nullable SDExternalCompletionBlock)completedBlock;
```

- UIImage+GIF.h

主要用来根据 NSData 生成一个 GIF 图片和一个判断是否为 GIF 图片。

- UIImage+MultiFormat.h

主要用来根据 NSData 生成不同格式的图片，这里可能我们需要用到的是，根据 Data 判断图片的格式。

### 下载操作

- SDWebImageDownloaderOperation：NSOperation


```
@interface SDWebImageDownloaderOperation : NSOperation <SDWebImageDownloaderOperationInterface, SDWebImageOperation, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
```

这个文件可以说是整个 SD 的灵魂，它控制着图片的下载过程，它与 NSOperationQueue 配合使用。关于更多 NSOperation 的介绍，近期会翻译一篇文章来聊一聊 NSOperation。SDWebImageDownloaderOperationInterface：这是一个协议，可以自定义自己的 NSOperation，只要实现该协议中的方法，并且继承自 NSOperation。

**主要用到的知识点：**

- 使用 NSURLSession 下载
- dispatch_barrier_async，dispatch_barrier_sync，dispatch_sync
- 自定义 NSOperation
- 网络请求认证
- 通知中心
- 后台任务

**初始化：**

```
- (nonnull instancetype)initWithRequest:(nullable NSURLRequest *)request
                              inSession:(nullable NSURLSession *)session
                                options:(SDWebImageDownloaderOptions)options NS_DESIGNATED_INITIALIZER;
```

使用这个方法来创建一个 SDWebImageDownloaderOperation，NS_DESIGNATED_INITIALIZER 这个宏说明所有的初始化方法最终都要调用这个方法，request 就是网络请求的 request，session 当前 Operation 所在的 Session，options：SDWebImageDownloaderOptions，如何来下载任务，有一些枚举值。

### SDWebImageDownloader
这个类主要负责下载图片，它是一个单例。它内部有 `SDWebImageDownloadToken`，用来标示一个下载任务，这样根据 token 来取消对应的任务。可以使用以下方法对 SDWebImageDownloader 进行初始化。当然如果想使用一个自定义的 NSURLSessionConfiguration，可以使用下面这个初始化方法：

```
- (nonnull instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)sessionConfiguration NS_DESIGNATED_INITIALIZER;
```
来初始化，下面是它的具体实现：

```
- (nonnull instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)sessionConfiguration {
    if ((self = [super init])) {
        // 下载的 Operation
        _operationClass = [SDWebImageDownloaderOperation class];
        _shouldDecompressImages = YES;
        _executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
        
        // 下载对列，最大的并发数是6
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = 6;
        _downloadQueue.name = @"com.hackemist.SDWebImageDownloader";
        _URLOperations = [NSMutableDictionary new];
        
        // HTTP header
#ifdef SD_WEBP
        _HTTPHeaders = [@{@"Accept": @"image/webp,image/*;q=0.8"} mutableCopy];
#else
        _HTTPHeaders = [@{@"Accept": @"image/*;q=0.8"} mutableCopy];
#endif
        _barrierQueue = dispatch_queue_create("com.hackemist.SDWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _downloadTimeout = 15.0;

        // NSURLSession
        sessionConfiguration.timeoutIntervalForRequest = _downloadTimeout;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:nil];
    }
    return self;
}
```
这是 SDWebImageDownloader 最终调用的初始化方法，主要配置了一些下载必备的数据。

**下载方法：**这个方法主要用来下载一个任务，下载任务使用的是 NSOperation + NSOperationQueue，来控制下载。也就是说这个方法主要生产一个 NSOperation ，并添加到 NSOperationQueue 中，这样 NSOperationQueue 将自动管理下载任务。使用 NSOperation 的好处就是可以控制下载的整个过程，并且不需要管理线程的创建。当然它的优点也就是它的缺点，只是使用场景的不同。

url：图片下载的路径    
options：图片下载的选项，它主要有下面这几种选项：

- SDWebImageDownloaderLowPriority = 1 << 0, 低优先级
- SDWebImageDownloaderProgressiveDownload = 1 << 1, 渐进式的下载，也就是一块一块的下载
- SDWebImageDownloaderUseNSURLCache = 1 << 2, 默认情况不使用 URLCache，它与 NSURLRequestUseProtocolCachePolicy 对应，设置后使用 URLCache
- SDWebImageDownloaderIgnoreCachedResponse = 1 << 3,
- SDWebImageDownloaderContinueInBackground = 1 << 4, 后台下载任务
- SDWebImageDownloaderHandleCookies = 1 << 5, 它与 HTTPShouldHandleCookies 对应
- SDWebImageDownloaderAllowInvalidSSLCertificates = 1 << 6, 允许不信任的 SSL 证书
- SDWebImageDownloaderHighPriority = 1 << 7, 高优先级下载
- SDWebImageDownloaderScaleDownLargeImages = 1 << 8, 对下载后的图片做处理

progress：进度回调，注意这个进度是在后台线程执行，刷新 UI 需要回到主线程    
completed：下载完成后的回调     
SDWebImageDownloadToken：返回值用这个来标示一个下载任务，取消的时候使用

```
- (nullable SDWebImageDownloadToken *)downloadImageWithURL:(nullable NSURL *)url
                                                   options:(SDWebImageDownloaderOptions)options
                                                  progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                                                 completed:(nullable SDWebImageDownloaderCompletedBlock)completedBlock {
    __weak SDWebImageDownloader *wself = self;

// block 返回值是 SDWebImageDownloaderOperation，在 block 中创建一个 SDWebImageDownloaderOperation
 
    return [self addProgressCallback:progressBlock completedBlock:completedBlock forURL:url createCallback:^SDWebImageDownloaderOperation *{
        __strong __typeof (wself) sself = wself;
        NSTimeInterval timeoutInterval = sself.downloadTimeout;
        if (timeoutInterval == 0.0) {
            timeoutInterval = 15.0;
        }

        // In order to prevent from potential duplicate caching (NSURLCache + SDImageCache) we disable the cache for image requests if told otherwise
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:(options & SDWebImageDownloaderUseNSURLCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:timeoutInterval];
        request.HTTPShouldHandleCookies = (options & SDWebImageDownloaderHandleCookies);
        request.HTTPShouldUsePipelining = YES;
        if (sself.headersFilter) {
            request.allHTTPHeaderFields = sself.headersFilter(url, [sself.HTTPHeaders copy]);
        }
        else {
            request.allHTTPHeaderFields = sself.HTTPHeaders;
        }
        
        // 创建 SDWebImageDownloaderOperation，创建完成后添加到downloadQueue 中
        SDWebImageDownloaderOperation *operation = [[sself.operationClass alloc] initWithRequest:request inSession:sself.session options:options];
        operation.shouldDecompressImages = sself.shouldDecompressImages;
        
        // 处理 HTTP 认证的，大多情况不用处理
        if (sself.urlCredential) {
            operation.credential = sself.urlCredential;
        } else if (sself.username && sself.password) {
            operation.credential = [NSURLCredential credentialWithUser:sself.username password:sself.password persistence:NSURLCredentialPersistenceForSession];
        }
        
        // 设置 Operation 的优先级
        if (options & SDWebImageDownloaderHighPriority) {
            operation.queuePriority = NSOperationQueuePriorityHigh;
        } else if (options & SDWebImageDownloaderLowPriority) {
            operation.queuePriority = NSOperationQueuePriorityLow;
        }

        [sself.downloadQueue addOperation:operation];
        if (sself.executionOrder == SDWebImageDownloaderLIFOExecutionOrder) {
            // Emulate LIFO execution order by systematically adding new operations as last operation's dependency
            [sself.lastAddedOperation addDependency:operation];
            sself.lastAddedOperation = operation;
        }

        return operation;
    }];
}
```
使用上面这个方法下载时，前提需要了解下面这个方法的实现。它使用一个字典缓存了所有的下载。使用 SDWebImageDownloadToken 来标记一个下载任务。

```
@property (strong, nonatomic, nonnull) NSMutableDictionary<NSURL *, SDWebImageDownloaderOperation *> *URLOperations;
```


```
- (nullable SDWebImageDownloadToken *)addProgressCallback:(SDWebImageDownloaderProgressBlock)progressBlock
                                           completedBlock:(SDWebImageDownloaderCompletedBlock)completedBlock
                                                   forURL:(nullable NSURL *)url
                                           createCallback:(SDWebImageDownloaderOperation *(^)())createCallback {
    // 如果 URL 为空直接回调，并返回
    if (url == nil) {
        if (completedBlock != nil) {
            completedBlock(nil, nil, nil, NO);
        }
        return nil;
    }

    __block SDWebImageDownloadToken *token = nil;

    dispatch_barrier_sync(self.barrierQueue, ^{
    // 从缓存中取出 Operation
        SDWebImageDownloaderOperation *operation = self.URLOperations[url];
        if (!operation) {
            // 缓存不存在，调用 Block 创建一个新的 Operation
            operation = createCallback();
            self.URLOperations[url] = operation;

            __weak SDWebImageDownloaderOperation *woperation = operation;
            operation.completionBlock = ^{
              SDWebImageDownloaderOperation *soperation = woperation;
              if (!soperation) return;
              if (self.URLOperations[url] == soperation) {
                  [self.URLOperations removeObjectForKey:url];
              };
            };
        }
        
        // 创建一个标记，并添加回调到缓存
        id downloadOperationCancelToken = [operation addHandlersForProgress:progressBlock completed:completedBlock];

        token = [SDWebImageDownloadToken new];
        token.url = url;
        token.downloadOperationCancelToken = downloadOperationCancelToken;
    });

    return token;
}
```
以上就是下载的主要方法。还有一些设置属性，很简单，这里不作介绍。

### 缓存 SDImageCache
SD中的缓存主要采用了内存缓存（NSCache）加磁盘缓存（保存到沙河目录中的 Cache 目录下），SDImageCacheConfig 主要负责配置缓存。

**初始化**

`directory`：文件所要保存到沙河目录，默认的是 Cache 目录    
`ns`：文件的域名，最终的路径为：.../cache/om.hackemist.SDWebImageCache.ns
。需要注意的是所有的I/O操作都在一个串行对列中执行。这里主要用到了文件的一些操作，比如文件大小，保存文件，文件路径等。文件保存到沙盒时主要以文件的下载路径，MD5后，加上文件后缀作为文件名，保存到本地和 NSCache 中。

```
_ioQueue = dispatch_queue_create("com.hackemist.SDWebImageCache", DISPATCH_QUEUE_SERIAL);
```


```
- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns
                       diskCacheDirectory:(nonnull NSString *)directory NS_DESIGNATED_INITIALIZER;
```

它监听了3个通知在初始化的时候：

- UIApplicationDidReceiveMemoryWarningNotification：有内存警告时清除所有的缓存
- UIApplicationWillTerminateNotification：删除已过期的文件
- UIApplicationDidEnterBackgroundNotification：在后台删除已过期的文件

当然可以使用单例初始化，使用默认的配置。
`+ (nonnull instancetype)sharedImageCache;`

### SDWebImageManager

主要用来管理 SDImageCache 和 SDWebImageDownloader。也就是它把缓存和下载结合起来。

**初始化：**

这个方法是 SDWebImageManager 最终的初始化方法，也就是说所有的初始化方法最终都会调用这个方法，方便使用者自定义 SDWebImageManager，当然通常情况下使用单例方法初始化 `+ (nonnull instancetype)sharedManager;`。

```
- (nonnull instancetype)initWithCache:(nonnull SDImageCache *)cache downloader:(nonnull SDWebImageDownloader *)downloader NS_DESIGNATED_INITIALIZER;
```

```
- (nonnull instancetype)initWithCache:(nonnull SDImageCache *)cache downloader:(nonnull SDWebImageDownloader *)downloader {
    if ((self = [super init])) {
        _imageCache = cache;
        _imageDownloader = downloader;
        // 下载失败的 URL 缓存，注意它使用的是集合，这样保证缓存中没有重复的 URL
        _failedURLs = [NSMutableSet new];
        // 正在运行的操作
        _runningOperations = [NSMutableArray new];
    }
    return self;
}
```

**下载一个图片的主要方法：**

```
- (id <SDWebImageOperation>)loadImageWithURL:(nullable NSURL *)url
                                     options:(SDWebImageOptions)options
                                    progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                                   completed:(nullable SDInternalCompletionBlock)completedBlock
```
                                   
这里会将方法分成很多部分来讲：

- 1.参数异常判断，保证程序的健壮性，一个好的程序，要处理好各种异常情况

```
// 使用断言来保证完成的 Block 不能为空，也就是说如果你不需要完成回调，直接使用 SDWebImagePrefetcher 就行
NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");

// 保证 URL 是 NSString 类型，转换成 NSURL 类型
if ([url isKindOfClass:NSString.class]) {
   url = [NSURL URLWithString:(NSString *)url];
}

// 保证 url 为 NSURL 类型
if (![url isKindOfClass:NSURL.class]) {
   url = nil;
}
```

- 2.对 url 做异常处理，是否为不可使用的下载链接。`SDWebImageCombinedOperation ` 是一个 NSObeject 对象。

```
 __block SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
 __weak SDWebImageCombinedOperation *weakOperation = operation;

// 判断是否为下载失败的 url
BOOL isFailedUrl = NO;
if (url) {
   // 保证线程安全
   @synchronized (self.failedURLs) {
       isFailedUrl = [self.failedURLs containsObject:url];
    }
}

// 如果是失败的 url 且 operations 不为 SDWebImageRetryFailed，或者 url 为空直接返回错误
if (url.absoluteString.length == 0 || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil] url:url];
        return operation;
}
```
- 3.保存当前的 Operation 到缓存

```
@synchronized (self.runningOperations) {
    [self.runningOperations addObject:operation];
}
// 获取 url 对应的 Key
NSString *key = [self cacheKeyForURL:url];

```

```
- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url {
    if (!url) {
        return @"";
    }
    // typedef NSString * _Nullable (^SDWebImageCacheKeyFilterBlock)(NSURL * _Nullable url);，cacheKeyFilter 是一个 Block，你可以自己设置 Cache 对应的 key
    if (self.cacheKeyFilter) {
        return self.cacheKeyFilter(url);
    } else {
        return url.absoluteString;
    }
}
```

- 4. 从 Cache 中获取图片，它结合 option，进行不同的操作

```
- (nullable NSOperation *)queryCacheOperationForKey:(nullable NSString *)key done:(nullable SDCacheQueryCompletedBlock)doneBlock
```

- 4-1.如果 Operation 已经取消，则移除，并结束程序的执行

```
if (operation.isCancelled) {
    [self safelyRemoveOperationFromRunning:operation];
    return;
}
```

- 4-2. 如果未能在缓存中找到图片，或者强制刷新缓存，或者代理中未实现要强制下载图片，那么它就需要下载图片。

```
if ((!cachedImage || options & SDWebImageRefreshCached) && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url])) {}
```

SDWebImageDownloaderOptions 根据不同的选项做不同的操作，根据 SDWebImageOptions 转换成对应的 SDWebImageDownloaderOptions。这里需要注意位运算，根据位运算可以计算出不同的选项。那么使用位定义的枚举和用普通定义的枚举值有什么优缺点？需要读者考虑。比如下面这两种定义方法个的优缺点。

```
SDWebImageDownloaderLowPriority = 1 << 0,

SDWebImageDownloaderLowPriority = 1,
```

```
SDWebImageDownloaderOptions downloaderOptions = 0;
if (options & SDWebImageLowPriority)
downloaderOptions |= SDWebImageDownloaderLowPriority;

if (options & SDWebImageProgressiveDownload) downloaderOptions |= SDWebImageDownloaderProgressiveDownload;
            
if (options & SDWebImageRefreshCached) downloaderOptions |= SDWebImageDownloaderUseNSURLCache;
            
if (options & SDWebImageContinueInBackground) downloaderOptions |= SDWebImageDownloaderContinueInBackground;
            
if (options & SDWebImageHandleCookies) downloaderOptions |= SDWebImageDownloaderHandleCookies;
            
if (options & SDWebImageAllowInvalidSSLCertificates) downloaderOptions |= SDWebImageDownloaderAllowInvalidSSLCertificates;
            
if (options & SDWebImageHighPriority) downloaderOptions |= SDWebImageDownloaderHighPriority;
            
if (options & SDWebImageScaleDownLargeImages) downloaderOptions |= SDWebImageDownloaderScaleDownLargeImages;
            
if (cachedImage && options & SDWebImageRefreshCached) {
  downloaderOptions &= ~SDWebImageDownloaderProgressiveDownload;
  downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
}
```

使用 `imageDownloader` 下载图片，下载完成后保存到缓存，并移除 Operation。如果发生错误，，需要将失败的 Url 保存到 failedURLs，避免实效的 Url 多次下载。这里需要注意一个 delegate （`[self.delegate imageManager:self transformDownloadedImage:downloadedImage withURL:url]`），它需要调用者自己实现，这样缓存中将保存转换后的图片。

```
SDWebImageDownloadToken *subOperationToken = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage *downloadedImage, NSData *downloadedData, NSError *error, BOOL finished){

}
```

- 4-3. 在缓存中找到图片，直接返回

- 4-4. 图片不在缓存或者代理中不需要下载的，直接返回

### SDWebImagePrefetcher
它是一个图片预加载的类，你可以设置多个 URL。这种更适合哪些，在 wifi 情况下提前加载一些图片，缓存起来，用户使用的时候，直接从本地缓存中读取。它实现起来也很简单，使用一个递归来执行每一个下载。它的本质使用的是 SDWebImageManager 处理下载，没有使用单例，而新创建一个 manager。

**初始化：**

```
 (nonnull instancetype)initWithImageManager:(SDWebImageManager *)manager {
    if ((self = [super init])) {
        _manager = manager;
        _options = SDWebImageLowPriority;
        _prefetcherQueue = dispatch_get_main_queue();
        self.maxConcurrentDownloads = 3;
    }
    return self;
}
```

**SDWebImagePrefetcherDelegate：**

每下载完一个后，走一次回调
```
- (void)imagePrefetcher:(nonnull SDWebImagePrefetcher *)imagePrefetcher didPrefetchURL:(nullable NSURL *)imageURL finishedCount:(NSUInteger)finishedCount totalCount:(NSUInteger)totalCount;
```

所有任务下载完后，执行回调

```
- (void)imagePrefetcher:(nonnull SDWebImagePrefetcher *)imagePrefetcher didFinishWithTotalCount:(NSUInteger)totalCount skippedCount:(NSUInteger)skippedCount;
```

### SDWebImageCompat

由于 SD 会用到不同的平台，需要做一些兼容性的处理。

### NSData+ImageContentType

根据 Data 来解析图片的格式


## SD 使用的知识点总结

- **GCD：**

关于引用一段话：
> Dispatch barriers 是一组函数，在并发队列上工作时扮演一个串行式的瓶颈。使用 GCD 的障碍（barrier）API 确保提交的 Block 在那个特定时间上是指定队列上唯一被执行的条目。这就意味着所有的先于调度障碍提交到队列的条目必能在这个 Block 执行前完成。


```
// 创建一个并行队列
_barrierQueue = dispatch_queue_create("com.hackemist.SDWebImageDownloaderOperationBarrierQueue", DISPATCH_QUEUE_CONCURRENT);

// 添加一个任务到对列中，使用 dispatch_barrier_async 添加的任务可以保存后添加
的任务依赖与前面添加过的任务，也就是说如果先前添加的任务还没有执行完成，那么后添加
的任务不会执行，从而保证了线程安全。 
dispatch_barrier_async(self.barrierQueue, ^{
    [self.callbackBlocks addObject:callbacks];
});

// dispatch_sync 保证同步执行方法，保证了线程安全
- (nullable NSArray<id> *)callbacksForKey:(NSString *)key {
    __block NSMutableArray<id> *callbacks = nil;
    dispatch_sync(self.barrierQueue, ^{
        callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
        [callbacks removeObjectIdenticalTo:[NSNull null]];
    });
    return [callbacks copy]; 
}

// dispatch_barrier_sync 保证同步执行方法，保证了线程安全
- (BOOL)cancel:(nullable id)token {
    __block BOOL shouldCancel = NO;
    dispatch_barrier_sync(self.barrierQueue, ^{
        [self.callbackBlocks removeObjectIdenticalTo:token];
        if (self.callbackBlocks.count == 0) {
            shouldCancel = YES;
        }
    });
    if (shouldCancel) {
        [self cancel];
    }
    return shouldCancel;
}

// 回到主线程
dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStartNotification object:self];
});

// SD 的 cache 使用一个串行对列，控制线程的访问
_ioQueue = dispatch_queue_create("com.hackemist.SDWebImageCache", DISPATCH_QUEUE_SERIAL);

```

- **NSOperation：**
使用 NSOperation 更好的控制一个逻辑复杂的操作，可以控制它的整个操作过程，同时也不需要自己管理和创建线程。关于自定义 NSOperation，这里不做过多的解释。不过使用 NSOperation 可以做到 Operation 之间的依赖，控制队列中操作的最大并发数，取消某个操作，而使用 GCD 的话做不到这一点。

- **NSURLSession：**   
这是 iOS7 以后网络请求类，它可以支持文件上传，文件下载。

- **使用 runtime 给某个已有的类添加属性**

```
static char TAG_ACTIVITY_STYLE;

- (void)sd_setIndicatorStyle:(UIActivityIndicatorViewStyle)style{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_STYLE, [NSNumber numberWithInt:style], OBJC_ASSOCIATION_RETAIN);
}

- (int)sd_getIndicatorStyle{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_STYLE) intValue];
}
```

- **NSCache：**
内存缓存，如同字典一样很好用。


## SD 中的思想


- 耦合度低，每个类负责不同的操作，相互之间可以独立使用
- 使用扩展，方便使用者
- 异步下载图片，并保存到内存与磁盘，提高系统性能
- 保证主线程不被卡顿，提高性能
- 通过一个 Manager 来控制不同的操作

## 时序图
这张流程图涵盖了 SD 加载一张图片时需要经历的过程：

![流程图](http://upload-images.jianshu.io/upload_images/1664496-c650090200af9b72.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## SD类图
通过以上的学习，我们可以掌握各个类的作用，那么可以总结一下这张图。

- 所有的操作都围绕在 SDWebImageManager；
- SDWebImageManager 中包含了 SDImageCache 和 SDWebImageDownloader，来处理图片的下载和缓存；
- SDWebImageDownloader 使用 SDWebImageDownloaderOperation 执行下载操作；
- SDImageCache 使用 SDImageConfig 来配置缓存
- 从 SDWebImageManager 衍生出一个预加载图片的类 SDWebImagePrefetcher，负责多个图片的预先加载
- 底层封装好通过扩展 UIView 让视图可以加载图片

看懂这张图需要明白 UML（Unified Modeling Language） 类图：

- 依赖关系(dependency)：
依赖关系是用一套带箭头的虚线表示的，UIButton(WebCache) 依赖于 UIView（WebCache）；

> 它是一种临时性的关系，通常在运行期间产生，并且随着运行时的变化； 依赖关系也可能发生变化.显然，依赖也有方向，双向依赖是一种非常糟糕的结构，我们总是应该保持单向依赖，杜绝双向依赖的产生；

- 聚合关系(aggregation)：聚合关系用一条带空心菱形箭头的直线表示，聚合关系用于表示实体对象之间的关系，表示整体由部分构成的语义；例如一个部门由多个员工组成；SDWebImagePrefetcher 由 SDWebImageManager 组成；

- 实现关系(realize)：实现关系用一条带空心箭头的虚线表示；比如 SDWebImageDownloaderOperation 实现了协议 SDWebImageOperation
- 泛化关系(generalization)：泛化关系用一条带空心箭头的实线表示，它是一种继承关系。



![整体架构](http://upload-images.jianshu.io/upload_images/1664496-c9039b14890ee6d5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 使用实例
- 实例一：使用 UIView 的扩展加载图片，并外部自动设置图片

```
[cell.sdimageView sd_internalSetImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil options:SDWebImageLowPriority operationKey:nil setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
     cell.sdimageView.image = image;
} progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
}];
```

- 实例二：预加载图片

```
[SDWebImagePrefetcher sharedImagePrefetcher].delegate = self;
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:resultUrl progress:^(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls) {
        
} completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
        
}];
```


## 总结
通过 SD 的深入学习，让我了解到一个好的开源库中使用的思想，深有体会，建议读者也可以尝试详细读一个开源库。在读 SD 的时候，需要把自己不懂的知识点，通过其它资料来掌握，这个过程收获很大。前后大约花费了一周的时间（每天 1小时 30 分，大约），完成了这篇博客，如果有什么不合理的地方，读者可以指出。深知写博客需要一个长期坚持的过程，而付出很多自由的时间。所以我在看别人的博客时会特别认真的融入作者当时的思想中。那么 SD 中的思想究竟如何运用到我们的项目中呢？lefe 建议读者可以从以下方面入手：

- **解耦：**模块之间一定不要有太多的关联，我们往往对项目中的某个类做增量操作，不断的给某个类添加新的代码，导致这个类越来越重，我们试着把一个类拆分为不同的功能模块；
- **思路明确：**从图片的下载到图片显示到视图上，要有明确的思路，先有一个大致的流程，然后逐步细化，逐步实现；
- **层次明确：**应用层的使用不会印象到底层的设计；
- **GCD 和 NSOperation：** 各有利弊，要合理的使用；
- **注意性能：**一定要注意性能，结合多线程，提升性能，比如 SD 读取文件时会在一条线程中读取；
- **方便使用者：**写三方库时，要让用户使用起来超级方便，比如在自己项目中写项目组中公用的模块时，要有明确的注释，让使用这更方便的使用；


## 参考

[GCD](http://www.liman123.com/2015/10/21/GCD%E6%80%BB%E7%BB%93/)

[时序图](http://www.cnblogs.com/ywqu/archive/2009/12/22/1629426.html)

[类图](http://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html)

如果您想第一时间看到我们的文章，欢迎关注公众号。
![微信公众号](http://upload-images.jianshu.io/upload_images/1664496-f94c6e4f349a2f74.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
