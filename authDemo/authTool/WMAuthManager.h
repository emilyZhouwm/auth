//
//  WMAuthManager.h
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, WMAuthType)
{
    WMAuthNone          = 0,
    
    WMAuthTencent       = 1 << 0,
    WMAuthWeibo         = 1 << 1,
    
    WMAuthWeixin        = 1 << 2,
    WMAuthFacebook      = 1 << 3,
    
    WMAuthAll = WMAuthTencent | WMAuthWeibo | WMAuthWeixin | WMAuthFacebook,
};

typedef void(^WMAuthBlock)(BOOL isOK, NSString *openID, NSString *unionID);
typedef void(^WMUserInfoBlock)(NSString *userName, NSString *userAvatar);
typedef void(^WMUserInfoImgBlock)(NSString *userName, UIView *userAvatar);
typedef void(^WMShareBlock)(NSError *error);

@interface WMAuthManager : NSObject

// 用户手机是否安装对应第三方
+ (BOOL)isAppInstalled:(WMAuthType)authType;

// 注册第三方
+ (void)registerApp:(WMAuthType)authType
    withApplication:(UIApplication *)application//facebook专用
        withOptions:(NSDictionary *)launchOptions;

// 第三方回调响应
+ (BOOL)handleOpenURL:(NSURL *)url
          application:(UIApplication *)application//facebook专用
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation;

// 恢复状态
+ (void)activateApp;//facebook专用

// 发起对应第三方跳转登录
+ (void)sendAuthType:(WMAuthType)authType
           withBlock:(WMAuthBlock)result// 登录回调block，成功返回TRUE和ID，失败返回FALSE和错误信息
        withUserInfo:(WMUserInfoBlock)block// 获取用户信息回调，成功返回用户名和头像
     withUserInfoImg:(WMUserInfoImgBlock)imgBlock//facebook专用
      withController:(UIViewController *)vc;//weixin专用

+ (BOOL)isUserInfo:(WMAuthType)authType;
+ (NSString *)getUserName:(WMAuthType)authType;
+ (NSString *)getUserAvatar:(WMAuthType)authType;

@end
