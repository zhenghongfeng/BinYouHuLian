//
//  BYMineViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/8.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYMineViewController.h"
#import "BYSettingViewController.h"
#import "BYCaredLocationViewController.h"
#import "BYMessageListViewController.h"
#import "BYMyShopBusinessViewController.h"
#import "BYMyBuddyListViewController.h"
#import "BYAboutMeInfoViewController.h"
#import "BYRegisterViewController.h"
#import "ConversationListController.h"

@interface BYMineViewController ()

@property (nonatomic, strong) NSArray *itemTitles;

@end

@implementation BYMineViewController

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
    
    self.navigationItem.title = @"我";
    self.itemTitles = @[@"会话列表", @"我的好友", @"留言", @"我的店业务", @"位置", @"关于我", @"设置"];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.itemTitles[indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([NSString isValueableString:GetToken]) {
        UIViewController *vc;
        if (indexPath.row == 0) {
            vc = [ConversationListController new];
        }
        if (indexPath.row == 1) {
            vc = [BYMyBuddyListViewController new];
        }
        if (indexPath.row == 2) {
            vc = [BYMessageListViewController new];
        }
        if (indexPath.row == 3) {
            vc = [BYMyShopBusinessViewController new];
        }
        if (indexPath.row == 4) {
            vc = [BYCaredLocationViewController new];
        }
        if (indexPath.row == 5) {
            vc = [BYAboutMeInfoViewController new];
        }
        if (indexPath.row == 6) {
            vc = [BYSettingViewController new];
        }
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        BYRegisterViewController *vc = [[BYRegisterViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.hidden = YES;
        [self presentViewController:nav animated:YES completion:nil];
    }
}
@end
