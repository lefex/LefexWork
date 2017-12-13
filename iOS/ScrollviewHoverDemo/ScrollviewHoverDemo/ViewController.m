//
//  ViewController.m
//  ScrollviewHoverDemo
//
//  Created by wsy on 2017/12/12.
//  Copyright © 2017年 WSY. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>

#define DZHWidth ([UIScreen mainScreen].bounds.size.width)
#define DZHHeight ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)createUI
{
    // http://www.jianshu.com/p/6519c07b9109
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat itemHeight = 200;
    
    _scrollView = ({
        UIScrollView *view = [[UIScrollView alloc] initWithFrame:self.view.frame];
        view.contentSize = CGSizeMake(width, 2*width);
        [self.view addSubview:view];
        view;
    });
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:(CGRectMake(0, 0, DZHWidth, DZHHeight))];
    [self.view addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(0, 2*DZHHeight);
    
    UIView *view1 = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, DZHWidth, 100))];
    view1.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:view1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:(CGRectMake(0, 102, DZHWidth, 100))];
    view2.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:view2];
    
    UIView *view3 = [[UIView alloc] initWithFrame:(CGRectMake(0, 204, DZHWidth, 100))];
    view3.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:view3];
    
    UIView *view4 = [[UIView alloc] initWithFrame:(CGRectMake(0, 306, DZHWidth, 100))];
    view4.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:view4];
    
    UIView *view5 = [[UIView alloc] initWithFrame:(CGRectMake(0, 408, DZHWidth, 100))];
    view5.backgroundColor = [UIColor purpleColor];
    [scrollView addSubview:view5];
    [view5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.view.mas_top).priority(1000);
        make.top.equalTo(view4.mas_bottom).offset(2).priority(500);
        make.size.mas_equalTo(CGSizeMake(DZHWidth, 100));
        make.left.equalTo(self.view);
    }];
    
    UIView *view6 = [[UIView alloc] initWithFrame:(CGRectMake(0, 510, DZHWidth, 100))];
    view6.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:view6];
    
    UIView *view7 = [[UIView alloc] initWithFrame:(CGRectMake(0, 612, DZHWidth, 100))];
    view7.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:view7];
    
    UIView *view8 = [[UIView alloc] initWithFrame:(CGRectMake(0, 714, DZHWidth, 100))];
    view8.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:view8];
    
    [scrollView bringSubviewToFront:view5];
}

- (UIView *)viewWithBackGroundColor:(UIColor *)color
{
    UIView *view = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = color;
        view;
    });
    return view;
}

@end
