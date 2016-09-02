//
//  BYUserInfoSettingTableViewCell.m
//  BinYouHuLian
//
//  Created by zhf on 16/9/2.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYUserInfoSettingTableViewCell.h"

@implementation BYUserInfoSettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth - 61, 6.5, 51, 31)];
        NSLog(@"%@", NSStringFromCGSize(self.mySwitch.frame.size));
        [self.contentView addSubview:self.mySwitch];
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
