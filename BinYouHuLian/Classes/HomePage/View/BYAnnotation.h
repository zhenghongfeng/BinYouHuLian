//
//  BYAnnotation.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/18.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BYAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

#pragma mark 自定义一个图片属性在创建大头针视图时使用
@property (nonatomic,strong) UIImage *image;

#pragma mark 大头针详情左侧图标
@property (nonatomic,strong) UIImage *icon;
#pragma mark 大头针详情描述
@property (nonatomic,copy) NSString *detail;
#pragma mark 大头针右下方星级评价
@property (nonatomic,strong) UIImage *rate;

@end
