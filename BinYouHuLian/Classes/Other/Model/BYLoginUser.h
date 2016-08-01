//
//  BYLoginUser.h
//  BinYouHuLian
//
//  Created by zhf on 16/7/31.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYLoginUser : NSObject <NSCoding>

/** phone */
@property (nonatomic, copy) NSString *phone;
/** avatar */
@property (nonatomic, copy) NSString *avatar;
/** id */
@property (nonatomic, copy) NSString *userId;
/** nickname */
@property (nonatomic, copy) NSString *nickname;
/** registTime */
@property (nonatomic, copy) NSString *registTime;

//+ (BYLoginUser *)shareLoginUser;

@end
