//
//  BYSearchListTableViewCell.m
//  BinYouHuLian
//
//  Created by zhf on 16/7/29.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYSearchListTableViewCell.h"

@implementation BYSearchListTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.iconImageView = [UIImageView new];
        [self.contentView addSubview:self.iconImageView];
        
        self.nameLabel = [UILabel new];
        [self.contentView addSubview:self.nameLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.iconImageView.frame = CGRectMake(10, 6, 32, 32);
    self.nameLabel.frame = CGRectMake(45, 0, self.width - 45, 44);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
