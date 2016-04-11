//
//  BYCreateShopViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/8.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYCreateShopViewController.h"

@interface BYCreateShopViewController ()

@end

@implementation BYCreateShopViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 如果滑动移除控制器的功能失效，清空代理(让导航控制器重新设置这个功能)
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    self.title = @"开店";
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [backBtn setImage:[UIImage imageNamed:@"ac_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    // 让按钮内部的所有内容左对齐
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    // 让按钮的内容往左边偏移10
//    backBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
}

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
