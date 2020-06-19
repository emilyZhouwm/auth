//
//  WMNetwork.h
//
//  Created by zwm on 15/6/15.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^WMNetworkBlock)(id data, NSError *error);

@interface WMNetwork : AFHTTPSessionManager

+ (id)sharedInstance;

+ (void)requestWithFullUrl:(NSString *)urlPath withParams:(NSDictionary *)params andBlock:(WMNetworkBlock)block;

@end
