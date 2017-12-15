//
//  ViewController.m
//  ScrollviewHoverDemo
//
//  Created by wsy on 2017/12/12.
//  Copyright © 2017年 WSY. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "MainScrollView.h"
#import "MainTableView.h"

#define DZHWidth ([UIScreen mainScreen].bounds.size.width)
#define DZHHeight ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MainScrollView *scrollView;
@property (nonatomic, strong) MainTableView *tableView;

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
        MainScrollView *view = [[MainScrollView alloc] initWithFrame:self.view.frame];
        view.contentSize = CGSizeMake(width, 2*DZHHeight);
        [self.view addSubview:view];
        view;
    });
    
    UIView *view4 = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, DZHWidth, itemHeight))];
    view4.backgroundColor = [UIColor grayColor];
    [_scrollView addSubview:view4];
    
    UIView *view5 = [[UIView alloc] initWithFrame:(CGRectMake(0, itemHeight, DZHWidth, 100))];
    view5.backgroundColor = [UIColor purpleColor];
    [_scrollView addSubview:view5];
    [view5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.view.mas_top).priority(1000);
        make.top.equalTo(view4.mas_bottom).offset(2).priority(500);
        make.size.mas_equalTo(CGSizeMake(DZHWidth, 100));
        make.left.equalTo(self.view);
    }];
    
    _tableView = ({
        MainTableView *view = [[MainTableView alloc] initWithFrame:CGRectMake(0, itemHeight + 100, DZHWidth, 600) style:UITableViewStylePlain];
        view.delegate = self;
        view.dataSource = self;
        [view registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ID"];
        [_scrollView addSubview:view];
        view;
    });
    
    [_scrollView bringSubviewToFront:view5];
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

#pragma mark - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID" forIndexPath:indexPath];
    cell.textLabel.text = @"Hello Lefe_x";
    return cell;
}

@end
