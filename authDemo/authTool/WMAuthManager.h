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

typedef void(^AuthBlock)(BOOL isOK, NSString *openID);
typedef void(^UserInfoBlock)(NSString *userName, NSString *userAvatar);
typedef void(^UserInfoImgBlock)(NSString *userName, UIView *userAvatar);

@interface WMAuthManager : NSObject

+ (BOOL)isAppInstalled:(WMAuthType)authType;

+ (void)registerApp:(WMAuthType)authType
    withApplication:(UIApplication *)application//facebook专用
        withOptions:(NSDictionary *)launchOptions;

+ (BOOL)handleOpenURL:(NSURL *)url
          application:(UIApplication *)application//facebook专用
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation;

+ (void)activateApp;//facebook专用

+ (void)sendAuthType:(WMAuthType)authType
           withBlock:(AuthBlock)result
        withUserInfo:(UserInfoBlock)block
     withUserInfoImg:(UserInfoImgBlock)block//facebook专用
      withController:(UIViewController *)viewController;//weixin专用

+ (BOOL)isUserInfo:(WMAuthType)authType;
+ (NSString *)getUserName:(WMAuthType)authType;
+ (NSString *)getUserAvatar:(WMAuthType)authType;

@end
