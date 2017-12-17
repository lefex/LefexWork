ReactiveX（Reactive Extensions）是通过可观察的流实现异步编程的一种API，它结合了观察者模式、迭代器模式和函数式编程的精华。RxSwift是ReactiveX编程思想的一种实现，几乎每一种语言都会有那么一个Rx[xxxx]框架，比如 RxJava，RxJS 等。Rx 可以概括为，对某些数据流（很广，可以是一些事件等）进行处理，使其变成可观察对象（Observable）序列，这样观察者（observer）就可以订阅这些序列【观察者模式】。然而对于订阅者来说（observer）某些选项（items）并不是自己需要的（需要过滤），某些选项（items）需要转换才能达到自己的目的【操作符 filter, map 等】。为了提升用户体验，或其它目的，有些操作需要放到特定的线程去执行，比如 UI 操作需要放到主线程，这就涉及到了调度器【调度器 Scheduler】。所以Rx可以这样概括，Rx = Observables + LINQ + Schedulers，其中 LINQ（Language Integrated Query）语言集成查询，比如那些操作符号。

图1是 RxSwift 的简单的应用，从数组中找出 Lefe_x 并显示到 Label 上。
![图片发自简书App](http://upload-images.jianshu.io/upload_images/1664496-4ff798745469df9c.jpg)

![图片发自简书App](http://upload-images.jianshu.io/upload_images/1664496-cbc88d52c0be8b8e.jpg)

![图片发自简书App](http://upload-images.jianshu.io/upload_images/1664496-2fa84fd7653e31b7.jpg)

