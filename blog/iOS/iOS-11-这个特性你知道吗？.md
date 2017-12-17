适配 iOS 11 时意外发现个 **New Color Set** ，仔细研究了下，发现比较爽。它集中管理项目中的颜色，项目中有多少颜色一目了然。

![color.png](http://upload-images.jianshu.io/upload_images/1664496-64ad1311e8de7814.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

使用的时候，直接使用：

```
[UIColor colorNamed:name];
```

但是这个方法只有在 iOS 11 以上系统有效，我们可以自己实现一个方法，或者把系统的方法替换掉。

```
@implementation UIColor (main)

+ (UIColor *)mtColorNamed:(NSString *)name
{
    if (name.length == 0) {
        return [UIColor clearColor];
    }
    
    NSString *cString = [[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if (cString.length != 6) {
        return [UIColor clearColor];
    }
    
    if (@available(iOS 11.0, *)) {
        return [UIColor colorNamed:name];
    } else {
        return [self mtColorWithHexString:name];
    }
}

+ (UIColor *)mtColorWithHexString:(NSString *)color
{
    unsigned int r, g, b;
    [[NSScanner scannerWithString:[color substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&r];
    [[NSScanner scannerWithString:[color substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&g];
    [[NSScanner scannerWithString:[color substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&b];
    
    return [UIColor colorWithRed:((CGFloat) r / 255.0f) green:((CGFloat) g / 255.0f) blue:((CGFloat) b / 255.0f) alpha:1.0f];
}

@end
```

使用时，直接调用我们自定义的方法即可：

```
static NSString* const k50E3C2Color = @"50E3C2";
static NSString* const k10AEFFColor = @"10AEFF";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(40, 100, 100, 50)];
    _label.text = k50E3C2Color;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor mtColorNamed:k10AEFFColor];
    _label.backgroundColor = [UIColor mtColorNamed:k50E3C2Color];
    [self.view addSubview:_label];
}
```

![result.png](http://upload-images.jianshu.io/upload_images/1664496-65035cf2b74a7123.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 推荐阅读

[iOS 11 适配看这篇还不够？](http://www.jianshu.com/p/84543baee9f8)

[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
