//
//  BYShop.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/18.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYShop.h"

@implementation BYShop

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 替换属性名
        [BYShop mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
            return @{
                     @"myDescription": @"description",
                     @"myLegalPerson": @"legalPerson",
                     @"myId": @"id"
                     };
        }];
    }
    return self;
}

@end
