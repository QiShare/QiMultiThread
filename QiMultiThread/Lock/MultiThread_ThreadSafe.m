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


@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) NSConditionLock *conditionLock;

@property (nonatomic, strong) NSRecursiveLock *recursiveLock;

@end

@implementation MultiThread_ThreadSafe

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"ThreadSafe"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _lock = [[NSLock alloc] init];
    _semaphore = dispatch_semaphore_create(1);
    _condition = [[NSCondition alloc] init];
    _ticketsArr = [NSMutableArray array];
    _conditionLock = [[NSConditionLock alloc] initWithCondition:CONDITION_NO_DATA];
    
    _ticketCount = 30;
    [self multiThread];
}

- (void)multiThread {
    
    dispatch_queue_t queue = dispatch_queue_create("QiMultiThreadSafeQueue", DISPATCH_QUEUE_CONCURRENT);
    
//    for (NSInteger i=0; i<10; i++) {
        dispatch_async(queue, ^{
            [self testNSRecursiveLock:10];
        });
//    }
    
//    for (NSInteger i=0; i<10; i++) {
//        dispatch_async(queue, ^{
//            [self testNSConditionLockRemove];
//        });
//    }
}




- (void)testNSLock {
    
    [_lock lock];
    
    if (_ticketCount > 0) {
        
        [NSThread sleepForTimeInterval:0.2];
        
        _ticketCount --;
        NSLog(@"--->> %@卖了一张票，还剩%ld张", [NSThread currentThread], (long)_ticketCount);
    }
    
    [_lock unlock];
}

- (void)testDispatchSemaphore {
    
    // 注意：_semaphore：信号量；DISPATCH_TIME_FOREVER超时时间；返回值
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    if (_ticketCount > 0) {
        
        [NSThread sleepForTimeInterval:0.2];
        
        _ticketCount --;
        NSLog(@"--->> %@卖了一张票，还剩%ld张", [NSThread currentThread], (long)_ticketCount);
    }
    
    dispatch_semaphore_signal(_semaphore);
}

- (void)testNSConditionAdd {
    
    [_condition lock];
    
    NSObject *object = [NSObject new];
    [_ticketsArr addObject:object];
    NSLog(@"---->>%@ add", [NSThread currentThread]);
    [_condition signal];
    
    [_condition unlock];
}

- (void)testNSConditionRemove {
    
    [_condition lock];
    
    if (!_ticketsArr.count) {
        NSLog(@"---->> wait");
        [_condition wait];
    }
    [_ticketsArr removeObjectAtIndex:0];
    NSLog(@"---->>%@ remove", [NSThread currentThread]);
    
    [_condition unlock];
}


- (void)testNSConditionLockAdd {
    
    // 满足CONDITION_NO_DATA时，加锁
    [_conditionLock lockWhenCondition:CONDITION_NO_DATA];
    
    // 生产数据
    NSObject *object = [NSObject new];
    [_ticketsArr addObject:object];
    NSLog(@"---->>%@ add", [NSThread currentThread]);
    [_condition signal];
    
    // 有数据，解锁并设置条件
    [_conditionLock unlockWithCondition:CONDITION_HAS_DATA];
}

- (void)testNSConditionLockRemove {
    
    // 有数据时，加锁
    [_conditionLock lockWhenCondition:CONDITION_HAS_DATA];
    
    // 消费数据
    if (!_ticketsArr.count) {
        NSLog(@"---->> wait");
        [_condition wait];
    }
    [_ticketsArr removeObjectAtIndex:0];
    NSLog(@"---->>%@ remove", [NSThread currentThread]);
    
    //3. 没有数据，解锁并设置条件
    [_conditionLock unlockWithCondition:CONDITION_NO_DATA];
}


- (void)testNSRecursiveLock:(NSInteger)tag {
    
    [_recursiveLock lock];
    
    if (tag > 0) {
        
        [NSThread sleepForTimeInterval:0.2];
        
        [self testNSRecursiveLock:tag - 1];
        NSLog(@"---->> %ld", (long)tag);
    }
    
    [_recursiveLock unlock];
}

- (void)NSConditionLock {
    
}

- (void)testSynchronized {
    
    @synchronized (self) {
        if (_ticketCount > 0) {
            
            [NSThread sleepForTimeInterval:0.2];
            
            _ticketCount --;
            NSLog(@"--->> %@卖了一张票，还剩%ld张", [NSThread currentThread], (long)_ticketCount);
        }
    }
}


@end
