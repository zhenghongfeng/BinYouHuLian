//
//  BYSearchViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/8.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYSearchViewController.h"

@interface BYSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *searchHistoryDatas;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITableView *searchTableView;

@property (nonatomic, strong) NSMutableArray *searchData;

@end

@implementation BYSearchViewController

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
    
    [self.searchBar becomeFirstResponder];
    
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
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    if (tableView == _tableView) {
        if (indexPath.section == 0) {
            cell.textLabel.text = self.searchHistoryDatas[indexPath.row];
        } else {
            cell.textLabel.text = @"清除搜索历史";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = kMainColor;
        }
    } else {
        cell.textLabel.text = self.searchData[indexPath.row];
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        if (indexPath.section == 0) {
            [self.view endEditing:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"location" object:nil userInfo:nil];
        }
        
        if (indexPath.section == 1) {
            
            [_tableView removeFromSuperview];
            
            [[NSFileManager defaultManager] removeItemAtPath:[self plistPath] error:nil];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"已清空历史记录";
            [hud hide:YES afterDelay:1];
        }
    } else {
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"location" object:nil userInfo:nil];
    }
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入关键字";
        [hud hide:YES afterDelay:1.5];
        return;
    }
    // 读取沙盒中pilst数据
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:[self plistPath]];
    
    NSMutableArray *arr = [NSMutableArray array];
    
    // 判断是否为nil
    if (array) {
        [array insertObject:searchBar.text atIndex:0];
        [array writeToFile:[self plistPath] atomically:YES];
    } else {
        [arr addObject:searchBar.text];
        [arr writeToFile:[self plistPath] atomically:YES];
    }
    //  沙盒路径
    NSLog(@"%@", NSHomeDirectory());
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"location" object:nil userInfo:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"searchText == %@", searchText);
    if (searchText.length == 0) {
        [_searchTableView removeFromSuperview];
        return;
    }
    [self.searchData removeAllObjects];
    for (NSInteger i = 0; i < 5; i++) {
        NSString *str = [NSString stringWithFormat:@"%@%zd", searchText, i];
        [self.searchData addObject:str];
    }
    [self.view addSubview:self.searchTableView];
    [self.searchTableView reloadData];
}

- (IBAction)back {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}















@end
