//
//  ViewController.m
//  Atomic
//
//  Created by wsy on 2017/11/25.
//  Copyright © 2017年 WSY. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, copy) NSString *name;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"1%@", [NSThread currentThread]);
        self.name = @"Thread1";
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"2%@", [NSThread currentThread]);
        self.name = @"Thread2";
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"3%@", [NSThread currentThread]);
        NSLog(@"name: %@", self.name);
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"4%@", [NSThread currentThread]);
        self.name = nil;
    });
}

@end
