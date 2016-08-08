//
//  BYApplyListTableViewCell.h
//  BinYouHuLian
//
//  Created by zhf on 16/8/8.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BYApply;

@interface BYApplyListTableViewCell : UITableViewCell

/** apply */
@property (nonatomic, strong) BYApply *apply;

/** accept */
@property (nonatomic, strong) UIButton *acceptButton;

@end
