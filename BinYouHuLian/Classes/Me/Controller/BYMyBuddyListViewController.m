//
//  BYMyBuddyListViewController.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/25.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYMyBuddyListViewController.h"
#import "BYAddBuddyViewController.h"
#import "BYMyBuddyListTableViewCell.h"
#import "BYFriend.h"
#import "ChatViewController.h"
#import "BYAddApplyViewController.h"
#import "BYChatRoomViewController.h"
#import "BYMyBlackListViewController.h"

#import "BYUserDetailInfoViewController.h"

@interface BYMyBuddyListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *friends;

/** titleArray */
@property (nonatomic, strong) NSMutableArray *titleArray;
/** dataArray */
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UIView *redDotView;

@end

@implementation BYMyBuddyListViewController

#pragma mark - getter

- (NSArray *)array
{
    if (_array == nil) {
        _array = @[@"好友申请", @"聊天室", @"黑名单"];
    }
    return _array;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        // 更改索引的背景颜色
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        // 更改索引的文字颜色
        _tableView.sectionIndexColor = [UIColor grayColor];
    }
    return _tableView;
}

- (UIView *)redDotView
{
    if (_redDotView == nil) {
        _redDotView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth - 30, 20, 5, 5)];
        _redDotView.backgroundColor = [UIColor redColor];
        _redDotView.layer.masksToBounds = YES;
        _redDotView.layer.cornerRadius = 2.5;
        _redDotView.hidden = YES;
    }
    return _redDotView;
}


#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self requestData];
    [self requestRedDot];
}

- (void)requestRedDot
{
    NSDictionary *dic = @{@"username": GetPhone};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/apply/list/count?"] parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            if ([responseObject[@"applyListCount"] integerValue]) {
                self.redDotView.hidden = NO;
            } else {
                self.redDotView.hidden = YES;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
}

- (void)requestData
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic = @{
                          @"phone": GetPhone
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
    [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/friends?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        [hud hide:YES];
        [_titleArray removeAllObjects];
        [_dataArray removeAllObjects];
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            NSArray *array = responseObject[@"friends"];
            if (array.count == 0) {
                [MBProgressHUD showModeText:@"您还没有好友，去添加好友吧" view:self.view];
            }
            self.friends = [BYFriend mj_objectArrayWithKeyValuesArray:array];
            [self dealDataWithArray:[BYFriend mj_objectArrayWithKeyValuesArray:array]];
//            [self.tableView reloadData];
        } else {
            [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.localizedDescription);
        [hud hide:YES];
        [MBProgressHUD showModeText:error.localizedDescription view:self.view];
    }];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
/**
 *  获取首字母
 */
- (NSString *)returnFirstWordWithString:(NSString *)str
{
    NSMutableString *mutStr = [NSMutableString stringWithString:str];
    //将mutStr中的汉字转化为带音标的拼音（如果是汉字就转换，如果不是则保持原样）
    CFStringTransform((__bridge CFMutableStringRef)mutStr, NULL, kCFStringTransformMandarinLatin, NO);
    //将带有音标的拼音转换成不带音标的拼音（这一步是从上一步的基础上来的，所以这两句话一句也不能少）
    CFStringTransform((__bridge CFMutableStringRef)mutStr, NULL, kCFStringTransformStripCombiningMarks, NO);
    if (mutStr.length > 0) {
        //全部转换为大写 取出首字母并返回
        NSString *res = [[mutStr uppercaseString] substringToIndex:1];
        return res;
    } else {
        return @"";
    }
}

