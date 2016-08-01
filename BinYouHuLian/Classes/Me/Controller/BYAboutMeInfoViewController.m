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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"个人信息";
    
    [self setupTableView];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docPath stringByAppendingPathComponent:@"loginUser.archiver"];
    NSLog(@"path=%@",path);
}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
        //1.获取文件路径
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [docPath stringByAppendingPathComponent:@"loginUser.archiver"];
        NSLog(@"path=%@",path);
        
        //2.从文件中读取对象
        BYLoginUser *loginUser = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:[@"http://123.56.186.178/api/download/img?path=" stringByAppendingString:loginUser.avatar]] placeholderImage:[UIImage imageNamed:@"add_header_edit_btn"]];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else {
        BYAboutMeInfoNicknameTableViewCell *cell = [[BYAboutMeInfoNicknameTableViewCell alloc] init];
        cell.textLabel.text = @"昵称";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
