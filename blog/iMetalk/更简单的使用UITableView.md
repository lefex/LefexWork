本文转载于： [iMetalk](https://lefex.github.io/)

**本文由 [iMetalk](https://lefex.github.io/) 团队的成员 武卓 完成，主要帮助读者简化UITableView的创建**。  

> 俗话说的好：没有什么界面是一个 UITableView 解决不了的，如果不行，那就俩个！

因为经常在工作用到 UITableView ，几乎每个界面都要用到，每次写一坨 UITableView 初始化对于我，对于 UIViewController 都是一种负担，便有了对 UITableView 封装的想法。

# 一、UITableViewDataSource

UITableView操作最多的就是UITableViewDataSource协议了,其中最常用的有`numberOfRowsInSection`和`tableView: cellForRowAtIndexPath:`这两个方法。那么对UITableView封装的第一步就是把UITableViewDataSource协议中的方法抽离出来。TCZDataSource 就是 UITableViewDataSource 协议的一个实现。

- **TCZDataSource.h 文件**

```
typedef void (^TCZCellConfigureBlock)(id cell, NSIndexPath * indexPath);
```

```
@interface TCZDataSource : NSObject<UITableViewDataSource>

// 初始化
- (id)init;

// 表示数据源是否是有多个`section`
@property (nonatomic, assign) BOOL isGroup;

// cell cell复用时的回调
@property (nonatomic, copy) TCZCellConfigureBlock cellConfigureBlock;

// 数据源，需要实现`TCZCellConfigureDelegate `协议
@property (nonatomic, strong) NSArray<TCZCellConfigureDelegate> *dataModels;

@end
```


- **TCZCellConfigureDelegate**

`dataModels `中的数据源必须实现`TCZCellConfigureDelegate ` 协议，它主要有以下几个方法：

```

@optional
// 返回cell的唯一标识
- (NSString *)cellIdentifierConfigure;

@required

// 返回cell的名字，主要用来创建对应的cell
- (NSString *)cellNameConfigure;

// 返回cell的高度
- (CGFloat)cellHeightConfigure;
```
  
- **TCZDataSource.m文件**

根据`isGroup`来返回section数量以及row数量,

```
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.isGroup ? _dataModels.count : 1;
}
```

```
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isGroup) {
        NSArray *sectionData = [_dataModels objectAtIndex:section];
        return sectionData.count;
    }
    else{
        return _dataModels.count;
    }
}
```

首先我们取出加载的数据,然后根据`TCZCellConfigureDelegate `把我们需要的cellIdentifier拿到，通过`dequeueReusableCellWithIdentifier: forIndexPath :`就可以得到对应的cell，接着通过`self.cellConfigureBlock `把我们的cell以及indexPath传出去，这样我们可以自定义的对cell进行赋值了。

```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<TCZCellConfigureDelegate> model = [self modelsAtIndexPath:indexPath];
    NSString *cellIdentifier;
    cellIdentifier = [model cellIdentifierConfigure] ? : [model cellNameConfigure] ;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (self.cellConfigureBlock) {
        self.cellConfigureBlock(cell, indexPath);
    }
    
    return cell;
}

```

`TCZDataSource`中就这些代码,实现思路通过`TCZCellConfigureDelegate`协议取到对应cell的基本信息,再通过self.cellConfigureBlock回调在外部对cell进行自定义操作。

# 二、UITableViewDelegate
既然已经把 UITableViewDataSource 抽离出来，接下来就是把 UITaleView 另一个重要的协议`<UITableViewDelegate>`抽离。大体思路跟`TCZDataSource`一致,声明`TCZTableViewDelegate`类,实现<UITableViewDelegate>协议，因为Delegate中涉及到estimatedRowHeight，所以我们声明`TCZTableConfigure`类，配置UITaleView 的基本属性。

**TCZTableConfigure.h文件**

```
@interface TCZTableConfigure : NSObject

// 自动估算cell高度
@property (nonatomic, assign) BOOL isEstimated;

// cell高度 动态or固定
@property (nonatomic, assign) BOOL isAuto;
@property (nonatomic, assign) BOOL isGroup;

@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) CGFloat sectionHeight;

@end

```

**TCZTableConfigure.m文件**

- **初始化**

`TCZTableViewDelegate` 通过 `TCZTableConfigure `初始化`TCZTableViewConfigureBlock `回调可以在初始化时自定义`TCZTableConfigure `的内容。

```
typedef void (^TCZTableViewConfigureBlock)(TCZTableConfigure *configure);

- (id)initWithConfigure:(TCZTableViewConfigureBlock)configureBlock
{
    if(self = [super init]) {
        TCZTableConfigure *aConfigure = [TCZTableConfigure new];
        configureBlock ? configureBlock(aConfigure) : nil;
        _configure = aConfigure;
    }
    return self;
}

```

- **配置Cell的高度**

通过`TCZCellConfigureDelegate`协议 `cellHeightConfigure `  来配置rowHeight,如果没有实现这个协议就使用`TCZTableConfigure`的默认高度

```
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sectionHeaderHeightForSection:)])
    {
        return [self.delegate sectionHeaderHeightForSection:section];
    }
    
    return _configure.sectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sectionViewForHeaderInSection:)])
    {
        return [self.delegate sectionViewForHeaderInSection:section];
    }
    
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_configure.isEstimated) {
        return UITableViewAutomaticDimension;
    }
    
    id<TCZCellConfigureDelegate> model = [self modelsAtIndexPath:indexPath];
    CGFloat height = [model cellHeightConfigure];
    
    return _configure.isAuto ? height : _configure.rowHeight;
}

```

# 三、TCZBaseTabelView的实现
最后就差tableView了，声明`TCZBaseTabelView`基类，对其进行一些初始化的配置以及注册cell。

在TCZDataSource的`set`方法中，通过实现`<TCZCellConfigureDelegate>`协议的数据源向UITableView中注册cell。获取到cell 的 class 以及 indentifier，对cell进行register。为了避免重复register，需要用一个`Dictionary `记录一下cell。

```
- (void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    [super setDataSource:dataSource];
    [self regiserCells];
}

- (void)regiserCells
{
    TCZDataSource *_dataSource = (TCZDataSource *)self.dataSource;
    NSMutableDictionary *indentifierDict = [NSMutableDictionary dictionary];
    [_dataSource.dataModels enumerateObjectsUsingBlock:^(id<TCZCellConfigureDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![indentifierDict objectForKey:[obj cellNameConfigure]]) {
            [indentifierDict setObject:[obj cellIdentifierConfigure] ? :[obj cellNameConfigure] forKey:[obj cellNameConfigure]];
            NSString *indentifier = [obj cellIdentifierConfigure] ? :[obj cellNameConfigure];
            [self registerClass:NSClassFromString([obj cellNameConfigure])   forCellReuseIdentifier:indentifier];
        }
    }];
}

```

# 四、实战
实现以上的协议后，那么如何使用呢？只需在`ViewController`中,简单的对`TCZDataSource`,`TCZTableViewDelegate`,`TCZBaseTabelView` 初始化就可以使用了。

**ViewController.m文件**

```
tableView = [[TCZBaseTabelView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain configure:^(TCZTableConfigure *configure) {
	//自义定configure
}];
    
dataSource = [[TCZDataSource alloc]init];
dataSource.isGroup = NO;
dataSource. dele.dataModels = dataArr;
dataSource.cellConfigureBlock = ^(id cell, NSIndexPath *indexPath) {
	//cell加载
 };
    
    
delegate = [[TCZTableViewDelegatealloc]initWithConfigure:^(TCZTableConfigure *configure) {
	//自义定configure
}];
delegate.dataModels = dataArr;

tableView.delegate = delegate;
tableView.dataSource = dataSource;  
[self.view addSubview:tableView];
[table reloadData];

```

# 五、遇到的问题
另外说一下这几天自己在使用`Masrony`中`mas_updateConstraints:`方法时，踩到的一个坑。

场景如下,在cell中，加载数据源时要调整一个子控件的宽度，子控件初始化代码：

```
 _imageShowView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.contentView.mas_left);
          make.top.equalTo(self.contentView.mas_top);
          make.bottom.equalTo(self.contentView.mas_bottom);
          make.width.mas_equalTo(self.contentView.mas_height);
      		}];
        imageView;
    });

```
子控件调整布局代码：

```
[_imageShowView mas_updateConstraints:^(MASConstraintMaker *make) {
     make.width.mas_equalTo(0);
}];
```
结果_imageShowView的宽度并没有改变。原因是在`mas_updateConstraints`方法里，同一个布局的是相对的约束对象也是一致才行，这样才算一次update。

源码如下:

```
- (MASLayoutConstraint *)layoutConstraintSimilarTo:(MASLayoutConstraint *)layoutConstraint {
    // check if any constraints are the same apart from the only mutable property constant

    // go through constraints in reverse as we do not want to match auto-resizing or interface builder constraints
    // and they are likely to be added first.
    for (NSLayoutConstraint *existingConstraint in self.installedView.constraints.reverseObjectEnumerator) {
        if (![existingConstraint isKindOfClass:MASLayoutConstraint.class]) continue;
        if (existingConstraint.firstItem != layoutConstraint.firstItem) continue;
        if (existingConstraint.secondItem != layoutConstraint.secondItem) continue;
        if (existingConstraint.firstAttribute != layoutConstraint.firstAttribute) continue;
        if (existingConstraint.secondAttribute != layoutConstraint.secondAttribute) continue;
        if (existingConstraint.relation != layoutConstraint.relation) continue;
        if (existingConstraint.multiplier != layoutConstraint.multiplier) continue;
        if (existingConstraint.priority != layoutConstraint.priority) continue;

        return (id)existingConstraint;
    }
    return nil;
}

```

于是把初始化中width的约束修改了一下：

```
[_imageShowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);       
            make.top.equalTo(self.contentView.mas_top); 
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.width.mas_equalTo(HEIGHTSCALE(125));
 }];
```

另外还有一个小坑，如果cell中添加了tableView，cell中的tableView不要设置tableHeaderView,否则滑动会有异常。


如果您想第一时间看到我们的文章，欢迎关注公众号。
![微信公众号](http://upload-images.jianshu.io/upload_images/1664496-f94c6e4f349a2f74.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
