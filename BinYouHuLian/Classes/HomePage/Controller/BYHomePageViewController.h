//
//  ViewController.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/7.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYHomePageViewController : UIViewController

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;


- (void)jumpToChatVC;

@end

