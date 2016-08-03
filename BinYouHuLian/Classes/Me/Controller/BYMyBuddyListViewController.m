//
//  BYMyBuddyListViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/25.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYMyBuddyListViewController.h"
#import "BYAddBuddyViewController.h"
#import "BYMyBuddyListTableViewCell.h"
#import "BYChatViewController.h"
#import "BYFriend.h"
#import "ChatViewController.h"

@interface BYMyBuddyListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *buddyList;
@property (nonatomic, strong) UITableView *tableView;

/** friends */
@property (nonatomic, strong) NSMutableArray *friends;

@end

@implementation BYMyBuddyListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"好友列表";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBuddy)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic = @{
                          @"phone": GetPhone
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/friends?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            NSArray *array = responseObject[@"friends"];
            if (array.count == 0) {
                [MBProgressHUD showModeText:@"您还没有好友，去添加好友吧" view:self.view];
                return ;
            }
            self.friends = [BYFriend mj_objectArrayWithKeyValuesArray:array];
            [self.tableView reloadData];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
            return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
    [hud hide:YES];
    
    // 从数据库获取所有的好友  无网络的情况
//    self.buddyList = [[EMClient sharedClient].contactManager getContactsFromDB];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    BYMyBuddyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[BYMyBuddyListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    BYFriend *friend = self.friends[indexPath.row];
    
    cell.textLabel.text = friend.nickname;
    cell.detailTextLabel.text = friend.phone;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[@"http://123.56.186.178/api/download/img?path=" stringByAppendingString:friend.avatar]] placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BYFriend *friend = self.friends[indexPath.row];
//    BYChatViewController *vc = [[BYChatViewController alloc] initWithConversationChatter:friend.phone conversationType:EMConversationTypeChat];
    ChatViewController *vc = [[ChatViewController alloc] initWithConversationChatter:friend.phone conversationType:EMConversationTypeChat];
    vc.title = friend.nickname;
    vc.myFriend = friend;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除好友
    EMError *error = [[EMClient sharedClient].contactManager deleteContact:self.buddyList[indexPath.row]];
    if (!error) {
        NSLog(@"删除成功");
    }
    
    [self.buddyList removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

#pragma mark - 跳到添加好友界面

- (void)addBuddy
{
    BYAddBuddyViewController *vc = [[BYAddBuddyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}






@end
