//
//  BYRegisterNextStepViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/7/18.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYRegisterNextStepViewController.h"
#import "UserCacheManager.h"

@interface BYRegisterNextStepViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

/** back button */
@property (nonatomic, strong) UIButton *backButton;
/** title label */
@property (nonatomic, strong) UILabel *titleLabel;
/** avatar button */
@property (nonatomic, strong) UIButton *avatarButton;
/** nickname textField */
@property (nonatomic, strong) UITextField *nicknameTextField;
/** password textField */
@property (nonatomic, strong) UITextField *passwordTextField;
/** affirm password textField */
@property (nonatomic, strong) UITextField *affirmPasswordTextField;
/** ok button */
@property (nonatomic, strong) UIButton *okButton;
/** pass label */
@property (nonatomic, strong) UILabel *passLabel;

@end

@implementation BYRegisterNextStepViewController

#pragma mark - lazy load

- (UIButton *)backButton
{
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] init];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"myback"] forState:UIControlStateNormal];
        _backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
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

- (UIButton *)avatarButton
{
    if (_avatarButton == nil) {
        _avatarButton = [UIButton new];
        [_avatarButton setBackgroundImage:[UIImage imageNamed:@"addAvatar"] forState:UIControlStateNormal];
        [_avatarButton addTarget:self action:@selector(addAvatarClick) forControlEvents:UIControlEventTouchUpInside];
        _avatarButton.layer.masksToBounds = YES;
        _avatarButton.layer.cornerRadius = 40;
        _avatarButton.backgroundColor = [UIColor grayColor];
    }
    return _avatarButton;
}

- (UITextField *)nicknameTextField
{
    if (_nicknameTextField == nil) {
        _nicknameTextField = [[UITextField alloc] init];
        _nicknameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _nicknameTextField.placeholder = @"昵称(必填)";
        _nicknameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nicknameTextField.tintColor = [UIColor blackColor];
    }
    return _nicknameTextField;
}

- (UITextField *)passwordTextField
{
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
        _passwordTextField.placeholder = @"密码(不少于八位)";
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.tintColor = [UIColor blackColor];
        _passwordTextField.delegate = self;
    }
    return _passwordTextField;
}

- (UITextField *)affirmPasswordTextField
{
    if (_affirmPasswordTextField == nil) {
        _affirmPasswordTextField = [[UITextField alloc] init];
        _affirmPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
        _affirmPasswordTextField.placeholder = @"确认密码(请再次输入以上密码)";
        _affirmPasswordTextField.secureTextEntry = YES;
        _affirmPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _affirmPasswordTextField.tintColor = [UIColor blackColor];
        _affirmPasswordTextField.delegate = self;
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
    [self.view addSubview:self.avatarButton];
    [self.view addSubview:self.nicknameTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.affirmPasswordTextField];
    [self.view addSubview:self.okButton];    
}

- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addAvatarClick
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:0];
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    UIAlertAction *photo = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    // 用来判断来源 Xcode中的模拟器是没有拍摄功能的,当用模拟器的时候我们不需要把拍照功能加速
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertController addAction:photo];
        [alertController addAction:camera];
        [alertController addAction:cancel];
    } else {
        [alertController addAction:photo];
        [alertController addAction:cancel];
    }
}

//这个是选取完照片后要执行的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    //选取裁剪后的图片
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    [self.avatarButton setBackgroundImage:image forState:UIControlStateNormal];
    
}


