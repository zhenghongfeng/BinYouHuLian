//
//  ViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/7.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYHomePageViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BYRegisterViewController.h"
#import "BYMineViewController.h"
#import "BYSearchViewController.h"
#import "BYCreateShopViewController.h"
#import "BYAnnotation.h"
#import "BYShopDetailViewController.h"
#import "BYCalloutAnnotation.h"
#import "BYCalloutAnnotatonView.h"
#import "BYGPSLocation.h"
#import "BYShop.h"

@interface BYHomePageViewController () <MKMapViewDelegate,CLLocationManagerDelegate>

{
    NSString *_longitude;//用户经度
    NSString *_latitude;//用户纬度
    BOOL isAppear;//地图是否显示完成
}

/** 位置管理者 */
@property (nonatomic, strong) CLLocationManager *locationManager;
/** 地图 */
@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) CLLocation *location;
/** 回到当前位置 */
@property (nonatomic, strong) UIButton *locateBtn;
/** 搜索 */
@property (nonatomic, strong) UIButton *searchBtn;
/** 我的 */
@property (nonatomic, strong) UIButton *mineBtn;
/** 开店 */
@property (nonatomic, strong) UIButton *createShopBtn;

@property (nonatomic, strong) UIImageView *centerImageView;

@property (nonatomic, strong) CLGeocoder* geocoder;

@property (nonatomic, strong) UILabel *adressLabel;

@property (nonatomic, strong) NSMutableArray *annotations;

@property (nonatomic, strong) NSMutableArray *shops;

@end

@implementation BYHomePageViewController

#pragma mark - getter

- (CLLocationManager *)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        // 每隔多远定位一次
        //        _locationManager.distanceFilter = 100;
        /**
         CLLocationAccuracy kCLLocationAccuracyBestForNavigation;  // 最合适导航
         CLLocationAccuracy kCLLocationAccuracyBest; // 最好的
         CLLocationAccuracy kCLLocationAccuracyNearestTenMeters; // 10m
         CLLocationAccuracy kCLLocationAccuracyHundredMeters; // 100m
         CLLocationAccuracy kCLLocationAccuracyKilometer; // 1000m
         CLLocationAccuracy kCLLocationAccuracyThreeKilometers; // 3000m
         */
//         精确度越高，越耗电，定位时间越长
//                _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        //请求定位服务
        //        if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        //            [self.locationManager requestWhenInUseAuthorization];
        //        }
        //        if (kIOS_VERSION >= 8.0) {
        //            [self.locationManager requestWhenInUseAuthorization];
        //        }
        // 系统适配
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            
            // 前后台定位授权
            //            [self.locationManager requestAlwaysAuthorization];
            
            // 前台定位授权
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    return _locationManager;
}

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        _mapView.mapType = MKMapTypeStandard;
        // 跟踪用户
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        // 禁止地图旋转
        _mapView.rotateEnabled = NO;
        
        CLLocationCoordinate2D coord2D = _mapView.centerCoordinate;
//        //放大地图的经纬度位置。
//        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord2D, 250, 250);
        
        //提供经纬度信息
//        CLLocationCoordinate2D coord2D = {39.910650, 116.47030};
        //显示区域精度
        MKCoordinateSpan span = {0.1, 0.1};
        //设置显示区域，MKCoordinateRegion是结构体类型
        MKCoordinateRegion region = {coord2D, span};
        //给地图设置显示区域
        [_mapView setRegion:region animated:YES];
    }
    return _mapView;
}

- (UIButton *)locateBtn
{
    if (!_locateBtn) {
        _locateBtn = [self createButtonWithTitle:nil image:@"icon_locate_in_map" action:@selector(locateBtnClick) alpha:0.0];
    }
    return _locateBtn;
}

- (UIButton *)mineBtn
{
    if (!_mineBtn) {
        _mineBtn = [self createButtonWithTitle:@"我的" image:nil action:@selector(mineBtnClick) alpha:0.6];
    }
    return _mineBtn;
}

- (UIButton *)createShopBtn
{
    if (!_createShopBtn) {
        _createShopBtn = [self createButtonWithTitle:@"开店" image:nil action:@selector(createShopBtnClick) alpha:0.6];
    }
    return _createShopBtn;
}

- (UIButton *)searchBtn
{
    if (!_searchBtn) {
        _searchBtn = [self createButtonWithTitle:@"搜索" image:nil action:@selector(searchBtnClick) alpha:0.6];
    }
    return _searchBtn;
}

