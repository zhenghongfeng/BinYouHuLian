//
//  BYRegisterViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/7.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYRegisterViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "BYRegisterNextStepViewController.h"
#import "BYLoginViewController.h"

@interface BYRegisterViewController ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *verCodeTextField;
@property (nonatomic, strong) UIButton *verCodeButton;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIButton *nextStepButton;
@property (nonatomic, strong) UIButton *loginButton;


@end

@implementation BYRegisterViewController

#pragma mark - lazy load

- (UIButton *)backButton
{
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] init];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"注册新账号";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UITextField *)phoneTextField
{
    if (_phoneTextField == nil) {
        _phoneTextField = [[UITextField alloc] init];
        _phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
        _phoneTextField.placeholder = @"手机号码";
        _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _phoneTextField.tintColor = [UIColor blackColor];
    }
    return _phoneTextField;
}

- (UITextField *)verCodeTextField
{
    if (_verCodeTextField == nil) {
        _verCodeTextField = [[UITextField alloc] init];
        _verCodeTextField.borderStyle = UITextBorderStyleRoundedRect;
        _verCodeTextField.placeholder = @"验证码";
        _verCodeTextField.rightViewMode = UITextFieldViewModeAlways;
        _verCodeTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _verCodeTextField.tintColor = [UIColor blackColor];
        _verCodeTextField.rightView = ({
            _verCodeButton = [[UIButton alloc] init];
            _verCodeButton.frame = CGRectMake(0, 0, 140, 40);
            [_verCodeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
            [_verCodeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _verCodeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [_verCodeButton addTarget:self action:@selector(verCodeClick) forControlEvents:UIControlEventTouchUpInside];
            _verCodeButton;
        });
    }
    return _verCodeTextField;
}

- (UIButton *)nextStepButton
{
    if (_nextStepButton == nil) {
        _nextStepButton = [UIButton new];
        [_nextStepButton setTitle:@"下一步" forState:UIControlStateNormal];
        _nextStepButton.backgroundColor = [UIColor blackColor];
        _nextStepButton.layer.masksToBounds = YES;
        _nextStepButton.layer.cornerRadius = 5;
        [_nextStepButton addTarget:self action:@selector(nextStepButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextStepButton;
}

- (UIButton *)loginButton
{
    if (_loginButton == nil) {
        _loginButton = [UIButton new];
        [_loginButton setTitle:@"已有账号" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.phoneTextField];
    [self.view addSubview:self.verCodeTextField];
    [self.view addSubview:self.nextStepButton];
    [self.view addSubview:self.loginButton];
}

- (void)verCodeClick
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
    
    NSDictionary *dic = @{@"phone": self.phoneTextField.text,
                          @"istest": @"0"
                          };
    
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

- (void)nextStepButtonClick
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
    if (self.verCodeTextField.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入验证码";
        [hud hide:YES afterDelay:1];
        return;
    }
    BYRegisterNextStepViewController *vc = [BYRegisterNextStepViewController new];
    vc.phone = self.phoneTextField.text;
    vc.verCode = self.verCodeTextField.text;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  返回
 */
- (void)back {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginClick
{
    BYLoginViewController *vc = [BYLoginViewController new];
    [self.navigationController pushViewController:vc animated:YES];
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
    
    _nextStepButton.sd_layout
    .centerXIs(self.view.centerX)
    .topSpaceToView(_verCodeTextField, 20)
    .widthIs(130)
    .heightIs(40);
    
    _loginButton.sd_layout
    .centerXIs(self.view.centerX)
    .bottomSpaceToView(self.view, 20)
    .widthIs(100)
    .heightIs(40);
}

- (void)dealloc
{
    [_timer invalidate];
}

@end
