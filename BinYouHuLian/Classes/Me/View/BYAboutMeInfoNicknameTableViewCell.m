//
//  BYAboutMeInfoNicknameTableViewCell.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/1.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYAboutMeInfoNicknameTableViewCell.h"

@implementation BYAboutMeInfoNicknameTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.myNickNameLabel = [[UILabel alloc] init];
        self.myNickNameLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.myNickNameLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.myNickNameLabel.frame = CGRectMake(self.contentView.width - 200, 0, 200, 44);
}


@end
