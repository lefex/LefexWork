#### Block 内存管理：
Block 内存主要分派到 NSGlobalBlock（data area），NSMallocBlock（堆 区 ）和 NSConcreteStackBlock（栈区）。在 ARC 环境下，Lefe没有遇到过栈区的 Block，因为 Block 会自动拷贝到栈区。

![屏幕快照 2017-06-23 下午10.06.35.png](http://upload-images.jianshu.io/upload_images/1664496-5725dee9cf47d2f4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

````
- (void)testBlockMemoryManagerCase1
{
    self.logId = @"Hello login";
    
    // __NSGlobalBlock__  全局，保存到数据区（data area） block
    /**
     1、当 block 字面量写在全局作用域时，即为 global block；
     2、当 block 字面量不获取任何外部变量时，即为 global block；
     */
    void(^block1)(void) = ^(){
    };
    block1();
    NSLog(@"block1: %@", block1);
    
    NSLog(@"finsh block: %@", self.finshBlock);
    
    // __NSMallocBlock__ 堆区的block，捕获了变量
    /**
     当 block 从栈拷贝到堆后，当栈上变量作用域结束时，仍然可以继续使用 block
     
     */
    void(^block2)(void) = ^(){
        NSLog(@"Block2: %@", self.logId);
    };
    block2();
    NSLog(@"block2: %@", block2);
    
    /**
     _NSConcreteStackBlock 栈区的 block
     如果其变量作用域结束，这个 block 就被废弃block 上的 __block 变量也同样会被废弃。
     为了解决这个问题，block 提供了 copy 的功能，将 block 和 __block 变量从栈拷贝到堆，就是下面要说的 _NSConcreteMallocBlock。
     */
````

#### 循环引用一：

![屏幕快照 2017-06-23 下午9.44.37.png](http://upload-images.jianshu.io/upload_images/1664496-2475f1c68187f872.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

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

        /**
     修改前的：
     self.finshBlock = ^(BOOL isSuccess) {
        [self loginTest];
     };
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
}
````

#### 循环引用二：

![屏幕快照 2017-06-23 下午9.52.27.png](http://upload-images.jianshu.io/upload_images/1664496-7e6ab7f9bbb0b9e3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


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


![屏幕快照 2017-06-23 下午9.44.37.png](http://upload-images.jianshu.io/upload_images/1664496-1591b2d2ed140066.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

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
     修改前的代码：
     self.finshBlock = ^(BOOL isFinish) {
        name = @"Hello lefe";
     };
     */
}
```

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
