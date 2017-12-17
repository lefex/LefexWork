---
layout: post
title: UICollectionView自定义布局
date: 2017-03-12 08:20:24.000000000 +08:00
---

**本文由 [iMetalk](https://lefex.github.io/) 团队的成员 田向阳 完成，主要帮助读者使用UICollectionView进行自定义布局**。  

## 前言 
上一期，由我们的污大神给大家讲解了如何简单的使用tableview，想必大家一定会很想亲自上手去练练吧，但是这一期我就不讲tableview了，不过看了标题就知道这一期我要讲什么了，没错,就是UICollectionView，不过可能让大家失望的是，我并不会教大家怎么简单的使用CollectionView，而是会给大家安利一些关于UICollectionView的一些常规的知识点，帮助大家在以后项目中如何轻松的实现某些效果和样式！

`俗话说的好：没有什么界面是一个 UITableView 解决不了的，如果不行，那就俩个！` 污大神这句话说的一点都不错，在这个tableview横行的年代，你说你不会用tableview，那么真的只有 呵呵 了~~。

不过UICollectionView相对于UITableView可以说是青出于蓝而胜于蓝（话也不能这么说，毕竟他俩都是继承于UIScrollView），它和UITableView很相似，但它要更加强大，并不是因为tableview不够用，而是因为在UICollectionView中Apple给我们打开了一扇通向无限可能的大门:UICollectionViewFlowLayout.下面我就慢慢给大家讲解这个大门，如何去打开。

## UICollectionView 基础： 
 这个部分不做细讲，可直接查看系统的API 查看相关的方法，大部分用法类似tableview 
 
 - UICollectionViewDataSource 数据源协议
 - UICollectionViewDelegate   委托协议 
 - UICollectionViewFlowLayout 视图布局对象(这个是流视图布局，继承于UICollectionViewLayout)基本上这个布局可以说是自动排版，也就是一行排满，就自动换行。如果我们要自定义样式的话，一般继承UICollectionViewFlowLayout就行了。
 * UICollectionViewDelegateFlowLayout 这个是FlowLAyout的代理协议  可以通过这些个协议来调整 cell大大小 和 layout的一些属性 （minimumInteritemSpacing，minimumLineSpacing,sectionInset等）
 
## UICollectionView 创建： 

```objectivec
// 初始化
self.collectionView = ({
    CollectionViewFlowLayout *layout = [[CollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame)/2.0) collectionViewLayout:layout];
    [self.view addSubview:collectionView];
    collectionView.backgroundColor = [UIColor whiteColor];//我为什么要设置为白色呢，以为没有数据的时候就是一片漆黑！！！
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
//注册Cell
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    collectionView;
    });

//必须实现的两个数据源协议方法 
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0  blue:arc4random()%255/255.0  alpha:1];
    return cell;

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

// 还有一部分相关的代理方法 就不一一列举了  如  和UITableView一样 UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{}

//控制单元格的大小 就用到了  UICollectionViewDelegateFlowLayout
#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100.f,100.f);
}

//collectionView 上下左右的偏移  类似 scroll的 contentInset
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
//区头  区尾 的大小 高度 
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(100.f,100.f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return (CGSize){ScreenWidth,22};
}

```
代码中的 CollectionViewFlowLayout  就是我自己定义的layout继承于UICollectionViewFlowLayout
 
## UICollectionView自定义布局： 
关于布局，而且用UICollectionView去布局，最常见的莫过于九宫格了吧，相信绝大多数的app里面多多少少都会用到这样的布局，在没有collectionView的年代，布局九宫格大家是不是跟我一样要用个for循环，然后计算出相应的坐标去排布呢？另外还有在两年前比较流行的 瀑布流布局刚开始怎么实现呢，用scrollView?亦或tableview 但是这两个都太麻烦，不过有了collectionView实现这样的效果就省事多了。
    
要自定义UICollectionView布局，就要创建自己的layout继承于UICollectionViewFlowLayout，然后重写父类的几个方法就可以达到我们自定义布局的需求。下来我们来看看UICollectionViewFlowLayout类里一些比较重要的方法

-  \- (void)prepareLayout;     
为layout显示做准备工作，你可以在该方法里设置一些属性。另外说一下里面可能会遇到的坑，那就是计算单元格大小的时候，比如你要做一个九宫格，那么你计算的每一个宫格的大小 就应该把 宫格的间距 和左右的边距都给算进去 然后再根据具体需求去计算大小 否则计算出来的大小会有问题 一句话 细心为妙！！
- \- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect     
这个方法返回的是在collectionView的可见范围所有item对应的UICollectionViewLayoutAttributes对象的数组。collectionView的每个item都对应一个专门的UICollectionViewLayoutAttributes类型的对象来表示该item的一些属性，他不是一个视图，但包含了视图所有的属性，比如，frame  transform 等 

- \- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{return YES;}     
当前layout的布局发生变动时，是否重写加载该layout。默认返回的是NO，若返回YES，则重新执行上面的两个方法。讲一下最初遇到的坑，第一次自己写layout的时候，由于没有写这个方法，（没写的话是默认为NO，不刷新layout，然后自己在 layoutAttributesForElementsInRect 方法里更改了相应的Attributes属性 但是得到的效果和自己想要的效果差距太大，太大。后来还是在度娘的帮助下把这个问题给解决，重写了方法并设返回值为 YES！    
    
- \- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity   
这个方法 是返回最终collectionView的偏移量，也就是collectionView停止滚动时候的偏移量，通过这个方法可以控制你最终想要让collectionView停止的位置

## 项目实战 
最终的效果图
![collectionViewLayout.gif](http://upload-images.jianshu.io/upload_images/1664496-0e7a18fa7d13021b.gif?imageMogr2/auto-orient/strip)

前面已经讲过了关于自定义layout的几个重要的方法，那么下面就开始进入实战吧，下面我就先写一个我们项目中的一个小的例子，至于其他的效果，就要看你们自己的脑洞有多大了，废多看码~

```
    - (void)prepareLayout
    {
    [super prepareLayout];
    //设置滚动方向为横向滚动
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //设置单元格的大小
    self.itemSize = CGSizeMake(itemWidth, itemWidth);
    //设置item间距
    self.minimumInteritemSpacing = 5;
    self.minimumLineSpacing = 5;
    //设置左右间距 在collectionView初始位置 和 最后位置保证在也停留在正中间
    self.sectionInset = UIEdgeInsetsMake(0, (self.collectionView.frame.size.width - itemWidth)*SCALE, 0, (self.collectionView.frame.size.width - itemWidth)*SCALE);
    }

    //开启实时刷新布局
    - (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
    {
        return YES;
    }

    // 调整当前layout的样式
    - (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    //拿到当前视图内的layout组成的数组
    NSArray *temp  =  [super  layoutAttributesForElementsInRect:rect];
    NSMutableArray *attAtrray = [NSMutableArray array];
    //计算出相对于collectionView中心点 collectionView的实际偏移量
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width*0.5;
    for (int i = 0; i < temp.count; i ++) {
    UICollectionViewLayoutAttributes *att = [temp[i] copy]; //做copy操作 消除一下警告
    //计算据两边的cell 距离中间的偏移 取绝对值
    CGFloat offset = ABS(att.center.x - centerX);
    // 计算出scale 并调整 layout的transform属性
    CGFloat scale = 1 - offset / self.collectionView.frame.size.width*0.5;
    att.transform = CGAffineTransformMakeScale(scale, scale);

    [attAtrray addObject:att];
    }

    return  attAtrray;
    }


    - (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
    {
    CGRect  rect;
    rect.origin = proposedContentOffset;
    rect.size = self.collectionView.frame.size;
    NSArray *tempArray  = [super  layoutAttributesForElementsInRect:rect];
    CGFloat  gap = 1000;
    CGFloat  a = 0;

    for (int i = 0; i < tempArray.count; i++) {
    //判断和中心的距离，得到最小的那个
    UICollectionViewLayoutAttributes *att = tempArray[i];
    gap = ABS(att.center.x - proposedContentOffset.x - self.collectionView.frame.size.width * SCALE);
    if (gap < self.collectionView.frame.size.width *SCALE *SCALE) {
    //同样是计算出左右间距的偏移
    a = att.center.x - proposedContentOffset.x - self.collectionView.frame.size.width * SCALE;
    break;
    }
    }
    //调整x的偏移
    CGPoint  point = CGPointMake(proposedContentOffset.x + a , proposedContentOffset.y);
    return point;
    }

```
大家在实践过程中，可以去尝试着把 shouldInvalidateLayoutForBoundsChange 这个方法给注释了，可以看一下注释后的效果。另外，关于我在注视的地方提到的警告 可能重写layout的同学都会遇到 下面我把错误代码粘上来 。

```objectivec

2017-03-09 12:44:11.483 CollectionViewLayout[11131:92643] Logging only once for UICollectionViewFlowLayout cache mismatched frame
2017-03-09 12:44:11.484 CollectionViewLayout[11131:92643] UICollectionViewFlowLayout has cached frame mismatch for index path <NSIndexPath: 0xc000000000000016> {length = 2, path = 0 - 0} - cached value: {{104.02791666666667, 10.02791666666667}, {167.44416666666666, 167.44416666666666}}; expected value: {{104, 10}, {167.5, 167.5}}
2017-03-09 12:44:11.484 CollectionViewLayout[11131:92643] This is likely occurring because the flow layout subclass CollectionViewFlowLayout is modifying attributes returned by UICollectionViewFlowLayout without copying them

```
消除警告的方法就是 在对 UICollectionViewLayoutAttributes 对象更改属性的时候要做一下copy操作,除此之外 要用另一个数组重新组装一下 然后return 。另外关于 copy 和 mutableCopy 有兴趣的可以去研究研究，我就不在此多说了。

## 总结
在自定义collectionViewLayout的时候，难免会踩到坑，但是坑归坑，关键我们要心细，胆大，多去尝试，这样才能解决问题。关于collectionView自定义layout的简单介绍，大概就这么多了，可能也有一部分没有讲解出来，但是万变不离其宗，只要你理解了里面的原理和你自己想要的效果，剩下的事情就是代码的事情了~

[demo 地址](：https://github.com/a254711559/CollectionViewLayout)

如果您想第一时间看到我们的文章，欢迎关注公众号。
![微信公众号](http://upload-images.jianshu.io/upload_images/1664496-f94c6e4f349a2f74.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

