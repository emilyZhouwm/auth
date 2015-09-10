//
//  TencentAuthManager.m
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "TencentAuthManager.h"
#import <TencentOpenAPI/TencentOAuth.h>

@interface TencentAuthManager() <TencentSessionDelegate>

@property (nonatomic, assign) BOOL isOK;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) AuthBlock respBlcok;
@property (nonatomic, copy) UserInfoBlock userInfoBlcok;


@property (strong, nonatomic) TencentOAuth *tencentOAuth;

@end

@implementation TencentAuthManager

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TencentAuthManager alloc] init];
    });
    return manager;
}

+ (BOOL)isAppInstalled
{
    if (([TencentOAuth iphoneQQInstalled] && [TencentOAuth iphoneQQSupportSSOLogin])
        || ([TencentOAuth iphoneQZoneInstalled] && [TencentOAuth iphoneQZoneSupportSSOLogin])) {
        return TRUE;
    }
    return FALSE;
}

+ (void)sendAuthWithBlock:(AuthBlock)result
             withUserInfo:(UserInfoBlock)block
{
    TencentAuthManager *manager = [TencentAuthManager manager];
    manager.respBlcok = result;
    manager.userInfoBlcok = block;
    
    NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
    [manager.tencentOAuth authorize:permissions];
    //[manager.tencentOAuth authorize:permissions inSafari:NO];
    //[manager.tencentOAuth authorize:permissions localAppId:QQAppID inSafari:NO];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [TencentOAuth HandleOpenURL:url];
}

+ (BOOL)isUserInfo
{
    TencentAuthManager *manager = [TencentAuthManager manager];
    return manager.isOK;
}

+ (NSString *)getUserName
{
    TencentAuthManager *manager = [TencentAuthManager manager];
    return manager.nickName;
}

+ (NSString *)getUserAvatar
{
    TencentAuthManager *manager = [TencentAuthManager manager];
    return manager.iconUrl;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:self];
    }
    return self;
}

#pragma mark - TencentLoginDelegate
- (void)tencentDidLogin
{
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length]) {
        if (self.respBlcok) {
            self.respBlcok(YES, [_tencentOAuth openId]);
        }
        [_tencentOAuth getUserInfo];
    } else {
        if (self.respBlcok) {
            self.respBlcok(NO, @"QQ登录失败");
        }
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled) {
        if (self.respBlcok) {
            self.respBlcok(NO, @"用户取消QQ登录");
        }
    } else {
        if (self.respBlcok) {
            self.respBlcok(NO, @"QQ登录失败");
        }
    }
}

- (void)tencentDidNotNetWork
{
    if (self.respBlcok) {
        self.respBlcok(NO, @"无网络连接，请设置网络");
    }
}

- (void)getUserInfoResponse:(APIResponse *)response
{
    if (response.retCode == URLREQUEST_SUCCEED) {
        self.isOK = TRUE;
        self.nickName = [response.jsonResponse objectForKey:@"nickname"];
        self.iconUrl = [response.jsonResponse objectForKey:@"figureurl_qq_2"];
        if (self.userInfoBlcok) {
            self.userInfoBlcok(self.nickName, self.iconUrl);
        }
    }
}

@end
