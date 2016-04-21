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
#import "BYGPSLocation.h"

@interface BYSelectPlaceViewController () <MKMapViewDelegate,CLLocationManagerDelegate>
{
    NSString *_longitude;//用户经度
    NSString *_latitude;//用户纬度
    BOOL isAppear;//地图是否显示完成
}

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) CLLocation *location;
/** 回到当前位置按钮 */
@property (nonatomic, strong) UIButton *locateBtn;

/** ok按钮 */
@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) CLGeocoder* geocoder;

@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UILabel *adressLabel;


@end

@implementation BYSelectPlaceViewController

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        // 显示当前位置
        _mapView.showsUserLocation = YES;
        _mapView.mapType = MKMapTypeStandard;
        _mapView.userTrackingMode = MKUserTrackingModeFollow;//是否跟踪
        _mapView.rotateEnabled = NO;
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

- (void)setupConstraints
{
    [self.locateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).mas_equalTo(BYHomePageLocationButtonToLeftMargin);
        make.top.equalTo(self.view).mas_equalTo(@(kScreenHeight - BYHomePageLocationButtonW - BYHomePageLocationButtonToBottomMargin));
        make.size.mas_equalTo(CGSizeMake(BYHomePageLocationButtonW, BYHomePageLocationButtonW));
    }];
    
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).mas_equalTo((kScreenWidth - BYHomePageMineButtonW)  * 0.5);
        make.top.equalTo(self.view).mas_equalTo(@(kScreenHeight - BYHomePageMineButtonH - BYHomePageLocationButtonToBottomMargin));
        make.size.mas_equalTo(CGSizeMake(BYHomePageMineButtonW, BYHomePageMineButtonH));
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    //        //    //只要加上这段代码他就会出现一个图片
    //        CLLocationCoordinate2D coords = _mapView.userLocation.location.coordinate;
    //        //地图的缩放比例
    //        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    //        //构造地图显示范围
    //        MKCoordinateRegion region = MKCoordinateRegionMake(coords, span);
    //        [_mapView setRegion:region animated:YES];
    isAppear = YES;
    _centerImageView.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[BYGPSLocation sharedGPSLocation] startLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayUserLocation:) name:@"inceptCoordinate" object:nil];
    
    isAppear = NO;
    
    [self.view addSubview:self.mapView];
    
    _centerImageView = [[UIImageView alloc] init];
    _centerImageView.centerX = self.view.centerX;
    _centerImageView.centerY = self.view.centerY;
    _centerImageView.width = 30;
    _centerImageView.height = 40;
    _centerImageView.image = [UIImage imageNamed:@"map_point_on"];
    [self.view addSubview:_centerImageView];
    
    _adressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 50 - 10 - 40, kScreenWidth, 40)];
    _adressLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_adressLabel];
    
//    if(kIOS8)
//    {
//        [self getUserLocation];
//    }
    
    [self setupConstraints];
}

- (void)displayUserLocation:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    CLLocationCoordinate2D cl = CLLocationCoordinate2DMake([dict[@"latitude"] floatValue], [dict[@"longitude"] floatValue]);
    _mapView.centerCoordinate = cl;
    
}

#pragma mark - 选好了点击事件

- (void)okBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locateBtnClick
{
//    if(kIOS8)
//    {
//        //更新位置
//        [_locationManager startUpdatingLocation];
//    }
    [_mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
}

// 获取当前位置
- (void)getUserLocation
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    //kCLLocationAccuracyBest:设备使用电池供电时候最高的精度
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.distanceFilter = 50.0f;
    if (kIOS8)
    {
        [_locationManager requestAlwaysAuthorization];
    }
    //更新位置
    [_locationManager startUpdatingLocation];
    
}
#pragma mark - CLLocationManagerDelegate  位置更新后的回调

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //停止位置更新
    [_locationManager stopUpdatingLocation];
    
    CLLocation *loc = [locations firstObject];
    CLLocationCoordinate2D theCoordinate;
    //位置更新后的经纬度
    theCoordinate.latitude = loc.coordinate.latitude;
    theCoordinate.longitude = loc.coordinate.longitude;
    //设定显示范围
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.01;
    theSpan.longitudeDelta = 0.01;
    //设置地图显示的中心及范围
    MKCoordinateRegion theRegion;
    theRegion.center = theCoordinate;
    theRegion.span = theSpan;
    [_mapView setRegion:theRegion];
    _location = [locations lastObject];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *array, NSError *error)
     {
         CLGeocoder *geocoder = [[CLGeocoder alloc] init];
         [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *array, NSError *error) {
             
             if (array.count > 0)
             {
                 CLPlacemark *placemark = [array objectAtIndex:0];
                 // 将获得的所有信息显示到label上
                 NSLog(@"%@",placemark.name);
                 // 获取城市
                 NSString *city = placemark.name;
                 if (!city) {
                     // 四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                     city = placemark.name;
                 }
                 NSLog(@"当前城市:%@",city);
                 // 设置地图显示的类型及根据范围进行显示  安放大头针
                 MKPointAnnotation *pinAnnotation = [[MKPointAnnotation alloc] init];
                 pinAnnotation.coordinate = theCoordinate;
                 pinAnnotation.title = city;
                 [_mapView addAnnotation:pinAnnotation];
             }
             else if (error == nil && [array count] == 0)
             {
                 NSLog(@"No results were returned.");
             }
             else if (error != nil)
             {
                 NSLog(@"An error occurred = %@", error);
             }
             
             
         }];
         
     }];
}

