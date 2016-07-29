//
//  WMTencentManager.m
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "WMTencentManager.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface WMTencentManager () <TencentSessionDelegate, QQApiInterfaceDelegate>

@property (nonatomic, assign) BOOL isOK;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) WMAuthBlock respBlcok;
@property (nonatomic, copy) WMShareBlock msgRespBlcok;
@property (nonatomic, copy) WMUserInfoBlock userInfoBlcok;

@property (strong, nonatomic) TencentOAuth *tencentOAuth;

@end

@implementation WMTencentManager

+ (void)shareQQ:(NSString *)title
    description:(NSString *)description
          thumb:(NSData *)image
            url:(NSString *)url
         result:(WMShareBlock)result
{
    if (!image) {
        if (result) {
            result([NSError errorWithDomain:@"图片未知" code:1 userInfo:nil]);
        }
        return;
    }
    WMTencentManager *manager = [WMTencentManager manager];
    manager.msgRespBlcok = result;

    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:title description:description previewImageData:image];

    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];

    //将内容分享到qq
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    //将内容分享到qzone
    //QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];

    [manager handleSendResult:sent];
}

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WMTencentManager alloc] init];
    });
    return manager;
}

+ (BOOL)isAppInstalled
{
    if ([TencentOAuth iphoneQQInstalled] && [TencentOAuth iphoneQQSupportSSOLogin]) {
        return TRUE;
    }
    return FALSE;
}

+ (void)sendAuthWithBlock:(WMAuthBlock)result
             withUserInfo:(WMUserInfoBlock)block
{
    WMTencentManager *manager = [WMTencentManager manager];
    manager.respBlcok = result;
    manager.userInfoBlcok = block;

    NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
    [manager.tencentOAuth authorize:permissions];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    if ([QQApiInterface handleOpenURL:url delegate:[WMTencentManager manager]]) {
        return YES;
    }
    return [TencentOAuth HandleOpenURL:url];
}

+ (BOOL)isUserInfo
{
    WMTencentManager *manager = [WMTencentManager manager];
    return manager.isOK;
}

+ (NSString *)getUserName
{
    WMTencentManager *manager = [WMTencentManager manager];
    return manager.nickName;
}

+ (NSString *)getUserAvatar
{
    WMTencentManager *manager = [WMTencentManager manager];
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
            self.respBlcok(nil, [_tencentOAuth openId], @"0");
        }
        if (self.userInfoBlcok) {
            [_tencentOAuth getUserInfo];
        }
    } else {
        if (self.respBlcok) {
            self.respBlcok([NSError errorWithDomain:@"QQ登录失败" code:-1 userInfo:nil], @"0", @"0");
        }
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled) {
        if (self.respBlcok) {
            self.respBlcok([NSError errorWithDomain:@"用户取消QQ登录" code:-1 userInfo:nil], @"0", @"0");
        }
    } else {
        if (self.respBlcok) {
            self.respBlcok([NSError errorWithDomain:@"QQ登录失败" code:-1 userInfo:nil], @"0", @"0");
        }
    }
}

- (void)tencentDidNotNetWork
{
    if (self.respBlcok) {
        self.respBlcok([NSError errorWithDomain:@"无网络连接，请设置网络" code:-1 userInfo:nil], @"0", @"0");
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
    } else {
        self.isOK = FALSE;
    }
}

#pragma mark - QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req
{
}

- (void)onResp:(QQBaseResp *)resp
{
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        SendMessageToQQResp *tmpResp = (SendMessageToQQResp *)resp;

        if (tmpResp.type == ESENDMESSAGETOQQRESPTYPE && [tmpResp.result integerValue] == 0) {
            // 分享成功
            if (self.msgRespBlcok) {
                self.msgRespBlcok(nil);
            }
        } else {
            // 分享失败
            if (self.msgRespBlcok) {
                self.msgRespBlcok([NSError errorWithDomain:@"QQ分享失败" code:[tmpResp.result integerValue] userInfo:nil]);
            }
        }
    }
}

- (void)isOnlineResponse:(NSDictionary *)response
{
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    NSError *error = nil;
    switch (sendResult) {
        case EQQAPIAPPNOTREGISTED: {
            error = [NSError errorWithDomain:@"App未注册" code:EQQAPIAPPNOTREGISTED userInfo:nil];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID: {
            error = [NSError errorWithDomain:@"发送参数错误" code:EQQAPIMESSAGECONTENTINVALID userInfo:nil];
            break;
        }
        case EQQAPIQQNOTINSTALLED: {
            error = [NSError errorWithDomain:@"未安装手机QQ" code:EQQAPIQQNOTINSTALLED userInfo:nil];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI: {
            error = [NSError errorWithDomain:@"API接口不支持" code:EQQAPIQQNOTSUPPORTAPI userInfo:nil];
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE: {
            error = [NSError errorWithDomain:@"当前QQ版本太低，需要更新" code:EQQAPIVERSIONNEEDUPDATE userInfo:nil];
            break;
        }
        case EQQAPISENDFAILD: {
            error = [NSError errorWithDomain:@"发送失败" code:EQQAPISENDFAILD userInfo:nil];
            break;
        }
        default: {
            break;
        }
    }
    if (error && _msgRespBlcok) {
        _msgRespBlcok(error);
    }
}

@end
