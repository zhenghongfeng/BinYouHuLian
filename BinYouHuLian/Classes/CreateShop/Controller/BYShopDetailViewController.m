//
//  BYShopDetailViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/18.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYShopDetailViewController.h"
#import "BYShopIntroTableViewCell.h"
#import <UITableView+SDAutoTableViewCellHeight.h>
#import <SDCycleScrollView.h>
#import "ChatViewController.h"

#import "BYFriend.h"
#import "BYRoom.h"
#import "BYRegisterViewController.h"

@interface BYShopDetailViewController ()

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) BYFriend *friend;

@end

@implementation BYShopDetailViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"shop==%@", self.shop.name);
    
    self.title = @"店铺详情";
    self.titles = @[@"店名", @"类型", @"图文简介"];

    [self setupTabelView];
}

- (void)setupTabelView
{
    if (self.shop.images.count > 0) {
        
        UIView *header = [UIView new];
        
        SDCycleScrollView *scrollView = [SDCycleScrollView new];
        scrollView.placeholderImage = [UIImage imageNamed:@"shopPlaceholder"];
        scrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;

//        NSString *str1 = [BYImageURL stringByAppendingString:self.shop.picshow1];
        scrollView.imageURLStringsGroup = self.shop.images;
        
//        if (self.shop.picshow2) {
//            NSString *str2 = [BYImageURL stringByAppendingString:self.shop.picshow2];
//            scrollView.imageURLStringsGroup = @[str1, str2];
//            if (self.shop.picshow3) {
//                NSString *str3 = [BYImageURL stringByAppendingString:self.shop.picshow3];
//                scrollView.imageURLStringsGroup = @[str1, str2, str3];
//            }
//        }
        
        [header addSubview:scrollView];
        
        scrollView.sd_layout
        .leftSpaceToView(header, 0)
        .topSpaceToView(header, 0)
        .rightSpaceToView(header, 0)
        .heightIs(kScreenWidth);
        
        [header setupAutoHeightWithBottomView:scrollView bottomMargin:0];
        
        self.tableView.tableHeaderView = scrollView;
    }
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 100)];

    UIButton *privateChatbtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, self.view.width * 0.5 - 20, 40)];
    privateChatbtn.backgroundColor = [UIColor blackColor];
    privateChatbtn.layer.masksToBounds = YES;
    privateChatbtn.layer.cornerRadius = 5;
    [privateChatbtn setTitle:@"和老板私聊" forState:UIControlStateNormal];
    [privateChatbtn addTarget:self action:@selector(chatClick) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:privateChatbtn];
    
    UIButton *groupChatbtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width * 0.5 + 10, 10, self.view.width * 0.5 - 20, 40)];
    groupChatbtn.backgroundColor = [UIColor blackColor];
    groupChatbtn.layer.masksToBounds = YES;
    groupChatbtn.layer.cornerRadius = 5;
    [groupChatbtn setTitle:@"和老板群聊" forState:UIControlStateNormal];
    [groupChatbtn addTarget:self action:@selector(groupChatClick) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:groupChatbtn];
    
    self.tableView.tableFooterView = footerView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    BYShopIntroTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[BYShopIntroTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.titleLabel.text = self.titles[indexPath.row];
    
    switch (indexPath.row) {
        case 0:
            cell.contentLabel.text = self.shop.name;
            break;
        case 1:
            cell.contentLabel.text = self.shop.category;
            break;
        case 2:
            cell.contentLabel.text = self.shop.myDescription;
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 此升级版方法适用于cell的model有多个的情况下,性能比普通版稍微差一些,不建议在数据量大的tableview中使用,推荐使用“cellHeightForIndexPath:model:keyPath:cellClass:contentViewWidth:”方法同样是一步设置即可完成
    return [self cellHeightForIndexPath:indexPath cellContentViewWidth:self.view.width];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - even response

- (void)chatClick
{
    if (![NSString isValueableString:GetToken]) {
        [MBProgressHUD showModeText:@"请先登录" view:self.view];
        return;
    }
    if ([self.shop.myLegalPerson isEqualToString:GetPhone]) {
        [MBProgressHUD showModeText:@"不能与您自己私聊" view:self.view];
        return;
    }
    WeakSelf;
    NSDictionary *dic = @{
                          @"friend": self.shop.myLegalPerson
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
            chatViewController.navigationItem.title = @"店长";
            [weakSelf.navigationController pushViewController:chatViewController animated:YES];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:weakSelf.view];
    }];
}

- (void)groupChatClick
{
    if (![NSString isValueableString:GetToken]) {
        [MBProgressHUD showModeText:@"请先登录" view:self.view];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WeakSelf;
    NSDictionary *dic = @{
                          @"user": GetPhone,
                          @"shopId": self.shop.myId
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/room/detail?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        [hud hide:YES];
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            BYRoom *room = [BYRoom mj_objectWithKeyValues:responseObject[@"room"]];
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithConversationChatter:room.myId conversationType:EMConversationTypeChatRoom];
            chatViewController.room = room;
            chatViewController.navigationItem.title = room.name;
            [weakSelf.navigationController pushViewController:chatViewController animated:NO];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:weakSelf.view];
    }];
}

- (void)requestUserInfoDataWithShopOwner:(BYRoom *)room
{
    WeakSelf;
    NSDictionary *dic = @{
                          @"friend": room.owner
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/friendinfo?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            
            BYFriend *friend = [BYFriend mj_objectWithKeyValues:responseObject[@"userInfo"]];
            
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithConversationChatter:room.myId conversationType:EMConversationTypeChatRoom];
            chatViewController.myFriend = friend;
            chatViewController.navigationItem.title = friend.nickname;
            [weakSelf.navigationController pushViewController:chatViewController animated:NO];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:weakSelf.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:weakSelf.view];
    }];
}

@end
