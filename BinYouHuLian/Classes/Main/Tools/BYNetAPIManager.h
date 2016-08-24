//
//  BYNetAPIManager.h
//  BinYouHuLian
//
//  Created by zhf on 16/8/12.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYNetAPIManager : NSObject

+ (instancetype)sharedManager;

// login
- (void)requestLoginWithParameters:(NSDictionary *)parameters
                        progress:(void (^)(NSProgress *downloadProgress))downloadProgress
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
