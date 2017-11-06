# 给 iOS 开发者的 RxSwift

RxSwift 或许我们都听说过，但或许只知道 RxSwift 这个单词，长篇大论关于 RxSwift 的介绍往往使读者迷失在各种概念当中，却不知如何让它大展伸手。或许我们可以换一种姿势，一些应用场景会让我们产生共鸣，解决问题的方式由很多，为什么不找一种最优的呢？RxSwift也许会帮到你。通过例子学习系列文章将通过#iOS知识小集让#与读者见面。

### 什么是 ReactiveX（Reactive Extensions） 
 > - An API for asynchronous programming
with observable streams

> 通过可观察的流实现**异步编程**的一种API（不明白？嗯，看完所有的例子再读一篇）

> - ReactiveX is more than an API, it's an idea and a breakthrough in programming. It has inspired several other APIs, frameworks, and even programming languages.
> 
> ReactiveX 不仅仅是一种 API 那么简单，它更是一种编程思想的突破。它已经影响了其他 API，frameworks，以及编程语言。

### 它无处不在

它是跨平台的（RxJS，RxJava，RxNET），也就是说掌握 RxSwift 这种思想，学习其他的 Rx 系列的将非常简单。

### 【Day1】：修改用户昵称
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
- map：它属于 Rx 变换操作中的一种，主要对Observable发射的数据应用一个函数，执行某种操作，返回经过函数处理过的Observable。Observable可观察的对象，用来被观察者(observe)观察，这样observe可以监听Observable发出的事件；
- share(replay: 1)：

### 例二：发动态更有条理
某天老板说：lefe 增加一动态模块，用户可以发布图文动态，最多9张，而且要保证图片显示顺序要与用户选择的一致。

### 参考
- [Reactivex](http://reactivex.io)
- [RxSwift 学习指导索引](http://t.swift.gg/d/2-rxswift)
- [ReactiveX文档中文翻译](https://mcxiaoke.gitbooks.io/rxdocs/content/Intro.html)