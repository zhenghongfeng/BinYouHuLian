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
#import "BYFriend.h"
#import "ChatViewController.h"
#import "BYAddApplyViewController.h"
#import "BYChatRoomViewController.h"

@interface BYMyBuddyListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *friends;

@end

@implementation BYMyBuddyListViewController

#pragma mark - getter

- (NSArray *)array
{
    if (_array == nil) {
        _array = @[@"好友申请", @"聊天室"];
    }
    return _array;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self requestData];
}

- (void)requestData
{
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
                [hud hide:YES];
                [MBProgressHUD showModeText:@"您还没有好友，去添加好友吧" view:self.view];
            }
            self.friends = [BYFriend mj_objectArrayWithKeyValuesArray:array];
            [self.tableView reloadData];
        } else {
            [hud hide:YES];
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [hud hide:YES];
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"好友列表";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBuddy)];
    
    [self.view addSubview:self.tableView];
    
    // 从数据库获取所有的好友  无网络的情况
//    self.buddyList = [[EMClient sharedClient].contactManager getContactsFromDB];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.array.count : self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *ID = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        cell.textLabel.text = self.array[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"groupPublicHeader"];
        return cell;
    } else {
        static NSString *ID = @"cell";
        BYMyBuddyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[BYMyBuddyListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        BYFriend *friend = self.friends[indexPath.row];
        
        cell.textLabel.text = friend.nickname;
        cell.detailTextLabel.text = friend.phone;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[BYImageURL stringByAppendingString:friend.avatar]] placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            BYAddApplyViewController *vc = [BYAddApplyViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        if (indexPath.row == 1) {
            BYChatRoomViewController *vc = [BYChatRoomViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
    if (indexPath.section == 1) {
        BYFriend *friend = self.friends[indexPath.row];
        ChatViewController *vc = [[ChatViewController alloc] initWithConversationChatter:friend.phone conversationType:EMConversationTypeChat];
        vc.myFriend = friend;
        vc.navigationItem.title = friend.nickname;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = @{
                          @"username": GetPhone,
                          @"friendName": [self.friends[indexPath.row] phone]
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/delfriend?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [self.friends removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}

#pragma mark - 跳到添加好友界面

- (void)addBuddy
{
    BYAddBuddyViewController *vc = [[BYAddBuddyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}






@end
