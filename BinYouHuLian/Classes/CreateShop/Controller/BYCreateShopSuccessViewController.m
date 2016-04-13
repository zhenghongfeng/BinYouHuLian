//
//  BYCreateShopSuccessViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/13.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYCreateShopSuccessViewController.h"
#import "BYTopAligningLabel.h"

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
    
    BYTopAligningLabel *topAligningLabel = [[BYTopAligningLabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.label.frame) + 10, kScreenWidth - 20, 999)];
    [topAligningLabel setText:contentString];
    topAligningLabel.numberOfLines = 0;
    topAligningLabel.textColor = [UIColor grayColor];
    topAligningLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:topAligningLabel];
    
    UIButton *openShopButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(topAligningLabel.frame) + 10, kScreenWidth - 20, 40)];
    openShopButton.layer.masksToBounds = YES;
    openShopButton.layer.cornerRadius = 5;
    [openShopButton setTitle:@"开启微店" forState:UIControlStateNormal];
    openShopButton.backgroundColor = [UIColor redColor];
    [openShopButton addTarget:self action:@selector(openShopButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openShopButton];
}

- (void)openShopButtonClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    // 下面在首页弹出店铺详情界面
    
}


@end
