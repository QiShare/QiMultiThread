//
//  MultiThread_ThreadSafe.m
//  QiMultiThread
//
//  Created by wangdacheng on 2019/1/22.
//  Copyright © 2019 QiShare. All rights reserved.
//

#import "MultiThread_ThreadSafe.h"

@interface MultiThread_ThreadSafe ()

@end

@implementation MultiThread_ThreadSafe

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"ThreadSafe"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self testNSLock];
}


- (void)testNSLock {
    
    
    
}

- (void)testDispatchSemaphore {
    
    
    
}

- (void)testNSCondition {
    
    
    
}

- (void)testNSRecursiveLock {
    
}

- (void)NSConditionLock {
    
}

- (void)testSynchronized {
    
    // @synchronized
    
}


@end
