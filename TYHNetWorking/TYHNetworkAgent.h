//
//  TYHNetworkAgent.h
//  GKBB-iOS
//
//  Created by tanyuehong on 16/6/17.
//  Copyright © 2016年 xkw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "TYHBaseRequest.h"

typedef NS_ENUM(NSUInteger, TYHNetQuessType)
{
    TYHNetQuessTypeDefault,  //默认是一个类型的任务
    TYHNetQuessTypeChain,    //链式 任务按照数组顺序
    TYHNetQuessTypeBatch,    //并行任务 当所有任务完成后回调
};


@interface TYHNetworkAgent : NSObject

+ (TYHNetworkAgent *)sharedInstance;
- (void)addRequest:(TYHBaseRequest *)request;
- (void)cancelRequest:(TYHBaseRequest *)request;
- (void)cancelAllRequests;

/// 根据request和networkConfig构建url
- (NSString *)buildRequestUrl:(TYHBaseRequest *)request;

/**
 *  GET请求
 */
- (void)GET:(NSString *)URLString
                            parameters:(id)parameters
                              progress:(void (^)(NSProgress *downloadProgress))downloadProgress
                               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
/**
 *  精简GET请求
 */
- (void)GET:(NSString *)URLString parameters:(id)parameters  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  最精简版GET请求
 */
- (void)GET:(NSString *)URLString parameters:(id)parameters;
/**
 *  POST请求
 */
- (void)POST:(NSString *)URLString
                    parameters:(id)parameters
                      progress:(void (^)(NSProgress *))uploadProgress
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError * error))failure;
/**
 *  POST精简请求
 */
- (void)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
/**
 *  POST最精简版请求
 */
- (void)POST:(NSString *)URLString parameters:(id)parameters;


@end
