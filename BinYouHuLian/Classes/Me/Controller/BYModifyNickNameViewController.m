//
//  BYModifyNickNameViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/1.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYModifyNickNameViewController.h"
#import "UserCacheManager.h"

@interface BYModifyNickNameViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nickNameTextField;

@end

@implementation BYModifyNickNameViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"昵称";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightTopDoneClick)];
    
    _nickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 74, self.view.width, 44)];
    _nickNameTextField.backgroundColor = [UIColor whiteColor];
    _nickNameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
    _nickNameTextField.leftViewMode = UITextFieldViewModeAlways;
    _nickNameTextField.text = self.nickNameString;
    _nickNameTextField.clearButtonMode = UITextFieldViewModeAlways;
    [_nickNameTextField becomeFirstResponder];
    _nickNameTextField.placeholder = @"请输入昵称";
    _nickNameTextField.delegate = self;
    [_nickNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_nickNameTextField];
    
}
#pragma mark - 导航栏右侧按钮点击事件
- (void)rightTopDoneClick
{
    if (_nickNameTextField.text.length == 0) {
        [MBProgressHUD showModeText:@"请输入昵称" view:self.view];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic = @{
                          @"phone": GetPhone,
                          @"nickname": _nickNameTextField.text
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/nickname?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            SaveNickName(_nickNameTextField.text);
            [UserCacheManager saveInfo:GetPhone imgUrl:[@"http://123.56.186.178/api/download/img?path=" stringByAppendingString:GetAvatar] nickName:GetNickName];
            [self.navigationController popViewControllerAnimated:YES];
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

- (void)textFieldDidChange:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 11) {
                textField.text = [toBeString substringToIndex:11];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 11) {
            textField.text = [toBeString substringToIndex:11];
        }
    }
}

@end
