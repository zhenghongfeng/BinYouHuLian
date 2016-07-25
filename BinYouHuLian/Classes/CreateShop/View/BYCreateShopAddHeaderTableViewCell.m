//
//  BYCreateShopAddHeaderTableViewCell.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/12.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYCreateShopAddHeaderTableViewCell.h"

@implementation BYCreateShopAddHeaderTableViewCell

- (UIButton *)addPhotoButton
{
    if (_addPhotoButton == nil) {
        _addPhotoButton = [UIButton new];
        [_addPhotoButton setBackgroundImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
    }
    return _addPhotoButton;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.addPhotoButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _addPhotoButton.sd_layout
    .centerXIs(self.contentView.centerX)
    .centerYIs(self.contentView.centerY)
    .widthIs(100)
    .heightIs(100);
    
}

@end
