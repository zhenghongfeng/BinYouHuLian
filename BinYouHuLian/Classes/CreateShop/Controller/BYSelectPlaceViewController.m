//
//  BYSelectPlaceViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/13.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYSelectPlaceViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BYSelectPlaceViewController () <MKMapViewDelegate,CLLocationManagerDelegate>
{
    NSString *_userLongitude;//用户经度
    NSString *_userLatitude;//用户纬度
    BOOL isAppear;//地图是否显示完成
}

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) UIButton *locateBtn;

@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) UIImageView *centerImageView;

@property (nonatomic, strong) UILabel *adressLabel;

@property (nonatomic, assign) double longitude;

@property (nonatomic, assign) double latitude;

@property (nonatomic, strong) CLPlacemark* placemark;


@end

@implementation BYSelectPlaceViewController

- (UIButton *)backButton
{
    if (_backButton == nil) {
        _backButton = [UIButton new];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        _backButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _backButton.layer.masksToBounds = YES;
        _backButton.layer.cornerRadius = 5;
    }
    return _backButton;
}

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
        // 精确度越高，越耗电，定位时间越长
//        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        //请求定位服务
        //        if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        //            [self.locationManager requestWhenInUseAuthorization];
        //        }
        //        if (kIOS_VERSION >= 8.0) {
        //            [self.locationManager requestWhenInUseAuthorization];
        //        }
        // 系统适配
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            
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
//        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
        _mapView.delegate = self;
        // 显示当前位置
        _mapView.showsUserLocation = YES;
        _mapView.mapType = MKMapTypeStandard;
        _mapView.userTrackingMode = MKUserTrackingModeFollow;//是否跟踪
        // 禁止地图旋转
        _mapView.rotateEnabled = NO;
        CLLocationCoordinate2D coord2D;
        if (self.tag) {
            coord2D = CLLocationCoordinate2DMake(self.fromCreateShoplatitude, self.fromCreateShoplongitude);
        } else {
            coord2D = _mapView.centerCoordinate;
        }
        // 显示区域精度
        MKCoordinateSpan span = {0.01, 0.01};
        // 设置显示区域
        MKCoordinateRegion region = {coord2D, span};
        // 给地图设置显示区域
        [_mapView setRegion:region animated:YES];
    }
    return _mapView;
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
        _adressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 50 - 40, kScreenWidth, 50)];
        _adressLabel.textAlignment = NSTextAlignmentCenter;
        _adressLabel.numberOfLines = 0;
    }
    return _adressLabel;
}

- (UIButton *)locateBtn
{
    if (!_locateBtn) {
        _locateBtn = [self createButtonWithTitle:nil image:@"icon_locate_in_map" action:@selector(locateBtnClick) alpha:0.0];
    }
    return _locateBtn;
}

- (UIButton *)okButton
{
    if (!_okButton) {
        _okButton = [self createButtonWithTitle:@"选好了" image:nil action:@selector(okBtnClick) alpha:0.6];
    }
    return _okButton;
}

- (UIButton *)createButtonWithTitle:(NSString *)title image:(NSString *)image action:(SEL)action alpha:(CGFloat)alpha
{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    button.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    [self.view addSubview:button];
    return button;
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
    isAppear = YES;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"选位置";
    
    [self.locationManager startUpdatingLocation];
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.centerImageView];
    [self.view addSubview:self.adressLabel];
}

#pragma mark - CLLocationManagerDelegate  位置更新后的回调

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //停止位置更新
    [_locationManager stopUpdatingLocation];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D coord = [userLocation coordinate];
    NSLog(@"mapView纬度:%f,经度:%f",coord.latitude,coord.longitude);
    _userLongitude = [NSString stringWithFormat:@"%f" ,coord.longitude];
    _userLatitude = [NSString stringWithFormat:@"%f" ,coord.latitude];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    _adressLabel.text = @"正在获取你选择的地点...";
    NSLog(@"将要变化");
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    [_geocoder cancelGeocode];
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocationCoordinate2D cl =  mapView.centerCoordinate;
    NSLog(@"转换前：%f,%f",cl.latitude,cl.longitude);
    typeof(BYSelectPlaceViewController *)weakSelf = self;
    
    CLLocationCoordinate2D earthCL = [self gcj2wgs:cl ];
    
    //FIXME:不知什么原因有时候 PBRequester failed with Error Error Domain=NSURLErrorDomain Code=-1001 "The request timed out."所以加了线程，然并卵
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [weakSelf reverseGeocode1:earthCL.latitude  longitude:earthCL.longitude];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.8 animations:^{
//                _centerImageView.center = CGPointMake(weakSelf.view.center.x, weakSelf.view.center.y);
            } completion:^(BOOL finished) {
//                _centerImageView.center = CGPointMake(weakSelf.view.center.x, weakSelf.view.center.y);
            }];
        });
    });
}
#pragma mark 反地理编码
- (void)reverseGeocode1:(double)_lat longitude:(double)_long
{
    NSLog(@"转换后:%f,%f",_lat,_long);
    _latitude = _lat;
    _longitude = _long;
    
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    //注意初使化location参数 double转换，这里犯过错，    此外一般会用 全局_currLocation，在定位后得到
    CLLocation* location = [[CLLocation alloc] initWithLatitude:_lat longitude:_long];
    [_geocoder reverseGeocodeLocation:location
                    completionHandler:^(NSArray* placemarks, NSError* error) {
                        _placemark = [placemarks firstObject];
                        NSLog(@"详细信息:%@", _placemark.addressDictionary);
                        if(_placemark.addressDictionary == nil){
                            _adressLabel.text = @"地图没有识别到此地";
                        } else {
//                            NSString *addStr = [[placemark.addressDictionary objectForKey:@"FormattedAddressLines"] objectAtIndex:0];
//                            NSString *countyStr = [placemark.addressDictionary objectForKey:@"Country"];
//                            NSString *cityStr = [placemark.addressDictionary objectForKey:@"City"];
//                             NSString *streetStr = [placemark.addressDictionary objectForKey:@"Street"];
                            
                            _adressLabel.text = [NSString stringWithFormat:@"%@", _placemark.name];
                        }
                    }];
}

