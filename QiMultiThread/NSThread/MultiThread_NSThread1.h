//
//  MultiThreadController_101.h
//  QiMultiThread
//
//  Created by wangdacheng on 2018/12/10.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSThreadImage : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSData *imgData;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MultiThread_NSThread1 : UIViewController

@end

NS_ASSUME_NONNULL_END

