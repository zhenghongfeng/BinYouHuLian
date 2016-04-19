//
//  BYCreateShopSuccessViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/13.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYCreateShopSuccessViewController.h"
#import "BYShopDetailViewController.h"

static NSString *const contentString = @"我们会在订单交易成功后次日将款项提现到你填写的银行账户上，一般1~2个工作日到账。目前推广期免手续费。";

@interface BYCreateShopSuccessViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
@implementation BYCreateShopSuccessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"店铺创建成功";
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [self setupUI];
}

- (void)setupUI
{
    UILabel *label = [[UILabel alloc] init];
    label.text = contentString;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:label];
    
    label.sd_layout
    .leftSpaceToView(self.view, BYMargin)
    .topSpaceToView(self.view, CGRectGetMaxY(self.label.frame) + BYMargin)
    .rightSpaceToView(self.view, BYMargin)
    .autoHeightRatio(0);
    
    UIButton *button = [[UIButton alloc] init];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    [button setTitle:@"开启微店" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(openShopButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button.sd_layout
    .leftEqualToView(label)
    .rightEqualToView(label)
    .topSpaceToView(label, BYMargin)
    .heightIs(40);
}

- (void)openShopButtonClick
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    // 下面在首页跳到店铺详情界面
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[[UIApplication sharedApplication] keyWindow].rootViewController.navigationController pushViewController:[BYShopDetailViewController new] animated:YES];
//    });
}


@end
