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

@property (nonatomic, strong) NSMutableArray *searchDatas;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BYSearchViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, kScreenHeight - 60) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, BYTableViewCellH)];
        label.text = @"   搜索历史";
        _tableView.tableHeaderView = label;
        
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, BYTableViewCellH)];
        [deleteBtn setTitle:@"清除搜索记录" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _tableView.tableFooterView = deleteBtn;
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
    
    self.searchDatas = [NSMutableArray arrayWithContentsOfFile:[self plistPath]];
    
    if (self.searchDatas) {
        [self.view addSubview:self.tableView];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = self.searchDatas[indexPath.row];
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
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
}

- (IBAction)back {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}















@end
