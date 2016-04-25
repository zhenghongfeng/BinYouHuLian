//
//  BYAddBlackViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/25.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYAddBlackViewController.h"

@interface BYAddBlackViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;

@end

@implementation BYAddBlackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加黑名单";
    
}


- (IBAction)add:(id)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    
    if (self.userName.text.length == 0) {
        hud.labelText = @"账号不能为空";
    }
    //加入黑名单
    EMError *error = [[EMClient sharedClient].contactManager addUserToBlackList:self.userName.text relationshipBoth:YES];
    if (!error) {
        NSLog(@"发送成功");
        hud.labelText = @"加入成功";
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hide:YES];
    });
}

@end
