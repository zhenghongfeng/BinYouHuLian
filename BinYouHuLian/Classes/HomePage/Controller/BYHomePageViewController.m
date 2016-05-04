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

@interface BYHomePageViewController () <MKMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
/** 回到当前位置 */
@property (nonatomic, strong) UIButton *locateBtn;
/** 我的 */
@property (nonatomic, strong) UIButton *mineBtn;
/** 开店 */
@property (nonatomic, strong) UIButton *createShopBtn;
/** 搜索 */
@property (nonatomic, strong) UIButton *searchBtn;

@end

@implementation BYHomePageViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLocation) name:@"location" object:nil];
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.searchBtn];
    [self.view addSubview:self.locateBtn];
    [self.view addSubview:self.mineBtn];
    [self.view addSubview:self.createShopBtn];
    
    [self setupConstraints];
    
    if(kIOS_VERSION >= 8.0)
    {
        [self getUserLocation];
    }
}

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
    
    // Masonry
    /*
     [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
     make.left.equalTo(self.view).mas_equalTo(BYHomePageLocationButtonToLeftMargin);
     make.top.equalTo(self.view).mas_equalTo(BYHomePageLocationButtonToLeftMargin * 2);
     make.size.mas_equalTo(CGSizeMake(BYHomePageMineButtonW, BYHomePageMineButtonH));
     }];
     */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

// 获取当前位置
- (void)getUserLocation
{
    // 定位管理器
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位服务当前可能尚未打开，请设置打开！");
        return;
    }
    
    // 定位精度
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // 位置信息更新最小距离，只有移动大于这个距离才更新位置信息，默认为kCLDistanceFilterNone：不进行距离限制
    _locationManager.distanceFilter = 50.0f;
    if (kIOS_VERSION >= 8.0)
    {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    // 开始定位追踪，开始定位后将按照用户设置的更新频率执行
    [_locationManager startUpdatingLocation];
    
    MKCoordinateSpan theSpan;
    //地图的范围 越小越精确
    theSpan.latitudeDelta = 0.05;
    theSpan.longitudeDelta = 0.05;
    MKCoordinateRegion theRegion;
    theRegion.center = [[_locationManager location] coordinate];
    theRegion.span = theSpan;
    [_mapView setRegion:theRegion];
}

