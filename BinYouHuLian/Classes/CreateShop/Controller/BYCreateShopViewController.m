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

@interface BYCreateShopViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BYCreateShopViewController

static NSString * const BYCreateShopAddHeaderCellID = @"addHeaderCell";
static NSString * const BYCreateShopEditCellID = @"CreateShopEditCell";


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
    
    [self setupTableView];
}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
        
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BYCreateShopAddHeaderTableViewCell class]) bundle:nil] forCellReuseIdentifier:BYCreateShopAddHeaderCellID];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BYCreateShopEditTableViewCell class]) bundle:nil] forCellReuseIdentifier:BYCreateShopEditCellID];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : 2;
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
            BYCreateShopEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BYCreateShopEditCellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            static NSString *ID = @"cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            }
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
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            [self.view endEditing:YES];
            [self.navigationController popViewControllerAnimated:YES];
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
//    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    //在这里 调用上传头像的接口
    
    UIImage *roundImage = [image circleWithImage:image inset:2];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    BYCreateShopAddHeaderTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.addHeadButton.adjustsImageWhenHighlighted = NO;
    [cell.addHeadButton setBackgroundImage:roundImage forState:UIControlStateNormal];
    [cell.addHeadButton setBackgroundImage:roundImage forState:UIControlStateHighlighted];
    [cell.addHeadButton setImage:[UIImage imageNamed:@"add_header_edit_btn"] forState:UIControlStateNormal];
}


















@end
