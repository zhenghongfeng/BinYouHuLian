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

#import <Masonry.h>

@interface BYHomePageViewController () <MKMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) CLLocation *location;
/** 回到当前位置按钮 */
@property (nonatomic, strong) UIButton *locateBtn;
/** 我的按钮 */
@property (nonatomic, strong) UIButton *mineBtn;
/** 开店 */
@property (nonatomic, strong) UIButton *createShopBtn;
/** 搜索 */
@property (nonatomic, strong) UIButton *searchBtn;

@end

@implementation BYHomePageViewController

- (UIButton *)locateBtn
{
    if (!_locateBtn) {
        _locateBtn = [[UIButton alloc] init];
        [_locateBtn setImage:[UIImage imageNamed:@"icon_locate_in_map"] forState:UIControlStateNormal];
        [_locateBtn addTarget:self action:@selector(locateBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_locateBtn];
    }
    return _locateBtn;
}

- (UIButton *)mineBtn
{
    if (!_mineBtn) {
        _mineBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth * 0.5 - 40, kScreenHeight - 50, 80, 30)];
        [_mineBtn setTitle:@"我的" forState:UIControlStateNormal];
        _mineBtn.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
        [_mineBtn addTarget:self action:@selector(mineBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mineBtn;
}

- (UIButton *)createShopBtn
{
    if (!_createShopBtn) {
        _createShopBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 90, kScreenHeight - 50, 80, 30)];
        [_createShopBtn setTitle:@"开店" forState:UIControlStateNormal];
        _createShopBtn.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
        [_createShopBtn addTarget:self action:@selector(createShopBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createShopBtn;
}

- (UIButton *)searchBtn
{
    if (!_searchBtn) {
        _searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 80, 30)];
        [_searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
        _searchBtn.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
        [_searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchBtn;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMapView];
    
    [self.locateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).mas_equalTo(BYHomePageLocationButtonToLeftMargin);
        make.top.equalTo(self.view).mas_equalTo(@(kScreenHeight - BYHomePageLocationButtonW - BYHomePageLocationButtonToBottomMargin));
        make.size.mas_equalTo(CGSizeMake(BYHomePageLocationButtonW, BYHomePageLocationButtonW));
    }];
    
    [self.view addSubview:self.mineBtn];
    
    [self.view addSubview:self.createShopBtn];
    
    [self.view addSubview:self.searchBtn];
    
    
}

- (void)setupMapView
{
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    // 显示当前位置
    _mapView.showsUserLocation = YES;
    [self.view addSubview:_mapView];
    
    if(kIOS8)
    {
        [self getUserLocation];
    }
}

- (void)locateBtnClick
{
    // 显示当前位置
    _mapView.showsUserLocation = YES;
    
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

- (void)mineBtnClick
{
    BOOL isLogin = YES;
    if (isLogin) {
        BYMineViewController *vc = [[BYMineViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        BYRegisterViewController *vc = [[BYRegisterViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)searchBtnClick
{
    BYSearchViewController *vc = [[BYSearchViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)createShopBtnClick
{
    BYCreateShopViewController *vc = [[BYCreateShopViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
