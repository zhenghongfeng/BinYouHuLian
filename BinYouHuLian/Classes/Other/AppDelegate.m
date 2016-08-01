//
//  AppDelegate.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/7.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+BYEaseMob.h"
#import "BYNavigationController.h"
#import "BYHomePageViewController.h"

#define EaseMobAppKey @"binyou#binyouapp"

#ifdef DEBUG
#define APNSCerName @"aps_development"
#else
#define APNSCerName @"aps_distribution"
#endif

@interface AppDelegate () <EMClientDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    BYHomePageViewController *vc = [BYHomePageViewController new];
    self.window.rootViewController = [[BYNavigationController alloc] initWithRootViewController:vc];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    [self by_easemobApplication:application didFinishLaunchingWithOptions:launchOptions appkey:EaseMobAppKey apnsCertName:APNSCerName otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    return YES;
}

#pragma mark - UIApplicationDelegate

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

// App进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

// App将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

// 申请处理时间
- (void)applicationWillTerminate:(UIApplication *)application {
    
//    [[EaseMob sharedInstance] applicationWillTerminate:application];
}



@end
