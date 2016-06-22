//
//  TYHNetWorkConfig.m
//  GKBB-iOS
//
//  Created by tanyuehong on 16/6/17.
//  Copyright © 2016年 xkw. All rights reserved.
//

#import "TYHNetWorkConfig.h"

@implementation TYHNetWorkConfig
{
    NSMutableArray *_urlFilters;
    NSMutableArray *_cacheDirPathFilters;
}
+ (TYHNetWorkConfig *)sharedInstance {
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
        _urlFilters = [NSMutableArray array];
        _cacheDirPathFilters = [NSMutableArray array];
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        
        AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
        [manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NetWorkDidChange" object:nil userInfo:@{@"AFNetworkReachabilityStatus":@(status)}];
            });
        }];
        [manger startMonitoring];
    }
    return self;
}
- (void)addUrlFilter:(id<TYHUrlFilterProtocol>)filter {
    [_urlFilters addObject:filter];
}

- (void)addCacheDirPathFilter:(id<TYHCacheDirPathFilterProtocol>)filter {
    [_cacheDirPathFilters addObject:filter];
}

- (NSArray *)urlFilters {
    return [_urlFilters copy];
}

- (NSArray *)cacheDirPathFilters {
    return [_cacheDirPathFilters copy];
}
@end
