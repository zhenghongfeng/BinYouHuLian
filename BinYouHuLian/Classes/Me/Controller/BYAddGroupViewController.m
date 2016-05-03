//
//  BYAddGroupViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/29.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYAddGroupViewController.h"

@interface BYAddGroupViewController ()

@end

@implementation BYAddGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EMError *error = nil;
    EMGroupOptions *setting = [[EMGroupOptions alloc] init];
    setting.maxUsersCount = 500;
    setting.style = EMGroupStylePublicOpenJoin;// 创建不同类型的群组，这里需要才传入不同的类型
    EMGroup *group = [[EMClient sharedClient].groupManager createGroupWithSubject:@"宾友互联群" description:@"群组描述" invitees:@[@"111",@"wuzong"] message:@"邀请您加入群组" setting:setting error:&error];
    if(!error){
        NSLog(@"创建成功 -- %@",group);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
