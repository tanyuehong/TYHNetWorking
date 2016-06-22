//
//  TYHBaseRequest.h
//  GKBB-iOS
//
//  Created by tanyuehong on 16/6/17.
//  Copyright © 2016年 xkw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <AFNetworking.h>


//请求方式定义
typedef NS_ENUM(NSInteger , TYHRequestMethod) {
    TYHRequestMethodGet = 0,
    TYHRequestMethodPost,
    TYHRequestMethodHead,
    TYHRequestMethodPut,
    TYHRequestMethodDelete,
    TYHRequestMethodPatch,
};
typedef NS_ENUM(NSInteger , TYHRequestSerializerType) {
    TYHRequestSerializerTypeHTTP = 0,
    TYHRequestSerializerTypeJSON,
};
typedef NS_ENUM(NSInteger , TYHRequestPriority) {
    TYHRequestPriorityLow = -4L,
    TYHRequestPriorityDefault = 0,
    TYHRequestPriorityHigh = 4,
};

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^AFDownloadProgressBlock)(NSURLSessionDownloadTask *downLoadTask, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);

@class TYHBaseRequest;
typedef void(^TYHRequestCompletionBlock)(__kindof TYHBaseRequest *request);
@protocol TYHRequestDelegate <NSObject>

@optional

- (void)requestFinished:(TYHBaseRequest *)request;
- (void)requestFailed:(TYHBaseRequest *)request;
- (void)clearRequest;

@end
@protocol TYHRequestAccessory <NSObject>

@optional

- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;

@end

@interface TYHBaseRequest : NSObject

/// Tag
@property (nonatomic) NSInteger tag;
/// User info
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSProgress    *downloadProgress;
@property (nonatomic, strong) NSProgress    *uploadProgress;
@property (nonatomic, strong) NSURLResponse *response;

@property (nonatomic, weak) id<TYHRequestDelegate> delegate;
@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;
@property (nonatomic, strong, readonly) NSData *responseData;
@property (nonatomic, strong) id responseJSONObject;
@property (nonatomic, strong) NSError *requestOperationError;
@property (nonatomic, copy) TYHRequestCompletionBlock successCompletionBlock;
@property (nonatomic, copy) TYHRequestCompletionBlock failureCompletionBlock;
@property (nonatomic, strong) NSMutableArray *requestAccessories;

/// 请求的优先级, 优先级高的请求会从请求队列中优先出列
@property (nonatomic) TYHRequestPriority requestPriority;
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
- (void)start;
- (void)stop;
- (BOOL)isExecuting;
/// block回调
- (void)startWithCompletionBlockWithSuccess:(TYHRequestCompletionBlock)success
                                    failure:(TYHRequestCompletionBlock)failure;
- (void)setCompletionBlockWithSuccess:(TYHRequestCompletionBlock)success
                              failure:(TYHRequestCompletionBlock)failure;
/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;
/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<TYHRequestAccessory>)accessory;

// =========  以下方法由子类继承来覆盖默认值  =============
/**
 *    请求成功的回调
 */
- (void)requestCompleteFilter;

/**
 *    请求失败的回调
 */
- (void)requestFailedFilter;
/**
 *    请求的URL
 */
- (NSString *)requestUrl;
/**
 *  请求的CdnURL
 */
- (NSString *)cdnUrl;
/**
 *  请求的BaseURL
 */
- (NSString *)baseUrl;
/**
 *  请求的连接超时时间，默认为60秒
 */
- (NSTimeInterval)requestTimeoutInterval;
/**
 *  请求的参数列表
 */
- (id)requestArgument;
/**
 *   用于在cache结果，计算cache文件名时，忽略掉一些指定的参数
 */
- (id)cacheFileNameFilterForRequestArgument:(id)argument;
/**
 *    Http请求的方法
 */
- (TYHRequestMethod)requestMethod;

/// 请求的SerializerType
- (TYHRequestSerializerType)requestSerializerType;
/**
 *    请求的Server用户名和密码
 */
- (NSArray *)requestAuthorizationHeaderFieldArray;
/**
 *    在HTTP报头添加的自定义参数
 */
- (NSDictionary *)requestHeaderFieldValueDictionary;
/**
 *    构建自定义的UrlRequest，
 *    若这个方法返回非nil对象，会忽略requestUrl, requestArgument, requestMethod, requestSerializerType
 */
- (NSURLRequest *)buildCustomUrlRequest;
/**
 *    是否使用CDN的host地址
 */
- (BOOL)useCDN;
/**
 *    用于检查JSON是否合法的对象
 */
- (id)jsonValidator;
/**
 *     用于检查Status Code是否正常的方法
 */
- (BOOL)statusCodeValidator;
/**
 *     当POST的内容带有文件等富文本时使用
 */
- (AFConstructingBlock)constructingBodyBlock;
/**
 *     当需要断点续传时，指定续传的地址
 */
- (NSString *)resumableDownloadPath;
/**
 *     当需要断点续传时，获得下载进度的回调
 */
- (AFDownloadProgressBlock)resumableDownloadProgressBlock;

@end
