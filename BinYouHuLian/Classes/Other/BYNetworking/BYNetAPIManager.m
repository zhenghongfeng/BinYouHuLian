//
//  BYNetAPIManager.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/12.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYNetAPIManager.h"
#import "BYNetAPIClient.h"

@implementation BYNetAPIManager

+ (instancetype)sharedManager
{
    static BYNetAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

// login

- (void)requestLoginWithParameters:(NSDictionary *)parameters
                        progress:(void (^)(NSProgress *))downloadProgress
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSString *path = [BYBaseURL stringByAppendingString:@"/api/user/login?"];
    [BYNetAPIClient postRequestPath:path parameters:parameters progress:downloadProgress success:success failure:failure];
}

@end
