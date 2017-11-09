# 给 iOS 开发者的 RxSwift

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

#### 知识点说明
- 安装 RxSwift 时会安装 RxSwift(对ReactiveX的实现) 和 RxCocoa(对iOS cocoa 层的实现)；
- orEmpty：主要使 `String?` 类型变为 `String`类型；
- map：它属于 Rx 变换操作中的一种，主要对 Observable 发射的数据应用一个函数，执行某种操作，返回经过函数处理过的 Observable。Observable 可观察的对象，用来被观察者(observer)订阅，这样observe可以监听Observable发出的事件；
- share(replay: 1)：只允许监听一次；

### 到这里，还不了解基本概念？

#### Observable
Observable 直译为可观察的，它在 RxSwift 起到了举足轻重的作用，在整个 RxSwift 的使用过程中你会经常与它打交道。如果你使用过 RAC ，它如同 `Signal` 一样。RxSwift 中关键点就是在于如何把普通的数据或者事件变成可观察的，这样当某些数据或事件有变化的时候就会通知它的订阅者。



### 例二：发动态更有条理
某天老板说：lefe 增加一动态模块，用户可以发布图文动态，最多9张，而且要保证图片显示顺序要与用户选择的一致。

### 参考
- [Reactivex](http://reactivex.io)
- [RxSwift 学习指导索引](http://t.swift.gg/d/2-rxswift)
- [ReactiveX文档中文翻译](https://mcxiaoke.gitbooks.io/rxdocs/content/Intro.html)
- [realm](https://academy.realm.io/cn/posts/altconf-scott-gardner-reactive-programming-with-rxswift/)