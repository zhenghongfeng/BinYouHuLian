//
//  BYAddBuddyViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/25.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYAddBuddyViewController.h"

@interface BYAddBuddyViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userName;
@end

@implementation BYAddBuddyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加朋友";
    
    
}
- (IBAction)addBuddy:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.userName.text.length == 0) {
        hud.labelText = @"账号不能为空";
    }
    
    //1.获取文件路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docPath stringByAppendingPathComponent:@"loginUser.archiver"];
    NSLog(@"path=%@",path);
    
    //2.从文件中读取对象
    BYLoginUser *loginUser = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    NSDictionary *dic = @{
                          @"friendName": self.userName.text,
                          @"username": loginUser.phone
                          };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"access_token"] forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYUrl_dev stringByAppendingString:@"/ease/users/addfriend?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"添加成功";
            [hud hide:YES afterDelay:1];
            
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
    [hud hide:YES];
    
    // 发送加好友申请
//    EMError *error = [[EMClient sharedClient].contactManager addContact:_userName.text message:@"我想加您为好友"];
//    if (!error) {
//        NSLog(@"添加成功");
//        hud.labelText = @"添加成功";
//    } else {
//        NSLog(@"如果您已经发过，并且对方没有处理，您将不能再次发送");
//    }
//    [hud hide:YES afterDelay:1.5];
}

#pragma mark - UITextFieldDelegate


@end
