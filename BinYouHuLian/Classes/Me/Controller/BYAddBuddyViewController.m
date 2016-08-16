//
//  BYAddBuddyViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/25.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYAddBuddyViewController.h"
#import "BYFriend.h"
#import "BYMyBuddyListTableViewCell.h"
#import "BYApplyReasonViewController.h"

@interface BYAddBuddyViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

/** searchBar */
@property (nonatomic, strong) UISearchBar *searchBar;

/** tableView */
@property (nonatomic, strong) UITableView *tableView;

/** friend */
@property (nonatomic, strong) BYFriend *friend;

/** isfriend */
@property (nonatomic, assign) BOOL isfriend;

@end

@implementation BYAddBuddyViewController

#pragma mark - getter

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"添加朋友";
    
    [self.searchBar becomeFirstResponder];
}

#pragma mark - UISearchDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    WeakSelf;
    NSDictionary *dic = @{
                          @"friend": searchBar.text
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/friendinfo?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"userinfo == %@", responseObject);
        self.isfriend = [responseObject[@"isfriend"] boolValue];
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            weakSelf.friend = [BYFriend mj_objectWithKeyValues:responseObject[@"userInfo"]];
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
    cell.textLabel.text = self.friend.nickname;
    cell.detailTextLabel.text = self.friend.phone;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[@"http://123.56.186.178/api/download/img?path=" stringByAppendingString:self.friend.avatar]] placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
    
    UIButton *addButton = [[UIButton alloc] init];
    [addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (self.isfriend) {
        [addButton setTitle:@"已添加" forState:UIControlStateNormal];
        addButton.frame = CGRectMake(kScreenWidth - 70, 0, 60, 44);
    } else {
        [addButton setTitle:@"添加" forState:UIControlStateNormal];
        addButton.frame = CGRectMake(kScreenWidth - 54, 0, 44, 44);
        [addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell.contentView addSubview:addButton];
    
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
    BYApplyReasonViewController *vc =[BYApplyReasonViewController new];
    vc.userName = self.friend.phone;
    [self.navigationController pushViewController:vc animated:YES];
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
