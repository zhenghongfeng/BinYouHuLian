//
//  BYResetPasswordViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/7/19.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYResetPasswordViewController.h"

@interface BYResetPasswordViewController () <UITextFieldDelegate>

/** back button */
@property (nonatomic, strong) UIButton *backButton;
/** title label */
@property (nonatomic, strong) UILabel *titleLabel;
/** phone textField */
@property (weak, nonatomic) UITextField *phoneTextField;
/** verCode textField */
@property (weak, nonatomic) UITextField *verCodeTextField;
/** verCode button */
@property (nonatomic, strong) UIButton *verCodeButton;
/** ok button */
@property (nonatomic, strong) UIButton *okButton;
/** count on the verCode  */
@property (nonatomic, assign) NSInteger count;
/** timer */
@property (nonatomic, strong) NSTimer *timer;
/** password textField */
@property (nonatomic, strong) UITextField *passwordTextField;
/** affirm password textField */
@property (nonatomic, strong) UITextField *affirmPasswordTextField;
/** pass label */
@property (nonatomic, strong) UILabel *passLabel;

@end

@implementation BYResetPasswordViewController

#pragma mark - lazy load

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
        _titleLabel.text = @"重置密码";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
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
        phoneTextField.tintColor = [UIColor blackColor];
        _phoneTextField = phoneTextField;
    }
    return _phoneTextField;
}

- (UITextField *)verCodeTextField
{
    if (_verCodeTextField == nil) {
        UITextField *verCodeTextField = [[UITextField alloc] init];
        verCodeTextField.borderStyle = UITextBorderStyleRoundedRect;
        verCodeTextField.placeholder = @"验证码";
        verCodeTextField.tintColor = [UIColor blackColor];
        verCodeTextField.rightViewMode = UITextFieldViewModeAlways;
        verCodeTextField.rightView = ({
            _verCodeButton = [[UIButton alloc] init];
            _verCodeButton.frame = CGRectMake(0, 0, 140, 40);
            [_verCodeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
            [_verCodeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _verCodeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [_verCodeButton addTarget:self action:@selector(resetPasswordVerCodeClick) forControlEvents:UIControlEventTouchUpInside];
            _verCodeButton;
        });
        _verCodeTextField = verCodeTextField;
    }
    return _verCodeTextField;
}

- (UITextField *)passwordTextField
{
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
        _passwordTextField.placeholder = @"新密码(不少于八位)";
        _passwordTextField.tintColor = [UIColor blackColor];
        _passwordTextField.delegate = self;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _passwordTextField;
}

- (UITextField *)affirmPasswordTextField
{
    if (_affirmPasswordTextField == nil) {
        _affirmPasswordTextField = [[UITextField alloc] init];
        _affirmPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
        _affirmPasswordTextField.placeholder = @"确认密码(请再次输入以上密码)";
        _affirmPasswordTextField.tintColor = [UIColor blackColor];
        _affirmPasswordTextField.delegate = self;
        _affirmPasswordTextField.secureTextEntry = YES;
        _affirmPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _affirmPasswordTextField;
}

- (UIButton *)okButton
{
    if (_okButton == nil) {
        _okButton = [UIButton new];
        [_okButton setTitle:@"完成" forState:UIControlStateNormal];
        _okButton.backgroundColor = [UIColor blackColor];
        _okButton.layer.masksToBounds = YES;
        _okButton.layer.cornerRadius = 5;
        [_okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.phoneTextField];
    [self.view addSubview:self.verCodeTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.affirmPasswordTextField];
    [self.view addSubview:self.okButton];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetPasswordVerCodeClick
{
    if (self.phoneTextField.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入手机号码";
        [hud hide:YES afterDelay:1];
        return;
    }
    if (![NSString validatePhone:self.phoneTextField.text]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入正确的手机号码";
        [hud hide:YES afterDelay:1];
        return;
    }
    _count = 60;
    NSString *str = [NSString stringWithFormat:@"%2zd秒后重新发送", _count];
    [_verCodeButton setTitle:str forState:UIControlStateNormal];
    
    NSDictionary *dic = @{@"phone": self.phoneTextField.text};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[BYURL_Development stringByAppendingString:@"/sms/send?"] parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [_verCodeTextField becomeFirstResponder];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}

- (void)timerFired
{
    _verCodeButton.enabled = NO;
    _count--;
    if (_count == 0) {
        [_timer invalidate];
        _verCodeButton.enabled = YES;
        [_verCodeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
        return;
    }
    NSString *str = [NSString stringWithFormat:@"%02zd秒后重新发送", _count];
    [_verCodeButton setTitle:str forState:UIControlStateNormal];
}

- (void)okButtonClick
{
    if (self.phoneTextField.text.length == 0) {
        [MBProgressHUD showModeText:@"请输入手机号码" view:self.view];
        return;
    }
    if (self.verCodeTextField.text.length == 0) {
        [MBProgressHUD showModeText:@"请输入验证码" view:self.view];
        return;
    }
    if (self.passwordTextField.text.length < 8) {
        [MBProgressHUD showModeText:@"请输入大于八位密码" view:self.view];
        return;
    }
    if (![self.affirmPasswordTextField.text isEqualToString:self.passwordTextField.text]) {
        [MBProgressHUD showModeText:@"两次输入密码不一致" view:self.view];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *dic = @{
                          @"istest": BYVcode,
                          @"phone": self.phoneTextField.text,
                          @"password": [NSString md5:self.passwordTextField.text],
                          @"vcode": self.verCodeTextField.text
                          };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[BYURL_Development stringByAppendingString:@"/user/forget?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [hud hide:YES];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.passwordTextField) {
        if (self.passwordTextField.text.length == 0) {
            return;
        }
        if (self.passwordTextField.text.length < 8) {
            _passwordTextField.rightViewMode = UITextFieldViewModeAlways;
            self.passwordTextField.rightView = ({
                _passLabel = [[UILabel alloc] init];
                _passLabel.frame = CGRectMake(0, 0, 110, 40);
                _passLabel.text = @"密码至少八位";
                _passLabel.textColor = [UIColor redColor];
                _passLabel;
            });
        } else {
            _passwordTextField.rightViewMode = UITextFieldViewModeNever;
        }
    }
    
    if (textField == self.affirmPasswordTextField) {
        if (self.affirmPasswordTextField.text.length > 0) {
            if (![self.affirmPasswordTextField.text isEqualToString:self.passwordTextField.text]) {
                [MBProgressHUD showModeText:@"两次输入密码不一致" view:self.view];
                return;
            }
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - autoLayout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
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
    
    _verCodeTextField.sd_layout
    .leftSpaceToView(self.view, 20)
    .topSpaceToView(self.phoneTextField, 10)
    .widthIs(self.view.width - 40)
    .heightIs(40);
    
    _passwordTextField.sd_layout
    .leftSpaceToView(self.view, 20)
    .topSpaceToView(_verCodeTextField, 10)
    .widthIs(self.view.width - 40)
    .heightIs(40);
    
    _affirmPasswordTextField.sd_layout
    .leftSpaceToView(self.view, 20)
    .topSpaceToView(_passwordTextField, 10)
    .widthIs(self.view.width - 40)
    .heightIs(40);
    
    _okButton.sd_layout
    .centerXIs(self.view.centerX)
    .topSpaceToView(_affirmPasswordTextField, 20)
    .widthIs(130)
    .heightIs(40);
}

@end
