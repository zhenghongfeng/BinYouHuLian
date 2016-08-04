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
    
    self.navigationItem.title = @"添加朋友";
    
    
}
- (IBAction)addBuddy:(id)sender {
    
    if (self.userName.text.length == 0) {
        [MBProgressHUD showModeText:@"账号不能为空" view:self.view];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic = @{
                          @"friendName": self.userName.text,
                          @"username": GetPhone
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/addfriend?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"添加成功";
            [hud hide:YES afterDelay:1];
        } else {
            [hud hide:YES];
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [hud hide:YES];
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}

#pragma mark - UITextFieldDelegate


@end
