### 说明
本文是作者[Lefe](http://www.jianshu.com/p/88957fad1226)所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。
###正文
### PMFMDB是什么
[PMFMDB](https://github.com/lefex/PMFMDB-iOS) 是一个Sqlite数据库查看工具，只需简单的几行代码就可以集成到项目中，可以方便的查看数据库中的数据。

> 主页面，所有的功能 , 在这里你可以选择你需要的操作，比如查看所有的tables，执行某一条SQL语句，查看查询记录，删除所有的表。

![11.png](http://upload-images.jianshu.io/upload_images/1664496-074f92b357983ee0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 点击【All tables】可以查询所有的数据库表，点击右上角刷新按钮，可以显示创建表的SQL语句

![
![221.png](http://upload-images.jianshu.io/upload_images/1664496-f7dc596ac10d9b9d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
](http://upload-images.jianshu.io/upload_images/1664496-0a46bebd8edc0cdd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


> 查询某一张表的内容，可以查看表中所有的数据，也可以按某一条件来查询数据

![屏幕快照 2016-12-11 上午11.07.01.png](http://upload-images.jianshu.io/upload_images/1664496-75df68a033e813f4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


> 执行某一条SQL语句，可以根据需求执行某一条SQL语句

![屏幕快照 2016-12-11 上午11.09.29.png](http://upload-images.jianshu.io/upload_images/1664496-790788b8a46a44c3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 查询历史，这里保存所所有的查询结果，方便对照每一次的查询记录


![屏幕快照 2016-12-11 上午11.12.19.png](http://upload-images.jianshu.io/upload_images/1664496-6cc3db0e11d81fca.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


### 集成

```objective-c
#pragma mark - DB Tools
- (void)configureDebugDB
{
#ifdef DEBUG
//    [self setLeftButtonItemWithTitle:@"DB"];
    self.topView.leftTitle = @"DB";
#else 
#endif
}
- (void)didClickNavigationBarViewBackButon
{
#ifdef DEBUG
    PMMainViewController *main = [[PMMainViewController alloc] init];
    main.dataPath = [[SNFDBServer sharedInstance] dbPath];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:main];
    [self presentViewController:nav animated:YES completion:nil];
#else
    [super didClickNavigationBarViewBackButon];
#endif
}
```

[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