- (UIImageView *)centerImageView
{
    if (_centerImageView == nil) {
        _centerImageView = [[UIImageView alloc] init];
        _centerImageView.image = [UIImage imageNamed:@"map_point_on"];
    }
    return _centerImageView;
}

- (UILabel *)adressLabel
{
    if (_adressLabel == nil) {
        _adressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 50 - 10 - 40, kScreenWidth, 40)];
        _adressLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _adressLabel;
}

#pragma mark - private methods

- (UIButton *)createButtonWithTitle:(NSString *)title image:(NSString *)image action:(SEL)action alpha:(CGFloat)alpha
{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    button.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    return button;
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isAppear = YES;
    _centerImageView.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.locationManager startUpdatingLocation];
    
    isAppear = NO;
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.searchBtn];
    [self.view addSubview:self.locateBtn];
    [self.view addSubview:self.mineBtn];
    [self.view addSubview:self.createShopBtn];
    [self.view addSubview:self.centerImageView];
    [self.view addSubview:self.adressLabel];
    
    [self setupConstraints];
}

- (void)displayUserLocation:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    CLLocationCoordinate2D cl = CLLocationCoordinate2DMake([dict[@"latitude"] floatValue], [dict[@"longitude"] floatValue]);
    self.mapView.centerCoordinate = cl;
}

#pragma mark - CLLocationManagerDelegate
/**
 *  更新到位置之后调用
 *
 *  @param manager   位置管理者
 *  @param locations 位置数组
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"定位到了");
    
    // 拿到位置，做一些业务逻辑操作
    // 停止更新
    [self.locationManager stopUpdatingLocation];
}
/**
 *  授权状态发生改变时调用
 *
 *  @param manager 位置管理者
 *  @param status  状态
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"用户还未决定");
            break;
            
        case kCLAuthorizationStatusRestricted:
            NSLog(@"访问受限");
            break;
            
        case kCLAuthorizationStatusDenied:
            // 定位是否可用（是否支持定位或者定位是否开启）
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"定位开启，但被拒");
            } else {
                NSLog(@"定位关闭，不可用");
            }
            //            NSLog(@"被拒");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"获取前后台定位授权");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"获取后台定位授权");
            break;
            
        default:
            break;
    }
}

#pragma mark - MKMapViewDelegate
/**
 *  每次添加大头针都会调用此方法  可以自定义大头针的样式
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    if ([annotation isKindOfClass:[BYAnnotation class]]) {
        /*
        static NSString *key1 = @"AnnotationKey1";
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        //如果缓存池中不存在则新建
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:key1];
            //允许交互点击
            annotationView.canShowCallout = YES;
            //定义详情视图偏移量
            annotationView.calloutOffset = CGPointMake(0, 1);
            //定义右视图
            annotationView.rightCalloutAccessoryView = ({
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
                button.tag = [(BYAnnotation *)annotation tag];
                [button setTitle:@"查看详情" forState:UIControlStateNormal];
                [button setTitleColor:kMainColor forState:UIControlStateNormal];
                button.titleLabel.numberOfLines = 2;
                [button addTarget:self action:@selector(shopDetailClick:) forControlEvents:UIControlEventTouchUpInside];
                
                button;
            });
        }
         */
        
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] init];
        //允许交互点击
        annotationView.canShowCallout = YES;
        //定义详情视图偏移量
        annotationView.calloutOffset = CGPointMake(0, 1);
        //定义右视图
        annotationView.rightCalloutAccessoryView = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
            button.tag = [(BYAnnotation *)annotation tag];
            [button setTitle:@"查看详情" forState:UIControlStateNormal];
            [button setTitleColor:kMainColor forState:UIControlStateNormal];
            button.titleLabel.numberOfLines = 2;
            [button addTarget:self action:@selector(shopDetailClick:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        //修改大头针视图
        //重新设置此类大头针视图的大头针模型(因为有可能是从缓存池中取出来的，位置是放到缓存池时的位置)
        annotationView.annotation = annotation;
        annotationView.image = ((BYAnnotation *)annotation).image;//设置大头针视图的图片
        return annotationView;
    }
    //    else if ([annotation isKindOfClass:[BYCalloutAnnotation class]]){
    //        //对于作为弹出详情视图的自定义大头针视图无弹出交互功能（canShowCallout=false，这是默认值），在其中可以自由添加其他视图（因为它本身继承于UIView）
    //        BYCalloutAnnotatonView *calloutView = [BYCalloutAnnotatonView calloutViewWithMapView:mapView];
    //        calloutView.annotation = annotation;
    //        return calloutView;
    //    }
    else {
        return nil;
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    CLLocationCoordinate2D coord = [userLocation coordinate];
    
    NSLog(@"mapView纬度:%f,经度:%f",coord.latitude,coord.longitude);
    
    _longitude = [NSString stringWithFormat:@"%f" ,coord.longitude];
    _latitude = [NSString stringWithFormat:@"%f" ,coord.latitude];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    _adressLabel.text = @"正在获取你选择的地点...";
    NSLog(@"将要变化");
    //    if (_geocoder == nil) {
    //        _geocoder = [[CLGeocoder alloc] init];
    //    }
    //    [_geocoder cancelGeocode];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"已经变化");
    
    if (_longitude != nil && isAppear == YES) {
        CLLocationCoordinate2D cl =  mapView.centerCoordinate;
        NSLog(@"转换前：%f,%f",cl.latitude,cl.longitude);
        typeof(BYHomePageViewController *)weakSelf = self;
        
        CLLocationCoordinate2D earthCL = [self homegcj2wgs:cl];
        //FIXME:不知什么原因有时候 PBRequester failed with Error Error Domain=NSURLErrorDomain Code=-1001 "The request timed out."所以加了线程，然并卵
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [weakSelf homereverseGeocode1:earthCL.latitude  longitude:earthCL.longitude];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:0.8 animations:^{
                    self.centerImageView.center = CGPointMake(weakSelf.view.center.x, weakSelf.view.center.y);
                    
                } completion:^(BOOL finished) {
                    
                    self.centerImageView.center = CGPointMake(weakSelf.view.center.x, weakSelf.view.center.y);
                    
                }];
            });
        });
    }
}

