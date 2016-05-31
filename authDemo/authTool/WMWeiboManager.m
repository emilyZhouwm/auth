//
//  WMWeiboManager.m
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "WMWeiboManager.h"
#import "WeiboSDK.h"
#import "WeiboUser.h"

@interface WMWeiboManager() <WeiboSDKDelegate>


@property (nonatomic, assign) BOOL isOK;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) WMAuthBlock respBlcok;
@property (nonatomic, copy) WMUserInfoBlock userInfoBlcok;
@property (nonatomic, copy) WMShareBlock shareBlock;

@end

@implementation WMWeiboManager

+ (void)shareWB:(NSString *)title
    description:(NSString *)description
          thumb:(NSData *)image
            url:(NSString *)url
         result:(WMShareBlock)result
{
    WMWeiboManager *manager = [WMWeiboManager manager];
    manager.shareBlock = result;
    
    WBMessageObject *msg = [WBMessageObject message];
    msg.text = [NSString stringWithFormat:@"#%@分享#%@ (分享自 @%@) %@", title, description, title, url];
    
    WBImageObject *img = [WBImageObject object];
    img.imageData = image;
    msg.imageObject = img;
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    authRequest.scope = @"all";
    authRequest.shouldShowWebViewForAuthIfCannotSSO = YES;
    authRequest.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:msg authInfo:authRequest access_token:nil];
    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
}

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WMWeiboManager alloc] init];
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

+ (void)sendAuthWithBlock:(WMAuthBlock)result
             withUserInfo:(WMUserInfoBlock)block
{
    WMWeiboManager *manager = [WMWeiboManager manager];
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
    return [WeiboSDK handleOpenURL:url delegate:[WMWeiboManager manager]];
}

+ (BOOL)isUserInfo
{
    WMWeiboManager *manager = [WMWeiboManager manager];
    return manager.isOK;
}

+ (NSString *)getUserName
{
    WMWeiboManager *manager = [WMWeiboManager manager];
    return manager.nickName;
}

+ (NSString *)getUserAvatar
{
    WMWeiboManager *manager = [WMWeiboManager manager];
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
                self.respBlcok(YES, [(WBAuthorizeResponse *)response userID], @"0");
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
                self.respBlcok(NO, @"用户取消微博授权", @"0");
            }
        } else {//if (response.statusCode == WeiboSDKResponseStatusCodeAuthDeny) {
            if (self.respBlcok) {
                self.respBlcok(NO, @"微博授权失败", @"0");
            }
        }
    } else if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            if (self.shareBlock) {
                self.shareBlock(nil);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"微博分享失败" code:response.statusCode userInfo:nil];
            if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
                [NSError errorWithDomain:@"用户取消微博分享" code:response.statusCode userInfo:nil];
            }
            if (self.shareBlock) {
                self.shareBlock(error);
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
