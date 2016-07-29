//
//  WMAuthManager.h
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS (NSInteger, WMAuthType) {
    WMAuthNone = 0,
    WMAuthTencent = 1 << 0,
        WMAuthWeibo = 1 << 1,
        WMAuthWeixin = 1 << 2,
        WMAuthFacebook = 1 << 3,
        WMAuthAll = WMAuthTencent | WMAuthWeibo | WMAuthWeixin | WMAuthFacebook,
};

///  第三方授权回调
///  @param error       是否成功，返回nil成功，失败error.domain失败原因
///  @param openID      QQ的openId 微博userID 微信openid facebook的userID
///  @param unionID     微信一账号多app统一id，其他第三方没这个都传0
typedef void (^WMAuthBlock)(NSError *error, NSString *openID, NSString *unionID);
///  用户信息回调
///  @param userName   用户名
///  @param userAvatar 头像url
typedef void (^WMUserInfoBlock)(NSString *userName, NSString *userAvatar);
///  用户信息回调，facebook专用
///  @param userName   用户名
///  @param userAvatar 用户头像
typedef void (^WMUserInfoImgBlock)(NSString *userName, UIView *userAvatar);
///  分享回调
///  @param error 是否成功，返回nil成功，失败error.domain失败原因
typedef void (^WMShareBlock)(NSError *error);

@interface WMAuthManager : NSObject

///  0、用户手机是否安装对应第三方
///  @param authType 四者其一
///  @return 安装返回true，未安装返回false
+ (BOOL)isAppInstalled:(WMAuthType)authType;

///  1、注册第三方
///  @param authType      四者皆可WMAuthAll
///  @param application   facebook专用
+ (void)registerApp:(WMAuthType)authType
    withApplication:(UIApplication *)application
        withOptions:(NSDictionary *)launchOptions;

///  2、第三方回调响应
///  @param application     facebook专用
+ (BOOL)handleOpenURL:(NSURL *)url
          application:(UIApplication *)application
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation;

///  3、恢复状态，facebook专用
+ (void)activateApp;

///  4、发起对应第三方授权，目的是第三方授权登录或者第三方绑定
///  @param authType 四种其一
///  @param result   登录回调block，成功返回TRUE和ID，失败返回FALSE和错误信息
///  @param block    获取用户信息回调，成功返回用户名和头像
///  @param imgBlock facebook专用
///  @param vc       weixin专用
+ (void)sendAuthType:(WMAuthType)authType
           withBlock:(WMAuthBlock)result
        withUserInfo:(WMUserInfoBlock)block
     withUserInfoImg:(WMUserInfoImgBlock)imgBlock
      withController:(UIViewController *)vc;
///  4.1、同上，只是不去取用户名和头像
///  @param authType 四种其一
///  @param result   登录回调block，成功返回TRUE和ID，失败返回FALSE和错误信息
///  @param vc       weixin专用
+ (void)sendAuthType:(WMAuthType)authType
           withBlock:(WMAuthBlock)result
      withController:(UIViewController *)vc;

///  5、分享到对应第三方
///  @param authType    四种其一，以下参数的limit详见各自接口描述
///  @param title       标题
///  @param description 简要描述，对应微信时，nil朋友圈，非nil微信好友
///  @param image       配一张缩略图，对应微博时，nil发纯文本微博，非nil带图微博
///  @param url         指向链接，不能为空
///  @param result      回调是否成功，error为nil成功，失败error.domain原因
+ (void)shareAuthType:(WMAuthType)authType
                title:(NSString *)title
          description:(NSString *)description
                thumb:(UIImage *)image
                  url:(NSString *)url
               result:(WMShareBlock)result;

+ (BOOL)isUserInfo:(WMAuthType)authType;
+ (NSString *)getUserName:(WMAuthType)authType;
+ (NSString *)getUserAvatar:(WMAuthType)authType;

@end
