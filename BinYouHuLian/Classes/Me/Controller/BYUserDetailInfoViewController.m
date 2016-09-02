//
//  BYUserDetailInfoViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/9/2.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYUserDetailInfoViewController.h"

#import "BYFriend.h"

#import "ChatViewController.h"

#import "BYUserInfoSettingViewController.h"

@interface BYUserDetailInfoViewController () <UITableViewDataSource, UITableViewDelegate>

/** tableView */
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BYUserDetailInfoViewController

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
        
        UIButton *sendMessageButton = [UIButton new];
        sendMessageButton.backgroundColor = [UIColor blackColor];
        sendMessageButton.frame = CGRectMake(50, 30, kScreenWidth - 100, 40);
        sendMessageButton.layer.masksToBounds = YES;
        sendMessageButton.layer.cornerRadius = 5;
        [sendMessageButton setTitle:@"发消息" forState:UIControlStateNormal];
        [sendMessageButton addTarget:self action:@selector(sendMessageButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:sendMessageButton];
        _tableView.tableFooterView = view;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"详细资料";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [button setImage:[UIImage imageNamed:@"user_detailInfo_more"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
        button;
    })];
    
    [self.view addSubview:self.tableView];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = self.friend.nickname;
    cell.detailTextLabel.text = self.friend.phone;
    NSURL *url = [NSURL URLWithString:self.friend.avatar];
    [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
    
    return cell;
}

#pragma mark - UITableViewDataDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - custom event

- (void)sendMessageButtonClick
{
    ChatViewController *vc = [[ChatViewController alloc] initWithConversationChatter:self.friend.phone conversationType:EMConversationTypeChat];
    vc.myFriend = self.friend;
    vc.navigationItem.title = self.friend.nickname;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)moreButtonClick
{
    BYUserInfoSettingViewController *vc = [BYUserInfoSettingViewController new];
    vc.myFriend = self.friend;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
