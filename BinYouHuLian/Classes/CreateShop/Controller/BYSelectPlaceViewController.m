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

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) CLLocation *location;
/** 回到当前位置按钮 */
@property (nonatomic, strong) UIButton *locateBtn;

/** ok按钮 */
@property (nonatomic, strong) UIButton *okButton;

@end

@implementation BYSelectPlaceViewController

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        // 显示当前位置
        _mapView.showsUserLocation = YES;
    }
    return _mapView;
}

- (UIButton *)locateBtn
{
    if (!_locateBtn) {
        _locateBtn = [self createButtonWithTitle:nil image:@"icon_locate_in_map" action:@selector(locateBtnClick)];
    }
    return _locateBtn;
}

- (UIButton *)okButton
{
    if (!_okButton) {
        _okButton = [self createButtonWithTitle:@"选好了" image:nil action:@selector(okBtnClick)];
    }
    return _okButton;
}

- (UIButton *)createButtonWithTitle:(NSString *)title image:(NSString *)image action:(SEL)action
{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    button.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.mapView];
    
    if(kIOS8)
    {
        [self getUserLocation];
    }
    
    [self setupConstraints];
}

#pragma mark - 选好了点击事件

- (void)okBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locateBtnClick
{
    if(kIOS8)
    {
        //更新位置
        [_locationManager startUpdatingLocation];
    }
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

//- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(nullable UIView *)view
//{
//    
//}
//- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(nullable UIView *)view
//{
//    
//}


@end
