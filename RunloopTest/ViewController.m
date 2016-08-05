//
//  ViewController.m
//  RunloopTest
//
//  Created by lihongfeng on 16/8/5.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "ViewController.h"
#import "WLThread.h"

@interface ViewController ()
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSRunLoop *runloop;
@property (nonatomic, strong) WLThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"\n\n\n-----touch------");
//    [self gcd_timer];
    [self creatCustomRunloop];
}

// GCD 定时器
- (void)gcd_timer{
    __block int timeout = 10;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        if (timeout == 0) {
            NSLog(@"-------- 倒计时结束");
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"回主线程执行任务");
            });
        }else{
            NSLog(@"-------- %ds", timeout);
            timeout--;
        }
    });
    dispatch_resume(timer);
    self.timer = timer;
}

//常驻线程
- (void)creatCustomRunloop{
    WLThread *thread = [[WLThread alloc] initWithTarget:self selector:@selector(doTask) object:nil];
    [thread start];
    self.thread = thread;
}

- (void)doTask{
    NSLog(@"---doing task ...");
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [self runloop_observer];
    [[NSRunLoop currentRunLoop] run];
    self.runloop = [NSRunLoop currentRunLoop];
    
}

- (IBAction)click:(id)sender {
    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
}

- (void)test{
    NSLog(@"---do task again...");
}

//监听 runloop 状态
- (void)runloop_observer{
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry://即将进入 runloop
            {
                NSLog(@"-------kCFRunLoopEntry: 即将进入 runloop");
            }
                break;
            case kCFRunLoopBeforeTimers://即将处理 timer
            {
                NSLog(@"-------kCFRunLoopBeforeTimers: 即将处理 timer");
            }
                break;
            case kCFRunLoopBeforeSources://即将处理 sources
            {
                NSLog(@"-------kCFRunLoopBeforeSources: 即将处理 sources");
            }
                break;
            case kCFRunLoopBeforeWaiting://即将进入休眠
            {
                NSLog(@"-------kCFRunLoopBeforeWaiting: 即将进入休眠");
            }
                break;
            case kCFRunLoopAfterWaiting://runloop 被唤醒
            {
                NSLog(@"-------kCFRunLoopAfterWaiting: runloop 被唤醒");
            }
                break;
            case kCFRunLoopExit://即将退出 runloop
            {
                NSLog(@"-------kCFRunLoopExit: 即将退出 runloop");
            }
                break;
            default:
                break;
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    CFRelease(observer);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
