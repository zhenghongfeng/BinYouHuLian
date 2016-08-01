//
//  BYLoginUser.m
//  BinYouHuLian
//
//  Created by zhf on 16/7/31.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYLoginUser.h"

static NSString *kAvatar = @"avatar";
static NSString *kUserId = @"userId";
static NSString *kNickname = @"nickname";
static NSString *kRegistTime = @"registTime";

@implementation BYLoginUser

- (instancetype)init
{
    self = [super init];
    if (self) {
        [BYLoginUser mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
            return @{
                     @"userId": @"id",
                     };
        }];
    }
    return self;
}

//+ (BYLoginUser *)shareLoginUser
//{
//    static BYLoginUser *loginUser = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        loginUser = [[self alloc] init];
//    });
//    return loginUser;
//}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        NSString *propertyValue = [self valueForKey:propertyName];
        [aCoder encodeObject:propertyValue forKey:propertyName];
    }
    free(properties);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        for (int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:name];
            NSString *propertyValue = [aDecoder decodeObjectForKey:propertyName];
            [self setValue:propertyValue forKey:propertyName];
        }
        free(properties);
    }
    return self;
}

@end
