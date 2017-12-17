#### retain 方法
alloc 方法返回一个内存 block，并包含一个结构体 obj_layout 头，含有一个变量 retained 来存放引用数。这个数称为引用计数。图显示了一个对象在 GNUstep 实现中的结构。
你可以通过 retainCount 获得引用计数的值。

```
id obj = [[NSObject alloc] init]; NSLog(@"retainCount=%d", [obj retainCount]);
```

alloc 被调用后，引用计数是 1. 下面的源码显示了 retainCount 在 GNUstep 中的实现。```
- (NSUInteger) retainCount{return NSExtraRefCount(self) + 1;}inline NSUInteger NSExtraRefCount(id anObject)
{return ((struct obj_layout *)anObject)[-1].retained;}

```

源码从对象指针的头开始查询并且获得持有变量的计数值。由于内存 block 被分配时以0填充，retained 的值为 0. retainCount 函数 通过 "NSExtraRefCount(self) + 1" 返回值为 1.我们可以猜测到 retain 和 release 方法通过 +1，-1 来修改引用计数的值。

[obj retain]; 的实现

```- (id) retain{NSIncrementExtraRefCount(self);    return self;}inline void NSIncrementExtraRefCount(id anObject){if (((struct obj_layout *)anObject)[-1].retained == UINT_MAX - 1)[NSException raise: NSInternalInconsistencyExceptionformat: @"NSIncrementExtraRefCount() asked to increment too far"];((struct obj_layout *)anObject)[-1].retained++; 
}
```
尽管仅仅有几行代码，当变量 retained 的值溢出的时候，会抛出一个异常，从根本上说它是通过 “retained++” 来增加值。下面，我们学习 release 函数，它是和 retained 方法相反。

#### release 方法

可以轻松的知道 “release” 方法需要有一个 “retained--", 或许当值变为 0 是，还有一些代码。

```
[obj release];

```

 的实现如下：

 
```
- (void) release{if (NSDecrementExtraRefCountWasZero(self))[self dealloc]; }BOOLNSDecrementExtraRefCountWasZero(id anObject){if (((struct obj_layout *)anObject)[-1].retained == 0) {        return YES;    } else {((struct obj_layout *)anObject)[-1].retained--;return NO; }}
```

正如我们所期望的，“release” 是递减的。如果值为 0，对象将被 “dealloc” 方法销毁。我们看一下 “dealloc” 是如何实现的。

#### dealloc 方法

```
- (void) dealloc{NSDeallocateObject (self);}inline void NSDeallocateObject(id anObject){struct obj_layout *o = &((struct obj_layout *)anObject)[-1];free(o); 
}
```
 它仅仅释放了一个内存块。
 
 我们已经看到 alloc, retain, release, and dealloc 在 GNUstep 中的实现，同时也学到了如下知识：
 
 - 所有的 OC 对象有一个整数值称为引用计数
 - 当调用 alloc/new/copy/mutableCopy or retain 时，引用计数加 1
 - 调用 release 时引用计数减 1
 - 当引用计数变为 0 时，Dealloc

#### Autorelease

由于它的名字，你或许认为 autorelease 就像 ARC 一样。但是，他不是。它更像 C 语言中的自动变量。我们开始回顾一下C语言中的自动变量。然后，我们看一下 autorelease  在 GNUstep 中的实现，接下来是苹果对于 autorelease 的实现。

##### 自动变量

一个自动变量是一个词法作用域变量，当执行离开当前作用域，自动变量将自动销毁。

```
{int a;}
// 由于变量作用域离开了，自动变量将被销毁，而且不能继续访问
```

使用自动释放，你可以想使用自动变量的方式使用对象，意味着当执行离开代码块，release 方法将被自动调用。你也可以控制 block。

下面的步骤告诉你如何使用 autorelease 实例方法。

- 创建一个 NSAutoreleasePool 对象
- 调用 autorelease 来分配对象
- 释放 NSAutoreleasePool 对象

在创建和释放 NSAutoreleasePool 对象之间的代码块如同 C语言中自动变量的作用域。当 NSAutoreleasePool 对象释放时，NSAutoreleasePool 中所有的对象 将自动调用release 方法。下面是一些例子：

```
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; id obj = [[NSObject alloc] init];[obj autorelease];[pool drain];
```

上面代码中的最后一行，[pool drain] 将执行 [obj release]。 在  Cocoa Framework 中，NSAutoreleasePool 对象在任何地方被创建，拥有和释放，比如在 NSRunLoop，是应用的主循环。因此，在不明确需求的时候不要使用 NSAutoreleasePool 对象。

但是当有太多的自动释放对象时，应用的内存将变少。之所以发生是因为对象只有 NSAutoreleasePool 对象释放后才能释放。一个典型的例子是导入并修改图片的大小。在同一时刻，有太多的自动释放对象，比如 NSData 对象，UImage 对象。

```
for (int i = 0; i < numberOfImages; ++i) {/** Processing images, such as loading,etc.* Too many autoreleased objects exist,* because NSAutoreleasePool object is not discarded. * At some point, it causes memory shortage.*/}
```
在这种情况下，你需要创建一个 NSAutoreleasePool 对象，在适当的时候。
```
for (int i = 0; i < numberOfImages; ++i) {NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];/** Loading images, etc.* Too many autoreleased objects exist. */[pool drain];/** All the autoreleased objects are released by [pool drain]. */}
```

#### autorelease 的实现

这一节我们讨论 autorelease 在 GNUstep 中的实现。

`[obj autorelease];`

它的实现为：

```
- (id) autorelease{[NSAutoreleasePool addObject:self];}
```

事实上 autorelease 仅仅调用了 NSAutoreleasePool 的类方法 addObject，它实现起来有点困难。

fundamentally：根本地，从根本上；基础地
investigate：研究