//
//  ViewController.m
//  VolumnViewDemo
//
//  Created by Wang,Suyan on 2017/12/5.
//  Copyright © 2017年 Wang,Suyan. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


@interface ViewController ()

@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) NSInteger addCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _addCount = 0;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    _volumeView.backgroundColor = [UIColor yellowColor];
    // 如果设置了 Hidden 为 YES，那么修改音量时会弹出系统音量框
    _volumeView.hidden = NO;
    _volumeView.alpha = 0.01;
    for (UIView *view in [_volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.volumeSlider = (UISlider*)view;
            // 获取系统初始化音量
            [[AVAudioSession sharedInstance] outputVolume];
            break;
        }
    }
    
    [self.view addSubview:_volumeView];
    
    NSLog(@"😊Slider volum: %@", @(self.volumeSlider.value));
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [self.volumeSlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    [self createAudioPlayer];
}

- (void)createAudioPlayer {
    NSURL *audioUrl = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mp3"];
    NSError *error;

    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&error];
    if (error) {
        NSLog(@"Audio player init error: %@", error);
    }
    [_audioPlayer setVolume:1.0];
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}


- (void)volumeChanged:(NSNotification *)notification
{
    NSLog(@"Volume change: %@", notification);
   CGFloat volume = [notification.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    NSLog(@"😊Volume change: %@", @(volume));
}

- (void)sliderValueDidChange:(NSNotification *)notification {
    NSLog(@"Slider volume change: %@", notification);
    NSLog(@"😊Slider change volum: %@", @(self.volumeSlider.value));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (![_audioPlayer isPlaying]) {
        [_audioPlayer play];
    }
    // 只要设置了这个值，就会显示系统提示框
    _addCount++;
    if (_addCount > 10) {
        _addCount = 1;
    }
    [_audioPlayer setVolume:_addCount * 0.1];
    
    NSLog(@"㊗️ System volumn: %@", @([[AVAudioSession sharedInstance] outputVolume]));
    NSLog(@"㊗️ Player volumn: %@", @(_audioPlayer.volume));
    
    [self.volumeSlider setValue:0.5];

}

@end
