//
//  BYCreateShopViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/8.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYCreateShopViewController.h"
#import "BYCreateShopAddHeaderTableViewCell.h"
#import "BYCreateShopEditTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "BYPickerView.h"
#import "BYSelectPlaceViewController.h"
#import "BYCreateShopSuccessViewController.h"

@interface BYCreateShopViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BYPickerViewDelegate, UIScrollViewDelegate, BYSelectPlaceViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
/** 店铺类别titles */
@property (nonatomic, strong) NSMutableArray *categoryTitles;
/** 半通明弹层 */
@property (nonatomic, strong) UIView *coverView;
/** 类别选择器 */
@property (nonatomic, strong) BYPickerView *pickerView;
/** category */
@property (nonatomic, copy) NSString *category;
/** name */
@property (nonatomic, copy) NSString *shopName;
/** description */
@property (nonatomic, copy) NSString *shopDescription;
/** location */
@property (nonatomic, copy) NSString *location;
/** longitude */
@property (nonatomic, copy) NSString *longitude;
/** latitude */
@property (nonatomic, copy) NSString *latitude;
@end

@implementation BYCreateShopViewController

static NSString * const BYCreateShopAddHeaderCellID = @"addHeaderCell";
static NSString * const BYCreateShopEditCellID = @"CreateShopEditCell";

#pragma mark - getter

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        // 注册cell
        [_tableView registerClass:[BYCreateShopAddHeaderTableViewCell class] forCellReuseIdentifier:BYCreateShopAddHeaderCellID];
                
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BYCreateShopEditTableViewCell class]) bundle:nil] forCellReuseIdentifier:BYCreateShopEditCellID];
    }
    return _tableView;
}

- (NSArray *)categoryTitles
{
    if (!_categoryTitles) {
        _categoryTitles = [NSMutableArray array];
    }
    return _categoryTitles;
}

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _coverView.backgroundColor = [UIColor colorWithRed:0.50f green:0.49f blue:0.47f alpha:0.50f];
        
        // 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [_coverView addGestureRecognizer:tap];
        
        [_coverView addSubview:self.pickerView];
    }
    return _coverView;
}

- (BYPickerView *)pickerView
{
    if (!_pickerView) {
        _pickerView = [[BYPickerView alloc] initPickviewWithArray:self.categoryTitles isHaveNavControler:NO];
        _pickerView.delegate = self;
    }
    return _pickerView;
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"创建店铺";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightTopDoneClick)];
    
    [self.view addSubview:self.tableView];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"access_token"] forHTTPHeaderField:@"Authorization"];
    [manager POST:@"http://192.168.4.249/api/shop/cates?" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [hud hide:YES];
            
            [responseObject[@"list"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.categoryTitles addObject:obj[@"name"]];
            }];
            
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"请输入昵称";
            [hud hide:YES afterDelay:1];
            return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"重置失败";
        [hud hide:YES afterDelay:1];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        BYCreateShopAddHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BYCreateShopAddHeaderCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.addPhotoButton addTarget:self action:@selector(addHeadClick) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    } else {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"请选择店铺类别";
            return cell;
        } else if (indexPath.row == 1) {
            BYCreateShopEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BYCreateShopEditCellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textField.placeholder = @"请输入店铺名称（建议少于10个字）";
            [cell.textField setPlaceholderColor:[UIColor blackColor]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        } else if (indexPath.row == 2) {
            BYCreateShopEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BYCreateShopEditCellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textField.placeholder = @"请输入店铺简介";
            [cell.textField setPlaceholderColor:[UIColor blackColor]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = @"选位置";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? 150 : 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (self.categoryTitles.count > 0) {
                [self.navigationController.view addSubview:self.coverView];
            } else {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"请检查您的网络";
                [hud hide:YES afterDelay:1];
                return;
            }
        }
        if (indexPath.row == 3) {
            BYSelectPlaceViewController *vc = [[BYSelectPlaceViewController alloc] init];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - BYSelectPlaceViewControllerDelegate

- (void)selectedLocation:(NSString *)location longitude:(NSString *)longitude latitude:(NSString *)latitude
{
    NSLog(@"location = %@, longitude = %@, latitude = %@", location, longitude, latitude);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = location;
    self.location = location;
    self.longitude = longitude;
    self.latitude = latitude;
}

- (void)addHeadClick
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *fromCameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            NSString *mediaType = AVMediaTypeVideo;
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"请在'设置-隐私-相机'允许访问相机";
                
                return;
            } else {
                UIImagePickerController *pickImage = [[UIImagePickerController alloc] init];
                pickImage.delegate = weakSelf;
                pickImage.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickImage.allowsEditing = YES;
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]){
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                }
                [self.navigationController presentViewController:pickImage animated:YES completion:nil];
            }
        }
    }];
    
    UIAlertAction* fromPhotoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController * imagePickerC = [[UIImagePickerController alloc] init];
        imagePickerC.delegate = weakSelf;
        imagePickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerC.allowsEditing = YES;
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]){
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }
        [self presentViewController:imagePickerC animated:YES completion:nil];
    }];
    
    [alertController addAction:fromCameraAction];
    [alertController addAction:fromPhotoAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

// 完成选取图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
//    UIImage *roundImage = [image imageByRoundCornerRadius:2];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    BYCreateShopAddHeaderTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.addPhotoButton.adjustsImageWhenHighlighted = NO;
//    [cell.addHeadButton setBackgroundImage:roundImage forState:UIControlStateNormal];
//    [cell.addHeadButton setBackgroundImage:roundImage forState:UIControlStateHighlighted];
    [cell.addPhotoButton setImage:[UIImage imageNamed:@"add_header_edit_btn"] forState:UIControlStateNormal];
}

