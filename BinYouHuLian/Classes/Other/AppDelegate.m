//
//  AppDelegate.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/7.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "AppDelegate.h"
#import "BYNavigationController.h"
#import "BYHomePageViewController.h"

#define IMAPPKEY @"binyou#binyouapp"
#define IMAPNsCertName @"aps_development"

@interface AppDelegate () <EMClientDelegate, EMContactManagerDelegate, EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    BYHomePageViewController *vc = [BYHomePageViewController new];
    self.window.rootViewController = [[BYNavigationController alloc] initWithRootViewController:vc];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    // 集成环信SDK, AppKey:注册的appKey, apnsCertName:推送证书名(不需要加后缀)
    EMOptions *options = [EMOptions optionsWithAppkey:IMAPPKEY];
    options.apnsCertName = IMAPNsCertName;
    
    // 初始化SDK
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    //添加回调监听代理
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    
    //注册好友回调
//    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    
    //移除好友回调
//    [[EMClient sharedClient].contactManager removeDelegate:self];
    
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
    
    BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
    NSLog(@"isAutoLogin = %d", isAutoLogin);
//    if (isAutoLogin){
//        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
//    }
//    else
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
//    }
    
    //异步设置apns相关
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        EMPushOptions *options = [[EMClient sharedClient] getPushOptionsFromServerWithError:&error];
        
        NSLog(@"push error ========= %@", error.errorDescription);
        
        [[EMClient sharedClient] setApnsNickname:@"宾友"];
        
        options.displayStyle = EMPushDisplayStyleMessageSummary;
        
        options.noDisturbStatus = EMPushNoDisturbStatusClose;
        //        options.noDisturbingStartH = 23;
        //        options.noDisturbingEndH = 4;
        EMError *resultError = [[EMClient sharedClient] updatePushOptionsToServer];
        if (!resultError) {
            NSLog(@"APNS属性设置成功");
        }
    });
    
    
    
//    EMError *error = nil;
//    EMPushOptions *pushoptions = [[EMClient sharedClient] getPushOptionsFromServerWithError:&error];
//    pushoptions.displayStyle = EMPushDisplayStyleMessageSummary;
//    NSLog(@"push error ========= %@", error.errorDescription);
//    NSLog(@"push error ========= %@", error.errorDescription);
    
    return YES;
}

/*!
 *  自动登陆返回结果
 *
 *  @param aError 错误信息
 */
- (void)didAutoLoginWithError:(EMError *)aError
{
    NSLog(@"aError == %@" , aError);
    NSLog(@"aError == == %@", aError.errorDescription);
    NSLog(@"aError == == %@", aError.errorDescription);
}

#pragma mark - 重连
/*!
 *  SDK连接服务器的状态变化时会接收到该回调
 *
 *  有以下几种情况, 会引起该方法的调用:
 *  1. 登录成功后, 手机无法上网时, 会调用该回调
 *  2. 登录成功后, 网络状态变化时, 会调用该回调
 *
 *  @param aConnectionState 当前状态
 */
- (void)didConnectionStateChanged:(EMConnectionState)aConnectionState
{
    NSLog(@"重连");
}
#pragma mark - 被动退出登录
/*!
 *  当前登录账号在其它设备登录时会接收到该回调
 */
- (void)didLoginFromOtherDevice
{
    NSLog(@"当前登录账号在其它设备登录");
}

/*!
 *  当前登录账号已经被从服务器端删除时会收到该回调
 */
- (void)didRemovedFromServer
{
    NSLog(@"当前登录账号已经被从服务器端删除");
}

#pragma mark - EMContactManagerDelegate
/*!
 *  用户A发送加用户B为好友的申请，用户B会收到这个回调
 *
 *  @param aUsername   用户名
 *  @param aMessage    附属信息
 */
- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername message:(NSString *)aMessage
{
    // 拒绝加好友申请
    EMError *error = [[EMClient sharedClient].contactManager acceptInvitationForUsername:aUsername];
    if (!error) {
        NSLog(@"发送同意成功");
    }
    
    // 拒绝加好友申请
//    EMError *error = [[EMClient sharedClient].contactManager declineInvitationForUsername:@"8001"];
//    if (!error) {
//        NSLog(@"发送拒绝成功");
//    }
}

/*!
 @method
 @brief 用户A发送加用户B为好友的申请，用户B同意后，用户A会收到这个回调
 */
- (void)didReceiveAgreedFromUsername:(NSString *)aUsername
{
    
}

/*!
 @method
 @brief 用户A发送加用户B为好友的申请，用户B拒绝后，用户A会收到这个回调
 */
- (void)didReceiveDeclinedFromUsername:(NSString *)aUsername
{
    
}

- (void)didReceiveMessages:(NSArray *)aMessages
{
    NSLog(@"didReceiveMessages=====%@", aMessages);
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
