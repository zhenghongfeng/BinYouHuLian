//
//  ViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/7.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYHomePageViewController.h"
#import "BYRegisterViewController.h"
#import "BYMineViewController.h"
#import "BYSearchViewController.h"
#import "BYCreateShopViewController.h"
#import "BYAnnotation.h"
#import "BYShopDetailViewController.h"
#import "BYShop.h"
#import "ChatViewController.h"
#import "BYFriend.h"
#import "BYMySafeDictionary.h"

static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";

@interface BYHomePageViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
{
    NSString *_longitude;//用户经度
    NSString *_latitude;//用户纬度
}
// 地图是否显示完成
@property (nonatomic, assign) BOOL isAppear;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) UIButton *searchButton;

@property (nonatomic, strong) UIButton *locateButton;

@property (nonatomic, strong) UIButton *mineButton;

@property (nonatomic, strong) UIButton *createShopButton;

@property (nonatomic, strong) UIImageView *centerImageView;

@property (nonatomic, strong) CLGeocoder* geocoder;

@property (nonatomic, strong) UILabel *adressLabel;

@property (nonatomic, strong) NSMutableArray *annotations;

@property (nonatomic, strong) NSMutableArray *shops;

@property (nonatomic, strong) BYFriend *friend;

@property (nonatomic, strong) UIView *redDotView;

@property (nonatomic, strong) UIButton *rightBarButton;


@end

@implementation BYHomePageViewController

#pragma mark - NSNotificationCenter event

- (void)searchShop:(NSNotification *)notification
{
    [self requestSearchShop:notification.object];
}

- (void)redDot
{
//    self.redDotView.hidden = NO;
    [self.rightBarButton setImage:[UIImage imageNamed:@"applyRedDot"] forState:UIControlStateNormal];
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
    _isAppear = YES;
    
    // red dot
    [self requestRedDot];
}

- (UIView *)redDotView
{
    if (_redDotView == nil) {
        _redDotView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth - 20, 30, 5, 5)];
        _redDotView.backgroundColor = [UIColor redColor];
        _redDotView.layer.masksToBounds = YES;
        _redDotView.layer.cornerRadius = 2.5;
        _redDotView.hidden = YES;
    }
    return _redDotView;
}

- (UIButton *)rightBarButton
{
    if (_rightBarButton == nil) {
        _rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
//        [_rightBarButton setImage:[UIImage imageNamed:@"home_me"] forState:UIControlStateNormal];

        [_rightBarButton setImage:[UIImage imageNamed:@"applyNoRedDot"] forState:UIControlStateNormal];
        [_rightBarButton addTarget:self action:@selector(mineBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBarButton;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"宾友";
    self.annotations = @[].mutableCopy;
    self.shops = @[].mutableCopy;
    
//    [self.navigationController.navigationBar addSubview:self.redDotView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [button setImage:[UIImage imageNamed:@"home_search"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
        button;
    })];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchShop:) name:kNotficationSearchShopToHome object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestRedDot) name:kNotficationApplyRedDot object:nil];
    
    [self.view addSubview:self.mapView];
//    [self.view addSubview:self.searchButton];
    [self.view addSubview:self.locateButton];
    [self.view addSubview:self.mineButton];
//    [self.view addSubview:self.createShopButton];
    [self.view addSubview:self.centerImageView];
    [self.view addSubview:self.adressLabel];
    
    [self.locationManager startUpdatingLocation];
    
    if ([NSString isValueableString:GetToken]) {
        [self  judgeToken];
    }
    
    self.searchButton.sd_layout.leftSpaceToView(self.view, BYMargin)
    .topSpaceToView(self.view, BYMargin * 2)
    .widthIs(BYHomeButtonW)
    .heightIs(BYHomeButtonH);
    
    self.locateButton.sd_layout
    .leftSpaceToView(self.view, BYMargin)
    .bottomSpaceToView(self.view, BYMargin * 2)
    .widthIs(BYHomeButtonH)
    .heightIs(BYHomeButtonH);
    
    self.mineButton.sd_layout
    .bottomSpaceToView(self.view, BYMargin * 2)
    .centerXEqualToView(self.view)
    .widthIs(BYHomeButtonW)
    .heightIs(BYHomeButtonH);
    
    self.createShopButton.sd_layout
    .rightSpaceToView(self.view, BYMargin)
    .bottomSpaceToView(self.view,BYMargin * 2)
    .widthIs(BYHomeButtonW)
    .heightIs(BYHomeButtonH);
    
    self.centerImageView.sd_layout
    .centerXIs(self.view.centerX)
    .topSpaceToView(self.navigationController.navigationBar, (kScreenHeight - 64) / 2 - 30)
    .widthIs(20)
    .heightIs(30);
}

