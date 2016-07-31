//
//  BYLoginViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/7/18.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYLoginViewController.h"
#import "BYResetPasswordViewController.h"

@interface BYLoginViewController ()

/** back button */
@property (nonatomic, strong) UIButton *backButton;
/** title label */
@property (nonatomic, strong) UILabel *titleLabel;
/** phone textField */
@property (nonatomic, strong) UITextField *phoneTextField;
/** password textField */
@property (nonatomic, strong) UITextField *passwordTextField;
/** login button */
@property (nonatomic, strong) UIButton *loginButton;
/** register button */
@property (nonatomic, strong) UIButton *registerButton;
/** forget password button */
@property (nonatomic, strong) UIButton *forgetPasswordButton;


@end

@implementation BYLoginViewController

- (UIButton *)backButton
{
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] init];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"myback"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"登录";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithRed:0.96f green:0.78f blue:0.00f alpha:1.00f];
    }
    return _titleLabel;
}

- (UITextField *)phoneTextField
{
    if (_phoneTextField == nil) {
        UITextField *phoneTextField = [[UITextField alloc] init];
        phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
        phoneTextField.placeholder = @"手机号码";
        phoneTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        phoneTextField.tintColor = [UIColor colorWithRed:0.96f green:0.78f blue:0.00f alpha:1.00f];
        _phoneTextField = phoneTextField;
    }
    return _phoneTextField;
}

- (UITextField *)passwordTextField
{
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
        _passwordTextField.placeholder = @"密码";
        _passwordTextField.tintColor = [UIColor colorWithRed:0.96f green:0.78f blue:0.00f alpha:1.00f];
        _passwordTextField.secureTextEntry = YES;
    }
    return _passwordTextField;
}

- (UIButton *)loginButton
{
    if (_loginButton == nil) {
        _loginButton = [UIButton new];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        _loginButton.backgroundColor = [UIColor colorWithRed:0.96f green:0.78f blue:0.00f alpha:1.00f];
        _loginButton.layer.masksToBounds = YES;
        _loginButton.layer.cornerRadius = 5;
        [_loginButton addTarget:self action:@selector(loginCLick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (UIButton *)registerButton
{
    if (_registerButton == nil) {
        _registerButton = [UIButton new];
        [_registerButton setTitle:@"注册新账号" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_registerButton addTarget:self action:@selector(registerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

- (UIButton *)forgetPasswordButton
{
    if (_forgetPasswordButton == nil) {
        _forgetPasswordButton = [UIButton new];
        [_forgetPasswordButton setTitle:@"忘记密码" forState:UIControlStateNormal];
        [_forgetPasswordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_forgetPasswordButton addTarget:self action:@selector(forgetPasswordClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgetPasswordButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.phoneTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.registerButton];
    [self.view addSubview:self.forgetPasswordButton];
    
    [self setupAutoLayout];
}

- (void)loginCLick
{
    if (self.phoneTextField.text.length == 0) {
        [MBProgressHUD showModeText:@"请输入手机号码" view:self.view];
        return;
    }
    if (![NSString validatePhone:self.phoneTextField.text]) {
        [MBProgressHUD showModeText:@"请输入正确的手机号码" view:self.view];
        return;
    }
    if (self.passwordTextField.text.length == 0) {
        [MBProgressHUD showModeText:@"请输入密码" view:self.view];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"登录中...";
    
    NSString *phone = self.phoneTextField.text;
    NSString *password = [NSString md5:self.passwordTextField.text];
    
    NSDictionary *dic = @{
                          @"phone": phone,
                          @"password": password
                          };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[BYUrl_dev stringByAppendingString:@"/user/login?"] parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [hud hide:YES];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:responseObject[@"access_token"] forKey:@"access_token"];
            [userDefaults synchronize];
            
            EMError *error = [[EMClient sharedClient] loginWithUsername:phone password:password];
            
            if (!error) {
                NSLog(@"登录成功");
                [[EMClient sharedClient].options setIsAutoLogin:YES];
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                EMError *error = nil;
                EMPushOptions *options = [[EMClient sharedClient] getPushOptionsFromServerWithError:&error];
                
                NSLog(@"push error ========= %@", error.errorDescription);
                
                [[EMClient sharedClient] setApnsNickname:@"宾友"];
                
                options.displayStyle = EMPushDisplayStyleMessageSummary;
                
                options.noDisturbStatus = EMPushNoDisturbStatusClose;
                //        options.noDisturbingStartH = 23;
                //        options.noDisturbingEndH = 4;
                EMError *resultError = [[EMClient sharedClient] updatePushOptionsToServer];
                if (!resultError) {
                    NSLog(@"APNS属性设置成功");
                }
            });
            
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"登录失败";
            [hud hide:YES afterDelay:1];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"登录失败";
        [hud hide:YES afterDelay:1];
    }];
}

- (void)registerClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)forgetPasswordClick
{
    BYResetPasswordViewController *vc = [BYResetPasswordViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - autoLayout

- (void)setupAutoLayout
{
    _backButton.sd_layout
    .leftSpaceToView(self.view, 20)
    .topSpaceToView(self.view, 20)
    .widthIs(25)
    .heightIs(25);
    
    _titleLabel.sd_layout
    .centerXIs(self.view.centerX)
    .topSpaceToView(self.view, 20)
    .widthIs(200)
    .heightIs(25);
    
    _phoneTextField.sd_layout
    .leftSpaceToView(self.view, 20)
    .topSpaceToView(_titleLabel, 20)
    .widthIs(self.view.width - 40)
    .heightIs(40);
    
    _passwordTextField.sd_layout
    .leftSpaceToView(self.view, 20)
    .topSpaceToView(self.phoneTextField, 10)
    .widthIs(self.view.width - 40)
    .heightIs(40);
    
    _loginButton.sd_layout
    .centerXIs(self.view.centerX)
    .topSpaceToView(_passwordTextField, 20)
    .widthIs(150)
    .heightIs(40);
    
    _registerButton.sd_layout
    .centerXIs(self.view.centerX)
    .bottomSpaceToView(self.view, 20)
    .widthIs(100)
    .heightIs(40);
    
    _forgetPasswordButton.sd_layout
    .rightEqualToView(_passwordTextField)
    .topSpaceToView(_passwordTextField, 5)
    .widthIs(80)
    .heightIs(30);
    
}




@end
