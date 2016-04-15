//
//  BYRegisterViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/7.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYRegisterViewController.h"

@interface BYRegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@property (weak, nonatomic) IBOutlet UITextField *verCodeTestField;
@end
@implementation BYRegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
    [self.phoneNumberTextField becomeFirstResponder];
}
/**
 *  返回
 */
- (IBAction)Back {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 *  获取验证码
 */
- (IBAction)getVerCode {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"验证码已发送";
    hud.mode= MBProgressHUDModeText;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}
/**
 *  登录
 */
- (IBAction)login {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([_phoneNumberTextField.text isEqualToString:@""]) {
        hud.labelText = @"请输入手机号";
        hud.mode= MBProgressHUDModeText;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    if ([_verCodeTestField.text isEqualToString:@""]) {
        hud.labelText = @"请输入验证码";
        hud.mode= MBProgressHUDModeText;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    
    
    
    
    // yes：登录成功  no:登录失败
    BOOL isLogin = YES;
    
    if (isLogin) {
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"正在登录";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            // 本地缓存
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:loginStatus];
            
            [self.view endEditing:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
        
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            hud.labelText = @"登录失败";
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }
    
}
@end
