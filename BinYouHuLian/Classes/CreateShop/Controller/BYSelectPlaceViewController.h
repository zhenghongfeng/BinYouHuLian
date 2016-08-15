//
//  BYSelectPlaceViewController.h
//  BinYouHuLian
//
//  Created by zhf on 16/4/13.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BYSelectPlaceViewControllerDelegate <NSObject>

- (void)selectedLocation:(NSString *)location longitude:(double)longitude latitude:(double)latitude;

@end

@interface BYSelectPlaceViewController : UIViewController

@property (nonatomic, weak) id<BYSelectPlaceViewControllerDelegate> delegate;

/** longitude */
@property (nonatomic, assign) double fromCreateShoplongitude;
/** latitude */
@property (nonatomic, assign) double fromCreateShoplatitude;

@property (nonatomic, assign) BOOL tag;

@end
