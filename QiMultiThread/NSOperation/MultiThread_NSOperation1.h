//
//  MultiThread_NSOperation1.h
//  QiMultiThread
//
//  Created by wangdacheng on 2018/12/22.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OperationImage : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSData *imgData;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MultiThread_NSOperation1 : UIViewController

@end

NS_ASSUME_NONNULL_END
