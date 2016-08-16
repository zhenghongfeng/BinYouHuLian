//
//  BYSearchViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/8.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYSearchViewController.h"
#import "BYSearchListTableViewCell.h"
#import "BYShop.h"

@interface BYSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) NSMutableArray *searchHistoryDatas;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITableView *searchTableView;

@property (nonatomic, strong) NSMutableArray *searchData;

@property (nonatomic, strong) NSMutableArray *shops;

@property (nonatomic, strong) NSMutableArray *keys;

@end

@implementation BYSearchViewController

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.tintColor = [UIColor blackColor];
        _searchBar.placeholder = @"请输入店铺关键字";
        [self.view addSubview:_searchBar];
    }
    return _searchBar;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setTitle:@"取消" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UITableView *)searchTableView
{
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, kScreenHeight - 60) style:UITableViewStyleGrouped];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
    }
    return _searchTableView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, kScreenHeight - 60) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, BYTableViewCellH)];
        label.text = @"   搜索历史";
        _tableView.tableHeaderView = label;
    }
    return _tableView;
}

- (void)deleteBtnClick
{
    [_tableView removeFromSuperview];
    
    [[NSFileManager defaultManager] removeItemAtPath:[self plistPath] error:nil];
}

- (NSString *)plistPath
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    
    // 拼接文件的完整路径
    NSString *filePatch = [path stringByAppendingPathComponent:@"searchRecord.plist"];
    return filePatch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.searchBar becomeFirstResponder];
    [self.view addSubview:self.backButton];
    
    self.searchHistoryDatas = [NSMutableArray arrayWithContentsOfFile:[self plistPath]];
    self.searchData = [NSMutableArray array];
    
    if (self.searchHistoryDatas) {
        [self.view addSubview:self.tableView];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tableView == _tableView ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        return section == 0 ? self.searchHistoryDatas.count : 1;
    } else {
        return self.searchData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == _tableView) {
        static NSString *ID = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        if (indexPath.section == 0) {
            cell.textLabel.text = self.searchHistoryDatas[indexPath.row];
        } else {
            cell.textLabel.text = @"清除搜索历史";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = kMainColor;
        }
        return cell;
    } else {
        static NSString *ID = @"cell";
        BYSearchListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[BYSearchListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        if ([self.searchData[indexPath.row] isKindOfClass:[BYShop class]]) {
            cell.nameLabel.text = [self.shops[indexPath.row] name];
            cell.iconImageView.image = [UIImage imageNamed:@"searchShopLocation"];
        } else {
            cell.nameLabel.text = self.searchData[indexPath.row];
            cell.iconImageView.image = [UIImage imageNamed:@"searchResult"];
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *name = cell.textLabel.text;
        if (indexPath.section == 0) {
            [self.view endEditing:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"location" object:name userInfo:nil];
        }
        if (indexPath.section == 1) {
            [_tableView removeFromSuperview];
            [[NSFileManager defaultManager] removeItemAtPath:[self plistPath] error:nil];
            [MBProgressHUD showModeText:@"已清空历史记录" view:self.view];
        }
    } else {
        BYSearchListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *name = cell.nameLabel.text;
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotficationSearchShopToHome object:name userInfo:nil];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length == 0) {
        [MBProgressHUD showModeText:@"请输入关键字" view:self.view];
        return;
    }
    [self requestShopsDataWithSearchText:searchBar.text isSearchButtonClicked:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"searchText == %@", searchText);
    if (searchText.length == 0) {
        [_searchTableView removeFromSuperview];
        [self.shops removeAllObjects];
        return;
    }
    [self.searchData removeAllObjects];
    [self requestShopsDataWithSearchText:searchText isSearchButtonClicked:NO];
}

- (void)requestShopsDataWithSearchText:(NSString *)searchText isSearchButtonClicked:(BOOL)isClicked
{
    NSString *key = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (key.length == 0) {
        return;
    }
    NSDictionary *dic = @{
                          @"lowerlong": @(_leftTopLongitude),
                          @"lowerlati": @(_leftTopLatitude),
                          @"upperlong": @(_rightBottomLongitude),
                          @"upperlati": @(_rightBottomLatitude),
                          @"key": key
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[BYURL_Development stringByAppendingString:@"/shop/search?"] parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            self.shops = [BYShop mj_objectArrayWithKeyValuesArray:responseObject[@"stores"]];
            [self.searchData addObjectsFromArray:self.shops];
            if (isClicked) {
                if (self.searchData.count == 0) {
                    [MBProgressHUD showModeText:@"未搜索到相关店铺" view:self.view];
                    return ;
                } else {
                    // 读取沙盒中pilst数据
                    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:[self plistPath]];
                    
                    NSMutableArray *arr = [NSMutableArray array];
                    
                    // 判断是否为nil
                    if (array) {
                        [array insertObject:searchText atIndex:0];
                        [array writeToFile:[self plistPath] atomically:YES];
                    } else {
                        [arr addObject:searchText];
                        [arr writeToFile:[self plistPath] atomically:YES];
                    }
                    //  沙盒路径
                    NSLog(@"%@", NSHomeDirectory());
                    
                    
                    [self.view endEditing:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"location" object:searchText userInfo:nil];
                }
            } else {
                if (self.searchData.count == 0) {
                    return ;
                }
                [self.searchData addObjectsFromArray:responseObject[@"keys"]];
                [self.view addSubview:self.searchTableView];
            }
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}

- (void)back {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - auto layout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _backButton.sd_layout
    .topSpaceToView(self.view, 30)
    .rightSpaceToView(self.view, 10)
    .widthIs(40)
    .heightIs(30);
    
    self.searchBar.sd_layout
    .topSpaceToView(self.view, 30)
    .leftSpaceToView(self.view, 10)
    .rightSpaceToView(_backButton, 0)
    .heightIs(30);
    
    
}












@end
