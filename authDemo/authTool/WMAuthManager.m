//
//  WMAuthManager.m
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "WMAuthManager.h"
#import "WeiXinAuthManager.h"
#import "WeiboAuthManager.h"
#import "TencentAuthManager.h"
#import "FacebookAuthManager.h"

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
        [WeiboAuthManager registerApp];
    }
    if (CheckAuthType(sAuthType, WMAuthWeixin)) {
        [WeiXinAuthManager registerApp];
    }
    if (CheckAuthType(sAuthType, WMAuthFacebook)) {
        [FacebookAuthManager registerApp:application withOptions:launchOptions];
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url
          application:(UIApplication *)application
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation
{
    if (CheckAuthType(sAuthType, WMAuthTencent)) {
        if ([TencentAuthManager handleOpenURL:url]) {
            return TRUE;
        }
    }
    if (CheckAuthType(sAuthType, WMAuthWeibo)) {
        if ([WeiboAuthManager handleOpenURL:url]) {
            return TRUE;
        }
    }
    if (CheckAuthType(sAuthType, WMAuthWeixin)) {
        if ([WeiXinAuthManager handleOpenURL:url]) {
            return TRUE;
        }
    }
    if (CheckAuthType(sAuthType, WMAuthFacebook)) {
        return [FacebookAuthManager handleOpenURL:url
                                      application:application
                                sourceApplication:sourceApplication
                                       annotation:annotation];
    }
    return FALSE;
}

+ (void)activateApp
{
    if (CheckAuthType(sAuthType, WMAuthFacebook)) {
        [FacebookAuthManager activateApp];
    }
}

+ (BOOL)isAppInstalled:(WMAuthType)authType
{
    BOOL ret = FALSE;
    switch (authType) {
        case WMAuthTencent: {
            ret = [TencentAuthManager isAppInstalled];
            break;
        }
        case WMAuthWeibo: {
            ret = [WeiboAuthManager isAppInstalled];
            break;
        }
        case WMAuthWeixin: {
            ret = [WeiXinAuthManager isAppInstalled];
            break;
        }
        case WMAuthFacebook: {
            ret = [FacebookAuthManager isAppInstalled];
            break;
        }
        default:break;
    }
    return ret;
}

+ (void)sendAuthType:(WMAuthType)authType
           withBlock:(AuthBlock)result
        withUserInfo:(UserInfoBlock)block
     withUserInfoImg:(UserInfoImgBlock)imgBlock//facebook专用
      withController:(UIViewController *)viewController
{
    switch (authType) {
        case WMAuthTencent: {
            [TencentAuthManager sendAuthWithBlock:result withUserInfo:block];
            break;
        }
        case WMAuthWeibo: {
            [WeiboAuthManager sendAuthWithBlock:result withUserInfo:block];
            break;
        }
        case WMAuthWeixin: {
            [WeiXinAuthManager sendAuthWithBlock:result withUserInfo:block withController:viewController];
            break;
        }
        case WMAuthFacebook: {
            [FacebookAuthManager sendAuthWithBlock:result withUserInfoImg:imgBlock];
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
            ret = [TencentAuthManager isUserInfo];
            break;
        }
        case WMAuthWeibo: {
            ret = [WeiboAuthManager isUserInfo];
            break;
        }
        case WMAuthWeixin: {
            ret = [WeiXinAuthManager isUserInfo];
            break;
        }
        case WMAuthFacebook: {
            ret = [FacebookAuthManager isUserInfo];
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
            ret = [TencentAuthManager getUserName];
            break;
        }
        case WMAuthWeibo: {
            ret = [WeiboAuthManager getUserName];
            break;
        }
        case WMAuthWeixin: {
            ret = [WeiXinAuthManager getUserName];
            break;
        }
        case WMAuthFacebook: {
            ret = [FacebookAuthManager getUserName];
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
            ret = [TencentAuthManager getUserAvatar];
            break;
        }
        case WMAuthWeibo: {
            ret = [WeiboAuthManager getUserAvatar];
            break;
        }
        case WMAuthWeixin: {
            ret = [WeiXinAuthManager getUserAvatar];
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