- (void)requestRedDot
{
    NSDictionary *dic = @{@"username": GetPhone};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/apply/list/count?"] parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            if ([responseObject[@"applyListCount"] integerValue]) {
                [_rightBarButton setImage:[UIImage imageNamed:@"applyRedDot"] forState:UIControlStateNormal];
            } else {
                [_rightBarButton setImage:[UIImage imageNamed:@"applyNoRedDot"] forState:UIControlStateNormal];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}

- (void)judgeToken
{
    NSDictionary *dic = @{
                          @"friend": GetPhone
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/friendinfo?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"userinfo == %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1000) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您的账号被另一台设备挤掉线" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                BYRegisterViewController *vc = [[BYRegisterViewController alloc] init];
                vc.isPopToHome = YES;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                nav.navigationBar.hidden = YES;
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
                SaveToken(nil);
                SavePhone(nil);
                SaveNickName(nil);
                SaveAvatar(nil);
            }];
            [alert addAction:action];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self.locationManager stopUpdatingLocation];
}

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
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请在手机设置-隐私-定位服务中允许访问位置信息" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *url = [NSURL URLWithString:@"prefs:root=info.binyou.binyouhulian"];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                NSLog(@"定位关闭，不可用");
            }
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
 *  每次添加标注都会调用此方法  可以自定义标注的样式
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // 对用户当前的位置的大头针特殊处理，直接使用系统提供的大头针
    if ([annotation isKindOfClass:[BYAnnotation class]] == NO) {
        return nil;
    }
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] init];
    annotationView.canShowCallout = YES;
    annotationView.calloutOffset = CGPointMake(0, 1);
    annotationView.rightCalloutAccessoryView = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
        button.tag = [(BYAnnotation *)annotation tag];
        [button setTitle:@"查看详情" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.07f green:0.80f blue:0.43f alpha:1.00f] forState:UIControlStateNormal];
        button.titleLabel.numberOfLines = 2;
        [button addTarget:self action:@selector(shopDetailClick:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    annotationView.annotation = (BYAnnotation *)annotation;
    annotationView.annotation.coordinate = annotation.coordinate;
    annotationView.image = ((BYAnnotation *)annotation).image;
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D coord = [userLocation coordinate];
    _longitude = [NSString stringWithFormat:@"%f" ,coord.longitude];
    _latitude = [NSString stringWithFormat:@"%f" ,coord.latitude];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    _adressLabel.text = @"正在获取你选择的地点...";
    NSLog(@"将要变化");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"已经变化");
    
    NSLog(@"%f---%f", mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
    
    if (_latitude != nil && _isAppear == YES) {
        
        [self requestSearchShop:@""];
        
        CLLocationCoordinate2D cl =  mapView.centerCoordinate;
        
        CLLocation* location = [[CLLocation alloc] initWithLatitude:cl.latitude longitude:cl.longitude];
        
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error) {
            CLPlacemark *placemark = [placemarks firstObject];
            if(placemark.addressDictionary == nil){
                self.adressLabel.text = @"地图没有识别到此地";
            } else {
                self.adressLabel.text = placemark.name;
            }
        }];
        
//        NSLog(@"转换前：%f,%f",cl.latitude,cl.longitude);
//        
//        WeakSelf;
//        CLLocationCoordinate2D earthCL = [self homegcj2wgs:cl];
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            [weakSelf homereverseGeocode1:earthCL.latitude  longitude:earthCL.longitude];
//            dispatch_async(dispatch_get_main_queue(), ^{
////                self.centerImageView.center = weakSelf.view.center;
//            });
//        });
    }
}

#pragma mark 反地理编码
- (void)homereverseGeocode1:(double)latitude longitude:(double)longitude
{
    CLLocation* location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error) {
        CLPlacemark *placemark = [placemarks firstObject];
        if(placemark.addressDictionary == nil){
            self.adressLabel.text = @"地图没有识别到此地";
        } else {
            self.adressLabel.text = placemark.name;
        }
    }];
}

