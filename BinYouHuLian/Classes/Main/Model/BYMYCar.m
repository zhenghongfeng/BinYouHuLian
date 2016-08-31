//
//  BYMYCar.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/30.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYMYCar.h"

@implementation BYMYCar

/*
 
 与之前的流程相比,在前面添加了两个逻辑:
 
 利用runtime向目标类Car动态添加了一个新的方法,此时Car类与MyCar类一样具备了xxx_run:这个方法,MyCar的利用价值便结束了;
 为了完成后续Car类中run:与xxx_run:的方法交换,此时需要更新swizzledMethod变量为Car中的xxx_run:方法所对应的Method.
 
 */

//+ (void)load {
//    Class originalClass = NSClassFromString(@"BYMYCar");
//    Class swizzledClass = [self class];
//    SEL originalSelector = NSSelectorFromString(@"run:");
//    SEL swizzledSelector = @selector(swizzled_run:);
//    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
//    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
//    
//    // 向BYMYCar类中新添加一个swizzled_run:的方法
//    BOOL registerMethod = class_addMethod(originalClass, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//    
//    if (!registerMethod) {
//        return;
//    }
//    // 需要更新swizzledMethod变量,获取当前Car类中xxx_run:的Method指针
//    swizzledMethod = class_getInstanceMethod(originalClass, swizzledSelector);
//    if (!swizzledMethod) {
//        return;
//    }
//    
//    BOOL didAddMethod = class_addMethod(originalClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//    if (didAddMethod) {
//        class_replaceMethod(originalClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//    } else {
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//}
//
//- (void)swizzled_run:(double)speed {
//    if (speed < 120) {
//        [self swizzled_run:speed];
//    }
//}

// 以上所有的逻辑也可以合并简化为以下:

/*
 简化后的代码便与之前使用Category的方式并没有什么差异, 这样代码就很容易覆盖到这两种场景了, 但我们需要明确此时class_replaceMethod所完成的工作却是不一样的.
 
 第一个class_replaceMethod与之前的逻辑一致, 当run:方法是实现在Car类或Car的父类, 分别执行method_setImplementation或class_addMethod;
 第二个class_replaceMethod则直接在Car类中注册了xxx_run:方法, 并且指定的IMP为当前run:方法的IMP;
 */
//+ (void)load {
//    Class originalClass = NSClassFromString(@"BYMYCar");
//    Class swizzledClass = [self class];
//    SEL originalSelector = NSSelectorFromString(@"run:");
//    SEL swizzledSelector = @selector(swizzled_run:);
//    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
//    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
//    
//    IMP originalIMP = method_getImplementation(originalMethod);
//    IMP swizzledIMP = method_getImplementation(swizzledMethod);
//    const char *originalType = method_getTypeEncoding(originalMethod);
//    const char *swizzledType = method_getTypeEncoding(swizzledMethod);
//    
//    class_replaceMethod(originalClass, swizzledSelector, originalIMP, originalType);
//    class_replaceMethod(originalClass, originalSelector, swizzledIMP, swizzledType);
//}
//
//- (void)swizzled_run:(double)speed {
//    if (speed < 120) {
//        [self swizzled_run:speed];
//    }
//}






@end