#pragma mark 反地理编码
- (void)homereverseGeocode1:(double)_lat longitude:(double)_long
{
    //UIKit坐标点转化 ——>  经纬度
    CLLocationCoordinate2D leftTopCoornation = [_mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:_mapView];
    NSLog(@"leftTopCoornation = %f, %f", leftTopCoornation.latitude, leftTopCoornation.longitude);
    
    CLLocationCoordinate2D rightBottomcoornation = [_mapView convertPoint:CGPointMake(kScreenWidth, kScreenHeight) toCoordinateFromView:_mapView];
    NSLog(@"rightBottomcoornation = %f, %f", rightBottomcoornation.latitude, rightBottomcoornation.longitude);
    
    
    
    
    NSLog(@"转换后:%f,%f",_lat,_long);
    NSDictionary *dic = @{
                          @"longitude": @(_long),
                          @"latitude": @(_lat),
                          @"distance": @"2"
                          };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:@"http://192.168.4.181/api/shop/search?" parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"responseObject = %@", responseObject);
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            //            [hud hide:YES];
            
            [_mapView removeAnnotations:_mapView.annotations];
            
            NSMutableArray *annotationArr = [NSMutableArray array];
            
            self.shops = [BYShop mj_objectArrayWithKeyValuesArray:responseObject[@"stores"]];
            
            for (int i = 0; i < self.shops.count; i++) {
                BYShop *shop = self.shops[i];
                CLLocationDegrees latitude = [shop.latitude doubleValue];
                CLLocationDegrees longitude = [shop.longitude doubleValue];
                CLLocationCoordinate2D locationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude);
                BYAnnotation *annotation = [[BYAnnotation alloc] init];
                annotation.coordinate = locationCoordinate2D;
                annotation.tag = i;
                annotation.shop = shop;
                [annotationArr addObject:annotation];
            }
            [_mapView addAnnotations:annotationArr];
            
        } else {
            //            hud.mode = MBProgressHUDModeText;
            //            hud.labelText = @"失败";
            //            [hud hide:YES afterDelay:1];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.labelText = @"登录失败";
//        [hud hide:YES afterDelay:1];
    }];
    
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    //注意初使化location参数 double转换，这里犯过错， 此外一般会用 全局_currLocation，在定位后得到
    CLLocation* location = [[CLLocation alloc] initWithLatitude:_lat longitude:_long];
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error) {
        CLPlacemark* placemark = [placemarks firstObject];
        //                        NSLog(@"详细信息:%@", placemark.addressDictionary);
        if(placemark.addressDictionary == nil){
            self.adressLabel.text = @"地图君没有识别此地。。。";
        } else {
            self.adressLabel.text = [NSString stringWithFormat:@"%@",placemark.addressDictionary[@"Name"]];
        }
    }];
}

