//
//  BYMessageModel.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/14.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYMessageModel.h"

@implementation BYMessageModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    BYMessageModel *message = [[BYMessageModel alloc] init];
    message.avatar = dict[@"avatar"];
    message.name = dict[@"name"];
    message.content = dict[@"content"];
    message.time = dict[@"time"];
//    [self setValuesForKeysWithDictionary:dict];
    return message;
}


+ (instancetype)messageWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSMutableArray *)arrayWithMessages:(NSArray *)array
{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        [arr addObject:[self messageWithDict:dict]];
    }
    return arr;
}


@end
