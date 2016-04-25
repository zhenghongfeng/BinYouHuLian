//
//  BYMyBuddyListTableViewCell.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/25.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYMyBuddyListTableViewCell.h"

@implementation BYMyBuddyListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.imageView.bounds =CGRectMake(0,0,44,44);
    self.imageView.frame =CGRectMake(20,2,40,40);
    self.imageView.contentMode =UIViewContentModeScaleAspectFit;
}

@end
