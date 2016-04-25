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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
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
 *  注册
 */
- (IBAction)registerAction {
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = @"验证码已发送";
//    hud.mode= MBProgressHUDModeText;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    });
    
    NSString *username = self.phoneNumberTextField.text;
    NSString *password = self.verCodeTestField.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (username.length == 0) {
        hud.labelText = @"请输入账号";
        hud.mode = MBProgressHUDModeText;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    if (password.length == 0) {
        hud.labelText = @"请输入密码";
        hud.mode = MBProgressHUDModeText;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    // 注册模式分两种，开放注册和授权注册。只有开放注册时，才可以客户端注册。开放注册是为了测试使用，正式环境中不推荐使用该方式注册环信账号， 授权注册的流程应该是您服务器通过环信提供的rest api注册，之后保存到您的服务器或返回给客户端
    EMError *error = [[EMClient sharedClient] registerWithUsername:username password:password];
    if (error == nil) {
        NSLog(@"注册成功");
        hud.labelText = @"注册成功";
        hud.mode= MBProgressHUDModeText;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    } else {
        NSLog(@"注册失败 %@",error);
        hud.labelText = @"注册失败";
        hud.mode= MBProgressHUDModeText;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }
    
}
/**
 *  登录
 */
- (IBAction)login {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([_phoneNumberTextField.text isEqualToString:@""]) {
        hud.labelText = @"请输入账号";
        hud.mode= MBProgressHUDModeText;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    if ([_verCodeTestField.text isEqualToString:@""]) {
        hud.labelText = @"请输入密码";
        hud.mode= MBProgressHUDModeText;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    
    NSString *username = self.phoneNumberTextField.text;
    NSString *password = self.verCodeTestField.text;
    
    BOOL isAutoLogin = [EMClient sharedClient].options.isAutoLogin;
    if (!isAutoLogin) {
        hud.mode = MBProgressHUDModeIndeterminate;
        EMError *error = [[EMClient sharedClient] loginWithUsername:username password:password];
        if (!error) {
            NSLog(@"登陆成功");
            // 自动登录：即首次登录成功后，不需要再次调用登录方法，在下次app启动时，SDK会自动为您登录。并且如果您自动登录失败，也可以读取到之前的会话信息。
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
//                // 本地缓存
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:loginStatus];
                
                [self.view endEditing:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            
            
        } else {
            hud.labelText = @"登录失败";
            hud.mode = MBProgressHUDModeText;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    }
    
    // yes：登录成功  no:登录失败
//    BOOL isLogin = YES;
//    
//    if (isLogin) {
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            
//            // 本地缓存
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:loginStatus];
//            
//            [self.view endEditing:YES];
//            [self dismissViewControllerAnimated:YES completion:nil];
//        });
//        
//    } else {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
//            hud.labelText = @"登录失败";
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//        });
//    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}
@end
