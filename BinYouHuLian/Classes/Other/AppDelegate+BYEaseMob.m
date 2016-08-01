//
//  AppDelegate+BYEaseMob.m
//  BinYouHuLian
//
//  Created by zhf on 16/7/31.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "AppDelegate+BYEaseMob.h"

@implementation AppDelegate (BYEaseMob)

- (void)by_easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig
{
    application.applicationIconBadgeNumber = 0;
    // 集成环信SDK, AppKey:注册的appKey, apnsCertName:推送证书名(不需要加后缀)
    EMOptions *options = [EMOptions optionsWithAppkey:appkey];
    options.apnsCertName = apnsCertName;
    [[EMClient sharedClient] initializeSDKWithOptions:options];
//    options.isAutoAcceptGroupInvitation = NO;
//    if ([otherConfig objectForKey:kSDKConfigEnableConsoleLogger]) {
//        options.enableConsoleLog = YES;
//    }
//    BOOL sandBox = [otherConfig objectForKey:@"easeSandBox"] && [[otherConfig objectForKey:@"easeSandBox"] boolValue];
//    if (!sandBox) {
//        [[EMClient sharedClient] initializeSDKWithOptions:options];
//    }
    
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
    
    //注册登录状态监听
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(loginStateChange:)
//                                                 name:KNOTIFICATION_LOGINCHANGE
//                                               object:nil];
//    
//    BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
//    if (isAutoLogin){
//        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
//    }
//    else
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
//    }
}

#pragma mark - AppDelegate

// 您注册了推送功能，iOS 会自动回调以下方法，得到deviceToken，您需要将deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
        NSLog(@"deviceToken == %@", deviceToken);
    });
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - login changed

- (void)loginStateChange:(NSNotification *)notification
{
    BOOL loginSuccess = [notification.object boolValue];
    if (loginSuccess) {//登陆成功加载主窗口控制器
        
    } else {//登陆失败加载登陆页面控制器
        
    }
}


#pragma mark - EMPushManagerDelegateDevice

// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                        options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.content", @"Apns content")
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
    
}

@end
