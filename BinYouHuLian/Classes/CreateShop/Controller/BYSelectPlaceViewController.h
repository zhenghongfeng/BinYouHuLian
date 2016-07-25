//
//  BYSelectPlaceViewController.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/13.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BYSelectPlaceViewControllerDelegate <NSObject>

- (void)selectedLocation:(NSString *)location longitude:(NSString *)longitude latitude:(NSString *)latitude;

@end

@interface BYSelectPlaceViewController : UIViewController

@property (nonatomic, weak) id<BYSelectPlaceViewControllerDelegate> delegate;

@end
