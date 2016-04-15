//
//  BYMyShopBusinessViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/14.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYMyShopBusinessViewController.h"
#import "BYMessageTableViewCell.h"
#import "BYMessageModel.h"
#import "BYChatViewController.h"

static NSString *const messageCellID = @"MessageCell";

@interface BYMyShopBusinessViewController () <UITableViewDataSource, UITableViewDelegate>
/** messages */
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) UITableView *tableView;
@end

@implementation BYMyShopBusinessViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"店里业务";
    
    NSDictionary *dict1 = @{
                            @"avatar": @"xiaoming",
                            @"name": @"小明",
                            @"content": @"您好！这里是宠物店。",
                            @"time": @"12:00"
                            };
    
    NSDictionary *dict2 = @{
                            @"avatar": @"xiaoli",
                            @"name": @"小李",
                            @"content": @"您好！这里是服装店。",
                            @"time": @"11:00"
                            };
    
    NSDictionary *dict3 = @{
                            @"avatar": @"xiaowang",
                            @"name": @"小王",
                            @"content": @"您好！这里是水果店。",
                            @"time": @"9:00"
                            };
    
    NSDictionary *dict4 = @{
                            @"avatar": @"xiaohong",
                            @"name": @"小红",
                            @"content": @"您好！这里是美食店。",
                            @"time": @"8:00"
                            };
    
    NSDictionary *dict5 = @{
                            @"avatar": @"xiaodong",
                            @"name": @"小东",
                            @"content": @"您好！这里是首饰店。",
                            @"time": @"6:00"
                            };
    
    NSDictionary *dict6 = @{
                            @"avatar": @"xiaoqiang",
                            @"name": @"小强",
                            @"content": @"您好！这里是足疗店。",
                            @"time": @"昨天"
                            };
    
    NSDictionary *dict7 = @{
                            @"avatar": @"xiaofeng",
                            @"name": @"小锋",
                            @"content": @"您好！这里是理发店。",
                            @"time": @"前天"
                            };
    
    self.messages = [BYMessageModel arrayWithMessages:@[dict1, dict2, dict3, dict4, dict5, dict6, dict7]];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BYMessageTableViewCell class]) bundle:nil] forCellReuseIdentifier:messageCellID];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BYMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCellID];
    cell.messageModel = self.messages[indexPath.row];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BYChatViewController *vc = [[BYChatViewController alloc] initWithConversationChatter:@"会话" conversationType:EMConversationTypeChat]; // 单聊会话类型
    vc.title = @"会话";
    [self.navigationController pushViewController:vc animated:YES];
}

@end
