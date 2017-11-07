# RxSwift 详解

> Rx是一个使用可观察数据流进行异步编程的编程接口，ReactiveX结合了观察者模式、迭代器模式和函数式编程的精华。

使用 Rx 时，需要明白它是如何使用观察者模式，迭代器模式和函数式编程的。

### 概念

- Reactive: 响应式的，也就是说当某个事件被触发时可以做出相应；
- Observable: 可观察的对象；
- Observer: 观察者对象；
- emit: 发射，Observable有事件触发时，会发射给Obesever;
- Iterable: 可迭代对象，比如数组可以支持遍历；
- Subscribe: 订阅，观察者对象订阅可观察的对象，这样当可观察的对象有新事件时会给观察者对象；
- "热"的Observable：只要订阅了，就会收到事件，它不能接收到已经发出的事件；
- "冷"的Observable：它会一直等待，直到有观察者订阅它才开始发射数据，因此这个观察者可以确保会收到整个数据序列；
- Operators：操作符，Rx 强大之处就在于它的操作符，可以对 Observable 做出很多中操作，比如组合（combine），变换（transform），过滤（filter）；
- Single：只发射(emit)一次值，因此它没有onNext方法；
- Subject：它同时充当了Observable和Observer；
- AsyncSubject：它只会把原始Observable的最后一个值发送给后续的观察者；
- BehaviorSubject：
- PublishSubject：
- ReplaySubject：
- Scheduler：调度器，给Observable操作符链添加多线程功能，比如某些事件是在主线程执行，某些在非主线程执行；

### Swift 中的一些操作

- associatedtype 目的使用协议范型

### RxSwift 各个类的说明

- ObserverType 一个协议，并添加了默认实现 onNext，onCompleted，onError；
- Event：一个枚举，定义了 next，error，completed；


### Observable的创建
- Never：一个从来不会终止也不好发射任何事件的序列；
- Empty: 创建一个不发射任何事件，但可以正常终止的序列；
- Throw：创建一个不发射任何事件，以错误终止的序列；
- From：把普通的数据转换成可观察的对象；
- Defer：当订阅者订阅的时候才创建