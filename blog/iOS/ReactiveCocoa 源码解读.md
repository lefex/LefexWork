# ReactiveCocoa 源码解读
学习 ReactiveCocoa 的时候首先知道如何使用，每个类的作用是什么，然后逐步解读源码。不过在学习 RAC 时，必须掌握 Block 的基本使用。

## 什么是响应式编程
至于这种概念上的东西，恐怕看了也不会明白。当你真正理解了 FRP 这种思想，它会让你更好的控制嵌套的异步回调事件，尤其是在 OC 中，block之间的嵌套简直是一场噩梦。比如一个简单的应用场景。Lefe 想要发送一个朋友圈动态，加入动态中包含了一个视频，3张图片，往往需要先发送视频和图片到文件服务器，然后从文件服务器获取到的Url提交给业务服务器，这个发送过程中，我们可以使用状态编程，使用一个状态来记录只有图片和视频都发送成功才去调用发送朋友圈动态的接口。那么使用 RAC 会让程序编的更简单。

## RACStream

> Stream 就是一个按时间排序的 Events 序列,它可以放射三种不同的 Events：(某种类型的)Value、Error 或者一个" Completed" Signal。你可以融合两个 Stream，也可以从一个 Stream 中过滤出你感兴趣的 Events 以生成一个新的 Stream，还可以把一个 Stream 中的数据值 映射到一个新的 Stream 中。

这个类是 FRP 中最主要的类，它表示的是一个事件流。其它的一些事件流都是它的子类。

**子类需要重写打方法：**

以下这几个方法都需子类进行重写，如果子类没有重写将抛出异常：

NSStringFromSelector(_cmd)：这个是当前方法的方法名。

```
NSString *reason = [NSString stringWithFormat:@"%@ must be overridden by subclasses", NSStringFromSelector(_cmd)];
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
```

```
+ (__kindof RACStream *)empty;
- (__kindof RACStream *)bind:(RACStreamBindBlock (^)(void))block;
- (__kindof RACStream *)concat:(RACStream *)stream;
- (__kindof RACStream *)zipWith:(RACStream *)stream;
```

**起一个具体的名字**

下面这两个方法主要是用来调试使用，给一个事件流起一个名字，这样调试的时候可以定位到某一个具体的事件流

```
@property (copy) NSString *name;
- (instancetype)setNameWithFormat:(NSString *)format, ... ;
```

**事件流处理**

事件处理主要用到了下面这些方法，
`flattenMap`:
`flatten`:
`map`:
`mapReplace`:
`filter`:
`ignore`:
`reduceEach`:
`startWith`:
`skip`:
`take`:
`zip`:
`zip:reduce`:
`concat`:
`scanWithStart:reduce`:
`scanWithStart:reduceWithIndex`:
`combinePreviousWithStart:reduce`:
`takeUntilBlock`:
`takeWhileBlock`:
`skipUntilBlock`:
`skipWhileBlock`:
`distinctUntilChanged`:

## 参考

[极客学院](http://wiki.jikexueyuan.com/project/android-weekly/issue-145/introduction-to-RP.html)

https://asce1885.gitbooks.io/android-rd-senior-advanced/content/


[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
