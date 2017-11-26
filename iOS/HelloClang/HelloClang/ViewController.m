//
//  ViewController.m
//  HelloClang
//
//  Created by wsy on 2017/11/25.
//  Copyright © 2017年 WSY. All rights reserved.
//

#import "ViewController.h"

#define DEFINEEight 8

@interface ViewController ()

@property (nonatomic, copy) NSString *name __attribute__ ((deprecated));

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    int first = 10;
    for (int i = 0; i < 2; i++) {
        first += i;
    }
    NSLog(@"%@", @(first));
    
}

@end
