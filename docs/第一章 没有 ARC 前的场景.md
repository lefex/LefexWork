### ARC 之前的场景

OSX Lion 和 iOS5 提供了一种称为 ARC 的内存管理机制。简短的说，ARC 把内存管理的工作让编译器来完成，而不是程序，这显著的提高了性能。在2、3章节，你将会看到 ARC 的强大。但是在进入如此梦幻的世界前，让我们回顾一下没有 ARC 时的场景。这样做，当我们在接下来两章深究 ARC 时，，你将会对整体有一个更全面的了解，ARC 必须提供一个强大库。
我们从内存管理的概述和它的概念开始，和接下来关于特征的实现，比如 alloc, dealloc, and autorelease.

#### 内存管理引用计数概述

Objective-C 中很多例子，我们可以把“内存管理”改述为“引用计数”。内存管理就是当程序需要一块内存的时候程序就分配给它一块，不需要的时候把它释放掉。不再使用的内存空间而没有把它释放掉是一种资源的浪费。同时也会引起程序的崩溃。引用计数，是被 George E. Collins 在1960年发明的，它使内存管理变的更简单。为了说明什么是引用计数，我们以办公室中的灯做一个类比。如图：

想想一下在办公室里只有一盏灯。早晨，当有人进入办公室，它需要灯，并打开了它。当他离开办公室时，由于他不再需要它了，所以他把灯关闭了。当多个人不断的打开关闭灯，当他们进来和出去时，会发生什么呢？当某个人离开的时候，他关闭了灯，这就意味着即使还有人在工作，办公室已变暗了。

为了解决这个问题，我们需要一种规则来保证当有一个或者多个人在办公室的时候灯要亮着，当没人的时候灯要熄灭。

- 1.当一个人来到一间空的办公室，她打开了灯
- 2.进入办公室的人，也可以使用灯
- 3.当有人离开时，他不再需要灯
- 4.当最后一个人离开办公室时，他把灯关闭

根据这些规则，我们介绍用一个计数器来记录有多少人。让我们看一下它是如何工作的。

- 1.当有人进入一个空屋子，计数器 +1，它从 0 变成了 1，因此灯打开了。
- 2.当另一个人进来后，计数器 +1，它从 1 变成了 2.
- 3.当有人离开时，计数器 -1，它从 2 变为了 1.
- 4.当最后一个人离开的时候，计数器变为 0 ， 灯也就关闭了。

让我们看一下，用这个比喻如何让我们理解内存管理。在 Objective- C 中，一个灯对应一个对象。虽然屋子里仅有一个灯，但是在 OC 中会有很多对象决定于计算机的资源限制。一个人对应于 OC 的上下文。上下文（Context）通常是一段代码，一个变量，一个变量的作用域，或者一个对象。它的意思就是处理一个目标对象。
Table 1–1 强调了办公室中的灯后 OC 中对象的关系。

正如我们可以使用计数器来管理灯，我们也可以用来在 OC 中管理应用的内存。换句话说，我们可以使用引用计数来管理 OC 中的对象。
上图中说明了使用引用计数来说明内存管理的概念。接下来的章节，我们深究这个概念并给出一些例子。

#### 探索内存管理的将来：
使用引用计数，你或许认为你需要记住引用计数的值，或者依赖于对象的其他对象，等等。其实没必要。你只需要根据下面的规则来思考引用计数就可以了。

- 你有任何你所创建的对象的所有权
- 你可以使用 retain 来拥有一个对象
- 当你不再需要一个对象时，你需要释放对它的拥有权
- 你不能释放不是你所拥有的对象的拥有权

以上是引用计数所有的规则。你所做的就是遵循这些规则。你一点也不用担心引用计数。”创建“，”拥有“ 和 ”释放拥有“ 使用规则，对于引用计数，“销毁”是很常用的词。 Table 1–2 展示了这些短语与 OC 中方法的联系。通常，你分配一个对象，某一时刻 retain 了它，然后你需要为每一个 alloc/retain 发送一个 release 消息。 一个对象从内存中移除时会调用 dealloc 方法。这些方法没有被 OC 提供。这是 Foundation Framework 的特征。在 Foundation Framework 有一个 alloc 类方法,和实例方法 retain, release, 和 dealloc 来处理内存管理。至于它是如何完成的，我们在下面的章节说明。

