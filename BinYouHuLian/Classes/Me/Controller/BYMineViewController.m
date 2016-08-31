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

@interface BYMineViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *itemTitles;

@property (nonatomic, strong) UIView *redDotView;

@end

@implementation BYMineViewController

#pragma mark - getter

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (UIView *)redDotView
{
    if (_redDotView == nil) {
        _redDotView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth - 30, 20, 5, 5)];
        _redDotView.backgroundColor = [UIColor redColor];
        _redDotView.layer.masksToBounds = YES;
        _redDotView.layer.cornerRadius = 2.5;
        _redDotView.hidden = YES;
    }
    return _redDotView;
}


#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestRedDot];
}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = YES;
//}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"我";
//    self.itemTitles = @[@"会话列表", @"我的好友", @"关于我", @"设置", @"留言", @"我的店业务", @"位置"];

    self.itemTitles = @[@"会话列表", @"我的好友", @"关于我", @"设置"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestRedDot) name:kNotficationApplyRedDot object:nil];
    
    [self.view addSubview:self.tableView];
    
    
}

- (void)requestRedDot
{
    NSDictionary *dic = @{@"username": GetPhone};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/apply/list/count?"] parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            if ([responseObject[@"applyListCount"] integerValue]) {
                self.redDotView.hidden = NO;
            } else {
                self.redDotView.hidden = YES;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
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
    if (indexPath.row == 1) {
        [cell.contentView addSubview:self.redDotView];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

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
            vc = [BYAboutMeInfoViewController new];
        }
        if (indexPath.row == 3) {
            vc = [BYSettingViewController new];
        }
//        if (indexPath.row == 4) {
//            vc = [BYMessageListViewController new];
//        }
//        if (indexPath.row == 5) {
//            vc = [BYMyShopBusinessViewController new];
//        }
//        if (indexPath.row == 6) {
//            vc = [BYCaredLocationViewController new];
//        }
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        BYRegisterViewController *vc = [[BYRegisterViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.hidden = YES;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
