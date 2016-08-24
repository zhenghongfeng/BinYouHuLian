//
//  BYSettingTableViewCell.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/24.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYSettingTableViewCell.h"


@implementation BYSettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _rightLabel = [UILabel new];
        _rightLabel.frame = CGRectMake(kScreenWidth - 105, 0, 80, 44);
        _rightLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_rightLabel];
    }
    return self;
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
