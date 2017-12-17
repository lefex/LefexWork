本文是作者[Lefe](http://www.jianshu.com/p/88957fad1226)所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。

#### 说明：

使用 Block 的时候，我们通常会有以下几点疑问，我们带着这种疑问来阅读本文，本文难免会有遗漏或者错误，望读者朋友们提出来。[Lefe](http://www.jianshu.com/p/88957fad1226) 在使用 Block 的时候主要遇到了以下问题：

- 难道只要使用了 self 就需要使用 __weak 来避免循环引用吗？
- 为避免循环应用，为什么使用了 __weak 还需要使用 __strong ?
- 为什么使用 __block 修改变量后就可以在 Block 内部修改它的值？
- Block 什么时候释放呢？它是如何进行内存管理的？
- Block 为什么要用 copy？
- 为什么有些 Block 即使捕获了 self 也不会产生循环引用？
- 自动变量（局部变量）如何被 Block 捕获的，对象又是如何被 Block 捕获的？

带着这些问题，我们一块来揭开 Block 的真实面目，本文篇幅较长，可以分段阅读，建议读者耐心阅读，很枯燥的，如果能动手实现以下，会有趣很多。在阅读之前我们先了解下 `Clang`

#### Clang

本文主要用到了 `Clang`，那什么是 `Clang` 呢？它是 Xcode 默认的编译器。更多关于`Clang` 可以参考 [本文](https://github.com/ming1016/study/wiki/%E6%B7%B1%E5%85%A5%E5%89%96%E6%9E%90-iOS-%E7%BC%96%E8%AF%91-Clang---LLVM) 。这里我们主要用 Clang 把 Block 的实现转换成 C++ ，其实和 C 差不多，除了构造函数外。

打开 shell，进入 Lefe 的测试项目中，输入：

`clang -rewrite-objc HelloLefe.m`，这是会在当前目录下生产一个对应的 HelloLefe.cpp 文件，打开它就对了。截个图看看，别光看美女。


![屏幕快照 2017-06-25 上午9.36.43.png](http://upload-images.jianshu.io/upload_images/1664496-a821be9ae04537e5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


#### 内存分配

在阅读下文前，我们需要对内存分配有一定的了解

- **栈：** 在执行函数时，函数内局部变量的存储单元都可以在栈上创建，函数执行结束时这些存储单元自动被释放。栈内存分配运算内置于处理器的指令集中，效率很高，但是分配的内存容量有限。
- **堆：** 就是那些由 new分配的内存块，他们的释放编译器不去管，由我们的应用程序去控制，一般一个new就要对应一个 release。如果程序员没有释放掉，那么在程序结束后，操作系统会自动回收。这部分内存需要程序员手动释放。当然使用 ARC 后我们不需要处理。
- **全局/静态存储区：**全局变量和静态变量被分配到同一块内存中，在以前的C语言中，全局变量又分为初始化的和未初始化的，在C++里面没有这个区分了，他们共同占用同一块内存区。这部分数据不需要程序员手动释放，他会随着程序的消失二释放。
- **常量存储区：** 这是一块比较特殊的存储区，他们里面存放的是常量，不允许修改。


![屏幕快照 2017-06-25 上午10.20.09.png](http://upload-images.jianshu.io/upload_images/1664496-d8d007775ca9e141.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


关于内存分配的阅读 [本文](http://chenqx.github.io/2014/09/25/Cpp-Memory-Management/)

#### Block 是如何实现的

掌握了 `Clange` 的基本使用，那我们就看看 Block 究竟做了什么。从一个简单的例子开始。

Lefe 在 `HelloLefe.m ` 文件中，写了一个 Block，使用 `clang -rewrite-objc HelloLefe.m` 转换，转换后可以看到 Block 的具体实现。

````
- (void)lefeTestComplete
{
    void (^complete)(void) = ^(void){
        NSLog(@"Block\n");
    };
    complete();
}

@end

````

转换后的代码如下：

- 发现每个结构体的生成都会是一个又长又臭的名字，它会使用类名 `HelloLefe` 和方法名 `lefeTestComplete `等生成一个结构体，也就是 block 的实现，它是一个很重要的结构体。它主要包含了2个结构体和一个构造方法。 

````
struct __HelloLefe__lefeTestComplete_block_impl_0 {
    struct __block_impl impl;
    struct __HelloLefe__lefeTestComplete_block_desc_0* Desc;
    
    // 构造方法
    __HelloLefe__lefeTestComplete_block_impl_0(void *fp, struct __HelloLefe__lefeTestComplete_block_desc_0 *desc, int flags=0) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
    }
};

````

- `__block_impl `结构体，是 `__HelloLefe__lefeTestComplete_block_impl_0 ` 结构体的第一个变量

````
struct __block_impl {
  void *isa;  // isa 指针，block 其实也是一个 OC 对象，每个类都有一个指向其实例的一个指针
  int Flags;
  int Reserved;
  void *FuncPtr; // 相当于 block 中要执行的函数的指针
};
````

- 结构体 `__HelloLefe__lefeTestComplete_block_impl_0` 的第二个变量

````
static struct __HelloLefe__lefeTestComplete_block_desc_0 {
    size_t reserved;
    size_t Block_size;
} __HelloLefe__lefeTestComplete_block_desc_0_DATA = { 0, sizeof(struct __HelloLefe__lefeTestComplete_block_impl_0)};

````

- 同样，以类名和方法名生成一个函数，这个函数也就是 `^(void){ NSLog(@"Block\n"); };` 转换后的结果，__cself 和 OC 中的 self 差不多一个意思，它就是 `__HelloLefe__lefeTestComplete_block_impl_0 `，是指向结构体 `__HelloLefe__lefeTestComplete_block_impl_0 `的指针

````
static void __HelloLefe__lefeTestComplete_block_func_0(struct __HelloLefe__lefeTestComplete_block_impl_0 *__cself) {
    
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_7__cv2l59cn5x90wh88hrkp35x80000gp_T_HelloLefe_b006ae_mi_0);
}
````


- 主函数，编译器编译后会自动给每个方法添加两个参数 `self ` 和 `_cmd `

````
static void _I_HelloLefe_lefeTestComplete(HelloLefe * self, SEL _cmd) {

     // 这段代码是对 void (^complete)(void) = ^(void){ NSLog(@"Block\n");}; 的转换
     
    void (*complete)(void) = ((void (*)())&__HelloLefe__lefeTestComplete_block_impl_0((void *)__HelloLefe__lefeTestComplete_block_func_0, &__HelloLefe__lefeTestComplete_block_desc_0_DATA));
    
    // 这段代码相当于对 complete(); 的转换，
    ((void (*)(__block_impl *))((__block_impl *)complete)->FuncPtr)((__block_impl *)complete);
}

````
从上面的转换过程可以看出，声明一个 block 首先调用结构体 `__HelloLefe__lefeTestComplete_block_impl_0 ` 的构造函数，得到一个 IMP，相当于 OC 中的 IPM，它保存了这个 block 所需要的信息，当调用 block 的时候，直接调用 IPM-> FuncPtr。

到这里相信读者还是对 Block 的实现很陌生，很正常，坚持阅读一会，试试看。头脑中试着把 Block 就当做是一个 NSObject 对象。

#### Block 捕获变量

记得刚接触 Block 的时候，只是隐约听到 Block 可以自动捕获 Block 中使用的变量。是的，Block 可以捕获它所用到的自动变量或对象，但是它只是捕获了它所用到的变量，其他用不到的变量它并不会捕获，这里就是引起循环引用的一个重点，下文会详细将到。对应全局变量 Block 并不或去捕获。

以上的 block 的实现多少有点眉目了，那么 block 是如何捕获变量的，我把将要转换的代码改为：

```
- (void)lefeTestComplete
{
    int dmy = 256;
    int val = 10;
    const char *fmt = "val = %d\n";
    
    void (^complete)(void) = ^(void){
        printf(fmt, val);
    };
    complete();
}
```

转换后的代码如下，观察的实现发现多了
`const char *fmt; int val;` 这就是 block 捕获的变量，但我们发现 `dmy ` 这个变量并没有捕获，因为在 block 中压根就没使用。结构体的构造方法也需要传入捕获的变量来构造结构体。

```
struct __HelloLefe__lefeTestComplete_block_impl_0 {
  struct __block_impl impl;
  struct __HelloLefe__lefeTestComplete_block_desc_0* Desc;
  const char *fmt;
  int val;
  __HelloLefe__lefeTestComplete_block_impl_0(void *fp, struct __HelloLefe__lefeTestComplete_block_desc_0 *desc, const char *_fmt, int _val, int flags=0) : fmt(_fmt), val(_val) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __HelloLefe__lefeTestComplete_block_func_0(struct __HelloLefe__lefeTestComplete_block_impl_0 *__cself) {
  const char *fmt = __cself->fmt; // bound by copy
  int val = __cself->val; // bound by copy

        printf(fmt, val);
    }

static struct __HelloLefe__lefeTestComplete_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __HelloLefe__lefeTestComplete_block_desc_0_DATA = { 0, sizeof(struct __HelloLefe__lefeTestComplete_block_impl_0)};

static void _I_HelloLefe_lefeTestComplete(HelloLefe * self, SEL _cmd) {
    int dmy = 256;
    int val = 10;
    const char *fmt = "val = %d\n";

    void (*complete)(void) = ((void (*)())&__HelloLefe__lefeTestComplete_block_impl_0((void *)__HelloLefe__lefeTestComplete_block_func_0, &__HelloLefe__lefeTestComplete_block_desc_0_DATA, fmt, val));
    ((void (*)(__block_impl *))((__block_impl *)complete)->FuncPtr)((__block_impl *)complete);
}

```

#### 修改 Block 中的捕获的变量

上面的例子中，并不能在 Block 中修改所捕获的变量，那么如何修改 Block 中所捕获的变量呢？可以使用 __block。如果修改 Block 中的变量，编译器会直接报错。比如：

```
- (void)leftTestBlock
{
    int age = 0;
    void (^block)(void) = ^{
        age = 10;
    };
}
```
这段代码编译器直接会报错，可能有些同学会说直接用 __block，但是为什么使用 __block 就可以呢？再看一下下面的代码：

```
// 全局变量
int global_val = 1;
// 全局静态变量
static int static_global_val = 2;

- (void)lefeTestComplete
{
    // 静态变量
    static int static_val = 3;
    void (^complete)(void) = ^{
        global_val *= 1;
        static_global_val *= 2;
        static_val *= 3;
    };
    complete();
}

```
这段代码是没有任何问题的，它可以正常的编译通过，它没有使用 __block。详细大部分的同学读到这里都会有一个疑惑，这是为什么呢？我们不妨来看一下他的具体实现。发现全局变量并没有被捕获到 `__HelloLefe__lefeTestComplete_block_impl_0 ` 中，仅仅捕获了 static_val，想想也是，全局变量直接可以获取到，为什么还要捕获他呢？但捕获静态变量和以前不一样的是它捕获的是一个指针 `int *static_val;` 哦，对啊，直接使用它的指针就可以修改它了，但是为什么普通变量不可以使用其指针呢？因为一个 block 必须存在即使它所捕获变量的作用域释放掉，作用域释放掉后其变量也随之销毁，这意味着 block 就不能访问所捕获的自动变量了，如何修改？但是静态变量和全局变量不会释放啊！

```
int global_val = 1;
static int static_global_val = 2;


struct __HelloLefe__lefeTestComplete_block_impl_0 {
  struct __block_impl impl;
  struct __HelloLefe__lefeTestComplete_block_desc_0* Desc;
  int *static_val;
  __HelloLefe__lefeTestComplete_block_impl_0(void *fp, struct __HelloLefe__lefeTestComplete_block_desc_0 *desc, int *_static_val, int flags=0) : static_val(_static_val) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __HelloLefe__lefeTestComplete_block_func_0(struct __HelloLefe__lefeTestComplete_block_impl_0 *__cself) {
  int *static_val = __cself->static_val; // bound by copy

        global_val *= 1;
        static_global_val *= 2;
        (*static_val) *= 3;
    }

static struct __HelloLefe__lefeTestComplete_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __HelloLefe__lefeTestComplete_block_desc_0_DATA = { 0, sizeof(struct __HelloLefe__lefeTestComplete_block_impl_0)};

static void _I_HelloLefe_lefeTestComplete(HelloLefe * self, SEL _cmd) {
    static int static_val = 3;
    void (*complete)(void) = ((void (*)())&__HelloLefe__lefeTestComplete_block_impl_0((void *)__HelloLefe__lefeTestComplete_block_func_0, &__HelloLefe__lefeTestComplete_block_desc_0_DATA, &static_val));
    ((void (*)(__block_impl *))((__block_impl *)complete)->FuncPtr)((__block_impl *)complete);
}
```
通过上面的学习我们可以了解到，修改 Block 中捕获的变量，可以使用一下几种方式：

- 通过 __block 修饰变量
- 使用静态变量
- 使用全局变量、全局静态变量
- 使用指针，静态变量就是通过指针来修改它的值的

读到这里，相信你已经明白如何捕获自动变量了，也知道如何修改 Block 中所捕获的变量了，难道你不想知道为啥使用 __block 修饰后就可以修改 Block 中所捕获的变量吗？哈哈，坚持一下！

### __block 究竟是如何实现的呢？

__block 如同  static, auto 等修饰符，主要作用是觉得某一变量该保存到哪里。看看它是如何实现的。把下面的代码转化：

```
- (void)lefeTestComplete
{
    __block int val = 10;
    void (^complete)(void) = ^{val = 1;};
    
    complete();
}
```

转换后发现多了很多内容，为什么使用 __block 需要增加这么多代码呢？Lefe 表示很好奇。当使用 __block 变量时，会将 __block 变量从栈拷贝的堆上。当多个 block 共用一个 __block 变量时，__block 变量有一个计数器来记录有多少个 block 引用了它，block 释放掉的时候，__block 变量的引用计数将减1，直到为0时，__block 变量才会释放。

- __block 转换后的结构体

```
struct __Block_byref_val_0 {
  void *__isa;
  // __forwarding 主要用来获取 __block 变量的值，它的指向会根据 block 所处的内存位置不同，所指向的也不同。
  __Block_byref_val_0 *__forwarding; 
  int __flags;
  int __size;
  int val; // 值
};
```

- Block 的实现，发现多了 __Block_byref_val_0，它就是一个 block 变量

```
struct __HelloLefe__lefeTestComplete_block_impl_0 {
  struct __block_impl impl;
  struct __HelloLefe__lefeTestComplete_block_desc_0* Desc;
  __Block_byref_val_0 *val; // by ref
  
  __HelloLefe__lefeTestComplete_block_impl_0(void *fp, struct __HelloLefe__lefeTestComplete_block_desc_0 *desc, __Block_byref_val_0 *_val, int flags=0) : val(_val->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```

- `^{val = 1;}` 的实现被转换后：

```
static void __HelloLefe__lefeTestComplete_block_func_0(struct __HelloLefe__lefeTestComplete_block_impl_0 *__cself) {
  __Block_byref_val_0 *val = __cself->val; // bound by ref
(val->__forwarding->val) = 1;
}
```

```
static void __HelloLefe__lefeTestComplete_block_copy_0(struct __HelloLefe__lefeTestComplete_block_impl_0*dst, struct __HelloLefe__lefeTestComplete_block_impl_0*src) {
_Block_object_assign((void*)&dst->val, (void*)src->val, 8/*BLOCK_FIELD_IS_BYREF*/);
}

static void __HelloLefe__lefeTestComplete_block_dispose_0(struct __HelloLefe__lefeTestComplete_block_impl_0*src) {
_Block_object_dispose((void*)src->val, 8/*BLOCK_FIELD_IS_BYREF*/);
}

static struct __HelloLefe__lefeTestComplete_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __HelloLefe__lefeTestComplete_block_impl_0*, struct __HelloLefe__lefeTestComplete_block_impl_0*);
  void (*dispose)(struct __HelloLefe__lefeTestComplete_block_impl_0*);
} __HelloLefe__lefeTestComplete_block_desc_0_DATA = { 0, sizeof(struct __HelloLefe__lefeTestComplete_block_impl_0), __HelloLefe__lefeTestComplete_block_copy_0, __HelloLefe__lefeTestComplete_block_dispose_0};
```

- `__block int val = 10;` 转化后的代码如下，转换后变成一个结构体，并且初始化的时候值为 10

```
static void _I_HelloLefe_lefeTestComplete(HelloLefe * self, SEL _cmd) {
    __attribute__((__blocks__(byref))) __Block_byref_val_0 val = {
    	(void*)0,
    	(__Block_byref_val_0 *)&val, 
    	0, 
    	sizeof(__Block_byref_val_0), 
    	10
    };
    
    void (*complete)(void) = ((void (*)())&__HelloLefe__lefeTestComplete_block_impl_0((void *)__HelloLefe__lefeTestComplete_block_func_0, &__HelloLefe__lefeTestComplete_block_desc_0_DATA, (__Block_byref_val_0 *)&val, 570425344));

    ((void (*)(__block_impl *))((__block_impl *)complete)->FuncPtr)((__block_impl *)complete);
}

```

### Block 的内存段

下图主要说明 block 主要保存在栈，堆和数据区。
![屏幕快照 2017-06-23 下午10.06.35.png](http://upload-images.jianshu.io/upload_images/1664496-5725dee9cf47d2f4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

那什么样的变量分派到栈中、堆中或数据区呢？

- 1、当 block 字面量写在全局作用域时，即为 global block；
- 2、当 block 字面量不获取任何外部变量时，即为 global block；

除了以上2中情况外，其他的都分派到栈区，分派到栈区的 block ，当作用域结束后，它所捕获的变量也就释放掉了。为了解决这个问题，Blocks 提供了一个函数，可以把栈上的 block 拷贝到堆上。这样即使作用域结束也不会使 block 被释放。被 copy 后的 block ，它的 isa 指针就会变成 `impl.isa = &_NSConcreteMallocBlock`。Block 也就成了堆上的 Block。

使用 ARC 后，编译器会自动把栈中的 block 复制到堆上。

```
typedef int (^blk_t)(int);
blk_t func(int rate) {
	return ^(int count){return rate * count;}; 
}
```

```
blk_t func(int rate) {
	blk_t tmp = &__func_block_impl_0(
	__func_block_func_0, &__func_block_desc_0_DATA, rate);
	// 直接复制了一个 block，也就是拷贝到了堆上，即使当这个函数结束后，这个 block 任然不会被销毁 
	tmp = objc_retainBlock(tmp);
	return objc_autoreleaseReturnValue(tmp); }
```

但是不是所有的时候，编译器都会执行 copy 操作的，以下情况编译器不会执行 copy 操作的

- Block 作为一个参数传递给一个函数或方法时。

举个例子，下面这个例子会直接 crash，所以需要给数组中的 block 要执行 copy 操作

```
+ (id)getBlockArray {
    int val = 10;
    return [[NSArray alloc] initWithObjects:
            ^{NSLog(@"blk0:%d", val);},
            ^{NSLog(@"blk1:%d", val);},
            nil
            ];
}

+ (void)lefeTestComplete
{
    id obj = [self getBlockArray];
    typedef void (^blk_t)(void);
    blk_t blk = (blk_t)[obj objectAtIndex:0];
    blk();
}
```

但是使用系统提供的方法不需要执行 copy 操作，比如 GCD，因为在函数内部自己已经实现了 copy。

### 捕获对象：

前面都在讲捕获的是基本类型的变量，那么 Block 是如何捕获对象的呢？下面的例子中的数组中，打印结果为：

```
Array: (
    Lefe,
    Wang,
    Su,
    Yan
)
```
说明数组没有被释放掉。Block 内部会强引用对象，直到 Block 被释放，被引用的对象也将被释放。


```
@implementation HelloLefe

LefeBlock block;

+ (void)lefeTestComplete
{
    NSMutableArray *array = [NSMutableArray array];
    block = ^(NSString *name){
        [array addObject:name];
        
        NSLog(@"Array: %@", array);
    };
}

+ (void)addObject
{
    block(@"Lefe");
    block(@"Wang");
    block(@"Su");
    block(@"Yan");
    
}

@end

```

#### 循环引用一：

````
- (void)testMemoryLeakCase1
{
    self.logId = @"Hello logId";
    
    /**
     这种情况最容易发现，因为编译器会自动提示出现循环引用
     Why？
     self（SecondViewController）持有了 finshBlock，你可以把它当作一个普通的属性，是强引用
     而 finshBlock 又引用了 self，这样就形成了一个闭环。
     How？
     既然是因为出现了闭环，我们只需要打破这层闭环就可以，让 finshBlock 持有一个弱引用，这样 self（SecondViewController）持有了 finshBlock，但是 finshBlock 没有持有 self
     */
    
    // __weak typeof(self) weakSelf = self; 一般的宏定义是这样的
    __weak SecondViewController *wSelf = self;
    
    self.finshBlock = ^(BOOL isSuccess) {
        [wSelf loginTest];
    };
    
    /**
     在我们的应用中一般是下面这种方式写，为啥使用了 __weak 和 __strong ?
     有人可能会问，先 weak 后 strong，那相当于还是强引用了 self，你确定 strong的是 self？
     */
    
    /**
     打印：
     (lldb) p weakSelf
     (SecondViewController *) $0 = 0x0000000101c16f10
     (lldb) p self
     (SecondViewController *) $1 = 0x0000000101c16f10
     (lldb) p strongSelf
     (SecondViewController *) $2 = 0x0000000101c16f10
     (lldb)
     
     发现 weakSelf self 和 strongSelf 的内存地址是一样的，只是一次浅拷贝;
     */
    __weak typeof(self) weakSelf = self;
    
    self.finshBlock = ^(BOOL isSuccess) {
        // 如果没有这句话，当 self 被释放后，weakSelf 就变为了空，所以关于 weakSelf 的一些操作也就没什么意义了，如果还想让 weakSelf 所调用的一些方法有意义那么久需要强引用 weakSelf；
        __strong typeof(self) strongSelf = weakSelf;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"weakSelf.logId: %@", strongSelf.logId);
            NSString *name = strongSelf.logId;
            if (name.length > 0) {
                NSLog(@"Hello world");
            }
            [strongSelf loginTest];
        });
    };
    self.finshBlock(YES);
    
    /**
     修改前的：
     self.finshBlock = ^(BOOL isSuccess) {
        [self loginTest];
     };
     */
}
````

#### 循环引用二：
````
- (void)testMemoryLeakCase2
{
    /**
     这里面出现了两个对象的内存泄漏: task 和 self
     task的内存泄漏：
     task 有个属性叫 blcok，但是在 block 中又捕获了 task，这样就形成了一个闭环
     self 的内存泄漏：
     因为这个 block 中捕获了 self，block 没有释放那么 self 咋么能释放呢？
     所以只要打破这个闭环，self 就释放了。
     
     */
    AsyncTask *task = [AsyncTask new];
    
    __weak AsyncTask *wTask = task;
    task.block = ^(BOOL isFinish) {
        NSString *name = wTask.lastLoginId;
        self.logId = name;
    };
    [task sendLogin];
    
    /**
     AsyncTask *task = [AsyncTask new];
     task.block = ^(BOOL isFinish) {
     NSString *name = task;
     self.logId = name;
     };
     [task sendLogin];
     */
}
````

#### 循环引用三：

其实实例变量是通过 self->name 访问的，所以也可能造成循环引用。

````
- (void)testMemoryLeakCase3
{
    /**
     这里可能不太容易看出来，访问 name 实例变量相当于 self->name
     这样 self 持有 finshBlock， finshBlock 持有 self，形成闭环，造成循环引用
     */
    
    __weak SecondViewController *wSelf = self;
    self.finshBlock = ^(BOOL isFinish) {
        /*
         Dereferencing a __weak pointer is not allowed due to possible null value caused by race condition, assign it to strong variable first
         */
        // 发现这样写不行，还报错，它的意思是 __weak 指针可能为空，必须要强引用
        // wSelf->name = @"Hello lefe";
        
        /**
         那么为什么在 testMemoryLeakCase1 中 wSelf.logId = @"Hello logId"; 没有编译错误呢？我想
         估计 wSelf.logId 等价于 [wSelf logId]，相当于调用了一个方法，
         nil 调用方法是没有错误的。你知道属性和实例变量的区别吗？
         
         下面这行代码也会报错的：
         __weak AsyncTask *task;
         task->_sex;
         
         */
        wSelf.logId = @"Hello logId";
        
        __strong SecondViewController *strongSelf = wSelf;
        strongSelf->_name = @"Hello lefe";
    };
    
    /**
    也可以使用下面方法来解除循环引用
    __block id temp = self;
    self.finshBlock = ^(BOOL isFinish) {
        temp = nil;
    };
    self.finshBlock(YES);
    */
    
    
    /**
     修改前的代码：
     self.finshBlock = ^(BOOL isFinish) {
        name = @"Hello lefe";
     };
     */
}
````

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
