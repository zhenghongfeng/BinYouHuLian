//
//  BYApplyListTableViewCell.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/8.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYApplyListTableViewCell.h"

#import "BYApply.h"

@interface BYApplyListTableViewCell ()

@end

@implementation BYApplyListTableViewCell

- (UIButton *)acceptButton
{
    if (_acceptButton == nil) {
        _acceptButton = [[UIButton alloc] init];
    }
    return _acceptButton;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.acceptButton];
    }
    return self;
}

- (void)setApply:(BYApply *)apply
{
    _apply = apply;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[@"http://123.56.186.178/api/download/img?path=" stringByAppendingString:apply.avatar]] placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
    self.textLabel.text = apply.nickname;
    self.detailTextLabel.text = apply.reason;
    if (apply.applyStatus) {
        _acceptButton.backgroundColor = [UIColor whiteColor];
        [_acceptButton setTitle:@"已添加" forState:UIControlStateNormal];
        [_acceptButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _acceptButton.enabled = NO;
    } else {
        _acceptButton.backgroundColor = [UIColor blackColor];
        [_acceptButton setTitle:@"接受" forState:UIControlStateNormal];
    }
}

- (void)acceptButtonClick
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.acceptButton.sd_layout
    .topSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .bottomSpaceToView(self.contentView, 0)
    .widthIs(60);
}



@end
