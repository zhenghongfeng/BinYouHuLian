//
//  BYUserInfoSettingViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/9/2.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYUserInfoSettingViewController.h"

#import "BYUserInfoSettingTableViewCell.h"

#import "BYFriend.h"

@interface BYUserInfoSettingViewController () <UITableViewDataSource, UITableViewDelegate>

/** tableView */
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BYUserInfoSettingViewController

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"资料设置";
    
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    BYUserInfoSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[BYUserInfoSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = @"加入黑名单";
    [cell.mySwitch addTarget:self action:@selector(mySwitchChange:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

#pragma mark - UITableViewDataDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)mySwitchChange:(UISwitch *)mySwitch
{
    if (mySwitch.on) {
        NSLog(@"yes");
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"加入黑名单，你将不再收到对方的消息" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSDictionary *dic = @{
                                  @"id": GetPhone,
                                  @"blackIds": self.myFriend.phone,
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
                } else {
                    [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"error = %@", error.localizedDescription);
                [hud hide:YES];
                [MBProgressHUD showModeText:error.localizedDescription view:self.view];
            }];
        }];
        [alertVC addAction:okAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            mySwitch.on = NO;
        }];
        [alertVC addAction:cancelAction];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    } else {
        NSLog(@"no");
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSDictionary *dic = @{
                              @"userId": GetPhone,
                              @"blackIds": self.myFriend.phone,
                              @"isgroup": @"0"
                              };
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
        [manager POST:[BYURL_Development stringByAppendingString:@"/ease/black/remove?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject = %@", responseObject);
            [hud hide:YES];
            NSInteger code = [responseObject[@"code"] integerValue];
            if (code == 1) {
                [MBProgressHUD showModeText:@"已移除黑名单" view:self.view];
            } else {
                [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@", error.localizedDescription);
            [hud hide:YES];
            [MBProgressHUD showModeText:error.localizedDescription view:self.view];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
