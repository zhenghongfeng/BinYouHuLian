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
#import "BYMessageViewController.h"
#import "BYMyShopBusinessViewController.h"

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
    
    self.title = @"我";
    self.itemTitles = @[@"设置", @"位置", @"留言", @"我的店业务"];
    
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
    UIViewController *vc;
    if (indexPath.row == 0) {
        vc = [[BYSettingViewController alloc] init];
    }
    if (indexPath.row == 1) {
        vc = [[BYCaredLocationViewController alloc] init];
    }
    if (indexPath.row == 2) {
        vc = [[BYMessageViewController alloc] init];
    }
    if (indexPath.row == 3) {
        vc = [[BYMyShopBusinessViewController alloc] init];
    }
    [self.navigationController pushViewController:vc animated:YES];
}
@end
