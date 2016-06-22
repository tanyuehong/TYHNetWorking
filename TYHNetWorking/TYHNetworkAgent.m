//
//  TYHNetworkAgent.m
//  GKBB-iOS
//
//  Created by tanyuehong on 16/6/17.
//  Copyright © 2016年 xkw. All rights reserved.
//

#import "TYHNetworkAgent.h"
#import "TYHNetWorkConfig.h"
#import "TYHBaseRequest.h"
#import "TYHNetworkPrivate.h"

@implementation TYHNetworkAgent
{
    AFHTTPSessionManager *_manager;
    TYHNetWorkConfig *_config;
    NSMutableDictionary *_requestsRecord;
    dispatch_queue_t _requestProcessingQueue;
}

+ (TYHNetworkAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (id)init {
    self = [super init];
    if (self) {
        _config = [TYHNetWorkConfig sharedInstance];
        _manager = [AFHTTPSessionManager manager];
        _requestsRecord = [NSMutableDictionary dictionary];
        _manager.operationQueue.maxConcurrentOperationCount = 4;
        _manager.securityPolicy = _config.securityPolicy;
    }
    return self;
}

//=======所有的GET请求===========
- (void)GET:(NSString *)URLString
 parameters:(id)parameters
   progress:(void (^)(NSProgress *downloadProgress))downloadProgress
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    URLString = [self getReuestUrlString:URLString];
    [_manager POST:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
    
}
- (void)GET:(NSString *)URLString parameters:(id)parameters  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [self GET:URLString parameters:parameters progress:nil success:success failure:failure];
}
- (void)GET:(NSString *)URLString parameters:(id)parameters
{
    [self GET:URLString parameters:parameters success:nil failure:nil];
}

// =================所有的POST请求==========
- (void)POST:(NSString *)URLString
                    parameters:(id)parameters
                      progress:(void (^)(NSProgress *))uploadProgress
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError * error))failure
{
    URLString = [self getReuestUrlString:URLString];
    [_manager POST:URLString parameters:parameters progress:uploadProgress success:success failure:failure];
}
- (void)POST:(NSString *)URLString
  parameters:(id)parameters
     success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
     failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [self POST:URLString parameters:parameters progress:nil success:success failure:failure];
}
- (void)POST:(NSString *)URLString parameters:(id)parameters
{
    [self POST:URLString parameters:parameters success:nil failure:nil];
}


- (NSString  *)getReuestUrlString:(NSString *)URLString
{
    if (![URLString hasPrefix:@"http"])
    {
        if (_config.baseUrl && _config.baseUrl.length>0)
        {
            URLString = [NSString  stringWithFormat:@"%@%@",_config.baseUrl,URLString];
        }else
        {
            NSLog(@"%s====网络请求路径错误",object_getClassName(self));
        }
    }
    
    return URLString;
}
- (NSString *)buildRequestUrl:(TYHBaseRequest *)request
{
    NSString *detailUrl = [request requestUrl];
 
    NSArray *filters = [_config urlFilters];
    if (filters && filters.count>0)
    {
        for (id<TYHUrlFilterProtocol> f in filters) {
            detailUrl = [f filterUrl:detailUrl withRequest:request];
        }
    }
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    NSString *baseUrl;
    if ([request useCDN]) {
        if ([request cdnUrl].length > 0) {
            baseUrl = [request cdnUrl];
        } else {
            baseUrl = [_config cdnUrl];
        }
    } else {
        if ([request baseUrl].length > 0) {
            baseUrl = [request baseUrl];
        } else {
            baseUrl = [_config baseUrl];
        }
    }
    return [NSString stringWithFormat:@"%@%@", baseUrl, detailUrl];
}
- (void)addRequest:(TYHBaseRequest *)request
{
    TYHRequestMethod method = [request requestMethod];
    NSString *url = [self buildRequestUrl:request];
    id param = request.requestArgument;
//    AFConstructingBlock constructingBlock = [request constructingBodyBlock];
    
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == TYHRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == TYHRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    // if api need server username and password
    NSArray *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString *)authorizationHeaderFieldArray.firstObject
                                                          password:(NSString *)authorizationHeaderFieldArray.lastObject];
    }
    
    // if api need add custom value to HTTPHeaderField
    NSDictionary *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                NSLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    
    // if api build custom url request
    NSURLRequest *customUrlRequest= [request buildCustomUrlRequest];
    
  
    if (customUrlRequest) {
        [_manager dataTaskWithRequest:customUrlRequest uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
            request.uploadProgress = uploadProgress;
        } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            request.downloadProgress = downloadProgress;
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            request.requestOperationError = error;
            request.response = response;
            request.responseJSONObject = responseObject;
        }];
 
    } else {
        if (method == TYHRequestMethodGet) {
            if (request.resumableDownloadPath) {
                // add parameters to URL;
                NSString *filteredUrl = [TYHNetworkPrivate urlStringWithOriginUrlString:url appendParameters:param];
                [_manager GET:filteredUrl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                    request.downloadProgress = downloadProgress;
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                 {
                     request.task = task;
                     request.responseJSONObject = responseObject;
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    request.requestOperationError = error;
                    request.task = task;
                }];
                
            } else {
                [_manager GET:url parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
                    request.downloadProgress = downloadProgress;
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                 {
                     request.task = task;
                     request.responseJSONObject = responseObject;
                     
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     request.requestOperationError = error;
                     request.task = task;
                 }];
            }
        } else if (method == TYHRequestMethodPost) {
            
            [_manager POST:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
                request.uploadProgress = uploadProgress;
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                request.task = task;
                request.responseJSONObject = responseObject;
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                request.task = task;
                request.requestOperationError = error;
            }];

        } else if (method == TYHRequestMethodHead) {
        
        } else if (method == TYHRequestMethodPut) {
      
        } else if (method == TYHRequestMethodDelete) {
  
        } else if (method == TYHRequestMethodPatch) {
   
        } else {
            NSLog(@"Error, unsupport method type");
            return;
        }
    }
    
    // Set request operation priority
    switch (request.requestPriority) {
        case TYHRequestPriorityHigh:
            request.task.priority = 1.0;
            break;
        case TYHRequestPriorityLow:
            request.task.priority = 0.0;
            break;
        case TYHRequestPriorityDefault:
        default:
            break;
    }
    
    // retain operation
    NSLog(@"Add request: %@", NSStringFromClass([request class]));
}
- (void)cancelRequest:(TYHBaseRequest *)request {
    [request.task cancel];
    [request clearCompletionBlock];
}
- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        TYHBaseRequest *request = copyRecord[key];
        [request stop];
    }
}
- (BOOL)checkResult:(TYHBaseRequest *)request {
    BOOL result = [request statusCodeValidator];
    if (!result) {
        return result;
    }
    id validator = [request jsonValidator];
    if (validator != nil) {
        id json = [request responseJSONObject];
        result = [TYHNetworkPrivate checkJson:json withValidator:validator];
    }
    return result;
}

@end
