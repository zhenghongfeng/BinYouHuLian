//
//  BYCalloutAnnotation.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/19.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface BYCalloutAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy,readonly) NSString *title;
@property (nonatomic, copy,readonly) NSString *subtitle;

#pragma mark 左侧图标
@property (nonatomic,strong) UIImage *icon;
#pragma mark 详情描述
@property (nonatomic,copy) NSString *detail;
#pragma mark 星级评价
@property (nonatomic,strong) UIImage *rate;

@end
