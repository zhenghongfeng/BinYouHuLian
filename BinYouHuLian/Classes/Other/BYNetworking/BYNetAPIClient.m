//
//  BYNetAPIClient.m
//  BinYouHuLian
//
//  Created by zhf on 16/8/12.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import "BYNetAPIClient.h"

@implementation BYNetAPIClient

+ (instancetype)sharedJsonClient {
    static BYNetAPIClient *sharedJsonClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedJsonClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:BYBaseURL]];
    });
    return sharedJsonClient;
}


#pragma mark-发送post请求
+ (void)postRequestPath:(NSString *)path
         parameters:(NSDictionary *)parameters
           progress:(void (^)(NSProgress *downloadProgress))downloadProgress
            success:(void (^)(NSURLSessionDataTask *task, id response))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:path parameters:parameters progress:downloadProgress success:success failure:failure];
}


@end
