//
//  BYMyGroupListViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/29.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYMyGroupListViewController.h"
#import "BYAddBuddyViewController.h"
#import "BYMyBuddyListTableViewCell.h"
#import "BYAddGroupViewController.h"

@interface BYMyGroupListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *myGroups;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BYMyGroupListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"群组列表";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroup)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //1.从服务器获取与我相关的群组列表
    EMError *error = nil;
    self.myGroups = [NSMutableArray arrayWithArray:[[EMClient sharedClient].groupManager getMyGroupsFromServerWithError:&error]];
    if (!error) {
        NSLog(@"获取成功 -- %@",self.myGroups);
    }
    
    //2. 获取数据库中所有的群组
//    NSArray *groupList = [[EMClient sharedClient].groupManager loadAllMyGroupsFromDB];
    
    //3. 取内存中的值
//    NSArray *groupList = [[EMClient sharedClient].groupManager getAllGroups];
    
    
}
/**
 *  添加好友
 */
- (void)addGroup
{
    BYAddGroupViewController *vc = [[BYAddGroupViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    BYMyBuddyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[BYMyBuddyListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
//    cell.textLabel.text = self.myGroups[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
   
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
//    EMError *error = [[EMClient sharedClient].contactManager deleteContact:self.myGroups[indexPath.row]];
//    if (!error) {
//        NSLog(@"删除成功");
//    }
//    
//    [self.buddyList removeObjectAtIndex:indexPath.row];
//    [self.tableView reloadData];
}

@end
