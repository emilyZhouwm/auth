//
//  WMTencentManager.h
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMAuthManager.h"

#define QQAppID     @"1104592420"

// Security.framework”, “libiconv.dylib”，“SystemConfiguration.framework”，
// “CoreGraphics.Framework”、“libsqlite3.dylib”、“CoreTelephony.framework”、“libstdc++.dylib”、“libz.dylib”

@interface WMTencentManager : NSObject

+ (BOOL)isAppInstalled;

+ (BOOL)handleOpenURL:(NSURL *)url;

+ (void)sendAuthWithBlock:(WMAuthBlock)result
             withUserInfo:(WMUserInfoBlock)block;

+ (BOOL)isUserInfo;
+ (NSString *)getUserName;
+ (NSString *)getUserAvatar;

///  分享到QQ
///  @param title       标题，最长128个字符
///  @param description 简要描述，最长512个字符
///  @param image       配一张缩略图，最大1M字节
///  @param url         指向链接，必填，最长512个字符
///  @param result      回调是否成功，error为nil成功，失败error.domain原因
+ (void)shareQQ:(NSString *)title
    description:(NSString *)description
          thumb:(NSData *)image
            url:(NSString *)url
         result:(WMShareBlock)result;

@end
