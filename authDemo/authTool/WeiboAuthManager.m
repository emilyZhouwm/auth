//
//  XinaAuthManager.m
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "WeiboAuthManager.h"
#import "WeiboSDK.h"
#import "WeiboUser.h"

@interface WeiboAuthManager() <WeiboSDKDelegate>


@property (nonatomic, assign) BOOL isOK;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) AuthBlock respBlcok;
@property (nonatomic, copy) UserInfoBlock userInfoBlcok;


@end

@implementation WeiboAuthManager

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WeiboAuthManager alloc] init];
    });
    return manager;
}

+ (BOOL)isAppInstalled
{
    return ([WeiboSDK isWeiboAppInstalled] && [WeiboSDK isCanSSOInWeiboApp]);
}

+ (void)registerApp
{
    if ([WeiboSDK registerApp:WBAppKey]) {
        NSLog(@"WeiboSDK registerApp OK");
    }
}

+ (void)sendAuthWithBlock:(AuthBlock)result
             withUserInfo:(UserInfoBlock)block
{
    WeiboAuthManager *manager = [WeiboAuthManager manager];
    manager.respBlcok = result;
    manager.userInfoBlcok = block;
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    //request.scope = @"all";
    request.scope = @"follow_app_official_microblog";
    [WeiboSDK sendRequest:request];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [WeiboSDK handleOpenURL:url delegate:[WeiboAuthManager manager]];
}

+ (BOOL)isUserInfo
{
    WeiboAuthManager *manager = [WeiboAuthManager manager];
    return manager.isOK;
}

+ (NSString *)getUserName
{
    WeiboAuthManager *manager = [WeiboAuthManager manager];
    return manager.nickName;
}

+ (NSString *)getUserAvatar
{
    WeiboAuthManager *manager = [WeiboAuthManager manager];
    return manager.iconUrl;
}

#pragma mark -
// 收到一个来自微博客户端程序的请求
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    NSLog(@"didReceiveWeiboRequest");
}

// 收到一个来自微博客户端程序的响应
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            if (self.respBlcok) {
                self.respBlcok(YES, [(WBAuthorizeResponse *)response userID]);
            }
            __weak typeof(self) weakself = self;
            [WBHttpRequest requestForUserProfile:[(WBAuthorizeResponse *)response userID]
                                 withAccessToken:[(WBAuthorizeResponse *)response accessToken]
                              andOtherProperties:nil
                                           queue:nil
                           withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                               if (!error) {
                                   [weakself getUserInfo:result];
                               }
                               
                           }];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            if (self.respBlcok) {
                self.respBlcok(NO, @"用户取消微博授权");
            }
        } else {//if (response.statusCode == WeiboSDKResponseStatusCodeAuthDeny) {
            if (self.respBlcok) {
                self.respBlcok(NO, @"微博授权失败");
            }
        }
    }

}

- (void)getUserInfo:(WeiboUser *)userInfo
{
    self.isOK = TRUE;
    self.nickName = userInfo.name;
    self.iconUrl = userInfo.avatarLargeUrl;
    if (self.userInfoBlcok) {
        self.userInfoBlcok(self.nickName, self.iconUrl);
    }
}

@end
