//
//  BYMessageModel.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/14.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYMessageModel : NSObject

/** 头像 */
@property (nonatomic, copy) NSString *avatar;
/** 名字 */
@property (nonatomic, copy) NSString *name;
/** 聊天内容 */
@property (nonatomic, copy) NSString *content;
/** 时间 */
@property (nonatomic, copy) NSString *time;

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)messageWithDict:(NSDictionary *)dict;

+ (NSMutableArray *)arrayWithMessages:(NSArray *)array;


@end
