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
    
    self.title = @"好友列表";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBuddy)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    NSDictionary *dic = @{
                          @"phone": @"15942601275"
                          };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"access_token"] forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYUrl_dev stringByAppendingString:@"/ease/users/friends?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [hud hide:YES];
            
            self.friends = [BYFriend mj_objectArrayWithKeyValuesArray:responseObject[@"friends"]];
            
            [self.tableView reloadData];
            
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = responseObject[@"msg"];
            [hud hide:YES afterDelay:1];
            return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"重置失败";
        [hud hide:YES afterDelay:1];
    }];
    
    // 从服务器获取所有的好友  有网络的情况
//    EMError *error = nil;
//    self.buddyList = [[NSMutableArray alloc] initWithArray:[[EMClient sharedClient].contactManager getContactsFromServerWithError:&error]];
//    NSLog(@"error = %@", error.errorDescription);
//    NSLog(@"error = %d", error.code);
//    
//    if (!error) {
//        NSLog(@"获取成功 -- %@",self.buddyList);
//    }
    
    // 从数据库获取所有的好友  无网络的情况
//    self.buddyList = [[EMClient sharedClient].contactManager getContactsFromDB];
}
/**
 *  添加好友
 */
- (void)addBuddy
{
    BYAddBuddyViewController *vc = [[BYAddBuddyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[@"http://www.binyou.info" stringByAppendingString:friend.avatar]] placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BYFriend *friend = self.friends[indexPath.row];
    BYChatViewController *vc = [[BYChatViewController alloc] initWithConversationChatter:friend.phone conversationType:EMConversationTypeChat];
    vc.title = friend.nickname;
    
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







@end
