//
//  MyOperation.h
//  QiMultiThread
//
//  Created by wangdacheng on 2018/12/25.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyOperation : NSOperation

+ (instancetype)downloadDataWithUrlString:(NSString *)urlString finishedBlock:(void (^)(NSData *data))finishedBlock;

@end

NS_ASSUME_NONNULL_END
