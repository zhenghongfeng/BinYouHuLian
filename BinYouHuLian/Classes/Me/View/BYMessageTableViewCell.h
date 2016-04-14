//
//  BYMessageTableViewCell.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/14.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BYMessageModel;

@interface BYMessageTableViewCell : UITableViewCell

/** message模型 */
@property (nonatomic, strong) BYMessageModel *messageModel;

@end
