//
//  MainScrollView.m
//  ScrollviewHoverDemo
//
//  Created by wsy on 2017/12/15.
//  Copyright © 2017年 WSY. All rights reserved.
//

#import "MainScrollView.h"
#import "AppDelegate.h"

static void * kOffsetContext = @"offsetContext";

@implementation MainScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.panGestureRecognizer.delegate = self;
        self.bounces = NO;
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:kOffsetContext];
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == kOffsetContext) {
        [AppDelegate app].offset = self.contentOffset;
        NSLog(@"Offset: %@", NSStringFromCGPoint(self.contentOffset));
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([AppDelegate app].offset.y >= 0) {
        return YES;
    } else {
        return NO;
    }
}

@end
