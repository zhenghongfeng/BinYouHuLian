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
#import "BYChatViewController.h"

@interface BYShopDetailViewController ()

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *contents;

@end

@implementation BYShopDetailViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"shop==%@", self.shop.name);
    
    self.title = @"店铺详情";
    self.titles = @[@"店名", @"类型", @"图文简介"];
    
    self.contents = @[@"吴老板的书店", @"18816889999", @"《岛上书店》是一本关于全世界所有书的书，写给全世界所有真正爱书的人。 岛上书店是间维多利亚风格的小屋，门廊上挂着褪色的招牌，上面写着：没有谁是一座孤岛，每本书都是一个世界A．J．费克里，人近中年，在一座与世隔绝的小岛上，经营一家书店。"];

    [self setupTabelView];
}

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

- (void)setupTabelView
{
    if (self.shop.picshow1) {
        UIView *header = [UIView new];
        
        NSString *str1 = [@"http://123.56.186.178" stringByAppendingString:self.shop.picshow1];
        NSString *str2 = [@"http://123.56.186.178" stringByAppendingString:self.shop.picshow2];
        NSString *str3 = [@"http://123.56.186.178" stringByAppendingString:self.shop.picshow3];
        
        SDCycleScrollView *scrollView = [SDCycleScrollView new];
        scrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
        scrollView.imageURLStringsGroup = @[str1, str2, str3];
        [header addSubview:scrollView];
        
        scrollView.sd_layout
        .leftSpaceToView(header, 0)
        .topSpaceToView(header, 0)
        .rightSpaceToView(header, 0)
        .heightIs(150);
        
        [header setupAutoHeightWithBottomView:scrollView bottomMargin:0];
        
        self.tableView.tableHeaderView = scrollView;
    }
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    
    UIButton *groupChatbtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, self.view.width * 0.5 - 20, 30)];
    groupChatbtn.backgroundColor = kMainColor;
    groupChatbtn.layer.masksToBounds = YES;
    groupChatbtn.layer.cornerRadius = 5;
    [groupChatbtn setTitle:@"和老板群聊" forState:UIControlStateNormal];
    [groupChatbtn addTarget:self action:@selector(groupChatClick) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:groupChatbtn];
    
    UIButton *privateChatbtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width * 0.5 + 10, 10, self.view.width * 0.5 - 20, 30)];
    privateChatbtn.backgroundColor = kMainColor;
    privateChatbtn.layer.masksToBounds = YES;
    privateChatbtn.layer.cornerRadius = 5;
    [privateChatbtn setTitle:@"和老板私聊" forState:UIControlStateNormal];
    [privateChatbtn addTarget:self action:@selector(chatClick) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:privateChatbtn];
    
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
    BYChatViewController *vc = [[BYChatViewController alloc] initWithConversationChatter:@"18612129273" conversationType:EMConversationTypeChat];
    vc.title = @"18612129273";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)groupChatClick
{
    BYChatViewController *vc = [[BYChatViewController alloc] initWithConversationChatter:@"wuzong" conversationType:EMConversationTypeGroupChat];
    vc.title = @"wuzong";
    [self.navigationController pushViewController:vc animated:YES];
}

@end