- (void)dealDataWithArray:(NSArray *)array
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 27; i++) {
        //给临时数组创建27个数组作为元素，用来存放A-Z和#开头的联系人
        NSMutableArray * array = [[NSMutableArray alloc] init];
        [tmpArray addObject:array];
    }
    
    for (BYFriend *model in array) {
        //AddressMode是联系人的数据模型
        //转化为首拼音并取首字母
        NSString *nickName = [self returnFirstWordWithString:model.nickname];
        int firstWord = [nickName characterAtIndex:0];
        
        //把字典放到对应的数组中去
        
        if (firstWord >= 65 && firstWord <= 90) {
            //如果首字母是A-Z，直接放到对应数组
//            NSMutableArray *array = tmpArray[firstWord - 65];
            [tmpArray[firstWord - 65] addObject:model];
//            tmpArray[firstWord - 65] = array;
        } else {
            //如果不是，就放到最后一个代表#的数组
//            NSMutableArray *array = [tmpArray lastObject];
            [[tmpArray lastObject] addObject:model];
//            tmpArray = array;
        }
    }
    
    //此时数据已按首字母排序并分组
    //遍历数组，删掉空数组
    for (NSMutableArray *mutArr in tmpArray) {
        //如果数组不为空就添加到数据源当中
        if (mutArr.count != 0) {
            [self.dataArray addObject:mutArr];
            BYFriend *model = mutArr[0];
            NSString *nickName = [self returnFirstWordWithString:model.nickname];
            int firstWord = [nickName characterAtIndex:0];
            //取出其中的首字母放入到标题数组，暂时不考虑非A-Z的情况
            if (firstWord >= 65 && firstWord <= 90) {
                [self.titleArray addObject:nickName];
            }
        }
    }
    //便利结束后，两个数组数目不相等说明有除大写字母外的其他首字母
    if (!(self.titleArray.count == self.dataArray.count)) {
        [self.titleArray addObject:@"#"];
    }
    
    //刷新tableView
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestRedDot) name:kNotficationApplyRedDot object:nil];
    
    _titleArray = [NSMutableArray array];
    _dataArray = [NSMutableArray array];
    
    self.navigationItem.title = @"好友列表";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:({
        UIButton *button = [UIButton new];
        button.size = CGSizeMake(25, 25);
//        button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [button setImage:[UIImage imageNamed:@"addUser"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(addBuddy) forControlEvents:UIControlEventTouchUpInside];
        button;
    })];
    
    [self.view addSubview:self.tableView];
    
    // 从数据库获取所有的好友  无网络的情况
//    self.buddyList = [[EMClient sharedClient].contactManager getContactsFromDB];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return section == 0 ? 2 : [self.dataArray[section] count];
    if (section == 0) {
        return self.array.count;
    } else {
        return [self.dataArray[section - 1] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *ID = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = self.array[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"groupPublicHeader"];
        if (indexPath.row == 0) {
            [cell.contentView addSubview:self.redDotView];
        }
        return cell;
    } else {
        static NSString *ID = @"cell";
        BYMyBuddyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[BYMyBuddyListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        BYFriend *friend = self.dataArray[indexPath.section - 1][indexPath.row];
        cell.myFriend = friend;
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.titleArray;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    } else {
        return 22;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    
    UIView *contentView = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 22)];
    label.text = self.titleArray[section - 1];
    label.textColor = [UIColor grayColor];
    [contentView addSubview:label];
    return contentView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            BYAddApplyViewController *vc = [BYAddApplyViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        if (indexPath.row == 1) {
            BYChatRoomViewController *vc = [BYChatRoomViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        if (indexPath.row == 2) {
            BYMyBlackListViewController *vc = [BYMyBlackListViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        BYFriend *friend = self.dataArray[indexPath.section - 1][indexPath.row];
//        ChatViewController *vc = [[ChatViewController alloc] initWithConversationChatter:friend.phone conversationType:EMConversationTypeChat];
//        vc.myFriend = friend;
//        vc.navigationItem.title = friend.nickname;
        BYUserDetailInfoViewController *vc = [BYUserDetailInfoViewController new];
        vc.friend = friend;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        BYFriend *model = [[self.dataArray objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
        NSDictionary *dic = @{
                              @"username": GetPhone,
                              @"friendName": model.phone
                              };
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:GetToken forHTTPHeaderField:@"Authorization"];
        [manager POST:[BYURL_Development stringByAppendingString:@"/ease/users/delfriend?"] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject = %@", responseObject);
            NSInteger code = [responseObject[@"code"] integerValue];
            if (code == 1) {
                [tableView beginUpdates];
                [self.dataArray[indexPath.section - 1] removeObjectAtIndex:indexPath.row];
                [tableView  deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
                
                //            [self.tableView reloadData];
            } else {
                [MBProgressHUD showModeText:responseObject[@"msg"] view:self.view];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@", error.localizedDescription);
            [MBProgressHUD showModeText:error.localizedDescription view:self.view];
        }];
    }
}

#pragma mark - 跳到添加好友界面

- (void)addBuddy
{
    BYAddBuddyViewController *vc = [[BYAddBuddyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
