//
//  BYCalloutAnnotatonView.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/19.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "BYCalloutAnnotation.h"

@interface BYCalloutAnnotatonView : MKAnnotationView

@property (nonatomic ,strong) BYCalloutAnnotation *calloutAnnotation;

#pragma mark 从缓存取出标注视图
+ (instancetype)calloutViewWithMapView:(MKMapView *)mapView;

@end
