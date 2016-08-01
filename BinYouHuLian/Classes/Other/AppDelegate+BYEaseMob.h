//
//  AppDelegate+BYEaseMob.h
//  BinYouHuLian
//
//  Created by zhf on 16/7/31.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (BYEaseMob)

- (void)by_easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig;

@end
