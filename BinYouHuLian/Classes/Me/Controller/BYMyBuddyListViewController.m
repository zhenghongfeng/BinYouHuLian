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

@interface BYMyBuddyListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *buddyList;
@property (nonatomic, strong) UITableView *tableView;

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
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 从服务器获取所有的好友  有网络的情况
    EMError *error = nil;
    self.buddyList = [[NSMutableArray alloc] initWithArray:[[EMClient sharedClient].contactManager getContactsFromServerWithError:&error]];
    if (!error) {
        NSLog(@"获取成功 -- %@",self.buddyList);
    }
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : self.buddyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    BYMyBuddyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[BYMyBuddyListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = @"创建Group";
        cell.imageView.image = [UIImage imageNamed:@"group"];
    } else {
        cell.textLabel.text = self.buddyList[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        BYChatViewController *vc = [[BYChatViewController alloc] initWithConversationChatter:self.buddyList[indexPath.row] conversationType:EMConversationTypeChat];
        vc.title = self.buddyList[indexPath.row];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1 ? YES : NO;
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
