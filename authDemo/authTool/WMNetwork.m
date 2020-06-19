//
//  WMNetwork.m
//
//  Created by zwm on 15/6/15.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "WMNetwork.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation WMNetwork

+ (WMNetwork *)sharedInstance
{
    static WMNetwork *_sharedNetwork = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedNetwork = [[WMNetwork alloc] init];
    });
    
    return _sharedNetwork;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    return self;
}

+ (void)requestWithFullUrl:(NSString *)urlPath
                withParams:(NSDictionary *)params
                  andBlock:(WMNetworkBlock)block
{
    if (!urlPath || urlPath.length <= 0) {
        return;
    }
    
    // log请求数据
    NSLog(@"\n===========request===========\n%@:\n%@", urlPath, params);
    urlPath = [urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // 发起请求
    [[WMNetwork sharedInstance] POST:urlPath parameters:params
     progress:^(NSProgress * _Nonnull uploadProgress) {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSLog(@"\n===========response POST===========\n%@:\n%@", urlPath, responseObject);
         if (block) {
             block(responseObject, nil);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"\n===========response POST===========\n%@:\n%@", urlPath, error);
         if (block) {
             block(nil, error);
         }
     }];
}

@end
