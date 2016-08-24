//
//  BYSettingViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/13.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYSettingViewController.h"
#import "BYRegisterViewController.h"
#import "BYSettingTableViewCell.h"

@interface BYSettingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) CGFloat cacheSize;

//@property (nonatomic, strong) NSArray *titles1;
//
//@property (nonatomic, strong) NSArray *titles2;
//
//@property (nonatomic, strong) NSArray *titles3;

@end

@implementation BYSettingViewController

#pragma mark - getter
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    
    self.titles = @[@"清理缓存"];
    
    _cacheSize = [self folderSizeAtPath];
    
    NSLog(@"%f", _cacheSize);
    
//    self.titles1 = @[@"账号管理", @"账号安全"];
//    self.titles2 = @[@"通知", @"隐私与安全", @"通用设置"];
//    self.titles3 = @[@"清理缓存", @"意见反馈" ,@"关于宾友"];
    
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        BYSettingTableViewCell *cell = [BYSettingTableViewCell new];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = self.titles[indexPath.row];
        
        cell.rightLabel.text = _cacheSize == 0 ? @"0M" : [NSString stringWithFormat:@"%.2fM", _cacheSize];
        return cell;
    } else {
        UITableViewCell *cell = [UITableViewCell new];
        cell.textLabel.text = @"退出当前账号";
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 去掉cell选中后的效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self cleanCache];
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:logoutAction];
        [self presentViewController:alert animated:YES completion:nil];
    }

    if (indexPath.section == 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
            [manager POST:[BYURL_Development stringByAppendingString:@"/user/logout?"] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"responseObject = %@", responseObject);
                 
                NSInteger code = [responseObject[@"code"] integerValue];
                if (code == 1) {
                    [hud hide:YES];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    EMError *error = [[EMClient sharedClient] logout:YES];
                    if (!error) {
                        NSLog(@"退出成功");
                        SaveToken(nil);
                        SavePhone(nil);
                        SaveNickName(nil);
                        SaveAvatar(nil);
                    }
                } else {
                    [hud hide:YES];
                    [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"error = %@", error.localizedDescription);
                [hud hide:YES];
                [MBProgressHUD showModeText:error.localizedDescription view:self.view];
            }];
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:logoutAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (float)folderSizeAtPath{
    NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    float folderSize;
    if ([fileManager fileExistsAtPath:folderPath]) {
        NSArray *childerFiles = [fileManager subpathsAtPath:folderPath];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath = [folderPath stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:absolutePath];
        }
        //SDWebImage框架自身计算缓存的实现
        folderSize += [[EMSDImageCache sharedImageCache] getSize] / 1024.0 /1024.0;
        return folderSize;
    }
    return 0;
}

- (float)fileSizeAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size / 1024.0 / 1024.0;
    }
    return 0;
}

/**
 *  清理缓存
 */
- (void)cleanCache
{
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在清理缓存...";
    
    //文件路径
    NSString *directoryPath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSArray *subpaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    
    for (NSString *subPath in subpaths) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"缓存已清除";
    [hud hide:YES afterDelay:1.5];
    
    _cacheSize = 0;
    [_tableView reloadData];
    
}


@end
