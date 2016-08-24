//
//  NSString+Category.h
//  BinYouHuLian
//
//  Created by zhf on 16/7/15.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)
/**
 *  md5加密
 */
+ (NSString *)md5:(NSString *)string;

/**
 *  正则判断手机号码格式
 */
+ (BOOL)validatePhone:(NSString *)phone;

/**
 *  有效字符串判断
 */
+ (BOOL)isValueableString:(NSString *)content;

@end
