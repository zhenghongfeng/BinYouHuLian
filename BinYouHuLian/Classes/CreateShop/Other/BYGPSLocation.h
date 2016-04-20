//
//  BYGPSLocation.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/20.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <Foundation/Foundation.h>
//定位库的头文件
#import <CoreLocation/CoreLocation.h>

@interface BYGPSLocation : NSObject <CLLocationManagerDelegate>

@property(nonatomic,strong)CLLocationManager *locMgr;
+ (BYGPSLocation *)sharedGPSLocation;
- (void)startLocation;

@end
