//
//  BYAddBlackUserViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/9/2.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYAddBlackUserViewController.h"

#import "BYBlackUser.h"
#import "BYMyBuddyListTableViewCell.h"

@interface BYAddBlackUserViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

/** searchBar */
@property (nonatomic, strong) UISearchBar *searchBar;

/** tableView */
@property (nonatomic, strong) UITableView *tableView;

/** isfriend */
@property (nonatomic, assign) NSInteger isfriend;

@property (nonatomic, strong) BYBlackUser *blackUser;

/** <#注释#> */
@property (nonatomic, strong) UIButton *addButton;


@end

@implementation BYAddBlackUserViewController

- (UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.placeholder = @"请输入对方的手机号";
        _searchBar.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _searchBar.tintColor = [UIColor blackColor];
        [self.view addSubview:_searchBar];
    }
    return _searchBar;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchBar.frame) + 20, self.view.width, kScreenHeight - CGRectGetMaxY(self.searchBar.frame) - 20) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

//- (UIButton *)addButton
//{
//    if (_addButton == nil) {
//        _addButton = [[UIButton alloc] init];
//        [_addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        if (self.isfriend == 2) {
//            [_addButton setTitle:@"已在黑名单中" forState:UIControlStateNormal];
//            _addButton.frame = CGRectMake(kScreenWidth - 130, 0, 120, 44);
//        } else {
//            [_addButton setTitle:@"添加" forState:UIControlStateNormal];
//            _addButton.frame = CGRectMake(kScreenWidth - 54, 0, 44, 44);
//            [_addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
//        }
//        [_addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _addButton;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"添加黑名单";
    
    [self.searchBar becomeFirstResponder];
}

#pragma mark - UISearchDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text isEqualToString:GetPhone]) {
        [MBProgressHUD showModeText:@"您不能添加自己" view:self.view];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    WeakSelf;
    NSDictionary *dic = @{
                          @"friend": searchBar.text
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/friendinfo?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"userinfo == %@", responseObject);
        [hud hide:YES];
        self.isfriend = [responseObject[@"isfriend"] integerValue];
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            weakSelf.blackUser = [BYBlackUser mj_objectWithKeyValues:responseObject[@"userInfo"]];
            [weakSelf.view addSubview:weakSelf.tableView];
            [weakSelf.tableView reloadData];
        } else {
            if (weakSelf.tableView) {
                [weakSelf.tableView removeFromSuperview];
            }
            [MBProgressHUD showModeText:responseObject[@"msg"] view:weakSelf.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [hud hide:YES];
        [MBProgressHUD showModeText:error.localizedDescription view:weakSelf.view];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BYMyBuddyListTableViewCell *cell = [[BYMyBuddyListTableViewCell alloc] init];
    cell.textLabel.text = self.blackUser.nickname;
    cell.detailTextLabel.text = self.blackUser.phone;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.blackUser.avatar] placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
    
    self.addButton = [[UIButton alloc] init];
    [self.addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (self.isfriend == 2) {
        [self.addButton setTitle:@"已在黑名单中" forState:UIControlStateNormal];
        self.addButton.frame = CGRectMake(kScreenWidth - 130, 0, 120, 44);
    } else {
        [self.addButton setTitle:@"添加" forState:UIControlStateNormal];
        self.addButton.frame = CGRectMake(kScreenWidth - 54, 0, 44, 44);
        [self.addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:self.addButton];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)addButtonClick
{
    NSLog(@"添加");
//    BYApplyReasonViewController *vc =[BYApplyReasonViewController new];
//    vc.userName = self.friend.phone;
//    [self.navigationController pushViewController:vc animated:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic = @{
                          @"id": GetPhone,
                          @"blackIds": self.blackUser.phone,
                          @"isgroup": @"0"
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/black/add?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        [hud hide:YES];
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [MBProgressHUD showModeText:@"已加入黑名单" view:self.view];
            [self.addButton setTitle:@"已添加" forState:UIControlStateNormal];
            self.addButton.frame = CGRectMake(kScreenWidth - 70, 0, 60, 44);
            self.addButton.enabled = NO;
            
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [hud hide:YES];
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
    
}

#pragma mark - auto layout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _searchBar.sd_layout
    .leftSpaceToView(self.view, 10)
    .topSpaceToView(self.navigationController.navigationBar, 10)
    .rightSpaceToView(self.view, 10)
    .heightIs(30);
}


@end
