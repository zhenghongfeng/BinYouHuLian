//
//  MBProgressHUD+BYCategory.m
//  BinYouHuLian
//
//  Created by zhf on 16/7/27.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "MBProgressHUD+BYCategory.h"

@implementation MBProgressHUD (BYCategory)


+ (void)showModeText:(NSString *)text view:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}

@end
