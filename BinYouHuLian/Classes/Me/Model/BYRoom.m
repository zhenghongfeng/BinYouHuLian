//
//  BYRoom.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/9.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYRoom.h"

@implementation BYRoom

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 替换属性名
        [BYRoom mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
            return @{
                     @"myDescription": @"description",
                     @"myId": @"id"
                     };
        }];
    }
    return self;
}
@end