- (void)requestSearchShop:(NSString *)key
{
    //UIKit坐标点转化 ——>  经纬度
    CLLocationCoordinate2D leftTopCoornation = [_mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:_mapView];
    
    CLLocationCoordinate2D rightBottomcoornation = [_mapView convertPoint:CGPointMake(kScreenWidth, kScreenHeight) toCoordinateFromView:_mapView];
    
    NSDictionary *dic = @{
                          @"lowerlong": @(leftTopCoornation.longitude),
                          @"lowerlati": @(leftTopCoornation.latitude),
                          @"upperlong": @(rightBottomcoornation.longitude),
                          @"upperlati": @(rightBottomcoornation.latitude),
                          @"key": key
                          };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[BYURL_Development stringByAppendingString:@"/shop/search?"] parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [_mapView removeAnnotations:_mapView.annotations];
            NSMutableArray *annotationArr = [NSMutableArray array];
            self.shops = [BYShop mj_objectArrayWithKeyValuesArray:responseObject[@"stores"]];
            for (int i = 0; i < self.shops.count; i++) {
                BYShop *shop = self.shops[i];
                CLLocationCoordinate2D locationCoordinate2D = CLLocationCoordinate2DMake([shop.latitude doubleValue], [shop.longitude doubleValue]);
                BYAnnotation *annotation = [[BYAnnotation alloc] init];
                annotation.coordinate = locationCoordinate2D;
                annotation.tag = i;
                annotation.shop = shop;
                [annotationArr addObject:annotation];
            }
            [_mapView addAnnotations:annotationArr];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
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
    NSLog(@"token = %@", GetToken);
    if ([NSString isValueableString:GetToken]) {
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
    //UIKit坐标点转化 ——>  经纬度
    CLLocationCoordinate2D leftTopCoornation = [_mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:_mapView];
    NSLog(@"leftTopCoornation = %f, %f", leftTopCoornation.latitude, leftTopCoornation.longitude);
    
    CLLocationCoordinate2D rightBottomcoornation = [_mapView convertPoint:CGPointMake(kScreenWidth, kScreenHeight) toCoordinateFromView:_mapView];
    
    BYSearchViewController *vc = [[BYSearchViewController alloc] init];
    vc.leftTopLatitude = leftTopCoornation.latitude;
    vc.leftTopLongitude = leftTopCoornation.longitude;
    vc.rightBottomLatitude = rightBottomcoornation.latitude;
    vc.rightBottomLongitude = rightBottomcoornation.longitude;
//    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)createShopBtnClick
{
    if ([NSString isValueableString:GetToken]) {
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

#pragma mark - public

- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSString *from = [notification.userInfo valueForKey:@"from"];
    NSDictionary *dic = @{
                          @"friend": from
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/friendinfo?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"userinfo == %@", responseObject);
        self.friend = [BYFriend mj_objectWithKeyValues:responseObject[@"userInfo"]];
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            NSDictionary *userInfo = notification.userInfo;
            if (userInfo)
            {
                if ([self.navigationController.topViewController isKindOfClass:[ChatViewController class]]) {
                    
                    ChatViewController *chatingVC = (ChatViewController *)self.navigationController.topViewController;
                    // 不同的对话者 需要更换界面
                    if (![chatingVC.myFriend.phone isEqualToString:self.friend.phone]) {
                        [chatingVC removeFromParentViewController];
                        ChatViewController *chatVC = [[ChatViewController alloc] initWithConversationChatter:self.friend.phone conversationType:EMConversationTypeChat];
                        chatVC.myFriend = self.friend;
                        chatVC.navigationItem.title = self.friend.nickname;
                        [self.navigationController pushViewController:chatVC animated:NO];
                    }
                } else {
                    if (userInfo)
                    {
                        NSArray *viewControllers = self.navigationController.viewControllers;
                        [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                            if (obj != self)
                            {
                                if (![obj isKindOfClass:[ChatViewController class]])
                                {
                                    [self.navigationController popViewControllerAnimated:NO];
                                }
                                else
                                {
                                    NSString *conversationChatter = userInfo[kConversationChatter];
                                    ChatViewController *chatViewController = (ChatViewController *)obj;
                                    if (![chatViewController.conversation.conversationId isEqualToString:conversationChatter])
                                    {
                                        [self.navigationController popViewControllerAnimated:NO];
                                        EMChatType messageType = [userInfo[kMessageType] intValue];
                                        chatViewController = [[ChatViewController alloc] initWithConversationChatter:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
                                        switch (messageType) {
                                            case EMChatTypeChat:
                                            {
                                                chatViewController.myFriend = self.friend;
                                                //                                        chatViewController.title = friend.nickname;
                                                //                                        chatViewController.imageURL = friend.avatar;
                                                NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
                                                for (EMGroup *group in groupArray) {
                                                    
                                                    if ([group.groupId isEqualToString:conversationChatter]) {
                                                        
                                                        chatViewController.myFriend = self.friend;
                                                        //   chatViewController.title = group.subject;
                                                        //                                                chatViewController.title = chater;
                                                        //                                                chatViewController.imageURL = chaterImage;
                                                        break;
                                                    }
                                                }
                                            }
                                                break;
                                            default:
                                                chatViewController.myFriend = self.friend;
                                                // chatViewController.title = conversationChatter;
                                                //                                        chatViewController.title = chater;
                                                //                                        chatViewController.imageURL = chaterImage;
                                                break;
                                        }
                                        [self.navigationController pushViewController:chatViewController animated:NO];
                                    }
                                    *stop= YES;
                                }
                            } else {
                                ChatViewController *chatViewController = (ChatViewController *)obj;
                                NSString *conversationChatter = userInfo[kConversationChatter];
                                EMChatType messageType = [userInfo[kMessageType] intValue];
                                chatViewController = [[ChatViewController alloc] initWithConversationChatter:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
                                switch (messageType) {
                                    case EMChatTypeGroupChat:
                                    {
                                        NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
                                        for (EMGroup *group in groupArray) {
                                            if ([group.groupId isEqualToString:conversationChatter]) {
                                                chatViewController.myFriend = self.friend;
                                                //      chatViewController.title = group.subject;
                                                //                                        chatViewController.title = chater;
                                                //                                        chatViewController.imageURL = chaterImage;
                                                break;
                                            }
                                        }
                                    }
                                        break;
                                    default:
                                        chatViewController.myFriend = self.friend;
                                        //  chatViewController.title = conversationChatter;
                                        //                                chatViewController.title = chater;
                                        //                                chatViewController.imageURL = chaterImage;
                                        break;
                                }
                                chatViewController.navigationItem.title = self.friend.nickname;
                                [self.navigationController pushViewController:chatViewController animated:NO];
                            }
                        }];
                    }
                }
            }
        } else {
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
    }];
}

- (EMConversationType)conversationTypeFromMessageType:(EMChatType)type
{
    EMConversationType conversatinType = EMConversationTypeChat;
    switch (type) {
        case EMChatTypeChat:
            conversatinType = EMConversationTypeChat;
            break;
        case EMChatTypeGroupChat:
            conversatinType = EMConversationTypeGroupChat;
            break;
        case EMChatTypeChatRoom:
            conversatinType = EMConversationTypeChatRoom;
            break;
        default:
            break;
    }
    return conversatinType;
}

#pragma mark - 离线推送

-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    WeakSelf;
    NSDictionary *dic = @{
                          @"friend": userInfo[@"f"]
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/friendinfo?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            weakSelf.friend = [BYFriend mj_objectWithKeyValues:responseObject[@"userInfo"]];
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithConversationChatter:weakSelf.friend.phone conversationType:EMConversationTypeChat];
            chatViewController.myFriend = weakSelf.friend;
            chatViewController.navigationItem.title = weakSelf.friend.nickname;
            [weakSelf.navigationController pushViewController:chatViewController animated:NO];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:weakSelf.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:weakSelf.view];
    }];
}

