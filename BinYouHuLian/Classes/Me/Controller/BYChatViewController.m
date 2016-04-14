//
//  BYChatViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/14.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYChatViewController.h"
#import <IQKeyboardManager.h>

@interface BYChatViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

/** 底部工具条 */
@property (nonatomic, strong) UIView *bottomToolBarView;

@end

@implementation BYChatViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    IQKeyboardManager *keyBoard = [IQKeyboardManager sharedManager];
    keyBoard.enable = NO;
    keyBoard.enableAutoToolbar = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"会话";
    
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, 0, kScreenWidth, self.view.height - 46);
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    self.bottomToolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 46, kScreenWidth, 46)];
    self.bottomToolBarView.backgroundColor = kRGB(242, 242, 245);
    [self.view addSubview:self.bottomToolBarView];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    IQKeyboardManager *keyBoard = [IQKeyboardManager sharedManager];
    keyBoard.enable = YES;
    keyBoard.enableAutoToolbar = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}


@end