#pragma mark 火星坐标转换成地球坐标
//const double a = 6378245.0;
//const double ee = 0.00669342162296594323;

- (BOOL)homeoutOfChina:(CLLocationCoordinate2D)coordinate
{
    if (coordinate.longitude < 72.004 || coordinate.longitude > 137.8347)
        return YES;
    if (coordinate.latitude < 0.8293 || coordinate.latitude > 55.8271)
        return YES;
    return NO;
}

double hometransformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

static double hometransformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

// 地球坐标系 (WGS-84) <- 火星坐标系 (GCJ-02)

- (CLLocationCoordinate2D)homegcj2wgs:(CLLocationCoordinate2D)coordinate
{
    if ([self homeoutOfChina:coordinate]) {
        return coordinate;
    }
    CLLocationCoordinate2D c2 = [self homewgs2gcj:coordinate];
    return CLLocationCoordinate2DMake(2 * coordinate.latitude - c2.latitude, 2 * coordinate.longitude - c2.longitude);
}
// 地球坐标系 (WGS-84) -> 火星坐标系 (GCJ-02)

- (CLLocationCoordinate2D)homewgs2gcj:(CLLocationCoordinate2D)coordinate
{
    const double a = 6378245.0;
    const double ee = 0.00669342162296594323;
    if ([self homeoutOfChina:coordinate]) {
        return coordinate;
    }
    double wgLat = coordinate.latitude;
    double wgLon = coordinate.longitude;
    double dLat = hometransformLat(wgLon - 105.0, wgLat - 35.0);
    double dLon = hometransformLon(wgLon - 105.0, wgLat - 35.0);
    double radLat = wgLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    return CLLocationCoordinate2DMake(wgLat + dLat, wgLon + dLon);
}

#pragma mark - even response
- (void)mineBtnClick
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *str = [userDefaults valueForKey:@"access_token"];
    if (str.length > 0) {
        BYMineViewController *vc = [[BYMineViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        BYRegisterViewController *vc = [[BYRegisterViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.hidden = YES;
        [self presentViewController:nav animated:YES completion:nil];
    }
}
- (void)searchBtnClick
{
    BYSearchViewController *vc = [[BYSearchViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)createShopBtnClick
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *str = [userDefaults valueForKey:@"access_token"];
    if (str.length > 0) {
        BYCreateShopViewController *vc = [[BYCreateShopViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        BYRegisterViewController *vc = [[BYRegisterViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.hidden = YES;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)shopDetailClick:(UIButton *)button
{
    BYShopDetailViewController *vc = [[BYShopDetailViewController alloc] init];
    vc.shop = self.shops[button.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)locateBtnClick
{
    [_mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
}

#pragma mark - autoLayout

- (void)setupConstraints
{
    // SDAutoLayout
    // 搜索
    self.searchBtn.sd_layout.leftSpaceToView(self.view, BYMargin)
    .topSpaceToView(self.view, BYMargin * 2)
    .widthIs(BYHomeButtonW)
    .heightIs(BYHomeButtonH);
    // 当前位置
    self.locateBtn.sd_layout
    .leftSpaceToView(self.view, BYMargin)
    .bottomSpaceToView(self.view, BYMargin * 2)
    .widthIs(BYHomeButtonH)
    .heightIs(BYHomeButtonH);
    // 我的
    self.mineBtn.sd_layout
    .bottomSpaceToView(self.view, BYMargin * 2)
    .centerXEqualToView(self.view)
    .widthIs(BYHomeButtonW)
    .heightIs(BYHomeButtonH);
    // 开店
    self.createShopBtn.sd_layout
    .rightSpaceToView(self.view, BYMargin)
    .bottomSpaceToView(self.view,BYMargin * 2)
    .widthIs(BYHomeButtonW)
    .heightIs(BYHomeButtonH);
    
    self.centerImageView.sd_layout
    .centerXIs(self.view.centerX)
    .centerYIs(self.view.centerY)
    .widthIs(30)
    .heightIs(40);
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
