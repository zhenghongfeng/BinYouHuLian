//
//  BYShopDetailViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/18.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYShopDetailViewController.h"
#import "BYShopDetailCycleView.h"

@interface BYShopDetailViewController () <UITableViewDelegate, UITableViewDataSource>
/** <#注释#> */
@property (nonatomic, strong) NSArray *titles;

@end

@implementation BYShopDetailViewController

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
    
    self.title = @"店铺详情";
    self.titles = @[@"店名", @"电话", @"图文简介"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    BYShopDetailCycleView *cycleView = [BYShopDetailCycleView pageView];
    cycleView.frame = CGRectMake(0, 0, 300, 130);
    cycleView.imageNames = @[@"img_00", @"img_01", @"img_02", @"img_03", @"img_04"];
    cycleView.otherColor = [UIColor grayColor];
    cycleView.currentColor = [UIColor orangeColor];

    tableView.tableHeaderView = cycleView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    
    UIButton *groupChatbtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, self.view.width * 0.5 - 20, 30)];
    groupChatbtn.backgroundColor = kMainColor;
    groupChatbtn.layer.masksToBounds = YES;
    groupChatbtn.layer.cornerRadius = 5;
    [groupChatbtn setTitle:@"和老板群聊" forState:UIControlStateNormal];
    [footerView addSubview:groupChatbtn];
    
    UIButton *privateChatbtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width * 0.5 + 10, 10, self.view.width * 0.5 - 20, 30)];
    privateChatbtn.backgroundColor = kMainColor;
    privateChatbtn.layer.masksToBounds = YES;
    privateChatbtn.layer.cornerRadius = 5;
    [privateChatbtn setTitle:@"和老板私聊" forState:UIControlStateNormal];
    [footerView addSubview:privateChatbtn];
    
    tableView.tableFooterView = footerView;

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = self.titles[indexPath.row];
    cell.detailTextLabel.text = @"范德萨发生的范德萨发违法而案发";
    return cell;
}


@end
