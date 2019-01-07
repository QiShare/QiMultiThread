//
//  MyOperation.m
//  QiMultiThread
//
//  Created by wangdacheng on 2018/12/25.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "MyOperation.h"


@interface MyOperation ()

//要下载图片的地址
@property (nonatomic, copy) NSString *urlString;
//执行完成后，回调的block
@property (nonatomic, copy) void (^finishedBlock)(NSData *data);

// 自定义变量，用于重写父类isFinished的set、get方法
@property (nonatomic, assign) BOOL taskFinished;

@end

@implementation MyOperation

+ (instancetype)downloadDataWithUrlString:(NSString *)urlString finishedBlock:(void (^)(NSData *data))finishedBlock {
    
    MyOperation *operation = [[MyOperation alloc] init];
    operation.urlString = urlString;
    operation.finishedBlock = finishedBlock;
    return operation;
}

// 监听/重写readonly属性的set、get方法
- (void)setTaskFinished:(BOOL)taskFinished {
    [self willChangeValueForKey:@"isFinished"];
    _taskFinished = taskFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished {

    return self.taskFinished;
}

- (void)main {

    // 打印当前线程
    NSLog(@"%@", [NSThread currentThread]);

    //判断是否被取消,取消正在执行的操作
    if (self.cancelled) {
        return;
    }

    NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //回到主线程更新UI

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.finishedBlock(data);
        }];
    }];
    [task resume];
}

//- (void)start {
//
//    // 打印当前线程
//    NSLog(@"%@", [NSThread currentThread]);
//
//    //判断是否被取消,取消正在执行的操作
//    if (self.cancelled) {
//        return;
//    }
//
//    NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        //回到主线程更新UI
//
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            self.finishedBlock(data);
//        }];
//
//    self.taskFinished = YES;
//    }];
//    [task resume];
//}

@end
