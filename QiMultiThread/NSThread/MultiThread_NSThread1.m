//
//  MultiThreadController_101.m
//  QiMultiThread
//
//  Created by wangdacheng on 2018/12/10.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "MultiThread_NSThread1.h"

@implementation NSThreadImage

@end

#define ColumnCount    4
#define RowCount       5
#define Margin         10

@interface MultiThread_NSThread1 ()

// imgView数组
@property (nonatomic, strong) NSMutableArray *imgViewArr;
// thread数组
@property (nonatomic, strong) NSMutableArray *threadArr;

@end

@implementation MultiThread_NSThread1

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"NSThread1"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self layoutViews];
}

- (void)layoutViews {
    
    CGSize size = self.view.frame.size;
    CGFloat imgWidth = (size.width - Margin * (ColumnCount + 1)) / ColumnCount;
    
    _imgViewArr = [NSMutableArray array];
    for (int row=0; row<RowCount; row++) {
        for (int colomn=0; colomn<ColumnCount; colomn++) {
            UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(Margin + colomn * (imgWidth + Margin), Margin + row * (imgWidth + Margin), imgWidth, imgWidth)];
            imageView.backgroundColor=[UIColor cyanColor];
            [self.view addSubview:imageView];
            [_imgViewArr addObject:imageView];
        }
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(15, (imgWidth + Margin) * RowCount + Margin, size.width - 15 * 2, 45);
    [button addTarget:self action:@selector(loadImgWithMultiThread) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"点击加载" forState:UIControlStateNormal];
    [self.view addSubview:button];
}


#pragma mark - 多线程下载图片

- (void)loadImgWithMultiThread {
    
    _threadArr = [NSMutableArray array];
    for (int i=0; i<RowCount*ColumnCount; ++i) {
        NSThreadImage *threadImg = [[NSThreadImage alloc] init];
        threadImg.index = i;
        NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(loadImg:) object:threadImg];
        thread.name = [NSString stringWithFormat:@"myThread%i",i];
        //// 优先级
        //thread.threadPriority = 1.0;
        [thread start];
        [_threadArr addObject:thread];
    }
}


#pragma mark - 加载图片

- (void)loadImg:(NSThreadImage *)threadImg {
    
    //// 休眠
    //[NSThread sleepForTimeInterval:2.0];
    //// 撤销(停止加载图片)
    //[[NSThread currentThread] cancel];
    //// 退出当前线程
    //[NSThread exit];
    
    
    // 请求数据
    threadImg.imgData =  [self requestData];
    // 回到主线程更新UI
    [self performSelectorOnMainThread:@selector(updateImg:) withObject:threadImg waitUntilDone:YES];
    
    // 打印当前线程
    NSLog(@"current thread: %@", [NSThread currentThread]);
}


#pragma mark - 请求图片数据

- (NSData *)requestData{
    
    NSURL *url = [NSURL URLWithString:@"https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/image/AppleInc/aos/published/images/a/pp/apple/products/apple-products-section1-one-holiday-201811?wid=2560&hei=1046&fmt=jpeg&qlt=95&op_usm=0.5,0.5&.v=1540576114151"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}


#pragma mark - 将图片显示到界面

- (void)updateImg:(NSThreadImage *)threadImg {
    
    UIImage *image = [UIImage imageWithData:threadImg.imgData];
    UIImageView *imageView = _imgViewArr[threadImg.index];
    imageView.image = image;
}


//#pragma mark 停止加载网络图片
//
//- (void)stopLoadingImgs {
//
//    for (int i=0; i<RowCount*ColumnCount; ++i) {
//
//        NSThread *thread = _threadArr[i];
//        if (!thread.isFinished) {
//            [thread cancel];
//        }
//    }
//}

@end
