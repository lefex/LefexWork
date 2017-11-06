iOS 11 适配

### 导航

iOS 11 中导航主要问题是，使自定义返回按钮点击区域变小了，导致用户体验很不好。主要有两种方法：

- 方法一：使用 Frame 布局
iOS 11 以前，imageView 的 Frame 可以是 `CGRectZero`，这样它的点击区域也很大，而 iOS 11 必须设置一个 Frame。

```
UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
imageView.userInteractionEnabled = YES;
imageView.contentMode = UIViewContentModeLeft;
imageView.image = image;
UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
```

- 方法二： 使用自动布局，当然这种方式 iOS8 以上才行，

```
UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
imageView.userInteractionEnabled = YES;
imageView.contentMode = UIViewContentModeLeft;
imageView.image = image;
if ([imageView respondsToSelector:@selector(widthAnchor)]) {
    NSLayoutConstraint *widthConstraint = [imageView.widthAnchor constraintEqualToConstant:80];
    // Swift widthConstraint.isActive = YES;
    widthConstraint.active = YES;
}
    
UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
```

[了解更多](https://stackoverflow.com/questions/44442573/navigation-bar-rightbaritem-image-button-bug-ios-11)

### automaticallyAdjustsScrollViewInsets 属性

iOS 11 后 UIViewController 的属性 automaticallyAdjustsScrollViewInsets，变为了 UIScrollView's contentInsetAdjustmentBehavior。如果发现界面无意中位置偏移了，很可能是这个属性导致的。

```

if (@available(iOS 11.0, *)) {
   self.collectionView.contentInsetAdjustmentBehavior =UIScrollViewContentInsetAdjustmentNever;
} else {
   self.automaticallyAdjustsScrollViewInsets = NO;
}
```

`MJRefresh` 出现的问题，[看这个](https://github.com/CoderMJLee/MJRefresh/issues/956)

### applicationDidEnterBackground 不执行

APP 进入后台后,applicationDidEnterBackground: 这个方法将延迟大约 1000 毫秒执行, 那么如果在进入后台时做一些任务，可能会达不到预期的效果。如果 APP 刚进入应用立即启动，applicationDidEnterBackground: 和 applicationWillEnterForeground: 这两个方法都不会调用。如果有这么一个场景，进入后台后给应用设置手势密码，当 APP 刚进入后就立即启动，那么 applicationDidEnterBackground：这个方法不会立即执行，从而手势密码也就不会设置。

### 设备名称

如果你的项目中有有关设备名的显示，比如 `来自 iPhone X`，那么你需要适配下新设备：

```
@"iPhone10,1" : @"iPhone 8",
@"iPhone10,4" : @"iPhone 8",
@"iPhone10,2" : @"iPhone 8 Plus",
@"iPhone10,5" : @"iPhone 8 Plus",
@"iPhone10,3" : @"iPhone X",
@"iPhone10,6" : @"iPhone X",
```
当然这些值可以 [看这里](https://www.theiphonewiki.com/wiki/Models)
推荐一个 [第三方库](https://github.com/squarefrog/UIDeviceIdentifier)

### UIImagePickerController 设置导航背景图

```
[self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
```
这样设置发现对 `UIImagePickerController ` 不起作用，需要使用：

```
self.navigationBar.barTintColor = [UIColor blackColor];
```

### WebViewJavascriptBridge crash

如何你项目中使用 [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge) 与 H5 交互，那么这里有一个 crash。

[解决方法](https://github.com/marcuswestin/WebViewJavascriptBridge/issues/267)

### 提交 AppStore
        
提交 AppStore 时需要 1024*1024 Logo，别好不容易打包好了，发现还需要一个 Logo，重新打包有点不值的。

![appStore.png](http://upload-images.jianshu.io/upload_images/1664496-f421da5d300965c0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### iPhone X

- iPhone X 的状态栏由原来的 20 变为了 44。这个如果在导航的位置设置自定义的 View，在 iPhone X 上出问题。会挡住 View 的显示。

![statusbar.png](http://upload-images.jianshu.io/upload_images/1664496-81b380a37e28997a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```
[UIApplication sharedApplication].statusBarFrame

{{0, 0}, {375, 44}}
```

- 启动页，如果使用 `LaunchScreen.storyboard` 作为启动页，需要调整下 Top 的约束，以前为 -20 ，改为 -44 ；

![LaunchScreen.png](http://upload-images.jianshu.io/upload_images/1664496-d4b398eab07c2bf6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如果不是采用 `LaunchScreen.storyboard` 这种方式作为启动页，可以 [看这篇](https://github.com/talisk/iPhoneXAdaptationTips/blob/master/CHINESE.md)

- 关于距离状态栏的高度在 iPhone X 有可能被挡住，需要留意一下；

[更多](https://developer.apple.com/ios/human-interface-guidelines/overview/iphone-x/)

### 屏幕尺寸变化

- {375, 812} iPhone X
- {375, 667} iPhone 8  /  iPhone 7  ／ iPhone 6
- {414, 736} iPhone 8P /  iPhone 7P  / iPhone 6P
- {320, 568} iPhone SE /  iPhone 5

### 参考

[bugly](https://mp.weixin.qq.com/s/AZFrqL9dnlgA6Vt2sVhxIw)