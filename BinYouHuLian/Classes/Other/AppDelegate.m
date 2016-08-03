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
#import "ChatViewController.h"

#define EaseMobAppKey @"binyou#binyouapp"

#ifdef DEBUG
#define APNSCerName @"aps_development"
#else
#define APNSCerName @"aps_distribution"
#endif

@interface AppDelegate () <EMClientDelegate, EMChatManagerDelegate>

@property (nonatomic, strong) BYHomePageViewController *vc;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"launchOptions = %@", launchOptions);
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    _vc = [BYHomePageViewController new];
    self.window.rootViewController = [[BYNavigationController alloc] initWithRootViewController:_vc];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    [self by_easemobApplication:application didFinishLaunchingWithOptions:launchOptions appkey:EaseMobAppKey apnsCertName:APNSCerName otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
//    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
//        [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
//        
//        ChatViewController *vc = [[ChatViewController alloc] init];
//        vc.dic = launchOptions;
//        [_vc.navigationController pushViewController:vc animated:YES];
//    }
    return YES;
}

#pragma mark - UIApplicationDelegate

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"离线推送");
    if (_vc) {
        ChatViewController *vc = [[ChatViewController alloc] init];
//        vc.dic = launchOptions;
        [_vc.navigationController pushViewController:vc animated:YES];
    }
}
//
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (_vc) {
        [_vc didReceiveLocalNotification:notification];
        
    }
}

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


- (void)didReceiveMessages:(NSArray *)aMessages
{
    for(EMMessage *message in aMessages){
        
        BOOL needShowNotification = (message.chatType != EMChatTypeChat) ? [self _needShowNotification:message.conversationId] : YES;
        
        if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            switch (state) {
                case UIApplicationStateActive:
                    [self playSoundAndVibration];
                    break;
                case UIApplicationStateInactive:
                    [self playSoundAndVibration];
                    break;
                case UIApplicationStateBackground:
                    [self showNotificationWithMessage:message];
                    break;
                default:
                    break;
            }
#endif
        }
    }
}

- (BOOL)_needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EMClient sharedClient].groupManager getAllIgnoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

- (void)playSoundAndVibration{
    NSDate *lastPlaySoundDate = [NSDate date];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:lastPlaySoundDate];
    if (timeInterval < 3) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == EMPushDisplayStyleMessageSummary) {
        EMMessageBody *messageBody = message.body;
        NSString *messageStr;
        switch (messageBody.type) {
            case EMMessageBodyTypeText: {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case EMMessageBodyTypeImage: {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case EMMessageBodyTypeLocation: {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case EMMessageBodyTypeVoice: {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case EMMessageBodyTypeVideo: {
                messageStr = NSLocalizedString(@"message.video", @"Video");
            }
                break;
            default:
                break;
        }
        NSString *title;
        if (message.chatType == EMChatTypeChat) {
            NSString * chater =  message.from;
            if (chater) {
                notification.alertBody = [NSString stringWithFormat:@"%@:%@",chater, messageStr];
            } else {
                notification.alertBody = @"您有一条新的短信消息";
            }
        } else if (message.chatType == EMChatTypeGroupChat) {
            NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationId]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.from, group.subject];
                    break;
                }
            }
        } else if (message.chatType == EMChatTypeChatRoom) {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
            NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
            NSString *chatroomName = [chatrooms objectForKey:message.conversationId];
            if (chatroomName)
            {
                title = [NSString stringWithFormat:@"%@(%@)", message.from, chatroomName];
            }
        }
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    } else {
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
//    [[ChatUIHelper shareHelper] playSoundAndVibration];
    
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:@"MessageType"];
    [userInfo setObject:message.conversationId forKey:@"ConversationChatter"];
    [userInfo setObject:message.from forKey:@"from"];
    notification.userInfo = userInfo;
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber += 1;
    
}

@end
