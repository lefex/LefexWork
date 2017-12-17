//
//  MainScrollView.h
//  ScrollviewHoverDemo
//
//  Created by wsy on 2017/12/15.
//  Copyright © 2017年 WSY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMeConsant.h"


@class MainScrollView;
@protocol MainScrollViewDelegate<NSObject>

- (void)scrollView:(MainScrollView *)scrollView didChangeLinkType:(ATMeLinkScrollType)linkType;

@end

@interface MainScrollView : UIScrollView<UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<MainScrollViewDelegate> mdelegate;

@end