#### 你拥有创建的任何对象的所有权
你使用以下列方法为前缀的方法创建的对象，你将拥有它：alloc，new，copy，mutableCopy。让我们看一下如何用代码创建一个对象。下面例子使用 alloc 创建一个对象并拥有它。

`id obj = [[NSObject alloc] init];`

NSObject 实例方法 copy 创建一个对象的副本，这个对象必须准守 NSCopying 协议，并且必须实现 copyWithZone：方法。同样，“mutableCopy” 实例方法创建一个可变的副本，这个对象必须准守 NSMutableCopying 协议，并且实现 mutableCopyWithZone：方法。copy 和 mutableCopy 的不同就和 NSArray 和 NSMutableArray 一样。这些方法和 alloc 、new 一样来创建一个对象，因此，你已经拥有了它。正如前面所描述的，当你使用以 alloc, new, copy, 或者 mutableCopy 为前缀的方法，创建一个对象，你就拥有了它。

#### 使用 retain 取得一个对象的所有权
有时，一些方法不是在  alloc/new/copy/mutableCopy 组方法返回一个对象。这种情况你没有创建它，因此你也没拥有它。下面的例子使用 NSMutableArray 的类方法 array。

Obtain an object without creating it yourself or having ownership

id obj = [NSMutableArray array];/** The obtained object exists and you don’t have ownership of it. */[obj retain];


当你不再需要时，你必须释放对它的拥有权。
当你拥有一个对象，你不再需要的时候，必须使用 release 方法来释放拥有权。

你创建一个对象，并且拥有它
id obj = [[NSObject alloc] init];
现在你已经拥有了它
[obj release];
这个对象已经被释放了。尽管有一个指针变量 obj 指向了这个对象，但是你不能再访问它。

上面的例子中，一个对象被创建并后，所有权被 alloc 分配，通过 release 方法来释放它。您可以对保留对象做同样的事情。

#### alloc, retain, release, 和 dealloc 的实现
OS X 和 iOS 的许多部分作为苹果公开可用的开源软件在苹果的开源项目中。正如上面所提到的，alloc, retain, release, 和 dealloc 是 NSObject 的方法。作为 Cocoa Framework 的一部分，不幸的是，Foundation Framework 并没有开源。幸运的是，由于 Core Foundation Framework 是苹果开源的一部分，NSObject 用到的内存管理的源码是开源的。但是，没有 NSObject 自己的实现，很难看到全貌。所以，让我们从另一个源代码GNUstep检查。GNUstep 对 Cocoa Framework 是兼容的。虽然我们不能期望它与苹果的实现完全相同，当它的工作方式是相同的，实现也是相似的。理解 GNUstep 源码可以帮助我们猜测 Cocoa 的实现。

#### alloc 方法
以 GNUstep 中的 NSObject 类的 alloc 方法开始。 作为一个侧面说明，本书中的部分源码为了更容易明白实现过程而有修改。调用 NSObject 的 “alloc” 方法：
id obj = [NSObject alloc];
 
alloc 方法的实现如下：

```
+ (id) alloc
{
return [self allocWithZone: NSDefaultMallocZone()];
}
+ (id) allocWithZone: (NSZone*)z
{
return NSAllocateObject (self, 0, z);
}

struct obj_layout {NSUInteger retained; 
};inline idNSAllocateObject (Class aClass, NSUInteger extraBytes, NSZone *zone){int size = /* needed size to store the object */ id new = NSZoneMalloc(zone, size);memset(new, 0, size);new = (id)&((struct obj_layout *)new)[1];}
```

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


#### 不太懂
you’ll form a greater appreciation of all that ARC has to offer and build a stronger foundation for when we delve into ARC in the next two chapters.

```
significantly 显著地
review 回顾；检查；复审
delve into 深究
appreciation 了解
overview 概述
rephrase 改述
invented 发明
analogy 类比
metaphor：比喻
corresponds to：对应于
figure： 图形
dig：探究
exploring：探索
relinquish：释放，放弃
phrases：短语，词组
compatible：兼容
manner：方式
fundamentally：根本地，从根本上；基础地
investigate：研究
```