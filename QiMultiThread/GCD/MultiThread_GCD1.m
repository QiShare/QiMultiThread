//
//  MultiThread_GCD1.m
//  QiMultiThread
//
//  Created by wangdacheng on 2019/1/11.
//  Copyright © 2019 QiShare. All rights reserved.
//

#import "MultiThread_GCD1.h"

const static char *QiShareQueue = "QiShareQueue";

@interface MultiThread_GCD1 ()

@end

@implementation MultiThread_GCD1

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"GCD1"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self asyncConcurrent];
}

- (void)addTask:(NSInteger)tag {
    
    [NSThread sleepForTimeInterval:2];
    
    NSLog(@"addTask%ld--->> %@", (long)tag, [NSThread currentThread]);
    
    NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.so.com/"]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"任务完成%ld--->> %@", (long)tag, [NSThread currentThread]);
        
    }];
    [task resume];
}

// 异步执行
- (void)asyncConcurrent {
    
    NSLog(@"currentThread--->> %@",[NSThread currentThread]);
    NSLog(@"asyncConcurrent--->> begin");
    
    // + 并发队列(开启多个线程，并发执行任务)
    dispatch_queue_t queue = dispatch_queue_create(QiShareQueue, DISPATCH_QUEUE_CONCURRENT);
//    // + 串行队列(开启1个新线程，串行执行任务)
//    dispatch_queue_t queue = dispatch_queue_create(QiShareQueue, DISPATCH_QUEUE_SERIAL);
//    // + 主队列(没有开启新线程，串行执行任务)
//    dispatch_queue_t queue = dispatch_get_main_queue();
    
    for (NSInteger i=0; i<10; i++) {
        
        dispatch_async(queue, ^{
            // 追加任务
            [self addTask:i];
        });
    }
    
    NSLog(@"asyncConcurrent--->> end");
}

// 同步执行
- (void)syncConcurrent {
    
    NSLog(@"currentThread--->> %@", [NSThread currentThread]);
    NSLog(@"syncConcurrent--->> begin");
    
//    // + 并发队列(没有开启新线程，串行执行任务)
//    dispatch_queue_t queue = dispatch_queue_create(QiShareQueue, DISPATCH_QUEUE_CONCURRENT);
//    // + 串行队列(没有开启新线程，串行执行任务)
//    dispatch_queue_t queue = dispatch_queue_create(QiShareQueue, DISPATCH_QUEUE_SERIAL);
    // + 主队列(1.主线程调用：死锁；2.其他线程调用：不会开启新线程，执行完一个任务，再执行下一个任务)
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    for (NSInteger i=0; i<10; i++) {
        
        dispatch_sync(queue, ^{
            // 追加任务
            [self addTask:i];
        });
    }
    
    NSLog(@"syncConcurrent--->> end");
}


// 线程间通信
- (void)test {
    
    
}


@end


