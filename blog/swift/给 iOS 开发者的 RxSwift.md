# 给 iOS 开发者的 RxSwift（一）

RxSwift 或许我们都听说过，但或许只知道 RxSwift 这个单词，长篇大论关于 RxSwift 的介绍往往使读者迷失在各种概念当中，却不知如何让它大展伸手。或许我们可以换一种姿势，一些应用场景会让我们产生共鸣，解决问题的方式由很多，为什么不找一种最优的呢？RxSwift也许会帮到你。

### 什么是 ReactiveX（Reactive Extensions） 
 > - An API for asynchronous programming
with observable streams

> 通过可观察的流实现**异步编程**的一种API（不明白？嗯，看完所有的例子再读一篇）

> - ReactiveX is more than an API, it's an idea and a breakthrough in programming. It has inspired several other APIs, frameworks, and even programming languages.
> 
> ReactiveX 不仅仅是一种 API 那么简单，它更是一种编程思想的突破。它已经影响了其他 API，frameworks，以及编程语言。

### 它无处不在

它是跨平台的（RxJS，RxJava，RxNET），也就是说掌握 RxSwift 这种思想，学习其他的 Rx 系列的将非常简单。

### 先来个总结？还没开始就总结！
ReactiveX（Reactive Extensions）是通过可观察的流实现异步编程的一种API，它结合了观察者模式、迭代器模式和函数式编程的精华。RxSwift 是 ReactiveX 编程思想的一种实现，几乎每一种语言都会有那么一个 Rx[xxxx] 框架，比如 RxJava，RxJS 等。Rx 可以概括为：

- **观察者模式 Observable**：对某些数据流（很广，可以是一些事件等）进行处理，使其变成可观察对象（Observable）序列，这样观察者（observer）就可以订阅这些序列；
- **操作符 Operators**：然而对于订阅者来说（observer）某些选项（items）并不是自己需要的（需要过滤），某些选项（items）需要转换才能达到自己的目的；
- **迭代模式 Iterator**：这样集合或者序列中的值就可以进行遍历了。
- **调度器 Scheduler**：为了提升用户体验，或其它目的，有些操作需要放到特定的线程去执行，比如 UI 操作需要放到主线程，这就涉及到了调度器。

**所以 Rx 可以这样概括，Rx = Observables + LINQ + Schedulers，其中 LINQ（Language Integrated Query）语言集成查询，比如那些操作符号。**


### 先来看个例子：修改用户昵称
用户昵称必须由3-10个字符组成，用户名不合法时显示提示（昵称由3-10个字符组成），且修改按钮不可点击。

```
func registerRx() {
    let nickNameValid = nickNameTextField.rx.text.orEmpty
        .map { (text) -> Bool in
        let tLength = text.characters.count
        return tLength >= 3 && tLength <= 10
        }
        .share(replay: 1)
    
    nickNameValid
        .bind(to: alertLabel.rx.isHidden)
        .disposed(by: disposeBag)
    
    nickNameValid
        .bind(to: changeButton.rx.isEnabled)
        .disposed(by: disposeBag)
    changeButton.rx.tap
        .subscribe { (next) in
         print("修改昵称成功!")
        }
        .disposed(by: disposeBag)
}
```

