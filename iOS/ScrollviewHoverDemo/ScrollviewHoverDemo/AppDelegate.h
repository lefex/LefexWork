//
//  AppDelegate.h
//  ScrollviewHoverDemo
//
//  Created by wsy on 2017/12/12.
//  Copyright © 2017年 WSY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMeConsant.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) CGPoint offset;


+ (AppDelegate *)app;

@end

