//
//  UIViewController+BYTracking.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/29.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "UIViewController+BYTracking.h"

@implementation UIViewController (BYTracking)

/*
 通过在Category的+ (void)load方法中添加Method Swizzling的代码,在类初始加载时自动被调用,load方法按照父类到子类,类自身到Category的顺序被调用.
 在dispatch_once中执行Method Swizzling是一种防护措施,以保证代码块只会被执行一次并且线程安全,不过此处并不需要,因为当前Category中的load方法并不会被多次调用.
 尝试先调用class_addMethod方法,以保证即便originalSelector只在父类中实现,也能达到Method Swizzling的目的.
 xxx_viewWillAppear:方法中[self xxx_viewWillAppear:animated];代码并不会造成死循环,因为Method Swizzling之后, 调用xxx_viewWillAppear:实际执行的代码已经是原来viewWillAppear中的代码了.
 */


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

// 其实以上的代码也可以简写为以下:
/*
 这是因为class_replaceMethod方法其实能够覆盖到class_addMethod和method_setImplementation两种场景, 对于第一个class_replaceMethod来说, 如果viewWillAppear:实现在父类, 则执行class_addMethod, 否则就执行method_setImplementation将原方法的IMP指定新的代码块; 而第二个class_replaceMethod完成的工作便只是将新方法的IMP指向原来的代码.
 */

//+ (void)load
//{
//    Class class = [self class];
//    
//    SEL originalSelector = @selector(viewWillAppear:);
//    SEL swizzledSelector = @selector(swizzled_viewWillAppear:);
//    
//    Method originalMethod = class_getInstanceMethod(class, originalSelector);
//    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//    
//    if (!originalMethod || !swizzledMethod) {
//        return;
//    }
//    
//    IMP originalIMP = method_getImplementation(originalMethod);
//    IMP swizzledIMP = method_getImplementation(swizzledMethod);
//    const char *originalType = method_getTypeEncoding(originalMethod);
//    const char *swizzledType = method_getTypeEncoding(swizzledMethod);
//    
//    class_replaceMethod(class, originalSelector, swizzledIMP, swizzledType);
//    class_replaceMethod(class, swizzledSelector, originalIMP, originalType);
//}
//
//- (void)swizzled_viewWillAppear:(BOOL)animated {
//    [self swizzled_viewWillAppear:animated];
//    NSLog(@"swizzled_viewWillAppear");
//}

@end
