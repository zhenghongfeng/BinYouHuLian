//
//  UIViewController+BYTracking.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/29.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "UIViewController+BYTracking.h"

@implementation UIViewController (BYTracking)


//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Class class = [self class];
//        
//        SEL originalSelector = @selector(viewWillAppear:);
//        SEL swizzledSelector = @selector(swizzled_viewWillAppear:);
//        
//        Method originalMethod = class_getInstanceMethod(class, originalSelector);
//        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//        
//        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//        if (didAddMethod) {
//            class_replaceMethod(class, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//        } else {
//            method_exchangeImplementations(originalMethod, swizzledMethod);
//        }
//    });
//}
//
//- (void)swizzled_viewWillAppear:(BOOL)animated {
//    [self swizzled_viewWillAppear:animated];
//    NSLog(@"swizzled_viewWillAppear");
//}

@end