![图片发自简书App](http://upload-images.jianshu.io/upload_images/1664496-5e45e2e8d905fae3.jpg)

#### 知识点说明
- 安装 RxSwift 时会安装 RxSwift(对ReactiveX的实现) 和 RxCocoa(对iOS cocoa 层的实现)；
- orEmpty：主要使 `String?` 类型变为 `String`类型；
- map：它属于 Rx 变换操作中的一种，主要对 Observable 发射的数据应用一个函数，执行某种操作，返回经过函数处理过的 Observable。Observable 可观察的对象，用来被观察者(observer)订阅，这样observe可以监听Observable发出的事件；
- share(replay: 1)：只允许监听一次；

### 到这里，还不了解基本概念？

#### Observable
Observable 直译为可观察的，它在 RxSwift 起到了举足轻重的作用，在整个 RxSwift 的使用过程中你会经常与它打交道。如果你使用过 RAC ，它如同 `Signal` 一样。RxSwift 中关键点就是在于如何把普通的数据或者事件变成可观察的，这样当某些数据或事件有变化的时候就会通知它的订阅者。

那如何能够让某些数据或事件成为 Observable  呢？   
RxSwift 中提供很多种创建 Observable 创建方法。比如：`From`、`never`、`empty` 和 `create` 等，[更多创建方法](http://reactivex.io/documentation/operators.html)。订阅者可以收到 3 个事件，`onNext`、`onError` 和 `onCompleted`，每个 Observable 都应该至少有一个 `onError` 或 `onCompleted` 事件，`onNext` 表示它传给下一个接收者时的数据流。

```
func create() {
       let observable = Observable<String>.create { (observer) -> Disposable in
        observer.onNext("Hello Lefe_x, I am here!")
        observer.onCompleted()
            return Disposables.create()
        }
        
        observable.subscribe(onNext: { (text) in
            print(text)
        }, onError: nil, onCompleted: {
            print("complete!")
        }, onDisposed: nil).disposed(by: disposeBag)
    }
```

![juli](http://upload-images.jianshu.io/upload_images/1664496-fcdc57e82af1fe49.jpg)

Lefe_x 经常刷微博，刚开始时他并不刷微博，别人也不会看到他发的内容（这时他是不可订阅的）。某天，Lefe_x 想让自己学到的知识能帮助更多的同学，他就注册了微博，开始了刷微博之旅（变成了可订阅的 Observable），这样别人就可以关注他（订阅）。慢慢地，越来越多的人开始关注他，这样当他发微博（事件流）的时候，它的粉丝就可以被提醒（通知订阅者），这些提醒有不同功能，比如有的是提醒 Lefe_x 发布了新微博，有的提醒微博被转发了(相当于 `onNext`、`onError` 和 `onCompleted` 事件)。

#### Operators 操作符
Observable 创建后，可能为了满足某些需求需要修改它，这时就需要用到操作符。RxSwift 提供了非常多的操作符，当然不必要一一掌握这些操作符，使用的时候查一下即可，当然常见的操作符必须要掌握，比如 `map`、`flatMap` 、`create` 、`filter` 等。[这里查看更多](http://reactivex.io/documentation/operators.html)


### 再来个例子放松下：
这个例子主要把查找数组中的字符串 `Lefe_x `，并显示到 Label 上。

```
override func viewDidLoad() {
    super.viewDidLoad()
    DispatchQueue.global().async {
        self.from()
    }
}
    
func from() {
    Observable.from(["Lefe", "Lefe_x", "lefex", "wsy", "Rx"])
        .subscribeOn(MainScheduler.instance)
        .filter({ (text) -> Bool in
            return text == "Lefe_x"
        })
        .map({ (text) -> String in
            return "我的新浪微博是: " + text
        })
        .subscribe(onNext: { [weak self] (text) in
            self?.nickNameLabel.text = text
        })
        .disposed(by: disposeBag)
}
```

运行结果为：
![图片发自简书App](http://upload-images.jianshu.io/upload_images/1664496-a44559df8be59fcd.jpg)

呀，这不是前几天有人写过的吗？没错，那是前几天发的一个 #iOS知识小集# ，不过哪里只是一个总结，没有详细的说明。这里主要说一下调度器 (Scheduler)。

#### Scheduler 调度器

如果你想给 Observable 操作符链添加多线程功能，你可以指定操作符（或者特定的Observable）在特定的调度器(Scheduler)上执行。对于 ReactiveX 中可观察对象操作符来说，它有时会携带一个调度器作为参数，这样可以指定可观察对象在哪一个线程中执行。而默认的情况下，某些可观察对象是在订阅者订阅时的那个线程中执行。SubscribeOn 可以改变可观察对象该在那个调度器中执行。ObserveOn 用来改变给订阅者发送通知时所在的调度器。这样就可以使可观察对象想在那个调度器中执行就在那个调度器中执行，不受约束，而这些细节是不被调用者所关心的。犹如 GCD 一样，你只管使用，底层线程是咋么创建的，你不必关心。

#### 写在最后
下一篇打算写一些关于 Rx 做数据绑定和网络层的交互。
就在这时遇到了**人身的第一次公司裁员**（创业公司，你懂的），小弟不得不选择离开目前的公司，今天是最后一天。如果那位兄台公司正好招人，收留一下小弟，坐标北京，再次谢过。也恳请各位能帮忙转发一下。邮箱：wsyxyxs@126.com ，或直接私信。

### 参考
- [Reactivex](http://reactivex.io)
- [RxSwift 学习指导索引](http://t.swift.gg/d/2-rxswift)
- [ReactiveX文档中文翻译](https://mcxiaoke.gitbooks.io/rxdocs/content/Intro.html)
- [realm](https://academy.realm.io/cn/posts/altconf-scott-gardner-reactive-programming-with-rxswift/)


[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
