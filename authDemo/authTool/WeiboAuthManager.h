//
//  XinaAuthManager.h
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMAuthManager.h"

#define WBAppKey    @"464916152"

//iOS 应用推荐使用默认授权回调页
#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"

//QuartzCore.framework 、 ImageIO.framework 、 SystemConfiguration.framework 、 Security.framework 、CoreTelephony.framework 、 CoreText.framework 、 UIKit.framework 、 Foundation.framework 和 CoreGraphics.framework

@interface WeiboAuthManager : NSObject

+ (BOOL)isAppInstalled;

+ (void)registerApp;

+ (BOOL)handleOpenURL:(NSURL *)url;

+ (void)sendAuthWithBlock:(AuthBlock)result
             withUserInfo:(UserInfoBlock)block;

+ (BOOL)isUserInfo;
+ (NSString *)getUserName;
+ (NSString *)getUserAvatar;

@end
