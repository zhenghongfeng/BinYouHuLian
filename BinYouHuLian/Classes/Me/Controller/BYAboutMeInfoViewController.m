//
//  BYAboutMeInfoViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/1.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYAboutMeInfoViewController.h"
#import "BYAboutMeInfoHeadTableViewCell.h"
#import "BYAboutMeInfoNicknameTableViewCell.h"
#import "BYModifyNickNameViewController.h"

@interface BYAboutMeInfoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BYAboutMeInfoViewController

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"个人信息";
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        BYAboutMeInfoHeadTableViewCell *cell = [[BYAboutMeInfoHeadTableViewCell alloc] init];
        cell.textLabel.text = @"头像";
        [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:[@"http://123.56.186.178/api/download/img?path=" stringByAppendingString:GetAvatar]] placeholderImage:[UIImage imageNamed:@"add_header_edit_btn"]];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else {
        BYAboutMeInfoNicknameTableViewCell *cell = [[BYAboutMeInfoNicknameTableViewCell alloc] init];
        cell.textLabel.text = @"昵称";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.myNickNameLabel.text = GetNickName;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
// 设置cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 60;
    } else {
        return 44;
    }
}

// cell点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { // 换头像
        
    }
    if (indexPath.row == 1) { // 修改昵称
        BYAboutMeInfoNicknameTableViewCell *cell = (BYAboutMeInfoNicknameTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        BYModifyNickNameViewController *vc = [[BYModifyNickNameViewController alloc] init];
        vc.nickNameString = cell.myNickNameLabel.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
