//
//  BYMyBlackListViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/9/2.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYMyBlackListViewController.h"
#import "BYBlackUser.h"

#import "BYAddBlackUserViewController.h"


@interface BYMyBlackListViewController () <UITableViewDataSource, UITableViewDelegate>

/** tableView */
@property (nonatomic, strong) UITableView *tableView;

/** blackUsers */
@property (nonatomic, strong) NSMutableArray *blackUsers;

@end

@implementation BYMyBlackListViewController

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic = @{
                          @"id": GetPhone
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/black/list?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        [hud hide:YES];
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            NSArray *array = responseObject[@"blackList"];
            if (array.count == 0) {
                [MBProgressHUD showModeText:@"暂无黑名单" view:self.view];
            }
            _blackUsers = [BYBlackUser mj_objectArrayWithKeyValuesArray:array];
            [self.tableView reloadData];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [hud hide:YES];
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"黑名单";
    
    _blackUsers = @[].mutableCopy;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:({
        UIButton *button = [UIButton new];
        button.frame = CGRectMake(0, 0, 25, 25);
        [button setBackgroundImage:[UIImage imageNamed:@"addFriend"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(addBlackUser) forControlEvents:UIControlEventTouchUpInside];
        button;
    })];
    
    [self.view addSubview:self.tableView];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _blackUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    BYBlackUser *blackUser = _blackUsers[indexPath.row];
    cell.textLabel.text = blackUser.nickname;
    cell.detailTextLabel.text = blackUser.phone;
    NSURL *url = [NSURL URLWithString:blackUser.avatar];
    [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        BYBlackUser *blackUser = _blackUsers[indexPath.row];
        NSDictionary *dic = @{
                              @"userId": GetPhone,
                              @"blackIds": blackUser.phone,
                              @"isgroup": @"0"
                              };
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
        [manager POST:[BYURL_Development stringByAppendingString:@"/ease/black/remove?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject = %@", responseObject);
            NSInteger code = [responseObject[@"code"] integerValue];
            if (code == 1) {
                [_blackUsers removeObjectAtIndex:indexPath.row];
                [self.tableView reloadData];
            } else {
                [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@", error.localizedDescription);
            [MBProgressHUD showModeText:error.localizedDescription view:self.view];
        }];
    }
}

#pragma mark - custom event

- (void)addBlackUser
{
    BYAddBlackUserViewController *vc = [BYAddBlackUserViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
