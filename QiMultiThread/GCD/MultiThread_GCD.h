//
//  multiThread_GCD.h
//  QiMultiThread
//
//  Created by wangdacheng on 2018/12/24.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCDImage : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSData *imgData;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MultiThread_GCD : UIViewController

@end

NS_ASSUME_NONNULL_END
