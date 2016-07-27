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
#import "ELCImagePickerController.h"
#import "BYLookBigImageViewController.h"

static CGFloat const addButtonHeight = 60.0;
static NSInteger const cellTag = 123;
static NSInteger const uploadImageMaxNumber = 3;

@interface BYCreateShopViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BYPickerViewDelegate, UIScrollViewDelegate, BYSelectPlaceViewControllerDelegate, ELCImagePickerControllerDelegate,BYLookBigImageViewControllerDelegate>

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

@property (nonatomic, strong) NSMutableArray *array1;

// 添加图片按钮
@property (nonatomic, strong) UIButton *addBtn;

@property (nonatomic, strong) UIButton *imageBtn;

@property (nonatomic, strong) NSMutableArray *selectImageArray;

@end

@implementation BYCreateShopViewController

static NSString * const BYCreateShopAddHeaderCellID = @"addHeaderCell";
static NSString * const BYCreateShopEditCellID = @"CreateShopEditCell";

#pragma mark - KKLookBigImageViewControllerDelegate
// 新增情况的代理方法
- (void)passAddImageArray:(NSMutableArray *)array
{
    UITableViewCell *cell = [self.tableView viewWithTag:cellTag];
    // 移除所有子视图
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 创建添加按钮
    [self setupAddButtonWithArray:array cell:cell];
    
    for (NSInteger i = 0; i < array.count; i++) {
        // 新增病例情况 创建图片按钮
        [self createImageButtonWithTag:i array:array cell:cell];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - 查看大图
- (void)imageBtnClick:(UIButton *)button
{
    BYLookBigImageViewController *vc = [[BYLookBigImageViewController alloc] init];
    vc.delegate = self;
    vc.imageArray1 = self.array1;
    vc.selectBtn = button.tag - 10;
    vc.fromNewAdd = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"创建店铺";
    
    self.array1 = [NSMutableArray array];
    self.selectImageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightTopDoneClick)];
    
    [self.view addSubview:self.tableView];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"access_token"] forHTTPHeaderField:@"Authorization"];
    [manager POST:@"http://192.168.4.181/api/shop/cates?" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
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
//        BYCreateShopAddHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BYCreateShopAddHeaderCellID];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        [cell.addPhotoButton addTarget:self action:@selector(addHeadClick) forControlEvents:UIControlEventTouchUpInside];
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.tag = cellTag;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // 创建添加按钮
        [self setupAddButtonWithArray:self.array1 cell:cell];
        for (NSInteger i = 0; i < self.array1.count; i++) {
            // 新增病例情况 创建图片按钮
            [self createImageButtonWithTag:i array:self.array1 cell:cell];
        }
        
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

// 创建添加按钮
- (void)setupAddButtonWithArray:(NSMutableArray *)array cell:(UITableViewCell *)cell
{
    self.addBtn = [[UIButton alloc] initWithFrame:CGRectMake(20 + (addButtonHeight + 15) * (array.count % 4), 10 + (addButtonHeight + 10) * (array.count / 4), addButtonHeight, addButtonHeight)];
    [self.addBtn setBackgroundImage:[UIImage imageNamed:@"addImage"] forState:UIControlStateNormal];
    [self.addBtn addTarget:self action:@selector(addHeadClick) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:self.addBtn];
}

// 新增病例情况 创建图片按钮
- (void)createImageButtonWithTag:(NSInteger)i array:(NSMutableArray *)array cell:(UITableViewCell *)cell
{
    UIButton *imageBtn = [[UIButton alloc] initWithFrame:CGRectMake(20 + (addButtonHeight + 15) * (i % 4), 10 + (addButtonHeight + 10) * (i / 4), addButtonHeight, addButtonHeight)];
    imageBtn.tag = i + 10;
    [imageBtn setBackgroundImage:array[i] forState:UIControlStateNormal];
    [imageBtn addTarget:self action:@selector(imageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    imageBtn.userInteractionEnabled = YES;
    [cell.contentView addSubview:imageBtn];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return indexPath.section == 0 ? 150 : 44;
    return indexPath.section == 0 ? 10 + ((addButtonHeight + 10) * (self.array1.count / 4) + addButtonHeight + 10) : 44;
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
    if (self.array1.count == 3) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"最多上传3张图片";
        [hud hide:YES afterDelay:1];
        return;
    }
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
        
        ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
        elcPicker.maximumImagesCount = uploadImageMaxNumber - self.array1.count;
        elcPicker.returnsOriginalImage = YES;
        elcPicker.returnsImage = YES;
        elcPicker.onOrder = YES;
        elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image
        elcPicker.imagePickerDelegate = self;
        [self presentViewController:elcPicker animated:YES completion:nil];
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
    
    self.selectImageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // 选取的图片数组
    [self.selectImageArray addObject:image];
    
    UITableViewCell *cell = [self.tableView viewWithTag:cellTag];
    
    [self.array1 addObjectsFromArray:self.selectImageArray];
    self.addBtn.frame = CGRectMake(20 + (addButtonHeight + 15) * (self.array1.count % 4), 10 + (addButtonHeight + 10) * (self.array1.count / 4), addButtonHeight, addButtonHeight);
    for (int i = 0; i < self.array1.count; i++) {
        [self createImageButtonWithTag:i array:self.array1 cell:cell];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - ELCImagePickerControllerDelegate
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.selectImageArray = [[NSMutableArray alloc] initWithCapacity:0];
    UITableViewCell *cell = [self.tableView viewWithTag:cellTag];
    for (NSDictionary *dict in info)
    {
        // 获取图片
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        
        // 选取的图片数组
        [self.selectImageArray addObject:image];
    }
    [self.array1 addObjectsFromArray:self.selectImageArray];
    self.addBtn.frame = CGRectMake(20 + (addButtonHeight + 15) * (self.array1.count % 4), 10 + (addButtonHeight + 10) * (self.array1.count / 4), addButtonHeight, addButtonHeight);
    for (int i = 0; i < self.array1.count; i++) {
        [self createImageButtonWithTag:i array:self.array1 cell:cell];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
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
    if (self.category == nil) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请选择店铺类别";
        [hud hide:YES afterDelay:1];
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    BYCreateShopEditTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.shopName = cell.textField.text;
    
    if (self.shopName == nil) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入店铺名称";
        [hud hide:YES afterDelay:1];
        return;
    }
    
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
    
    [manager POST:@"http://192.168.4.181/api/shop/create?" parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        /*
         Data: 要上传的二进制数据
         name:保存在服务器上时用的Key值
         fileName:保存在服务器上时用的文件名,注意要加 .jpg或者.png
         mimeType:让服务器知道我上传的是哪种类型的文件
         */
        
         //多张图片
//         NSArray *images = @[[UIImage imageNamed:@"anon_chat_bottom_Camera_press@3x"], [UIImage imageNamed:@"addAvatar"], [UIImage imageNamed:@"ac_back"]];//获得一组Image
         for(NSInteger i = 0; i < self.array1.count; i++)
         {
         // 取出图片
         UIImage *image = [self.array1 objectAtIndex:i];
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
