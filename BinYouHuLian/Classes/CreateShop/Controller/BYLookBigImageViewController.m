//
//  BYLookBigImageViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/7/26.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYLookBigImageViewController.h"
#import "BYLookBigPictureView.h"

@interface BYLookBigImageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation BYLookBigImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 40, 44);
        [button setTitle:@"删除" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickRightBarButton) forControlEvents:UIControlEventTouchUpInside];
        button;
    })];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%zd/%zd", self.selectBtn + 1, self.imageArray1.count];
    
    self.currentPage = self.selectBtn;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.scrollView.contentSize = CGSizeMake(self.view.width * self.imageArray1.count, 0);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.contentOffset = CGPointMake(self.view.width * self.selectBtn, 0);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    for (NSInteger i = 0; i < self.imageArray1.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.width * i, 0, self.view.width, kScreenHeight - 64)];
        imageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:imageView];
        
        BYLookBigPictureView *bigPictureView = [[BYLookBigPictureView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kScreenHeight - 64) andImage:self.imageArray1[i]];
        [imageView addSubview:bigPictureView];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentPage = scrollView.contentOffset.x / self.view.width;
    self.navigationItem.title = [NSString stringWithFormat:@"%zd/%zd", self.currentPage + 1, self.imageArray1.count];
}

#pragma mark - 删除
- (void)clickRightBarButton
{
    [self.imageArray1 removeObject:self.imageArray1[self.currentPage]];
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger i = 0; i < self.imageArray1.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.width * i, 0, self.view.width, kScreenHeight - 64)];
        imageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:imageView];
        
        BYLookBigPictureView *bigPictureView = [[BYLookBigPictureView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kScreenHeight - 64) andImage:self.imageArray1[i]];
        [imageView addSubview:bigPictureView];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(passAddImageArray:)]) {
        [self.delegate passAddImageArray:self.imageArray1];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.width * self.imageArray1.count, 0);
    if (self.currentPage >= self.imageArray1.count) {
        self.currentPage = self.imageArray1.count - 1;
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"%zd/%zd", self.currentPage + 1, self.imageArray1.count];
    if (self.imageArray1.count == 0) {
        self.navigationItem.title = @"";
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//- (void)clickLeftBarButton
//{
//    for (UIView *view in self.navigationController.view.subviews) {
//        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
//            UIActivityIndicatorView *activity = (UIActivityIndicatorView *)view;
//            [activity stopAnimating];
//        }
//    }
//    [super clickLeftBarButton];
//}


@end