#pragma mark - lazy load
- (CLLocationManager *)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    return _locationManager;
}

- (MKMapView *)mapView
{
    if (_mapView == nil) {
//        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
//        _mapView.showsScale = YES;
        // 跟踪用户
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        // 禁止地图旋转
        _mapView.rotateEnabled = NO;
        
        CLLocationCoordinate2D coord2D = _mapView.centerCoordinate;
        // 显示区域精度
        MKCoordinateSpan span = {0.01, 0.01};
        // 设置显示区域
        MKCoordinateRegion region = {coord2D, span};
        // 给地图设置显示区域
        [_mapView setRegion:region animated:YES];
    }
    return _mapView;
}

- (UIButton *)locateButton
{
    if (_locateButton == nil) {
        _locateButton = [self createButtonWithTitle:nil image:@"icon_locate_in_map" action:@selector(locateBtnClick) alpha:0.0];
    }
    return _locateButton;
}

- (UIButton *)mineButton
{
    if (_mineButton == nil) {
//        _mineButton = [self createButtonWithTitle:@"我的" image:nil action:@selector(mineBtnClick) alpha:0.6];
        _mineButton = [self createButtonWithTitle:@"开店" image:nil action:@selector(createShopBtnClick) alpha:0.6];
    }
    return _mineButton;
}

- (UIButton *)createShopButton
{
    if (_createShopButton == nil) {
        _createShopButton = [self createButtonWithTitle:@"开店" image:nil action:@selector(createShopBtnClick) alpha:0.6];
    }
    return _createShopButton;
}

- (UIButton *)searchButton
{
    if (_searchButton == nil) {
        _searchButton = [self createButtonWithTitle:@"搜索" image:nil action:@selector(searchBtnClick) alpha:0.6];
    }
    return _searchButton;
}

- (UIImageView *)centerImageView
{
    if (_centerImageView == nil) {
        _centerImageView = [[UIImageView alloc] init];
        _centerImageView.image = [UIImage imageNamed:@"map_point_on"];
    }
    return _centerImageView;
}

- (CLGeocoder *)geocoder
{
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (UILabel *)adressLabel
{
    if (_adressLabel == nil) {
        _adressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 50 - 10 - 40, kScreenWidth, 40)];
        _adressLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _adressLabel;
}

#pragma mark - custom methods

- (UIButton *)createButtonWithTitle:(NSString *)title image:(NSString *)image action:(SEL)action alpha:(CGFloat)alpha
{
    UIButton *button = [UIButton new];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    button.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    return button;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotficationSearchShopToHome object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotficationApplyRedDot object:nil];
}

@end
