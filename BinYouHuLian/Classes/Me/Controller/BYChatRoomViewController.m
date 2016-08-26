//
//  BYChatRoomViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/9.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYChatRoomViewController.h"
#import "BYRoom.h"
#import "ChatViewController.h"
#import "MJRefresh.h"

@interface BYChatRoomViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

/** rooms */
@property (nonatomic, strong) NSMutableArray *rooms;

/** page */
@property (nonatomic, assign) NSInteger page;

@end

@implementation BYChatRoomViewController

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        
        NSArray *refreshingImages = @[[UIImage imageNamed:@"Refreshing-0_110x90_"], [UIImage imageNamed:@"Refreshing-1_110x90_"], [UIImage imageNamed:@"Refreshing-2_110x90_"], [UIImage imageNamed:@"Refreshing-3_110x90_"], [UIImage imageNamed:@"Refreshing-4_110x90_"]];
        
        [header setImages:@[[UIImage imageNamed:@"Refreshing-0_110x90_"]] forState:MJRefreshStateIdle];

        [header setImages:@[[UIImage imageNamed:@"Refreshing-1_110x90_"]] forState:MJRefreshStatePulling];
        
        [header setImages:refreshingImages forState:MJRefreshStateRefreshing];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        
        _tableView.mj_header = header;
        
    }
    return _tableView;
}

- (void)loadNewData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_tableView.mj_header endRefreshing];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的聊天室";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    _page = 0;
    
    [self requestRoomsListDataWithPage:[NSString stringWithFormat:@"%zd", _page]];
    
}

- (void)requestRoomsListDataWithPage:(NSString *)page
{
    NSDictionary *parameters = @{
                                 @"page":page
                                 };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/room/rooms?"] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [hud hide:YES];
            
            self.rooms = [BYRoom mj_objectArrayWithKeyValuesArray:responseObject[@"rooms"]];
            if (self.rooms.count == 0) {
                [MBProgressHUD showModeText:@"暂无聊天室" view:self.view];
                return ;
            }
            if (self.rooms.count >= 15) {
                if (_tableView.mj_footer == nil) {
                    _page += 1;
                    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataWithPage)];
                    footer.refreshingTitleHidden = YES;

                    _tableView.mj_footer = footer;
                }
            }
            
            [self.tableView reloadData];
        } else {
            [hud hide:YES];
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [hud hide:YES];
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}

- (void)loadMoreDataWithPage
{
    NSDictionary *parameters = @{
                                 @"page":[NSString stringWithFormat:@"%zd", _page]
                                 };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/room/rooms?"] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [hud hide:YES];
            
            [_tableView.mj_footer endRefreshing];
            
            NSArray *array = [BYRoom mj_objectArrayWithKeyValuesArray:responseObject[@"rooms"]];
            if (array.count < 15) {
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [self.rooms addObjectsFromArray:array];
            
            [self.tableView reloadData];
            
        } else {
            [hud hide:YES];
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [hud hide:YES];
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    BYRoom *room = self.rooms[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"group"];
    cell.textLabel.text = room.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BYRoom *room = self.rooms[indexPath.row];
    ChatViewController *vc = [[ChatViewController alloc] initWithConversationChatter:room.myId conversationType:EMConversationTypeChatRoom];
    vc.navigationItem.title = room.name;
    vc.room = room;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = @{
                          @"id": [self.rooms[indexPath.row] myId],
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/room/del?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            [self.rooms removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}



@end
