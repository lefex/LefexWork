//
//  ViewController.m
//  TimerDemo
//
//  Created by Wang,Suyan on 2018/2/24.
//  Copyright © 2018年 Wang,Suyan. All rights reserved.
//

#import "ViewController.h"
#import "TimerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    TimerViewController *timerVC = [[TimerViewController alloc] init];
    [self.navigationController pushViewController:timerVC animated:YES];
}

@end
