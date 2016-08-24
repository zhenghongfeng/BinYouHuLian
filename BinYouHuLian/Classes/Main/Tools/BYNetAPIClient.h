//
//  BYNetAPIClient.h
//  BinYouHuLian
//
//  Created by zhf on 16/8/12.
//  Copyright © 2016年 郑洪锋. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NetworkMethod) {
    Get = 0,
    Post,
    Put,
    Delete
};

@interface BYNetAPIClient : NSObject

#pragma mark-发送post请求
+ (void)postRequestPath:(NSString *)path
        parameters:(NSDictionary *)parameters
          progress:(void (^)(NSProgress *downloadProgress))downloadProgress
           success:(void (^)(NSURLSessionDataTask *task, id response))success
           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


@end
