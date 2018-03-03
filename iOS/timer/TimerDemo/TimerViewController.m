//
//  TimerViewController.m
//  TimerDemo
//
//  Created by Wang,Suyan on 2018/2/25.
//  Copyright © 2018年 Wang,Suyan. All rights reserved.
//

#import "TimerViewController.h"

void lefexTimerAction(CFRunLoopTimerRef timer, void *info){
    NSLog(@"timer called at thread: %@", [NSThread currentThread]);
}

@interface TimerViewController ()
{
    CFRunLoopTimerRef threadTiemr;
    CFRunLoopRef threadRunloop;
    /**
     每条线程都是应用执行的一个分支，它会占用额为的空间，也就是说每条线程都会耗费系统资源
     
     */
    NSThread *currentThread;
}
@end

@implementation TimerViewController

- (void)dealloc
{
    NSLog(@"TimerViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 可以释放当前页面
    // [self createTimer];
    
    // 不会释放当前页面
    [self performSelectorInBackground:@selector(createTimerInOtherThread) withObject:nil];
}

- (void)createTimer
{
    CFAllocatorRef allocator = kCFAllocatorDefault;
    CFAbsoluteTime fireDate = CFAbsoluteTimeGetCurrent();
    CFTimeInterval interval = 2.0;
    CFOptionFlags flag = 0;
    CFIndex index = 0;
    CFRunLoopTimerCallBack callback = lefexTimerAction;
    CFRunLoopTimerContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(allocator, fireDate, interval, flag, index, callback, &context);
    CFRunLoopAddTimer(CFRunLoopGetMain(), timer, kCFRunLoopCommonModes);
}

- (void)createTimerInOtherThread
{
    CFAllocatorRef allocator = kCFAllocatorDefault;
    CFAbsoluteTime fireDate = CFAbsoluteTimeGetCurrent();
    CFTimeInterval interval = 2.0;
    CFOptionFlags flag = 0;
    CFIndex index = 0;
    CFRunLoopTimerCallBack callback = lefexTimerAction;
    CFRunLoopTimerContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(allocator, fireDate, interval, flag, index, callback, &context);
    
    // 获取当前线程的 runlopp，并且开启 runloop 定时器才能正常执行
    threadRunloop = CFRunLoopGetCurrent();
    currentThread = [NSThread currentThread];
    threadTiemr = timer;
    
    // 把timer添加到runloop中，timer将会跑起来
    CFRunLoopAddTimer(threadRunloop, timer, kCFRunLoopCommonModes);
    
    CFRunLoopRun();
    // 在 run 之后的代码将不会执行
    NSLog(@"runloop stop");
}

- (void)invalidTimer:(CFRunLoopTimerRef)timer
{
    if (timer) {
        CFRunLoopTimerInvalidate(timer);
        CFRelease(timer);
        timer = 0;
        
        NSLog(@"释放了 timer");
    } else {
        NSLog(@"timer is nill");
    }

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (threadTiemr) {
        // 既是不去 invalid timer,只要 tiemr 所在的 runloop 停止执行，它将停止执行
        [self invalidTimer:threadTiemr];
    }
    
    if (threadRunloop) {
        NSLog(@"Before runloop stop thread: %@, isExecuting: %@", currentThread, @(currentThread.isExecuting));
        // 如果不暂停 runloop 当前页面不会释放
        CFRunLoopStop(threadRunloop);
        threadRunloop = NULL;
        // 需要暂停一会 currentThread 将停止执行
        NSLog(@"After runloop stop thread: %@, isExecuting: %@", currentThread, @(currentThread.isExecuting));
    }
    
    // 当 runloop 停止后，它所在的线程也将停止执行
}

@end
