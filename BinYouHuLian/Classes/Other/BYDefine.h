//
//  BYDefine.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/7.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#ifndef BYDefine_h
#define BYDefine_h

//#define APIKEY @"dc7237217f752ba1a2c5be2bb90ac1d7" 高德地图 appkey

#define loginStatus @"isLogin"

//系统版本
#define kIOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//屏幕宽、高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


#define kMainColor [UIColor colorWithRed:255 / 255.0 green:143 / 255.0 blue:108 / 255.0 alpha:1.0]
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



