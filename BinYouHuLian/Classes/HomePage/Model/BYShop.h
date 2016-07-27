//
//  BYShop.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/18.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYShop : NSObject

/** name */
@property (nonatomic, copy) NSString *name;
/** 分类 */
@property(nonatomic, copy) NSString *category;
/** 描述 */
@property(nonatomic, copy) NSString *myDescription;
/** legalPerson */
@property (nonatomic, copy) NSString *legalPerson;
/** id */
@property (nonatomic, copy) NSString *myId;
/** 纬度 latitude */
@property (nonatomic, copy) NSString *latitude;
/** 经度 longitude */
@property (nonatomic, copy) NSString *longitude;
/** location */
@property (nonatomic, copy) NSString *location;
/** locs */
@property (nonatomic, strong) NSDictionary *locs;
/** picshow1 */
@property (nonatomic, copy) NSString *picshow1;
/** picshow2 */
@property (nonatomic, copy) NSString *picshow2;
/** picshow3 */
@property (nonatomic, copy) NSString *picshow3;




@end
