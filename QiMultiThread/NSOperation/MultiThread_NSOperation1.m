//
//  MultiThread_NSOperation1.m
//  QiMultiThread
//
//  Created by wangdacheng on 2018/12/22.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "MultiThread_NSOperation1.h"

@implementation OperationImage

@end

#define ColumnCount    4
#define RowCount       5
#define Margin         10

@interface MultiThread_NSOperation1 ()

@property (nonatomic, strong) NSMutableArray *imageViews;

@end

@implementation MultiThread_NSOperation1

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"NSOperation1"];
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

- (void)loadImageWithMultiOperation {
    
    int count = RowCount * ColumnCount;
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
    operationQueue.maxConcurrentOperationCount = 5;
    
    NSBlockOperation *tempOperation = nil;
    for (int i=0; i<count; ++i) {
        OperationImage *operationImg = [[OperationImage alloc] init];
        operationImg.index = i;
        
        ////1.直接使用操队列添加操作
        //[operationQueue addOperationWithBlock:^{
        //    [self loadImg:operationImg];
        //}];
        
        ////2.创建操作块添加到队列
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self loadImg:operationImg];
        }];
        if (i > 0) {// 设置依赖
            [blockOperation addDependency:tempOperation];
        }
        [operationQueue addOperation:blockOperation];
        tempOperation = blockOperation;
    }
}

#pragma mark - 将图片显示到界面

-(void)updateImage:(OperationImage *)operationImg {
    
    UIImage *image = [UIImage imageWithData:operationImg.imgData];
    UIImageView *imageView = _imageViews[operationImg.index];
    imageView.image = image;
}


#pragma mark - 请求图片数据

- (NSData *)requestData {
    
    NSURL *url = [NSURL URLWithString:@"https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/image/AppleInc/aos/published/images/a/pp/apple/products/apple-products-section1-one-holiday-201811?wid=2560&hei=1046&fmt=jpeg&qlt=95&op_usm=0.5,0.5&.v=1540576114151"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}


#pragma mark - 加载图片

- (void)loadImg:(OperationImage *)operationImg {
    
    // 请求数据
    operationImg.imgData = [self requestData];
    
    // 更新UI界面（mainQueue是UI主线程）
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updateImage:operationImg];
    }];
    
    // 打印当前线程
    NSLog(@"current thread: %@", [NSThread currentThread]);
}

@end
