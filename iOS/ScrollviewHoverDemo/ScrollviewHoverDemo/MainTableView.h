//
//  MainTableView.h
//  ScrollviewHoverDemo
//
//  Created by wsy on 2017/12/15.
//  Copyright © 2017年 WSY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMeConsant.h"

@interface MainTableView : UITableView<UIGestureRecognizerDelegate>

@property (nonatomic, assign) ATMeLinkScrollType linkType;

@end
