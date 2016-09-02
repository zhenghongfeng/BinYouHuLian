//
//  BYModifyNickNameViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/1.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYModifyNickNameViewController.h"
#import "UserCacheManager.h"

@interface BYModifyNickNameViewController () <UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITextField *nickNameTextField;

@end

@implementation BYModifyNickNameViewController

#pragma mark - getter

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableHeaderView = ({
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
            [headerView addSubview:self.nickNameTextField];
            headerView;
        });
    }
    return _tableView;
}

- (UITextField *)nickNameTextField
{
    if (_nickNameTextField == nil) {
        _nickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 44)];
        _nickNameTextField.backgroundColor = [UIColor whiteColor];
        _nickNameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
        _nickNameTextField.leftViewMode = UITextFieldViewModeAlways;
        _nickNameTextField.text = self.nickNameString;
        _nickNameTextField.clearButtonMode = UITextFieldViewModeAlways;
        _nickNameTextField.placeholder = @"请输入昵称";
        _nickNameTextField.delegate = self;
        _nickNameTextField.tintColor = [UIColor blackColor];
        [_nickNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_nickNameTextField becomeFirstResponder];
    }
    return _nickNameTextField;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"昵称";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightTopDoneClick)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark 键盘显示的监听方法

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    
    //获取键盘开始的frame
    NSValue *heightValue = info[UIKeyboardFrameBeginUserInfoKey];
    
    //将heightValue转化成cgRectValue   在获取size  在获取高度
    CGFloat height = [heightValue CGRectValue].size.height;
    
    self.tableView.height = self.view.height - height;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.tableView.height = self.view.height;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}
#pragma mark - 导航栏右侧按钮点击事件

- (void)rightTopDoneClick
{
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
            [UserCacheManager saveInfo:GetPhone imgUrl:GetAvatar nickName:GetNickName];
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
    if ([textField.text isEqualToString:self.nickNameString] || textField.text.length == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    NSString *toBeString = textField.text;
    NSString *lang = textField.textInputMode.primaryLanguage; // 键盘输入模式
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
        else {
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else {
        if (toBeString.length > 11) {
            textField.text = [toBeString substringToIndex:11];
        }
    }
}

@end
