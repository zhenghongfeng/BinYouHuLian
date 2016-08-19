//
//  BYApplyReasonViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/5.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYApplyReasonViewController.h"
#import "BYMyBuddyListViewController.h"

@interface BYApplyReasonViewController () <UITextViewDelegate>

/** textView */
@property (nonatomic, strong) UITextView *textView;

/** send */
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation BYApplyReasonViewController

- (UITextView *)textView
{
    if (_textView == nil) {
        _textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 5;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.borderColor = [UIColor grayColor].CGColor;
        _textView.tintColor = [UIColor blackColor];
        _textView.contentMode = UIViewContentModeTopLeft;
    }
    return _textView;
}

- (UIButton *)sendButton
{
    if (_sendButton == nil) {
        _sendButton = [UIButton new];
        _sendButton.backgroundColor = [UIColor blackColor];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _sendButton.layer.masksToBounds = YES;
        _sendButton.layer.cornerRadius = 10;
    }
    return _sendButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"申请理由";
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.textView];
    [self.view addSubview:self.sendButton];
}

#pragma mark - UITextViewDelegate



#pragma mark - send

- (void)sendButtonClick
{
    NSLog(@"发送");
    if (self.textView.text.length == 0) {
        [MBProgressHUD showModeText:@"请输入申请理由" view:self.view];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic = @{
                          @"friendName": self.userName,
                          @"username": GetPhone,
                          @"reason": self.textView.text
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/apply?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [hud hide:YES];
            _sendButton.backgroundColor = [UIColor grayColor];
            [_sendButton setTitle:@"已发送" forState:UIControlStateNormal];
            _sendButton.enabled = NO;
            [MBProgressHUD showModeText:@"发送成功" view:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                for (UIViewController *controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[BYMyBuddyListViewController class]]) {
                        BYMyBuddyListViewController *vc = (BYMyBuddyListViewController *)controller;
                        [self.navigationController popToViewController:vc animated:YES];
                    }
                }
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

#pragma mark - auto layout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _textView.sd_layout
    .leftSpaceToView(self.view, 10)
    .topSpaceToView(self.navigationController.navigationBar, 10)
    .rightSpaceToView(self.view, 10)
    .heightIs(100);
    
    _sendButton.sd_layout
    .topSpaceToView(_textView, 10)
    .centerXIs(self.view.centerX)
    .widthIs(100)
    .heightIs(30);
}

@end