#pragma mark - MKMapViewDelegate
/**
 *  每次添加大头针都会调用此方法  可以设置大头针的样式
 *
 *  @param mapView    地图
 *  @param annotation 标记
 *
 *  @return 标记视图
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // 判断大头针位置是否在原点,如果是则不加大头针
    if([annotation isKindOfClass:[mapView.userLocation class]])
        return nil;
    static NSString *annotationName = @"annotation";
    MKPinAnnotationView *anView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationName];
    if(anView == nil)
    {
        anView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationName];
    }
    anView.animatesDrop = YES;
    // 显示详细信息
    anView.canShowCallout = YES;
//    anView.leftCalloutAccessoryView   可以设置左视图
//    anView.rightCalloutAccessoryView   可以设置右视图
    return anView;
}

//长按添加大头针事件
- (void)lpgrClick:(UILongPressGestureRecognizer *)lpgr
{
    // 判断只在长按的起始点下落大头针
    if(lpgr.state == UIGestureRecognizerStateBegan)
    {
        // 首先获取点
        CGPoint point = [lpgr locationInView:_mapView];
        // 将一个点转化为经纬度坐标
        CLLocationCoordinate2D center = [_mapView convertPoint:point toCoordinateFromView:_mapView];
        MKPointAnnotation *pinAnnotation = [[MKPointAnnotation alloc] init];
        pinAnnotation.coordinate = center;
        pinAnnotation.title = @"长按";
        [_mapView addAnnotation:pinAnnotation];
    }
}

#pragma mark mapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D coord = [userLocation coordinate];
    NSLog(@"mapView经度:%f,纬度:%f",coord.latitude,coord.longitude);
    _longitude = [NSString stringWithFormat:@"%f" ,coord.longitude];
    _latitude = [NSString stringWithFormat:@"%f" ,coord.latitude];
}
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"定位失败：%@",error);
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
    if (_longitude != nil && isAppear == YES) {
        CLLocationCoordinate2D cl =  mapView.centerCoordinate;
        NSLog(@"转换前：%f,%f",cl.latitude,cl.longitude);
        typeof(BYSelectPlaceViewController *)weakSelf = self;
        
        CLLocationCoordinate2D earthCL = [self gcj2wgs:cl ];
        //FIXME:不知什么原因有时候 PBRequester failed with Error Error Domain=NSURLErrorDomain Code=-1001 "The request timed out."所以加了线程，然并卵
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [weakSelf reverseGeocode1:earthCL.latitude  longitude:earthCL.longitude];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.8 animations:^{
                    _centerImageView.center = CGPointMake(weakSelf.view.center.x, weakSelf.view.center.y-25);
                } completion:^(BOOL finished) {
                    _centerImageView.center = CGPointMake(weakSelf.view.center.x, weakSelf.view.center.y-15);
                }];
            });
        });
    }
}
#pragma mark 反地理编码
- (void)reverseGeocode1:(double)_lat longitude:(double)_long
{
    NSLog(@"转换后:%f,%f",_lat,_long);
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    //注意初使化location参数 double转换，这里犯过错，    此外一般会用 全局_currLocation，在定位后得到
    CLLocation* location = [[CLLocation alloc] initWithLatitude:_lat longitude:_long];
    [_geocoder reverseGeocodeLocation:location
                    completionHandler:^(NSArray* placemarks, NSError* error) {
                        CLPlacemark* placemark = [placemarks firstObject];
                        NSLog(@"详细信息:%@", placemark.addressDictionary);
                        if(placemark.addressDictionary == nil){
                            _adressLabel.text = @"地图君没有识别此地。。。";
                        }else {
                            _adressLabel.text = [NSString stringWithFormat:@"%@",placemark.addressDictionary[@"Name"]];
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


@end
