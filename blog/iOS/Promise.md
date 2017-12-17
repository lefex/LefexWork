**让“回调地狱”滚蛋吧！**

![timg.jpg](http://upload-images.jianshu.io/upload_images/1664496-874e3c9faff1b2e9.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

目前很多语言都支持了异步编程，比如 ES6 中新加的特性，它很好的支持了 `Promise`。相信不久后，Swift 也会支持这种异步编程的方式。不过目前有 [PromiseKit](https://github.com/mxcl/PromiseKit/blob/master/README.zh_CN.md) , 它很好的实现了 `Promise`。使用它完全可以避免“回调地狱”这种问题。

我现在有这么一个需求，先登录，登录后获取用户id，根据用户id 获取好用列表，然后获取动态列表。如果使用 Promise 的方式，是这样的：

```
func request() {
    // 1. 登录
	let logPormise = NetWork.postWithParams(params: nil, urlStr: loginUrl)
	
	logPormise.then { (result) -> Promise<[String: Any]> in
	
	    // 1. 获取好友列表
	    return NetWork.postWithParams(params: nil, urlStr: contactUrl)
	    
	    }.then { (result) -> Promise<[String: Any]> in
	        // 3. 获取动态列表
	        return NetWork.postWithParams(params: nil, urlStr: trendUrl)
	        
	    }.then { result in
	        
	    }.catch { error in
	        print("Network error:", error)
	}
}
```

那么什么是 Promise 呢？它翻译过来是“承诺”。它是异步编程的一种解决方案，使用它可以解决“回调地狱”的问题。从语法上来讲，Promise 是一个对象。 它主要有一下两个特点：

> （1）对象的状态不受外界影响。Promise对象代表一个异步操作，有三种状态：Pending（进行中）、Resolved（已完成，又称 Fulfilled）和Rejected（已失败）。只有异步操作的结果，可以决定当前是哪一种状态，任何其他操作都无法改变这个状态。这也是Promise这个名字的由来，它的英语意思就是“承诺”，表示其他手段无法改变。

>（2）一旦状态改变，就不会再变，任何时候都可以得到这个结果。Promise对象的状态改变，只有两种可能：从Pending变为Resolved和从Pending变为Rejected。只要这两种情况发生，状态就凝固了，不会再变了，会一直保持这个结果。如果改变已经发生了，你再对Promise对象添加回调函数，也会立即得到这个结果。这与事件（Event）完全不同，事件的特点是，如果你错过了它，再去监听，是得不到结果的。


### 如何开启 Demo

介绍 [PromiseKit](https://github.com/mxcl/PromiseKit/blob/master/README.zh_CN.md) 时，lefe 写了一个 Demo，可以在这里下载 [PromiseKitDemo](https://github.com/iMetalk/TCZDemo/tree/master/PromiseKitDemo) 。

如果你想使用本例的接口，可以使用 [TCZNodeServer](https://github.com/iMetalk/TCZNodeServer)  搭建一个服务器。这样能更容易的理解。比如我想让网络请求返回 code 值不为 200，这样表示网络异常，当然 `Promise` 就会走 `catch`。

```
module.exports = function (req, res) {
	var result = {
		code: 200,
		data: {
            userId: "123456"
		}
	}
	res.json(result);
}
```


### 构建 Promise

Promise 接收两个参数，fulfill 和 reject，它们是两个闭包，在 JS 中也就是两个函数，这样可能更好的理解。fulfill 的作用是从“未完成”变成“成功”（即从 Pending 变为 Resolved）；reject 的作用是从“未完成”变成“失败”（即从 Pending 变为 Rejected）。**Promise 一旦创建后就执行了**。
`let logPormise = NetWork.postWithParams(params: nil, urlStr: loginUrl)` 那么这个 logPormise 已经开始执行了。

```
required public init(resolvers: (@escaping (T) -> Swift.Void, @escaping (Error) -> Swift.Void) throws -> Swift.Void)
```

### Then

then 表示还可以做什么，它的作用是为 Promise 实例添加状态改变时的回调函数。下面的例子中一旦登录成功将执行 then 后的 block ，如果有异常发生，将执行 catch，捕获异常。

```
let logPormise = NetWork.postWithParams(params: nil, urlStr: loginUrl)
logPormise.then(execute: { (result) -> Promise<Any> in
     return Promise(value: result)
}).catch { error in
            
}
```

### Catch

 当 Promise 变为 reject 后调用，也就是用来捕获 Promise 的异常。
 
### When 

当所有被指定的 Promise 发生后，剩余的 Promise 才会发生。比如有这么个场景，只有用户登录，和获取联系人列表后才能获取动态列表；

```
func requestWhen() {
   let logPormise = NetWork.postWithParams(params: nil, urlStr: loginUrl)
   let contactPormise = NetWork.postWithParams(params: nil, urlStr: contactUrl)
        
   let resultPromise = when(resolved: [logPormise, contactPormise])
        
   resultPromise.then { (results) -> Promise<[String: Any]> in
        print(results)
        return NetWork.postWithParams(params: nil, urlStr: trendUrl)
            
   }.then { (trends) -> Promise<Any> in
        print(trends)
        return Promise(value: "Success")
   }.catch { (error) in
        print(error)
  }
}
```

运行结果为：

```
quest url:  http://192.168.199.140:3000/api/login/login
Request url:  http://192.168.199.140:3000/api/login/contactList
Request url:  http://192.168.199.140:3000/api/login/trendList
[PromiseKit.Result<Swift.Dictionary<Swift.String, Any>>.fulfilled(["code": 200, "data": {
    userId = 123456;
}]), PromiseKit.Result<Swift.Dictionary<Swift.String, Any>>.fulfilled(["code": 200, "data": <__NSCFArray 0x17026f140>(
{
    nickName = Lefe;
    userId = 123456;
}
)
])]

["code": 200, "data": <__NSCFArray 0x17406e340>(
{
    title = PromiseKit;
    trendId = 123456;
}
)
]
```

上面的例子中只有 logPormise 和 contactPormise 的状态都为 fulfilled，resultPromise 的状态才能为 fulfilled；只要 logPormise 和 contactPormise 有一个为 rejected，那么 resultPromise 的状态的 rejected。将会执行 catch 后的 block。


### race

上面代码中，只要logPormise 和 contactPormise之中有一个实例率先改变状态，resultPromise 的状态就跟着改变。当一堆承诺兑现时返回第一个承诺。也就是，第一个完成的胜出。就像比赛一样，当 3 个人赛跑时，第一名胜出，Promise 的状态就会改变。

```
func requestRace() {
   let logPormise = NetWork.postWithParams(params: nil, urlStr: loginUrl)
   let contactPormise = NetWork.postWithParams(params: nil, urlStr: contactUrl)
        
   let resultPromise = race(resolved: [logPormise, contactPormise])
        
   resultPromise.then { (results) -> Promise<[String: Any]> in
        print(results)
        return NetWork.postWithParams(params: nil, urlStr: trendUrl)
            
   }.then { (trends) -> Promise<Any> in
        print(trends)
        return Promise(value: "Success")
   }.catch { (error) in
        print(error)
  }
}
```

运行结果为：(与 `when` 运行的结果做一个对比，这里的请求只有返回两个回调)

```
Request url:  http://192.168.199.140:3000/api/login/login
Request url:  http://192.168.199.140:3000/api/login/contactList
Request url:  http://192.168.199.140:3000/api/login/trendList
["code": 200, "data": {
    userId = 123456;
}]
["code": 200, "data": <__NSCFArray 0x1702686c0>(
{
    title = PromiseKit;
    trendId = 123456;
}
)
]
```

### Join

when 和 join 都是在指定的 Promise 被兑现之后调用。只是 rejected 块有所不同。join 在拒绝之前总是等待所有的承诺完成，看它们之中是否有被拒绝的。而 when(fulfilled:) 只要有任何一个承诺被拒绝它就拒绝。

### Always

不管前面的 Promise 是 fulfilled 还是 rejected，always 的回调会一直调用

```
func requestAlways() {
    let logPormise = NetWork.postWithParams(params: nil, urlStr: loginUrl)
    logPormise.then { (results) in
       print(results)
            
    }.always(execute: { 
       print("always")
    })
    .catch { (error) in
       print(error)
   }
}
```

### OC 使用方法

OC 使用的是 `AnyPromise`，通过方法

```
[AnyPromise promiseWithResolverBlock:^(void (^ resolve)(id _Nullable)) {
    // resolve(param) 当 param 是 error 时调用相当于 reject，否则为 fullfilled
}
```

```
AnyPromise *logPrimise = [NetWork postWithParams:nil url:loginUrl];
logPrimise.then(^(NSDictionary *resultDict){
    NSLog(@"%@", resultDict);
    return [NetWork postWithParams:nil url:contactUrl];
}).then(^(NSDictionary *result){
    NSLog(@"%@", result);
    return [NetWork postWithParams:nil url:trendUrl];
}).then(^(NSDictionary *result){
    NSLog(@"%@", result);
}).catch(^(NSError *error){
    NSLog(@"%@", error);
});
```


## 参考

[博客](http://dev.dafan.info/detail/204760?p=)

[ES6](http://es6.ruanyifeng.com/#docs/promise)

[Eliyar's Blog](https://eliyar.biz/PromiseKit_101/)

[Onevcat](https://onevcat.com/2016/12/concurrency/)

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
