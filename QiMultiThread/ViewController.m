//
//  ViewController.m
//  QiMultiThread
//
//  Created by wangdacheng on 2018/12/10.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "ViewController.h"
#import "MultiThread_GCD.h"
#import "MultiThread_GCD1.h"
#import "MultiThread_NSThread.h"
#import "MultiThread_NSThread1.h"
#import "MultiThread_NSOperation.h"
#import "MultiThread_NSOperation1.h"
#import "MultiThread_ThreadSafe.h"

typedef NS_ENUM(NSInteger, MultiThreadType) {
    MultiThreadType_NSThread = 100,
    MultiThreadType_NSOperation,
    MultiThreadType_GCD,
    MultiThreadType_ThreadSafe,
};

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"多线程"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGFloat margin = 15;
    CGFloat offset = 100;
    CGFloat btnHeight = 45;
    CGSize size = self.view.frame.size;
    NSArray *titles = [NSArray arrayWithObjects:@"NSThread", @"NSOperation", @"GCD", @"ThreadSafe", nil];
    for (int i=0; i<titles.count; i++) {
        
        NSString *title = [titles objectAtIndex:i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(margin, offset, size.width - margin * 2, btnHeight);
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button.tag = i + 100;
        
        offset += btnHeight + margin;
    }
}

#pragma mark - Actions
- (void)buttonClicked:(UIButton *)button {
    
    MultiThreadType type = (MultiThreadType)button.tag;
    switch (type) {
        case MultiThreadType_NSThread: {
            MultiThread_NSThread1 *thread = [[MultiThread_NSThread1 alloc] init];
            [self.navigationController pushViewController:thread animated:YES];
            break;
        }
        case MultiThreadType_NSOperation: {
            MultiThread_NSOperation *operation = [[MultiThread_NSOperation alloc] init];
            [self.navigationController pushViewController:operation animated:YES];
            break;
        }
        case MultiThreadType_GCD: {
            MultiThread_GCD1 *gcd = [[MultiThread_GCD1 alloc] init];
            [self.navigationController pushViewController:gcd animated:YES];
            break;
        }
        case MultiThreadType_ThreadSafe: {
            MultiThread_ThreadSafe *threadSafe = [[MultiThread_ThreadSafe alloc] init];
            [self.navigationController pushViewController:threadSafe animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
