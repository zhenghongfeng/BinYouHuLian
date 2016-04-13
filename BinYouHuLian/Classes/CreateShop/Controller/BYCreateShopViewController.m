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

@interface BYCreateShopViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BYPickerViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
/** 店铺类别titles */
@property (nonatomic, strong) NSArray *categoryTitles;
/** 半通明弹层 */
@property (nonatomic, strong) UIView *coverView;
/** 类别选择器 */
@property (nonatomic, strong) BYPickerView *pickerView;

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
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BYCreateShopAddHeaderTableViewCell class]) bundle:nil] forCellReuseIdentifier:BYCreateShopAddHeaderCellID];
        
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BYCreateShopEditTableViewCell class]) bundle:nil] forCellReuseIdentifier:BYCreateShopEditCellID];
    }
    return _tableView;
}

- (NSArray *)categoryTitles
{
    if (!_categoryTitles) {
        _categoryTitles = @[@"宠物店", @"服装店", @"食品店", @"足疗店", @"理发店"];
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
        [cell.addHeadButton addTarget:self action:@selector(addHeadClick) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    } else {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"请选择店铺类别";
            return cell;
        } else if (indexPath.row == 1) {
            BYCreateShopEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BYCreateShopEditCellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textField setPlaceholderColor:[UIColor blackColor]];
            return cell;
        } else if (indexPath.row == 2) {
            BYCreateShopEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BYCreateShopEditCellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textField.placeholder = @"请输入店铺简介";
            [cell.textField setPlaceholderColor:[UIColor blackColor]];
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = @"选位置";
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
            [self.navigationController.view addSubview:self.coverView];
        }
        if (indexPath.row == 3) {
            BYSelectPlaceViewController *vc = [[BYSelectPlaceViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
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
    
    UIImage *roundImage = [image circleWithImage:image inset:2];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    BYCreateShopAddHeaderTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.addHeadButton.adjustsImageWhenHighlighted = NO;
    [cell.addHeadButton setBackgroundImage:roundImage forState:UIControlStateNormal];
    [cell.addHeadButton setBackgroundImage:roundImage forState:UIControlStateHighlighted];
    [cell.addHeadButton setImage:[UIImage imageNamed:@"add_header_edit_btn"] forState:UIControlStateNormal];
}

#pragma mark - BYPickerViewDelegate

-(void)toobarDonBtnHaveClick:(BYPickerView *)pickView resultString:(NSString *)resultString
{
    NSLog(@"%@", resultString);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = resultString;
}

#pragma mark - 移除半通明_coverView
- (void)tapClick
{
    [_coverView removeFromSuperview];
}

#pragma mark - 右上角的done
- (void)rightTopDoneClick
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"正在创建";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hide:YES];
        BYCreateShopSuccessViewController *vc = [[BYCreateShopSuccessViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    });
}




@end
