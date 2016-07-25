//
//  BYGPSLocation.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/20.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYGPSLocation.h"

@implementation BYGPSLocation
{
    double latitude;
    double longitude;
    
}

#pragma mark -懒加载
- (CLLocationManager*)locationManager
{
    if (_locationManager == nil) {
        //1.创建位置管理器（定位用户的位置）
        _locationManager = [[CLLocationManager alloc] init];
        //2.设置代理
        _locationManager.delegate = self;
        //当你移动一段位移后，所以移动距离大于筛选器说设置200m时候，通知委托更新位置；
        _locationManager.distanceFilter = MAXFLOAT;
    }
    return _locationManager;
}

+ (BYGPSLocation *)sharedGPSLocation
{
    static BYGPSLocation * location = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        location = [[BYGPSLocation alloc]init];
    });
    return location;
}
- (void)startLocation
{
    //请求定位服务
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray*)locations
{
    //CLLocation中存放的是一些经纬度, 速度等信息. 要获取地理位置需要转换做地理位置编码.
    // 1.取出位置对象
    CLLocation* loc = [locations firstObject];
    //    NSLog(@"GPS速度：%f", loc.speed);
    //    NSLog(@"GPS获取的设备的速度：%f",loc.speed);
    // 2.取出经纬度
    CLLocationCoordinate2D coordinate = loc.coordinate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"GPS------%f %f", coordinate.latitude, coordinate.longitude);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"inceptCoordinate" object:nil userInfo:@{@"latitude": [NSString stringWithFormat:@"%f",coordinate.latitude],@"longitude":[NSString stringWithFormat:@"%f",coordinate.longitude]}];
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"first"];
        
    });
    
    ////    if (latitude == coordinate.latitude && longitude == coordinate.longitude) {
    //        // 3.打印经纬度
    //      //    }
    ////    latitude = coordinate.latitude;
    ////    longitude = coordinate.longitude;
    ////
    //    // 停止定位(省电措施：只要不想用定位服务，就马上停止定位服务)
    [self.locationManager stopUpdatingLocation];
}
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    CLLocation *newLocation = [locations lastObject];
//    CLLocation *oldLocation;
//    if (locations.count > 1) {
//        oldLocation = [locations objectAtIndex:locations.count-2];
//    } else {
//        oldLocation = nil;
//    }
//
//    NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
//}
// 定位失败时激发的方法
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"定位失败: %@",error);
}


@end