#pragma mark - BYPickerViewDelegate

-(void)toobarDonBtnHaveClick:(BYPickerView *)pickView resultString:(NSString *)resultString
{
    NSLog(@"%@", resultString);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = resultString;
    self.category = resultString;
}

#pragma mark - 移除半通明_coverView
- (void)tapClick
{
    [_coverView removeFromSuperview];
}

#pragma mark - 右上角的done
- (void)rightTopDoneClick
{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    BYCreateShopEditTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.shopName = cell.textField.text;
    
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:2 inSection:1];
    BYCreateShopEditTableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:indexPath1];
    self.shopDescription = cell1.textField.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *dic = @{@"name": self.shopName,
                          @"description": self.shopDescription,
                          @"category": self.category,
                          @"longitude": self.longitude,
                          @"latitude": self.latitude,
                          @"location": self.location
                          };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"access_token"] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:@"http://192.168.4.249/api/shop/create?" parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        /*
         Data: 要上传的二进制数据
         name:保存在服务器上时用的Key值
         fileName:保存在服务器上时用的文件名,注意要加 .jpg或者.png
         mimeType:让服务器知道我上传的是哪种类型的文件
         */
        
         //多张图片
         NSArray *images = @[[UIImage imageNamed:@"anon_chat_bottom_Camera_press@3x"], [UIImage imageNamed:@"addAvatar"], [UIImage imageNamed:@"ac_back"]];//获得一组Image
         for(NSInteger i = 0; i < 3; i++)
         {
         // 取出图片
         UIImage *image = [images objectAtIndex:i];
         // 转成二进制
         NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
         // 上传的参数名
         NSString * Name = [NSString stringWithFormat:@"image %ld", i];
         // 上传fileName
         NSString * fileName = [NSString stringWithFormat:@"%@.jpg", Name];
         
         [formData appendPartWithFileData:imageData name:@"files" fileName:fileName mimeType:@"image/jpeg"];
         }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        
        NSInteger code = [responseObject[@"code"] integerValue];
        
        if (code == 1) {
            
            [hud hide:YES];
            
            [self.navigationController popViewControllerAnimated:YES];

        } else {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"请输入昵称";
            [hud hide:YES afterDelay:1];
            return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"注册失败";
        [hud hide:YES afterDelay:1];
    }];
}




@end
