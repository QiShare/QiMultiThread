//
//  MultiThreadController.m
//  QiMultiThread
//
//  Created by wangdacheng on 2018/12/10.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "MultiThread_NSThread.h"

@interface MultiThread_NSThread ()

// 显示图片
@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation MultiThread_NSThread

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"NSThread"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self layoutViews];
}

- (void)layoutViews {
    
    CGSize size = self.view.frame.size;
    
    _imgView =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, 300)];
    [self.view addSubview:_imgView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(15, CGRectGetMaxY(_imgView.frame) + 30, size.width - 15 * 2, 45);
    [button setTitle:@"点击加载" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loadImageWithThread) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}


#pragma mark - 多线程下载图片

- (void)loadImageWithThread {
    
    ////1.对象方法
    //NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadImage) object:nil];
    //[thread start];
    
    //2.类方法
    [NSThread detachNewThreadSelector:@selector(downloadImg) toTarget:self withObject:nil];
}


#pragma mark - 加载图片

- (void)downloadImg {
    
    // 请求数据
    NSData *data = [self requestData];
    // 回到主线程更新UI
    [self performSelectorOnMainThread:@selector(updateImg:) withObject:data waitUntilDone:YES];
}


#pragma mark - 请求图片数据

- (NSData *)requestData {
    
    NSURL *url = [NSURL URLWithString:@"https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/image/AppleInc/aos/published/images/a/pp/apple/products/apple-products-section1-one-holiday-201811?wid=2560&hei=1046&fmt=jpeg&qlt=95&op_usm=0.5,0.5&.v=1540576114151"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}


#pragma mark - 将图片显示到界面

- (void)updateImg:(NSData *)imageData {
    
    UIImage *image = [UIImage imageWithData:imageData];
    _imgView.image = image;
}

@end
