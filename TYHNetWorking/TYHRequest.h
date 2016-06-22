//
//  TYHRequest.h
//  GKBB-iOS
//
//  Created by tanyuehong on 16/6/17.
//  Copyright © 2016年 xkw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYHBaseRequest.h"

@interface TYHRequest : TYHBaseRequest

@property (nonatomic) BOOL ignoreCache;
/**
 *  返回当前缓存的对象
 */
- (id)cacheJson;
/**
 *  是否当前的数据从缓存获得
 */
- (BOOL)isDataFromCache;
/**
 *  强制更新缓存
 */
- (void)startWithoutCache;
/**
 *  返回是否当前缓存需要更新
 */
- (BOOL)isCacheVersionExpired;
/**
 *  手动将其他请求的JsonResponse写入该请求的缓存
 */
- (void)saveJsonResponseToCacheFile:(id)jsonResponse;

// For subclass to overwrite
- (NSInteger)cacheTimeInSeconds;
- (long long)cacheVersion;
- (id)cacheSensitiveData;

@end
