//
//  BYDefine.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/7.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#ifndef BYDefine_h
#define BYDefine_h

//#define BYURL_Development @"http://192.168.4.45/api" // 陈州的ip

#warning ---- 上线之前需要更改发送验证码接口的istest 为 0 ！

#define BYImageURL @"http://123.56.186.178/api/download/img?path="

#define BYBaseURL @"http://123.56.186.178"

#define BYURL_Development @"http://123.56.186.178/api"

// 环信聊天用的昵称和头像（发送聊天消息时，要附带这3个属性）
#define kChatUserId @"ChatUserId"// 环信账号
#define kChatUserNick @"ChatUserNick"
#define kChatUserPic @"ChatUserPic"

#define kCURRENT_USERNAME [[EMClient sharedClient] currentUsername]

// NSUserDefaults本地保存
#define Get(a) [[NSUserDefaults standardUserDefaults] objectForKey:a]
#define Save(a,b) [[NSUserDefaults standardUserDefaults] setObject:a forKey:b]; [[NSUserDefaults standardUserDefaults] synchronize]

#define GetToken          Get(@"user_accessToken") ? Get(@"user_accessToken") : @""
#define SaveToken(a)      Save(a,@"user_accessToken")

#define GetPhone         Get(@"user_phone") ? Get(@"user_phone") : @""
#define SavePhone(a)      Save(a,@"user_phone")

#define GetNickName      Get(@"user_nickname")
#define SaveNickName(a)   Save(a,@"user_nickname")

#define GetAvatar      Get(@"user_avatar")
#define SaveAvatar(a)   Save(a,@"user_avatar")

//通知Notification相关的宏
#define kNotficationSearchShopToHome     @"kNotficationSearchShopToHome" // 搜索店铺，跳到首页



#define WeakSelf __weak typeof(self) weakSelf = self;

#define loginStatus @"isLogin"

//系统版本
#define kIOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//屏幕宽、高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kMainColor [UIColor colorWithRed:1.00f green:0.85f blue:0.16f alpha:1.00f]

//rgb颜色(十进制)
#define kRGB(r, g, b) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:1.0]
//rgb颜色(十六进制)
#define UIColorFromHexRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0] \

//1个像素的宽度
#define SINGLE_LINE_WIDTH (1.0f/[UIScreen mainScreen].scale)

//release版本禁止输出NSLog内容

#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}




#endif



