//
//  ViewController.m
//  TestColor
//
//  Created by WangSuyan on 2017/9/20.
//  Copyright © 2017年 WangSuyan. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+main.h"

static NSString* const k50E3C2Color = @"50E3C2";
static NSString* const k10AEFFColor = @"10AEFF";

@interface ViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(40, 100, 100, 50)];
    _label.text = k50E3C2Color;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor mtColorNamed:k10AEFFColor];
    _label.backgroundColor = [UIColor mtColorNamed:k50E3C2Color];
    [self.view addSubview:_label];
}

@end
