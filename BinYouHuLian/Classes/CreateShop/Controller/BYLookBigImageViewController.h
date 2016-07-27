//
//  BYLookBigImageViewController.h
//  BinYouHuLian
//
//  Created by zhf on 16/7/26.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BYLookBigImageViewControllerDelegate <NSObject>

- (void)passAddImageArray:(NSMutableArray *)array; // 新增

@end

@interface BYLookBigImageViewController : UIViewController

@property (nonatomic, assign) NSInteger selectBtn; // 点击的按钮

@property (nonatomic, strong) NSMutableArray *imageArray1;

@property (nonatomic, weak) id <BYLookBigImageViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL fromNewAdd;

@end
