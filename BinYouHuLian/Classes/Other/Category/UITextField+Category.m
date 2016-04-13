//
//  UITextField+Category.m
//  BinYouHuLian
//
//  Created by zhf on 16/4/13.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "UITextField+Category.h"
#import <objc/runtime.h>

@implementation UITextField (Category)

// 只调用一次
+ (void)initialize
{
    unsigned int count = 0;
    
    Ivar *ivars = class_copyIvarList([UITextField class], &count);
    
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        NSLog(@"%s-----%s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
    
    free(ivars);
}

- (void)setPlaceholderColor:(UIColor *)color
{
    [self setValue:color forKeyPath:@"_placeholderLabel.textColor"];
}

@end
