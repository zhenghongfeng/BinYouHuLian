//
//  BYAboutMeInfoViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/1.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYAboutMeInfoViewController.h"
#import "BYAboutMeInfoHeadTableViewCell.h"
#import "BYAboutMeInfoNicknameTableViewCell.h"
#import "BYModifyNickNameViewController.h"
#import "UserCacheManager.h"

@interface BYAboutMeInfoViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BYAboutMeInfoViewController

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"个人信息";
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        BYAboutMeInfoHeadTableViewCell *cell = [[BYAboutMeInfoHeadTableViewCell alloc] init];
        cell.textLabel.text = @"头像";
        [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:[@"http://123.56.186.178/api/download/img?path=" stringByAppendingString:GetAvatar]] placeholderImage:[UIImage imageNamed:@"add_header_edit_btn"]];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else {
        BYAboutMeInfoNicknameTableViewCell *cell = [[BYAboutMeInfoNicknameTableViewCell alloc] init];
        cell.textLabel.text = @"昵称";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.myNickNameLabel.text = GetNickName;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
// 设置cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 60;
    } else {
        return 44;
    }
}

// cell点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { // 换头像
        [self modifyAvatar];
    }
    if (indexPath.row == 1) { // 修改昵称
        BYAboutMeInfoNicknameTableViewCell *cell = (BYAboutMeInfoNicknameTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        BYModifyNickNameViewController *vc = [[BYModifyNickNameViewController alloc] init];
        vc.nickNameString = cell.myNickNameLabel.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)modifyAvatar
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:0];
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    UIAlertAction *photo = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    // 用来判断来源 Xcode中的模拟器是没有拍摄功能的,当用模拟器的时候我们不需要把拍照功能加速
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertController addAction:photo];
        [alertController addAction:camera];
        [alertController addAction:cancel];
    } else {
        [alertController addAction:photo];
        [alertController addAction:cancel];
    }
}

//这个是选取完照片后要执行的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    //选取裁剪后的图片
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/user/avatar?"] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);//将UIImage转为NSData，1.0表示不压缩图片质量。
        [formData appendPartWithFileData:data name:@"avatar" fileName:@"test.jpg" mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        [hud hide:YES];
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            SaveAvatar(responseObject[@"avatar"]);
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            BYAboutMeInfoHeadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:[@"http://123.56.186.178/api/download/img?path=" stringByAppendingString:GetAvatar]] placeholderImage:[UIImage imageNamed:@"add_header_edit_btn"]];
            [self.tableView reloadData];
            
            [MBProgressHUD showModeText:@"头像修改成功" view:self.view];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [hud hide:YES];
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}

@end
