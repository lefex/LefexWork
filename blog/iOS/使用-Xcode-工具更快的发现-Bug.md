我们可以使用 Xcode 自带的 运行时工具发现代码中的漏洞，有些难以复现的 Bug 往往使用这些工具很容易定位到，比如线程引发的资源竞争问题，内存问题等。

![Diagnostics.png](http://upload-images.jianshu.io/upload_images/1664496-c5648d4e765bac40.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###【1】Main thread checker【Xcode 新增特性】
当某些代码必须在主线程执行时，而你没有在主线程执行，那么 Xcode9 会提示。`XXX must be used from thread only.`。这个工具 Xcode9 是默认打开的，建议开启。

###【2】Address Sanitizer
发生内存异常时可以使用这个工具调试，比如 buffer overflow, use-after-free, double free, use after end of scope。

###【3】Thread Sanitizer
定位多线程问题，比如数据争用（Data race），想要打开这个开关，需要关闭 Address Sanitizer ，Malloc Stack 和 Memory Management 选项。下面这段代码会出现资源竞争的问题。勾选后，将会提示：

```
Race on a library object in -[ViewController testThreadRace] at 0x7b080000db20
Race on a library object in -[ViewController testThreadRace] at 0x7b080000db20

for (int i = 0; i < 10; i++) {
   dispatch_async(dispatch_get_global_queue(0, 0), ^{
      [self testThreadRace];
   });
}

- (void)testThreadRace
{
    BOOL found = [_dict objectForKey:@"lefe"];
    if (found) {
        NSLog(@"Found");
    }
    [_dict setObject:@"WangSuyan" forKey:@"lefe"];
}
```

![data-race.png](http://upload-images.jianshu.io/upload_images/1664496-f9c6b3230f76ba1a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


###【4】Undefined Behavior Sanitizer 【Xcode 新增特性】
检测未定义的行为，这些多数服务与 C 语言，因为 OC 和 Swift 相对比较安全，在语言设计时就消除了大多数未定义的行为【图 4-1】。它可以检测到大约 15 种未定义的行为，比如常见的有数组越界，未初始化，无效的枚举值，除数为零和空值判断等。我们用例子来列举几个未定义的行为（想了解更多看官方文档 https://developer.apple.com/documentation/code_diagnostics/undefined_behavior_sanitizer）：

```
- (NSInteger)testUndefinedBehavior
{
    NSInteger value;
    if (self.name.length > 0) {
        value = 12;
    }
    return value;
}
```
如果勾选 Undefined Behavior Sanitizer 这样选项，Xcode 会提示

```
Variable 'value' is used uninitialized whenever 'if' condition is false
```

![array.png](http://upload-images.jianshu.io/upload_images/1664496-22045995c854cc91.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![swift_c.png](http://upload-images.jianshu.io/upload_images/1664496-dd44a1d3df34e8fe.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 推荐阅读

[【iOS 国际化】如何把国际化时需要3天的工作量缩减到10分钟](http://www.jianshu.com/p/2c77f0d108c3)
[Promise](http://www.jianshu.com/p/6bd083ff11b3)
[微信iOS数据库是什么样的](http://www.jianshu.com/p/68e9f22f9680)

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
