//
//  multiThread_GCD.m
//  QiMultiThread
//
//  Created by wangdacheng on 2018/12/24.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "MultiThread_GCD.h"

@implementation GCDImage

@end

#define ColumnCount    4
#define RowCount       5
#define Margin         10

@interface MultiThread_GCD ()

@property (nonatomic, strong) NSMutableArray *imageViews;

@end

@implementation MultiThread_GCD

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"GCD"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self layoutViews];
}

- (void)layoutViews {
    
    CGSize size = self.view.frame.size;
    CGFloat imgWidth = (size.width - Margin * (ColumnCount + 1)) / ColumnCount;
    
    _imageViews=[NSMutableArray array];
    for (int row=0; row<RowCount; row++) {
        for (int colomn=0; colomn<ColumnCount; colomn++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(Margin + colomn * (imgWidth + Margin), Margin + row * (imgWidth + Margin), imgWidth, imgWidth)];
            imageView.backgroundColor = [UIColor cyanColor];
            [self.view addSubview:imageView];
            [_imageViews addObject:imageView];
        }
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(15, (imgWidth + Margin) * RowCount + Margin, size.width - 15 * 2, 45);
    [button addTarget:self action:@selector(loadImageWithMultiOperation) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"点击加载" forState:UIControlStateNormal];
    [self.view addSubview:button];
}


#pragma mark - 多线程下载图片

//- (void)loadImageWithMultiOperation {
//
//    int count = RowCount * ColumnCount;
//
//    // 创建一个串行队列 第一个参数：队列名称 第二个参数：队列类型
//    // 注意queue对象不是指针类型
//    dispatch_queue_t serialQueue=dispatch_queue_create("QiShareSerialQueue", DISPATCH_QUEUE_SERIAL);
//    // 创建多个线程用于填充图片
//    for (int i=0; i<count; ++i) {
//        //异步执行队列任务
//        dispatch_async(serialQueue, ^{
//            GCDImage *gcdImg = [[GCDImage alloc] init];
//            gcdImg.index = i;
//            [self loadImg:gcdImg];
//        });
//
//    }
//}

- (void)loadImageWithMultiOperation {
    
    int count = RowCount * ColumnCount;
    
    // 取得全局队列 第一个参数：线程优先级 第二个参数：标记参数，目前没有用，一般传入0
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 创建多个线程用于填充图片
    for (int i=0; i<count; ++i) {
        //异步执行队列任务
        dispatch_sync(globalQueue, ^{
            GCDImage *gcdImg = [[GCDImage alloc] init];
            gcdImg.index = i;
            [self loadImg:gcdImg];
        });
        
    }
}


#pragma mark - 加载图片

- (void)loadImg:(GCDImage *)gcdImg {
    
    // 请求数据
    gcdImg.imgData = [self requestData];
    
    // 更新UI界面（mainQueue是UI主线程
//    dispatch_sync(dispatch_get_main_queue(), ^{
        [self updateImage:gcdImg];
//    });
    
    // 打印当前线程
    NSLog(@"current thread: %@", [NSThread currentThread]);
}


#pragma mark - 请求图片数据

- (NSData *)requestData {
    
    NSURL *url = [NSURL URLWithString:@"https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/image/AppleInc/aos/published/images/a/pp/apple/products/apple-products-section1-one-holiday-201811?wid=2560&hei=1046&fmt=jpeg&qlt=95&op_usm=0.5,0.5&.v=1540576114151"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}


#pragma mark - 将图片显示到界面

-(void)updateImage:(GCDImage *)gcdImg {
    
    UIImage *image = [UIImage imageWithData:gcdImg.imgData];
    UIImageView *imageView = _imageViews[gcdImg.index];
    imageView.image = image;
}


@end

