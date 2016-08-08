//
//  BYApply.h
//  BinYouHuLian
//
//  Created by zhf on 16/8/8.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYApply : NSObject

/** applyStatus */
@property (nonatomic, assign) BOOL applyStatus;
/** avatar */
@property (nonatomic, copy) NSString *avatar;
/** nickname */
@property (nonatomic, copy) NSString *nickname;
/** phone */
@property (nonatomic, copy) NSString *phone;
/** reason */
@property (nonatomic, copy) NSString *reason;

@end
