//
//  BYTopAligningLabel.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/13.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYTopAligningLabel.h"

@implementation BYTopAligningLabel


- (void)setText:(NSString *)text
{
    NSDictionary *attr = @{
                           NSFontAttributeName:self.font,
                           };
    CGSize size = [text boundingRectWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGRect frame = self.frame;
    frame.size.height = size.height;
    self.frame = frame;
    self.transform = transform;
    self.numberOfLines = 0;
    [super setText:text];
}

@end
