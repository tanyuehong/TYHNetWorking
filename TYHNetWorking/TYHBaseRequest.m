//
//  TYHBaseRequest.m
//  GKBB-iOS
//
//  Created by tanyuehong on 16/6/17.
//  Copyright © 2016年 xkw. All rights reserved.
//

#import "TYHBaseRequest.h"
#import "TYHNetworkAgent.h"
#import "TYHNetworkPrivate.h"

@implementation TYHBaseRequest

// =============子类继承的方法==========
- (void)requestCompleteFilter {}
- (void)requestFailedFilter   {}
- (NSString *)requestUrl      {return @"";}
- (NSString *)cdnUrl          {return @"";}
- (NSString *)baseUrl         {return @"";}
- (NSTimeInterval)requestTimeoutInterval {return 60;}
- (id)requestArgument {return nil;}
- (id)cacheFileNameFilterForRequestArgument:(id)argument {return argument;}
- (TYHRequestMethod)requestMethod { return TYHRequestMethodGet; }
- (TYHRequestSerializerType)requestSerializerType {return TYHRequestSerializerTypeHTTP;}
- (NSArray *)requestAuthorizationHeaderFieldArray {return nil;}
- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}
- (NSURLRequest *)buildCustomUrlRequest {
    return nil;
}
- (BOOL)useCDN {
    return NO;
}
- (id)jsonValidator {
    return nil;
}
- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

- (NSString *)resumableDownloadPath {
    return nil;
}
- (AFDownloadProgressBlock)resumableDownloadProgressBlock {
    return nil;
}
/// append self to request queue
- (void)start {
    [self toggleAccessoriesWillStartCallBack];
    [[TYHNetworkAgent sharedInstance] addRequest:self];
}

/// remove self from request queue
- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    self.delegate = nil;
    [[TYHNetworkAgent sharedInstance] cancelRequest:self];
    [self toggleAccessoriesDidStopCallBack];
}

- (BOOL)isCancelled {
#warning   这里 暂时没有找到替代方法
//    return self.requestOperation.is;
    return  NO;
}

- (BOOL)isExecuting {
#warning   这里 暂时没有找到替代方法
//    return self.requestOperation.isExecuting;
    return YES;
}

- (void)startWithCompletionBlockWithSuccess:(TYHRequestCompletionBlock)success
                                    failure:(TYHRequestCompletionBlock)failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(TYHRequestCompletionBlock)success
                              failure:(TYHRequestCompletionBlock)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (NSData *)responseData {
    return [_responseJSONObject dataUsingEncoding:NSUTF8StringEncoding];
}







#pragma mark - Request Accessories

- (void)addAccessory:(id<TYHRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}


@end
