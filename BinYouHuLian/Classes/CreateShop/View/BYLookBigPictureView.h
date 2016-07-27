//
//  BYLookBigPictureView.h
//  BinYouHuLian
//
//  Created by zhf on 16/7/26.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYLookBigPictureView : UIScrollView

@property (nonatomic, strong) UIImageView *imageView;

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image;

@end
