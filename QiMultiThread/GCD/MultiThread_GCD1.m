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
    
    [self deadLock];
}

- (void)addTask:(NSInteger)tag {
    
    [NSThread sleepForTimeInterval:2];
    
    NSLog(@"addTask%ld--->> %@", (long)tag, [NSThread currentThread]);
    
    NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.so.com/"]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"任务完成%ld--->> %@", (long)tag, [NSThread currentThread]);
        
    }];
    [task resume];
}


#pragma mark - 串行/并发队列 + 同步/异步调用组合

// 异步执行
- (void)asyncExecute {
    
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
- (void)syncExecute {
    
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


#pragma mark - dispatch_group

-(void)dispatchGroupNotify {
    
    NSLog(@"currentThread: %@", [NSThread currentThread]);
    NSLog(@"---start---");
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("QiShareQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"groupTask_1");
        NSLog(@"currentThread: %@", [NSThread currentThread]);
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:7];
        NSLog(@"groupTask_2");
        NSLog(@"currentThread: %@", [NSThread currentThread]);
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:4];
        NSLog(@"groupTask_3");
        NSLog(@"currentThread: %@", [NSThread currentThread]);
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"dispatch_group_Notify block end");
    });
    
    NSLog(@"---end---");
}

-(void)dispatchGroupWait {
    
    NSLog(@"currentThread: %@", [NSThread currentThread]);
    NSLog(@"---start---");
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("QiShareQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"groupTask_1");
        NSLog(@"currentThread: %@", [NSThread currentThread]);
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:7];
        NSLog(@"groupTask_2");
        NSLog(@"currentThread: %@", [NSThread currentThread]);
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:4];
        NSLog(@"groupTask_3");
        NSLog(@"currentThread: %@", [NSThread currentThread]);
    });
    
    //在此设置了一个10秒的等待时间，如果group的执行结束没有到12秒那么就返回0
    //如果执行group的执行时间超过了10秒，那么返回非0 数值，
    //在使用dispatch_group_wait函数的时候，会阻塞当前线程，阻塞的时间 在wait函数时间值和当前group执行时间值取最小的。
    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    NSLog(@"dispatch_group_wait result = %ld", result);
    
    NSLog(@"---end---");
}

-(void)dispatchGroupEnter {
    
    NSLog(@"currentThread: %@", [NSThread currentThread]);
    NSLog(@"---start---");
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("QiShareQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:7];
        NSLog(@"asyncTask_1");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:4];
        NSLog(@"asyncTask_2");
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"dispatch_group_notify block end");
    });
    NSLog(@"---end---");
}

- (void)dispatchBlockWait {
    
    dispatch_queue_t queue = dispatch_queue_create("QiShareQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"---before---");
        [NSThread sleepForTimeInterval:7];
        NSLog(@"---after---");
    });
    dispatch_async(queue, block);
    
    dispatch_async(queue, ^{
        long result = dispatch_block_wait(block, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
        NSLog(@"dispatch_block_wait result = %ld", result);
    });
}

- (void)diapatchBarrier {
    NSLog(@"currentThread: %@", [NSThread currentThread]);
    NSLog(@"---start---");
    
    dispatch_queue_t queue = dispatch_queue_create("QiShareQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:7];
        NSLog(@"asyncTask_1");
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:5];
        NSLog(@"asyncTask_2");
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"barrier_asyncTask");
        [NSThread sleepForTimeInterval:3];
        
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"asyncTask_4");
    });
    
    NSLog(@"---end---");
}

- (void)dispatchBlockNotify {
    
    //dispatch_queue_t queue = dispatch_queue_create("QiShareQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue = dispatch_queue_create("QiShareQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_block_t preBlock = dispatch_block_create(0, ^{
        NSLog(@"preBlock start");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"preBlock end");
    });
    dispatch_async(queue, preBlock);
    dispatch_block_t afterBlock = dispatch_block_create(0, ^{
        NSLog(@"has been notifyed");
    });
    
    dispatch_block_notify(preBlock, queue, afterBlock);
}

-(void)dispatchBlockCancel
{
    dispatch_queue_t queue = dispatch_queue_create("QiShareQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_block_t block = dispatch_block_create(0, ^{
        
    });
    dispatch_async(queue, block);
    dispatch_block_cancel(block);
}

- (void) dispatchSet2 {
    
    NSLog(@"currentThread: %@", [NSThread currentThread]);
    NSLog(@"---start---");
    
    dispatch_queue_t targetQueue = dispatch_queue_create("QiShareQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue1 = dispatch_queue_create("QiShareQueue_1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("QiShareQueue_2", DISPATCH_QUEUE_CONCURRENT);
    
    
    dispatch_set_target_queue(queue1, targetQueue);
    dispatch_set_target_queue(queue2, targetQueue);
    
    dispatch_async(queue1, ^{
        [NSThread sleepForTimeInterval:5];
        NSLog(@"Task_1");
        
    });
    dispatch_async(queue2, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"Task_2");
        
    });
    dispatch_async(queue2, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"Task_3");
        
    });
    
    NSLog(@"---end---");
}


- (void)deadLock {
    
    dispatch_queue_t queue = dispatch_queue_create("QiShareQueue", DISPATCH_QUEUE_SERIAL);
    
    NSLog(@"1");
    dispatch_async(queue, ^{
        NSLog(@"2");
        
        dispatch_sync(queue, ^{
            NSLog(@"3");
        });
    });
    NSLog(@"4");
}



@end

