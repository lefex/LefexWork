本文转载自：[iMetalk](https://lefex.github.io/)

**本文由 [iMetalk](https://lefex.github.io/) 团队的成员 薛好霞美女 完成，主要帮助读者如何对APP进行主题切换**。

# 一、前言
移动应用开发中，有时为了让应用有趣、多变、适应不同的场景，我们就会需要例如切换主题此类的功能（关键是，近期项目中需要有这个功能，所以……你懂得……）。说到主题切换，那么就需要做到切换主题的瞬间，使所有相关的界面元素都发生变化，如果你的项目足够大，界面足够复杂，这听起来是个大动作，其实也确实是个大动作哈哈……言归正传，我们要实现这一变化，这就需要一种机制来将主题切换这个事件抛出来，然后接受主题切换事件的相关界面做出相应改变，看到这里，你肯定也想到了 `NSNotificationCenter` ，没错，确实是用 `NSNotificationCenter`来实现的。下面，我就来说一下我在项目中的具体实现思路与步骤。

# 二、主题切换的具体设计思路
- 注册一个通知
- 创建一个常量类 `ThemeConstant`，用来定义通知名、主题目录文件名、一些key等等。
- 创建一个主题管理类 `ThemeManager`。
- 在已创建的主 `controller` 里作为注册的这个通知的监听者。
- 创建一个 `UIImage` 的扩展，`UIColor` 的扩展，`UIFont`的扩展。

# 三、实现主题切换需做的准备
在具体开始实现之前，我们需要一些准备工作。

**准备一**    
首先我们需要明确主题切换的时候哪些元素需要作出相应的改变：

- 图片，其中包括 `UIImageView` 上的图片，`UIButton` 上的常态、高亮、选中图片等等。
- 颜色，其中包括背景颜色，文字颜色等等。颜色最好能让设计人员有一个统一的标准，不然东一榔头西一棒子，这绝对会是主题开发中的坑。
- 字体。

**准备二**    
由于项目中的图片很多很杂，所以需要确定下图片的命名规则，以便主题的切换。我采用的命名规则是：

- 主题名_图片所在模块名_图片名（普通、常态）
- 主题名_图片所在模块名_图片名_hl（点击）
- 主题名_图片所在模块名_图片名_sel（选中）

**准备三**  
由于我们项目中的主题除了本地默认的黑白两套主题，还可下载其他的主题使用，所以，这就需要确定主题文件在沙河的目录结构并定义其目录文件名。具体如下：

```
@interface ThemeConstant : NSObject

/**
 *  通知
 */
extern NSString * const MTTChangeThemeNotificationName;

/**
 *  目录结构
 */
extern NSString * const MTTThemeResourceFolderName; //"ThemeResource"

extern NSString * const MTTBlackThemeName; //"Black"
extern NSString * const MTTWhiteThemeName; //"White"
extern NSString * const MTTUserDefaultsDicKey; //"themeName"

extern NSString * const MTTThemeImageFolderName;//"ThemeImage"
extern NSString * const MTTThemeConfigJsonName;//"ThemeConfig.json"

extern NSString * const MTTThemeImageCacheName;//"ThemeImageCache"

@end
```

# 四、主题切换的具体实现

好了，现在我们可以正式开始实现主题切换了。

### 1、创建主题管理类
**ThemeManager.h文件**

```

@interface ThemeManager : NSObject

+ (instancetype)sharedInstance;

//当前使用的主题名称
@property (nonatomic, copy, readonly) NSString *themeName;

//本地目录下的所有主题名称
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *themeNameArray;

//图片缓存对象X
@property (nonatomic, strong, readonly) YYMemoryCache *cache;

/**
 *  初始化主题
 */
- (void)initCurrentTheme;

/**
 *  更换主题
 */
- (void)changeThemeWithThemeName:(NSString *)themeName;

/**
 *  根据图片名获取图片
 *
 *  @param imageName 图片名
 *
 *  @return 图片
 */
- (UIImage *)getThemeImageNamed:(NSString *)imageName;

/**
 *  获取下载后的主题要保存的路径
 *
 *  @param themeName 要保存的主题名
 *
 *  @return 主题路径
 */
- (NSString *)getThemeSavedPath:(NSString *)themeName;


NS_ASSUME_NONNULL_END

@end
```

**ThemeManager.m文件**

```

单例。
+ (instancetype)sharedInstance
{
    static ThemeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ThemeManager alloc] init];
    });
    return instance;
}

```

初始化主题。应用启动的时候需要初始化主题，首先读取本地保存的主题名称去设置主题，该方法主要是对主题名称的一些判断逻辑。

```
- (void)initCurrentTheme
{
    NSString *userId = [[[MTServerCore getLoginServer] currentUser] userId];
    if (!userId.length) {
        //未登录
        self.themeName = MTTBlackThemeName;
        return;
    }

    //读取本地保存的主题名称去设置主题
    NSString *themeName = [self getUserThemeName];
    
    if (!themeName.length) {
        self.themeName = MTTBlackThemeName;
    }else if ([themeName isEqualToString:MTTBlackThemeName]){
        self.themeName = MTTBlackThemeName;
    }else if ([themeName isEqualToString:MTTWhiteThemeName]){
        self.themeName = MTTWhiteThemeName;
    }else{
        NSString *currentThemePath = [NSString mt_getThemePathWithThemeName:themeName];
        if (!currentThemePath.length) {
            self.themeName = MTTBlackThemeName;
        }else{
            self.themeName = themeName;
            [self getDownloadThemeResource];
        }
    }
}
```

切换主题。应用内切换主题的时候调用，该方法主要是对当前要设置主题的保存处理。

```
- (void)changeThemeWithThemeName:(NSString *)themeName
{
    if (!themeName.length) {
        return;
    }
    [_cache removeAllObjects];
    
    self.themeName = themeName;
    
    //保存当前主题
    [self setUserThemeName:_themeName];
    
    if ([_themeName isEqualToString:MTTBlackThemeName] || [_themeName isEqualToString:MTTWhiteThemeName]){
        [self sendChangeThemeNotification];
    }else{
        [self getDownloadThemeResource];
        [self sendChangeThemeNotification];
    }
}
```

发送主题切换的通知。该方法就是将主题切换的通知发出去，让接受通知的相关界面做出相应的主题改变。

```
- (void)sendChangeThemeNotification
{
    //发送主题切换的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:MTTChangeThemeNotificationName object:nil userInfo:nil];
}
```

获取下载的主题资源包。该方法就是对下载的主题的处理。

```
- (void)getDownloadThemeResource
{
    //获取主题包路径
    themePath = [NSString mt_getThemePathWithThemeName:_themeName];
    
    //获取主题包下图片包的路径
    imagePath = [themePath stringByAppendingPathComponent:MTTThemeImageFolderName];
    
    //获取主题包下颜色配置文件
    NSString *jsonFilePath = [themePath stringByAppendingPathComponent:MTTThemeConfigJsonName];
    NSData *data = [NSData dataWithContentsOfFile:jsonFilePath];
    NSError *error;
    themeConfigDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
} 
```

### 2、创建扩展类
**UIImage+Theme.h文件**


```
@interface UIImage (Theme)

/**
 设置主题图片

 @param imageName 图片名称（没有主题名前缀的）
 @return UIImage
 */
+ (UIImage *)mt_themeImageNamed:(NSString *)imageName;

@end
UIImage+Theme.m文件
+ (UIImage *)mt_themeImageNamed:(NSString *)imageName
{
    if (imageName.length == 0) {
        return nil;
    }
    
    // The default theme
    NSString *themeName = [ThemeManager sharedInstance].themeName;
    if ([themeName isEqualToString:MTTBlackThemeName] || [themeName isEqualToString:MTTWhiteThemeName]) {
        NSString *imgName = [NSString stringWithFormat:@"%@_%@",themeName,imageName];
        return [UIImage imageNamed:imgName];
    }
    
    // The download theme
    if ([[imageName pathExtension] length] > 0) {
        imageName = [imageName stringByDeletingPathExtension];
    }
    if ([imageName hasSuffix:@"@2x"]) {
        imageName = [imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
    }
    if ([imageName hasSuffix:@"@3x"]) {
        imageName = [imageName stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
    }
    
    return [self getImageWithScale:[UIScreen mainScreen].scale imageNamed:imageName];
}

+ (UIImage *)getImageWithScale:(NSUInteger)scale imageNamed:(NSString *)imageName
{
    NSString *name = [self imageNameWithScale:scale originName:imageName];
    
    UIImage *image = [self getThemeImage:name withCache:[ThemeManager sharedInstance].cache];
    
    if (!image && scale > 1) {
        return [self getImageWithScale:scale - 1 imageNamed:imageName];
    }
    
    return image;
}

+ (NSString *)imageNameWithScale:(NSUInteger)scale originName:(NSString *)originName
{
    if (scale == 1) {
        return [originName stringByAppendingString:@".png"];
    }
    
    return [originName stringByAppendingString:[NSString stringWithFormat:@"@%@x.png", @(scale)]];
}

+ (UIImage *)getThemeImage:(NSString *)imageName withCache:(YYMemoryCache *)cache
{
    //先去缓存里找
    UIImage *image = [cache objectForKey:imageName];
    if (image) {
        return image;
    }
    //去沙盒里找
    UIImage *finalImage = [[ThemeManager sharedInstance] getThemeImageNamed:imageName];
    if (finalImage) {
        [cache setObject:finalImage forKey:imageName];
        return finalImage;
    }
    
    return nil;
}
```

### 3、在APPDelegate中配置主题

在- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions方法中配置主题，如下所示：
```
//配置主题
[[ThemeManager sharedInstance] initCurrentTheme];
```

### 4、在应用内切换主题
```
[[ThemeManager sharedInstance] changeThemeWithThemeName:themeName];
```

### 五、总结
到这里，就只剩下最后一步了，在需要主题改变的已创建的主controller里接收通知，并用主题管理类里的当前主题的主题资源对界面上的元素做出改变即可。

如果您想第一时间看到我们的文章，欢迎关注公众号。
![微信公众号](http://upload-images.jianshu.io/upload_images/1664496-f94c6e4f349a2f74.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
