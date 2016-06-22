//
//  TYHNetWorkConfig.h
//  GKBB-iOS
//
//  Created by tanyuehong on 16/6/17.
//  Copyright © 2016年 xkw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYHBaseRequest.h"

//过滤器方法
@protocol TYHUrlFilterProtocol <NSObject>
- (NSString *)filterUrl:(NSString *)originUrl withRequest:(TYHBaseRequest *)request;
@end

@protocol TYHCacheDirPathFilterProtocol <NSObject>
- (NSString *)filterCacheDirPath:(NSString *)originPath withRequest:(TYHBaseRequest *)request;
@end

@interface TYHNetWorkConfig : NSObject

@property (strong, nonatomic) NSString *baseUrl;
@property (strong, nonatomic) NSString *cdnUrl;
@property (strong, nonatomic, readonly) NSArray *urlFilters;
@property (strong, nonatomic, readonly) NSArray *cacheDirPathFilters;
@property (strong, nonatomic) AFSecurityPolicy *securityPolicy;

+ (TYHNetWorkConfig *)sharedInstance;

- (void)addUrlFilter:(id<TYHUrlFilterProtocol>)filter;
- (void)addCacheDirPathFilter:(id <TYHCacheDirPathFilterProtocol>)filter;

@end