#pragma mark 火星坐标转换成地球坐标
const double a = 6378245.0;
const double ee = 0.00669342162296594323;
- (BOOL)outOfChina:(CLLocationCoordinate2D) coordinate
{
    if (coordinate.longitude < 72.004 || coordinate.longitude > 137.8347)
        return YES;
    if (coordinate.latitude < 0.8293 || coordinate.latitude > 55.8271)
        return YES;
    return NO;
}
double transformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

static double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}
// 地球坐标系 (WGS-84) <- 火星坐标系 (GCJ-02)

- (CLLocationCoordinate2D)gcj2wgs:(CLLocationCoordinate2D)coordinate
{
    if ([self outOfChina:coordinate]) {
        return coordinate;
    }
    CLLocationCoordinate2D c2 = [self wgs2gcj:coordinate];
    return CLLocationCoordinate2DMake(2 * coordinate.latitude - c2.latitude, 2 * coordinate.longitude - c2.longitude);
}
// 地球坐标系 (WGS-84) -> 火星坐标系 (GCJ-02)

- (CLLocationCoordinate2D)wgs2gcj:(CLLocationCoordinate2D)coordinate
{
    if ([self outOfChina:coordinate]) {
        return coordinate;
    }
    double wgLat = coordinate.latitude;
    double wgLon = coordinate.longitude;
    double dLat = transformLat(wgLon - 105.0, wgLat - 35.0);
    double dLon = transformLon(wgLon - 105.0, wgLat - 35.0);
    double radLat = wgLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    return CLLocationCoordinate2DMake(wgLat + dLat, wgLon + dLon);
    
}

#pragma mark - custom event

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)okBtnClick
{
    WeakSelf;
//    NSString *formattedAddressLines = [[_placemark.addressDictionary objectForKey:@"FormattedAddressLines"] objectAtIndex:0];
//    NSString *city = [_placemark.addressDictionary objectForKey:@"City"];
//    NSString *street = [_placemark.addressDictionary objectForKey:@"Street"];
//    NSString *name = [_placemark.addressDictionary objectForKey:@"Name"];
//    NSString *address = [NSString stringWithFormat:@"%@%@", formattedAddressLines, name];
    
    [_geocoder geocodeAddressDictionary:_placemark.addressDictionary completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *pl = [placemarks firstObject];
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(selectedLocation:longitude:latitude:)]) {
            [weakSelf.delegate selectedLocation:_adressLabel.text longitude:pl.location.coordinate.longitude latitude:pl.location.coordinate.latitude];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    
//    [_geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        CLPlacemark *pl = [placemarks firstObject];
//        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(selectedLocation:longitude:latitude:)]) {
//            [weakSelf.delegate selectedLocation:_adressLabel.text longitude:pl.location.coordinate.longitude latitude:pl.location.coordinate.latitude];
//            [weakSelf.navigationController popViewControllerAnimated:YES];
//        }
//    }];
}

- (void)locateBtnClick
{
    [_mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
}

#pragma mark - autoLayout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.backButton.sd_layout.leftSpaceToView(self.view, BYMargin)
    .topSpaceToView(self.view, BYMargin * 2)
    .widthIs(BYHomeButtonW)
    .heightIs(BYHomeButtonH);
    
    self.centerImageView.sd_layout
    .centerXIs(self.view.centerX)
    .topSpaceToView(self.navigationController.navigationBar, (kScreenHeight - 64) / 2 - 30)
    .widthIs(20)
    .heightIs(30);
    
    self.locateBtn.sd_layout
    .leftSpaceToView(self.view, BYMargin)
    .bottomSpaceToView(self.view, BYMargin * 2)
    .widthIs(BYHomeButtonH)
    .heightIs(BYHomeButtonH);
    
    self.okButton.sd_layout
    .bottomSpaceToView(self.view, BYMargin * 2)
    .centerXEqualToView(self.view)
    .widthIs(BYHomeButtonW)
    .heightIs(BYHomeButtonH);
}


@end
