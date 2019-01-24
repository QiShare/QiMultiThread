//
//  MultiThread_ThreadSafe.m
//  QiMultiThread
//
//  Created by wangdacheng on 2019/1/22.
//  Copyright © 2019 QiShare. All rights reserved.
//

#import "MultiThread_ThreadSafe.h"

#define CONDITION_NO_DATA   100
#define CONDITION_HAS_DATA  101

@interface MultiThread_ThreadSafe ()

//! 票数
@property (nonatomic, assign) NSInteger ticketCount;
@property (nonatomic, strong) NSMutableArray *ticketsArr;
//! NSLock
@property (nonatomic, strong) NSLock *lock;
//! 信号量semaphore
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
//! 条件锁
@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) NSConditionLock *conditionLock;
//! 递归锁
@property (nonatomic, strong) NSRecursiveLock *recursiveLock;

@end

@implementation MultiThread_ThreadSafe

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"ThreadSafe"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // 实例化各种锁
    _lock = [[NSLock alloc] init];
    _semaphore = dispatch_semaphore_create(1);
    _condition = [[NSCondition alloc] init];
    _ticketsArr = [NSMutableArray array];
    _conditionLock = [[NSConditionLock alloc] initWithCondition:CONDITION_NO_DATA];
    _recursiveLock = [[NSRecursiveLock alloc] init];
    
    _ticketCount = 30;
    [self multiThread];
}

- (void)multiThread {
    
    dispatch_queue_t queue = dispatch_queue_create("QiMultiThreadSafeQueue", DISPATCH_QUEUE_CONCURRENT);
    
    for (NSInteger i=0; i<10; i++) {
        dispatch_async(queue, ^{
            [self testNSConditionLockAdd];
        });
    }

    for (NSInteger i=0; i<10; i++) {
        dispatch_async(queue, ^{
            [self testNSConditionLockRemove];
        });
    }
}


#pragma mark - NSLock

- (void)testNSLock {
    
    while (1) {
        [_lock lock];
        if (_ticketCount > 0) {
            _ticketCount --;
            NSLog(@"--->> %@已购票1张，剩余%ld张", [NSThread currentThread], (long)_ticketCount);
        }
        else {
            [_lock unlock];
            return;
        }
        [_lock unlock];
        sleep(0.2);
    }
}


#pragma mark - dispatch_semaphore

- (void)testDispatchSemaphore:(NSInteger)num {
    
    while (1) {
        // 参数1为信号量；参数2为超时时间；ret为返回值
        //dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        long ret = dispatch_semaphore_wait(_semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.21*NSEC_PER_SEC)));
        if (ret == 0) {
            if (_ticketCount > 0) {
                NSLog(@"%d 窗口 卖了第%d张票", (int)num, (int)_ticketCount);
                _ticketCount --;
            }
            else {
                dispatch_semaphore_signal(_semaphore);
                NSLog(@"%d 卖光了", (int)num);
                break;
            }
            [NSThread sleepForTimeInterval:0.2];
            dispatch_semaphore_signal(_semaphore);
        }
        else {
            NSLog(@"%d %@", (int)num, @"超时了");
        }
        
        [NSThread sleepForTimeInterval:0.2];
    }
}


#pragma mark - NSCondition

- (void)testNSConditionAdd {
    
    [_condition lock];
    
    // 生产数据
    NSObject *object = [NSObject new];
    [_ticketsArr addObject:object];
    NSLog(@"--->>%@ add", [NSThread currentThread]);
    [_condition signal];
    
    [_condition unlock];
}

- (void)testNSConditionRemove {
    
    [_condition lock];
    
    // 消费数据
    if (!_ticketsArr.count) {
        NSLog(@"--->> wait");
        [_condition wait];
    }
    [_ticketsArr removeObjectAtIndex:0];
    NSLog(@"--->>%@ remove", [NSThread currentThread]);
    
    [_condition unlock];
}


#pragma mark - NSConditionLock

- (void)testNSConditionLockAdd {
    
    // 满足CONDITION_NO_DATA时，加锁
    [_conditionLock lockWhenCondition:CONDITION_NO_DATA];
    
    // 生产数据
    NSObject *object = [NSObject new];
    [_ticketsArr addObject:object];
    NSLog(@"--->>%@ add", [NSThread currentThread]);
    [_condition signal];
    
    // 有数据，解锁并设置条件
    [_conditionLock unlockWithCondition:CONDITION_HAS_DATA];
}

- (void)testNSConditionLockRemove {
    
    // 有数据时，加锁
    [_conditionLock lockWhenCondition:CONDITION_HAS_DATA];
    
    // 消费数据
    if (!_ticketsArr.count) {
        NSLog(@"--->>wait");
        [_condition wait];
    }
    [_ticketsArr removeObjectAtIndex:0];
    NSLog(@"--->>%@ remove", [NSThread currentThread]);
    
    //3. 没有数据，解锁并设置条件
    [_conditionLock unlockWithCondition:CONDITION_NO_DATA];
}


#pragma mark - NSRecursiveLock

- (void)testNSRecursiveLock:(NSInteger)tag {
    
    [_recursiveLock lock];
    
    if (tag > 0) {
        
        [self testNSRecursiveLock:tag - 1];
        NSLog(@"--->> %ld", (long)tag);
    }
    
    [_recursiveLock unlock];
}


#pragma mark - @synchronized

- (void)testSynchronized {
    
    @synchronized (self) {
        
        if (_ticketCount > 0) {
            
            _ticketCount --;
            NSLog(@"--->> %@已购票1张，剩余%ld张", [NSThread currentThread], (long)_ticketCount);
        }
    }
}


@end
