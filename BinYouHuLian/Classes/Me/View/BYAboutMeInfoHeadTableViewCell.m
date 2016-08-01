//
//  BYAboutMeInfoHeadTableViewCell.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/1.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYAboutMeInfoHeadTableViewCell.h"

@implementation BYAboutMeInfoHeadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.myImageView = [[UIImageView alloc] init];
        self.myImageView.layer.masksToBounds = YES;
        self.myImageView.layer.cornerRadius = 25;
        [self.contentView addSubview:self.myImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.myImageView.frame = CGRectMake(self.contentView.width - 50, 5, 50, 50);
}

@end
