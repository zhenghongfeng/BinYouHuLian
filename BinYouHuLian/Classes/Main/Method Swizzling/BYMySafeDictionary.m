//
//  BYMySafeDictionary.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/29.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYMySafeDictionary.h"

@implementation BYMySafeDictionary

/*
 3.在类簇中如何实现Method Swizzling
 
 在上面的代码中我们实现了对NSDictionary中的+ (id)dictionary方法的交换,但如果我们用类似代码尝试对- (id)objectForKey:(id)key方法进行交换后, 你便会发现这似乎并没有什么用.
 
 这是为什么呢? 平常我们在Xcode调试时,在下方Debug区域左侧的Variables View中,常常会发现如__NSArrayI或是__NSCFConstantString这样的Class类型, 这便是在Foundation框架中被广泛使用的类簇, 详情请参看Apple文档class cluster的内容.
 
 所以针对类簇的Method Swizzling问题就转变为如何对这些类簇中的私有类做Method Swizzling, 在上面介绍的不同类之间做Method Swizzling便已经能解决该问题, 下面一个简单的示例通过交换NSMutableDictionary的setObject:forKey:方法,让调用这个方法时当参数object或key为空的不会抛出异常:
 */

+ (void)load {
    Class originalClass = NSClassFromString(@"__NSDictionaryM");
    Class swizzledClass = [self class];
    SEL originalSelector = @selector(setObject:forKey:);
    SEL swizzledSelector = @selector(safe_setObject:forKey:);
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    
    IMP originalIMP = method_getImplementation(originalMethod);
    IMP swizzledIMP = method_getImplementation(swizzledMethod);
    const char *originalType = method_getTypeEncoding(originalMethod);
    const char *swizzledType = method_getTypeEncoding(swizzledMethod);
    
    class_replaceMethod(originalClass, originalSelector, originalIMP, originalType);
    class_replaceMethod(swizzledClass, swizzledSelector, swizzledIMP, swizzledType);
}

- (void)safe_setObject:(id)anObject forKey:(id)aKey {
    if (anObject && aKey) {
        [self safe_setObject:anObject forKey:aKey];
    } else if (aKey) {
        [(NSMutableDictionary *)self removeObjectForKey:aKey];
    }
}

@end
