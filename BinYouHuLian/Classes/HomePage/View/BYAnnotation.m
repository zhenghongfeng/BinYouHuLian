//
//  BYAnnotation.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/18.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYAnnotation.h"
#import "BYShop.h"

@implementation BYAnnotation


- (void)setShop:(BYShop *)shop
{
    _shop = shop;
    _title = shop.name;
    _subtitle = shop.myDescription;
    _image = [UIImage imageNamed:@"icon_map_arrow"];
}

@end