#pragma mark - MKMapViewDelegate
/**
 *  每次添加大头针都会调用此方法  可以自定义大头针的样式
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    if ([annotation isKindOfClass:[BYAnnotation class]]) {
        static NSString *key1 = @"AnnotationKey1";
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        //如果缓存池中不存在则新建
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:key1];
            //允许交互点击
            annotationView.canShowCallout = YES;
            //定义详情视图偏移量
            annotationView.calloutOffset=CGPointMake(0, 1);
            //定义右视图
            annotationView.rightCalloutAccessoryView = ({
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
                [button setTitle:@"查看详情" forState:UIControlStateNormal];
                [button setTitleColor:kMainColor forState:UIControlStateNormal];
                button.titleLabel.numberOfLines = 2;
                [button addTarget:self action:@selector(shopDetailClick) forControlEvents:UIControlEventTouchUpInside];
                button;
            });
//            annotationView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_classify_cafe.png"]];//定义详情左侧视图
        }
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

#pragma mark - even response

- (void)mineBtnClick
{
    
    BOOL isAutoLogin = [EMClient sharedClient].options.isAutoLogin;
    
    if (isAutoLogin) {
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

- (void)shopDetailClick
{
    BYShopDetailViewController *vc = [[BYShopDetailViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)locateBtnClick
{
    if(kIOS_VERSION >= 8.0)
    {
        [self getUserLocation];
    }
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

- (void)addAnnotationLocation:(CLLocationCoordinate2D)location title:(NSString *)title subtitle:(NSString *)subtitle imageName:(NSString *)imageName
{
    CLLocationCoordinate2D locationCoordinate2D = location;
    BYAnnotation *annotation = [[BYAnnotation alloc] init];
    annotation.coordinate = locationCoordinate2D;
    annotation.title = title;
    annotation.subtitle = subtitle;
    annotation.image = [UIImage imageNamed:imageName];
//    annotation1.icon = [UIImage imageNamed:@"icon_map_cateid_3"];
//    annotation1.detail = @"各种小猫、小狗、可爱的小动物";
//    annotation1.rate = [UIImage imageNamed:@"red_check@3x"];
    [_mapView addAnnotation:annotation];
}

- (void)addLocation
{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(39.98, 116.33);
    MKPointAnnotation *pinAnnotation = [[MKPointAnnotation alloc] init];
    pinAnnotation.coordinate = location;
    [_mapView addAnnotation:pinAnnotation];
}

#pragma mark - getter

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
//        _mapView.userLocation.title = @"哈哈哈哈哈";
        //添加大头针
        [self addAnnotationLocation:CLLocationCoordinate2DMake(39.98, 116.31) title:@"宠物店" subtitle:@"海淀区成府路清华科技园" imageName:@"icon_map_arrow"];
        [self addAnnotationLocation:CLLocationCoordinate2DMake(39.99, 116.32) title:@"水果店" subtitle:@"海淀区成府路清华科技园" imageName:@"icon_map_arrow"];
        [self addAnnotationLocation:CLLocationCoordinate2DMake(40.00, 116.33) title:@"理发店" subtitle:@"海淀区成府路清华科技园" imageName:@"icon_map_arrow"];
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


#pragma mark - CLLocationManagerDelegate

// 位置更新后的回调
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    // 停止定位追踪
//    [_locationManager stopUpdatingLocation];
//
//    // 取出第一个位置
//    CLLocation *loc = [locations firstObject];
//
//    // 位置更新后的经纬度
//    CLLocationCoordinate2D theCoordinate;
//    theCoordinate.latitude = loc.coordinate.latitude; // 纬度
//    theCoordinate.longitude = loc.coordinate.longitude; // 经度
//
//    // 设定显示范围
//    MKCoordinateSpan theSpan;
//    theSpan.latitudeDelta = 0.005;
//    theSpan.longitudeDelta = 0.001;
//
//    // 设置地图显示的中心及范围
//    MKCoordinateRegion theRegion;
//    theRegion.center = theCoordinate;
//    theRegion.span = theSpan;
//    [_mapView setRegion:theRegion];
//
//    /*
//    _location = [locations lastObject];
//    // 地理编码：根据给定的位置（通常是地名）确定地理坐标(经、纬度)。
//    // 反地理编码：可以根据地理坐标（经、纬度）确定位置信息（街道、门牌等）。
//    CLGeocoder *geocoder = [[CLGeocoder alloc] init]; // 地理编码
//
//    // 反地理编码
//    [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *array, NSError *error)
//     {
//         CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//         // 地理编码
////         [geocoder geocodeAddressString:@"北京" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
////
////         }];
//         [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *array, NSError *error) {
//
//             if (array.count > 0) {
//                 CLPlacemark *placemark = [array objectAtIndex:0];
//                 // 将获得的所有信息显示到label上
//                 NSLog(@"%@",placemark.name);
//                 // 获取城市
//                 NSString *city = placemark.name;
//                 if (!city) {
//                     // 四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
//                     city = placemark.name;
//                 }
//                 NSLog(@"当前城市:%@",city);
//                 // 设置地图显示的类型及根据范围进行显示  安放大头针
//                 MKPointAnnotation *pinAnnotation = [[MKPointAnnotation alloc] init];
//                 pinAnnotation.coordinate = theCoordinate;
//                 pinAnnotation.title = city;
//                 [_mapView addAnnotation:pinAnnotation];
//             } else if (error == nil && [array count] == 0) {
//                 NSLog(@"No results were returned.");
//             } else if (error != nil) {
//                 NSLog(@"An error occurred = %@", error);
//             }
//         }];
//     }];
//     */
//}

// 点击选中某个大头针时触发
// 点击一般的大头针KCAnnotation时添加一个大头针作为所点大头针的弹出详情视图
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //    BYAnnotation *annotation=view.annotation;
    //    if ([view.annotation isKindOfClass:[BYAnnotation class]]) {
    //        //点击一个大头针时移除其他弹出详情视图
    //        //        [self removeCustomAnnotation];
    //        //添加详情大头针，渲染此大头针视图时将此模型对象赋值给自定义大头针视图完成自动布局
    //        BYCalloutAnnotation *annotation1 = [[BYCalloutAnnotation alloc] init];
    //        annotation1.icon = annotation.icon;
    //        annotation1.detail = annotation.detail;
    //        annotation1.rate = annotation.rate;
    //        annotation1.coordinate = view.annotation.coordinate;
    //        [mapView addAnnotation:annotation1];
    //    }
}
// 取消选中大头针时触发
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    //    [self removeCustomAnnotation];
}

#pragma mark 移除所用自定义大头针
- (void)removeCustomAnnotation{
    [_mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[BYCalloutAnnotation class]]) {
            [_mapView removeAnnotation:obj];
        }
    }];
}

@end
