//
//  AppDelegate.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/7.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
 #import "EaseMob.h"

#define IMAPPKEY "binyou#binyou"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"%@", NSHomeDirectory()); // 沙盒路径
    
    //registerSDKWithAppKey:注册的appKey，详细见下面注释。
    //apnsCertName:推送证书名(不需要加后缀)，详细见下面注释。
    [[EaseMob sharedInstance] registerSDKWithAppKey:@IMAPPKEY apnsCertName:@"istore_dev"];
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self.window makeKeyAndVisible];
    
    ViewController *vc = [[ViewController alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = nav;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
// App进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

// App将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
// 申请处理时间
- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}

@end
