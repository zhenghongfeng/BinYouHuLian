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
    
    self.title = @"添加朋友";
    
    
}
- (IBAction)addBuddy:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    
    if (self.userName.text.length == 0) {
        hud.labelText = @"账号不能为空";
    }
    
    // 发送加好友申请
    EMError *error = [[EMClient sharedClient].contactManager addContact:_userName.text message:@"我想加您为好友"];
    if (!error) {
        NSLog(@"添加成功");
        hud.labelText = @"添加成功";
    } else {
        NSLog(@"如果您已经发过，并且对方没有处理，您将不能再次发送");
    }
    [hud hide:YES afterDelay:1.5];
}

#pragma mark - UITextFieldDelegate


@end