- (void)okButtonClick
{
    if (_nicknameTextField.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入昵称";
        [hud hide:YES afterDelay:1];
        return;
    }
    if (self.passwordTextField.text.length < 8) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入大于八位密码";
        [hud hide:YES afterDelay:1];
        return;
    }
    if (![self.affirmPasswordTextField.text isEqualToString:self.passwordTextField.text]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"两次输入密码不一致";
        [hud hide:YES afterDelay:1];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"注册中...";
    
    NSString *password = [NSString md5:self.passwordTextField.text];
    NSDictionary *dic = @{@"phone": self.phone,
                          @"password": password,
                          @"nickname": self.nicknameTextField.text,
                          @"vcode": self.verCode
                          };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[BYURL_Development stringByAppendingString:@"/user/regist?"] parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //单张图片
        UIImage *image = self.avatarButton.currentBackgroundImage;//获得一张Image
        NSData *data = UIImageJPEGRepresentation(image, 0.7);//将UIImage转为NSData，1.0表示不压缩图片质量。
        [formData appendPartWithFileData:data name:@"avatar" fileName:@"test.jpg" mimeType:@"image/jpeg"];
        
        /*
         Data: 要上传的二进制数据
         name:保存在服务器上时用的Key值
         fileName:保存在服务器上时用的文件名,注意要加 .jpg或者.png
         mimeType:让服务器知道我上传的是哪种类型的文件
         */
        /*
        //多张图片
        NSArray *images = self.photos;//获得一组Image
        for(NSInteger i = 0; i < self.images.count; i++)
        {
            // 取出图片
            UIImage *image = [images objectAtIndex:i];
            // 转成二进制
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            // 上传的参数名
            NSString * Name = [NSString stringWithFormat:@"image %ld", i];
            // 上传fileName
            NSString * fileName = [NSString stringWithFormat:@"%@.jpg", Name];
            
            [formData appendPartWithFileData:imageData name:Name fileName:fileName mimeType:@"image/jpeg"];
        }
         */
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            // async login EM
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                EMError *error = [[EMClient sharedClient] loginWithUsername:self.phone password:password];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        NSLog(@"环信登录成功");
                        // save token and userInfo(phone\nickname\avatar)
                        SaveToken(responseObject[@"access_token"]);
                        SavePhone([responseObject[@"user"] valueForKey:@"phone"]);
                        SaveNickName([responseObject[@"user"] valueForKey:@"nickname"]);
                        SaveAvatar([responseObject[@"user"] valueForKey:@"avatar"]);
                        
                        // 保存用户信息
                        
                        [UserCacheManager saveInfo:GetPhone imgUrl:GetAvatar nickName:GetNickName];
                        
                        // set auto login
                        [[EMClient sharedClient].options setIsAutoLogin:YES];
                        [[EMClient sharedClient].pushOptions setDisplayStyle:EMPushDisplayStyleMessageSummary];
                        [[EMClient sharedClient].pushOptions setNickname:GetNickName];
                        [[EMClient sharedClient] updatePushOptionsToServer];
                        
                        // dismissVC
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                        [hud hide:YES];
                        
                        [self requestTokenRecord];
                    } else {
                        [hud hide:YES];
                        [MBProgressHUD showModeText:@"登录异常" view:self.view];
                    }
                });
            });
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

- (void)requestTokenRecord
{
    NSDictionary *dic = @{
                          @"phone": self.phone,
                          @"deviceId": [[UIDevice currentDevice] identifierForVendor].UUIDString,
                          @"osVersion": [[UIDevice currentDevice] systemVersion],
                          @"appVersion": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                          @"deviceName": [[UIDevice currentDevice] model]
                          };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/device/record?"] parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
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
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"两次输入密码不一致";
                [hud hide:YES afterDelay:1];
                return;
            }
        }
    }
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
    
    _avatarButton.sd_layout
    .centerXIs(self.view.centerX)
    .topSpaceToView(_titleLabel, 20)
    .widthIs(80)
    .heightIs(80);
    
    _nicknameTextField.sd_layout
    .leftSpaceToView(self.view, 20)
    .topSpaceToView(_avatarButton, 20)
    .widthIs(self.view.width - 40)
    .heightIs(40);
    
    _passwordTextField.sd_layout
    .leftSpaceToView(self.view, 20)
    .topSpaceToView(_nicknameTextField, 10)
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
