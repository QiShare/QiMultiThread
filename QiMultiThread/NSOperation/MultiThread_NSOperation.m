//
//  MultiThread_NSOperation.m
//  QiMultiThread
//
//  Created by wangdacheng on 2018/12/22.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "MultiThread_NSOperation.h"

#import "MyOperation.h"

@interface MultiThread_NSOperation ()

// 显示图片
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation MultiThread_NSOperation

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"NSOperation"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self layoutViews];
}

-(void)layoutViews {
    
    CGSize size = self.view.frame.size;
    
    _imageView =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, 300)];
    [self.view addSubview:_imageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(15, CGRectGetMaxY(_imageView.frame) + 30, size.width - 15 * 2, 45);
    [button setTitle:@"加载图片" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(testMyOperation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}


#pragma mark - 多线程下载图片

//-(void)loadImgWithOperation {
//
//    // 创建Operation
//    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImg) object:nil];
//    //[invocationOperation start];
//
//    //创建操作队列，并将operation加入队列
//    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
//    [operationQueue addOperation:invocationOperation];
//}

- (void)testMyOperation {
    
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = 5;
    
    //MyOperation *temp = nil;
    for (NSInteger i=0; i<500; i++) {
        MyOperation *operation = [MyOperation downloadDataWithUrlString:@"https://www.so.com" finishedBlock:^(NSData * _Nonnull data) {
            NSLog(@"--- %d finished---", (int)i);
        }];
//        if (temp) {
//            [operation addDependency:temp];
//        }
//        temp = operation;
        [_queue addOperation:operation];
    }
}


#pragma mark - 加载图片

-(void)loadImg {
    
    // 请求数据
    NSData *data = [self requestData];
    
    // 回到主线程更新UI
    [self performSelectorOnMainThread:@selector(updateImg:) withObject:data waitUntilDone:YES];
}


#pragma mark - 请求网络图片数据

-(NSData *)requestData {
    
    NSURL *url = [NSURL URLWithString:@"https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/image/AppleInc/aos/published/images/a/pp/apple/products/apple-products-section1-one-holiday-201811?wid=2560&hei=1046&fmt=jpeg&qlt=95&op_usm=0.5,0.5&.v=1540576114151"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}


#pragma mark - 将图片显示到界面

-(void)updateImg:(NSData *)imageData {
    
    UIImage *image = [UIImage imageWithData:imageData];
    _imageView.image = image;
}

@end
