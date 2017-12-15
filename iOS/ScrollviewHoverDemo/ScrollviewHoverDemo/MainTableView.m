//
//  MainTableView.m
//  ScrollviewHoverDemo
//
//  Created by wsy on 2017/12/15.
//  Copyright © 2017年 WSY. All rights reserved.
//

#import "MainTableView.h"
#import "AppDelegate.h"


@implementation MainTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.panGestureRecognizer.delegate = self;
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [AppDelegate app].offset.y > 0;
}



@end
