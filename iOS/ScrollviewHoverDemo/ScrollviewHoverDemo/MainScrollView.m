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
static void * kPanGestureStateContext = @"gestureContext";

@interface MainScrollView()

@property (nonatomic, assign) ATMeLinkScrollType lastType;
@property (nonatomic, assign) BOOL isScrolling;

@end

@implementation MainScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.panGestureRecognizer.delegate = self;
        self.bounces = NO;
        self.lastType = ATMeLinkScrollTypeDown;
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:kOffsetContext];
        [self addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionNew context:kPanGestureStateContext];
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self) {
        if (context == kOffsetContext) {
            [AppDelegate app].offset = self.contentOffset;
//                    NSLog(@"Offset: %@", NSStringFromCGPoint(self.contentOffset));
        } else if (context == kPanGestureStateContext) {
           UIGestureRecognizerState state = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (state) {
                case UIGestureRecognizerStateEnded:
                {
                    if (self.isScrolling) {
                        break;
                    }
                    self.isScrolling = YES;
                    if (self.lastType == ATMeLinkScrollTypeTop) {
                        if (self.contentOffset.y < kATMeHeaderHeight - kATMeLimitTopHeight) {
                            [self setContentOffset:CGPointZero animated:YES];
                            self.lastType = ATMeLinkScrollTypeDown;
                        } else {
                            [self setContentOffset:CGPointMake(0, kATMeHeaderHeight) animated:YES];
                            self.lastType = ATMeLinkScrollTypeTop;
                        }
                    } else {
                        if (self.contentOffset.y < kATMeLimitBottomHeight) {
                            [self setContentOffset:CGPointZero animated:YES];
                            self.lastType = ATMeLinkScrollTypeDown;
                        } else {
                            [self setContentOffset:CGPointMake(0, kATMeHeaderHeight) animated:YES];
                            self.lastType = ATMeLinkScrollTypeTop;
                        }
                    }
                    [self callChangeLinkType:self.lastType];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.isScrolling = NO;
                    });
                    break;
                }
                case UIGestureRecognizerStateFailed:
                case UIGestureRecognizerStateCancelled:
                {
//                    [self setContentOffset:[self offsetAtScrollType] animated:YES];
                    break;
                }
                    
                default:
                    break;
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
    if ([AppDelegate app].offset.y >= 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSLog(@"🐂%@ \n 👩%@", gestureRecognizer, otherGestureRecognizer);
    return NO;
}

#pragma mark - Helper
- (CGPoint)offsetAtScrollType
{
    switch (self.lastType) {
        case ATMeLinkScrollTypeTop:
            return CGPointZero;
            break;
        case ATMeLinkScrollTypeDown:
            return CGPointZero;
            break;
        case ATMeLinkScrollTypeMid:
            return self.contentOffset;
            break;
        default:
            break;
    }
    return CGPointZero;
}

- (void)callChangeLinkType:(ATMeLinkScrollType)type
{
    if (self.mdelegate && [self.mdelegate respondsToSelector:@selector(scrollView:didChangeLinkType:)]) {
        [self.mdelegate scrollView:self didChangeLinkType:type];
    }
}


@end
