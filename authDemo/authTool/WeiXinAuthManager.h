//
//  WeiXinAuthManager.h
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMAuthManager.h"

#define WXAppKey    @"wx37496a0e9d616484"
#define WXSecret    @"c454b6604b65cf4bb852fc4ac27cb50f"

// SystemConfiguration.framework,libz.dylib,libsqlite3.0.dylib

@interface WeiXinAuthManager : NSObject 

+ (BOOL)isAppInstalled;

+ (void)registerApp;

+ (BOOL)handleOpenURL:(NSURL *)url;

+ (void)sendAuthWithBlock:(AuthBlock)result
             withUserInfo:(UserInfoBlock)block
           withController:(UIViewController *)viewController;

+ (BOOL)isUserInfo;
+ (NSString *)getUserName;
+ (NSString *)getUserAvatar;

@end
