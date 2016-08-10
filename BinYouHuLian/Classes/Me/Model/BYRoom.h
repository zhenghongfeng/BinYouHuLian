//
//  BYRoom.h
//  BinYouHuLian
//
//  Created by zhf on 16/8/9.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYRoom : NSObject

/** owner */
@property (nonatomic, copy) NSString *owner;
/** name */
@property (nonatomic, copy) NSString *name;
/** description */
@property (nonatomic, copy) NSString *myDescription;
/** id */
@property (nonatomic, copy) NSString *myId;
/** shopId */
@property (nonatomic, copy) NSString *shopId;
/** maxusers */
@property (nonatomic, assign) NSInteger maxusers;

@end
