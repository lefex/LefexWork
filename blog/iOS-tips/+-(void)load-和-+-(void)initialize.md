所有父类的 load 方法调用后才会调用子类的，所有的本身类调用 load 完后，它的 Category 中的 load 方法才好被调用
 
```
+ (void)load
{
    NSLog(@"load FourViewController");
}
```

只有第一次使用的时候才会调用，以后再使用时不会调用
 
 如果子类没有实现这个方法或者子类调用了[super initialize] ，父类将会被调用多次，不需要 super ，因为父类先调用，子类后调用
 可以使用
 if (self == [SecondViewController class]) {
     NSLog(@"initialize SecondViewController");
 }
 避免多次被调用
 
它会阻塞当前线程，所以需要注意发生死锁


```
+ (void)initialize
{
    NSLog(@"initialize FourViewController");
}
```
===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
