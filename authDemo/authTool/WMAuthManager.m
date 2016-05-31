//
//  WMAuthManager.m
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "WMAuthManager.h"
#import "WMWeiXinManager.h"
#import "WMWeiboManager.h"
#import "WMTencentManager.h"
#import "WMFacebookManager.h"

#define CheckAuthType(auth, type) ((auth & (type)) == (type))

static WMAuthType sAuthType;

@implementation WMAuthManager

+ (void)registerApp:(WMAuthType)authType
    withApplication:(UIApplication *)application
        withOptions:(NSDictionary *)launchOptions
{
    sAuthType = authType;
    if (CheckAuthType(sAuthType, WMAuthTencent)) {
    }
    if (CheckAuthType(sAuthType, WMAuthWeibo)) {
        [WMWeiboManager registerApp];
    }
    if (CheckAuthType(sAuthType, WMAuthWeixin)) {
        [WMWeiXinManager registerApp];
    }
    if (CheckAuthType(sAuthType, WMAuthFacebook)) {
        [WMFacebookManager registerApp:application withOptions:launchOptions];
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url
          application:(UIApplication *)application
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation
{
    if (CheckAuthType(sAuthType, WMAuthTencent)) {
        if ([WMTencentManager handleOpenURL:url]) {
            return TRUE;
        }
    }
    if (CheckAuthType(sAuthType, WMAuthWeibo)) {
        if ([WMWeiboManager handleOpenURL:url]) {
            return TRUE;
        }
    }
    if (CheckAuthType(sAuthType, WMAuthWeixin)) {
        if ([WMWeiXinManager handleOpenURL:url]) {
            return TRUE;
        }
    }
    if (CheckAuthType(sAuthType, WMAuthFacebook)) {
        return [WMFacebookManager handleOpenURL:url
                                      application:application
                                sourceApplication:sourceApplication
                                       annotation:annotation];
    }
    return FALSE;
}

+ (void)activateApp
{
    if (CheckAuthType(sAuthType, WMAuthFacebook)) {
        [WMFacebookManager activateApp];
    }
}

+ (BOOL)isAppInstalled:(WMAuthType)authType
{
    BOOL ret = FALSE;
    switch (authType) {
        case WMAuthTencent: {
            ret = [WMTencentManager isAppInstalled];
            break;
        }
        case WMAuthWeibo: {
            ret = [WMWeiboManager isAppInstalled];
            break;
        }
        case WMAuthWeixin: {
            ret = [WMWeiXinManager isAppInstalled];
            break;
        }
        case WMAuthFacebook: {
            ret = [WMFacebookManager isAppInstalled];
            break;
        }
        default:break;
    }
    return ret;
}

+ (void)sendAuthType:(WMAuthType)authType
           withBlock:(WMAuthBlock)result
        withUserInfo:(WMUserInfoBlock)block
     withUserInfoImg:(WMUserInfoImgBlock)imgBlock//facebook专用
      withController:(UIViewController *)vc
{
    switch (authType) {
        case WMAuthTencent: {
            [WMTencentManager sendAuthWithBlock:result withUserInfo:block];
            break;
        }
        case WMAuthWeibo: {
            [WMWeiboManager sendAuthWithBlock:result withUserInfo:block];
            break;
        }
        case WMAuthWeixin: {
            [WMWeiXinManager sendAuthWithBlock:result withUserInfo:block withController:vc];
            break;
        }
        case WMAuthFacebook: {
            [WMFacebookManager sendAuthWithBlock:result withUserInfoImg:imgBlock];
            break;
        }
        default:break;
    }
}

+ (BOOL)isUserInfo:(WMAuthType)authType
{
    BOOL ret = FALSE;
    switch (authType) {
        case WMAuthTencent: {
            ret = [WMTencentManager isUserInfo];
            break;
        }
        case WMAuthWeibo: {
            ret = [WMWeiboManager isUserInfo];
            break;
        }
        case WMAuthWeixin: {
            ret = [WMWeiXinManager isUserInfo];
            break;
        }
        case WMAuthFacebook: {
            ret = [WMFacebookManager isUserInfo];
            break;
        }
        default:break;
    }
    return ret;
}

+ (NSString *)getUserName:(WMAuthType)authType
{
    NSString *ret = nil;
    switch (authType) {
        case WMAuthTencent: {
            ret = [WMTencentManager getUserName];
            break;
        }
        case WMAuthWeibo: {
            ret = [WMWeiboManager getUserName];
            break;
        }
        case WMAuthWeixin: {
            ret = [WMWeiXinManager getUserName];
            break;
        }
        case WMAuthFacebook: {
            ret = [WMFacebookManager getUserName];
            break;
        }
        default:break;
    }
    return ret;
}

+ (NSString *)getUserAvatar:(WMAuthType)authType
{
    NSString *ret = nil;
    switch (authType) {
        case WMAuthTencent: {
            ret = [WMTencentManager getUserAvatar];
            break;
        }
        case WMAuthWeibo: {
            ret = [WMWeiboManager getUserAvatar];
            break;
        }
        case WMAuthWeixin: {
            ret = [WMWeiXinManager getUserAvatar];
            break;
        }
            // 没有
//        case WMAuthFacebook: {
//            ret = [FacebookAuthManager getUserAvatar];
//            break;
//        }
        default:break;
    }
    return ret;
}

@end
