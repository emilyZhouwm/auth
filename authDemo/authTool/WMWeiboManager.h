//
//  WMWeiboManager.h
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMAuthManager.h"

#define WBAppKey    @"464916152"

// iOS 应用推荐使用默认授权回调页
#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"

//QuartzCore.framework 、 ImageIO.framework 、 SystemConfiguration.framework 、 Security.framework 、CoreTelephony.framework 、 CoreText.framework 、 UIKit.framework 、 Foundation.framework 和 CoreGraphics.framework

@interface WMWeiboManager : NSObject

+ (BOOL)isAppInstalled;

+ (void)registerApp;

+ (BOOL)handleOpenURL:(NSURL *)url;

+ (void)sendAuthWithBlock:(WMAuthBlock)result
             withUserInfo:(WMUserInfoBlock)block;

+ (BOOL)isUserInfo;
+ (NSString *)getUserName;
+ (NSString *)getUserAvatar;

///  分享到微博
///  @param title  想要表达的文字
///  @param image  配一张缩略图，大小不能超过10M
///  @param url    指向链接
///  合起来长度小于140个汉字：msg.text = [NSString stringWithFormat:@"#考满分分享#%@ (分享自 @考满分网) %@", title, url];
///  @param result 回调是否成功，error为nil成功，失败error.domain原因
+ (void)shareWB:(NSString *)title
    description:(NSString *)description
          thumb:(NSData *)image
            url:(NSString *)url
         result:(WMShareBlock)result;

@end
