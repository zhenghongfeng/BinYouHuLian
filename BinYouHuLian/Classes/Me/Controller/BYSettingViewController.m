//
//  BYSettingViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/13.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYSettingViewController.h"
#import "BYRegisterViewController.h"

@interface BYSettingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *titles1;

@property (nonatomic, strong) NSArray *titles2;

@property (nonatomic, strong) NSArray *titles3;

@end
@implementation BYSettingViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"设置";
    self.titles1 = @[@"账号管理", @"账号安全"];
    self.titles2 = @[@"通知", @"隐私与安全", @"通用设置"];
    self.titles3 = @[@"清理缓存", @"意见反馈" ,@"关于宾友"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 2 : (section == 3 ? 1 : 3);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 3) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = self.titles1[indexPath.row];
            break;
        case 1:
            cell.textLabel.text = self.titles2[indexPath.row];
            break;
        case 2:
            cell.textLabel.text = self.titles3[indexPath.row];
            break;
        case 3:
            cell.textLabel.text = @"退出当前账号";
            cell.textLabel.textColor = [UIColor redColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 去掉cell选中后的效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 3) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            EMError *error = [[EMClient sharedClient] logout:YES];
            if (!error) {
                NSLog(@"退出成功");
                // 清空该用户的搜索记录
                [[NSFileManager defaultManager] removeItemAtPath:[self plistPath] error:nil];
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:[BYRegisterViewController new] animated:YES completion:nil];
                });
            } else {
                NSLog(@"退出失败");
            }
//            // 清空账号信息
//            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:loginStatus]; // 登录状态
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:logoutAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSString *)plistPath
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    
    // 拼接文件的完整路径
    NSString *filePatch = [path stringByAppendingPathComponent:@"searchRecord.plist"];
    return filePatch;
}

@end
