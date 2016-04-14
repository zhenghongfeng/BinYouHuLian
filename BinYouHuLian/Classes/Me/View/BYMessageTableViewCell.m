//
//  BYMessageTableViewCell.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/14.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYMessageTableViewCell.h"
#import "BYMessageModel.h"

@interface BYMessageTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
@implementation BYMessageTableViewCell

- (void)setMessageModel:(BYMessageModel *)messageModel
{
    _messageModel = messageModel;
    
    self.headImageView.image = [UIImage imageNamed:messageModel.avatar];
    self.nameLabel.text = messageModel.name;
    self.contentLabel.text = messageModel.content;
    self.timeLabel.text = messageModel.time;
}


@end
