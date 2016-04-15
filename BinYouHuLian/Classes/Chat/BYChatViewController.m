//
//  BYChatViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/15.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYChatViewController.h"

@interface BYChatViewController ()

@end

@implementation BYChatViewController

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

@end
