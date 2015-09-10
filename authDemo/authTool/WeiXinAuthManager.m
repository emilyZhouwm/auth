//
//  WeiXinAuthManager.m
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "WeiXinAuthManager.h"
#import "WXApiObject.h"
#import "WXApi.h"

#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

typedef void(^NetSuccessBlock)(NSString *resultString);
typedef void(^NetFailedBlock)(NSString *resultString);

@interface WeiXinAuthManager() <WXApiDelegate>


@property (nonatomic, assign) BOOL isOK;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) AuthBlock respBlcok;
@property (nonatomic, copy) UserInfoBlock userInfoBlcok;


@property (nonatomic, strong) AFHTTPRequestOperation *operation;

@end

@implementation WeiXinAuthManager

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WeiXinAuthManager alloc] init];
    });
    return manager;
}

+ (BOOL)isAppInstalled
{
    return [WXApi isWXAppInstalled];
}

+ (void)registerApp
{
    if ([WXApi registerApp:WXAppKey withDescription:@"demo 2.0"]) {
        NSLog(@"WXApi registerApp OK");
    }
}

+ (void)sendAuthWithBlock:(AuthBlock)result
             withUserInfo:(UserInfoBlock)block
           withController:(UIViewController *)viewController
{
    WeiXinAuthManager *manager = [WeiXinAuthManager manager];
    manager.respBlcok = result;
    manager.userInfoBlcok = block;
    
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"413e6ad8cae81487d315780b0a6717c0";
    //req.openID = WXAppKey;
    
    [WXApi sendAuthReq:req viewController:viewController delegate:manager];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:[WeiXinAuthManager manager]];
}

+ (BOOL)isUserInfo
{
    WeiXinAuthManager *manager = [WeiXinAuthManager manager];
    return manager.isOK;
}

+ (NSString *)getUserName
{
    WeiXinAuthManager *manager = [WeiXinAuthManager manager];
    return manager.nickName;
}

+ (NSString *)getUserAvatar
{
    WeiXinAuthManager *manager = [WeiXinAuthManager manager];
    return manager.iconUrl;
}

#pragma mark -
- (void)onReq:(BaseReq *)req
{
    NSLog(@"onReq");
}

- (void)onResp:(BaseResp *)resp
{
    if([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode == 0) {
            // temp.state 慎重的话校验state
            [self getOpenIDNetwork:((SendAuthResp *)resp).code];
        } else {
            if (resp.errCode == -4) {
                if (self.respBlcok) {
                    self.respBlcok(NO, @"用户拒绝微信授权");
                }
            } else if (resp.errCode == -2) {
                if (self.respBlcok) {
                    self.respBlcok(NO, @"用户取消微信授权");
                }
            } else {
                if (self.respBlcok) {
                    self.respBlcok(NO, @"微信授权失败");
                }
            }
        }
    }
}

// 微信授权登录部分
// 可以用其他网络模块改写这个部分
- (void)dealloc
{
    [self.operation cancel];
    self.operation = nil;
}

- (void)postDataWithHostUrl:(NSString *)url
          withPostDictonary:(NSDictionary *)aPostDic
        withCompletionBlock:(NetSuccessBlock)aSuccessBlock
            withFailedBlock:(NetFailedBlock)aFailedBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html", @"application/json", nil];
    
    NSString *urlStr = [[NSURL URLWithString:url relativeToURL:manager.baseURL] absoluteString];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:urlStr parameters:aPostDic error:nil];
    self.operation = [manager HTTPRequestOperationWithRequest:request
                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                          if (aSuccessBlock) {
                                                              aSuccessBlock(operation.responseString);
                                                          }
                                                      }
                                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                          if (aFailedBlock) {
                                                              aFailedBlock(operation.responseString);
                                                          }
                                                      }];
    
    [manager.operationQueue addOperation:self.operation];
}

- (void)getOpenIDNetwork:(NSString *)code
{
    __weak __typeof(self) weakSelf = self;
    NSDictionary *postDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             WXAppKey, @"appid",
                             WXSecret, @"secret",
                             code, @"code",
                             @"authorization_code", @"grant_type",
                             nil];
    [self postDataWithHostUrl:@"https://api.weixin.qq.com/sns/oauth2/access_token?"
            withPostDictonary:postDic
          withCompletionBlock:^(NSString *resultString) {
              [weakSelf openIDNetconnectWithResult:resultString withResult:YES];
          }
              withFailedBlock:^(NSString *resultString) {
                  [weakSelf openIDNetconnectWithResult:resultString withResult:NO];
              }];
}

- (void)openIDNetconnectWithResult:(NSString *)aResultString withResult:(BOOL)isOK
{
    if (isOK) {
        [self parseOpenID:aResultString];
    } else {
        if (self.respBlcok) {
            self.respBlcok(NO, @"微信授权失败，网络错误");
        }
    }
}

- (void)parseOpenID:(NSString *)aOpenID
{
    @try {
        NSData *data = [aOpenID dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *totalNetDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (totalNetDic==nil || totalNetDic.count==0) {
            // 解析失败，不是json或者后台传送给空
            if (self.respBlcok) {
                self.respBlcok(NO, @"微信授权失败，未知错误");
            }
            return;
        }
        
        // 优先解析错误码 {"errcode":40029,"errmsg":"invalid code"}
        if ([totalNetDic objectForKey:@"errcode"]) {
            // 出现错误
            NSString *errmsg = [totalNetDic objectForKey:@"errmsg"];
            if (self.respBlcok) {
                self.respBlcok(NO, [NSString stringWithFormat:@"微信授权失败，%@", errmsg]);
            }
            return;
        }
        
        if ([totalNetDic objectForKey:@"openid"]) {
            if (self.respBlcok) {
                self.respBlcok(YES, [totalNetDic objectForKey:@"openid"]);
            }
            // 授权成功，取用户信息
            [self getUserInfo:[totalNetDic objectForKey:@"openid"] andToken:[totalNetDic objectForKey:@"access_token"]];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"\n!!!!!!!!!!!!!!!!!!!\n解析崩溃了 原因:\n%@\n", exception);
        if (self.respBlcok) {
            self.respBlcok(NO, @"微信授权失败，解析错误");
        }
        return;
    }
    @finally {
    }
}

- (void)getUserInfo:(NSString *)openid andToken:(NSString *)token
{
    __weak __typeof(self) weakSelf = self;
    NSDictionary *postDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             token, @"access_token",
                             openid, @"openid",
                             nil];
    [self postDataWithHostUrl:@"https://api.weixin.qq.com/sns/userinfo?"
            withPostDictonary:postDic
          withCompletionBlock:^(NSString *resultString) {
              [weakSelf userInfoNetconnectWithResult:resultString withResult:YES];
          }
              withFailedBlock:^(NSString *resultString) {
                  [weakSelf userInfoNetconnectWithResult:resultString withResult:NO];
              }];
}

- (void)userInfoNetconnectWithResult:(NSString *)aResultString withResult:(BOOL)isOK
{
    if (isOK) {
        [self parseUserInfo:aResultString];
    } else {
    }
}

- (void)parseUserInfo:(NSString *)aOpenID
{
    @try {
        NSData *data = [aOpenID dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *totalNetDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (totalNetDic==nil || totalNetDic.count==0) {
            // 解析失败，不是json或者后台传送给空
            return;
        }
        
        // 优先解析错误码 {"errcode":40029,"errmsg":"invalid code"}
        if ([totalNetDic objectForKey:@"errcode"]) {
            // 出现错误
            return;
        }
        
        self.isOK = TRUE;
        self.nickName = [totalNetDic objectForKey:@"nickname"];
        self.iconUrl = [totalNetDic objectForKey:@"headimgurl"];
        if (self.userInfoBlcok) {
            self.userInfoBlcok(self.nickName, self.iconUrl);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"\n!!!!!!!!!!!!!!!!!!!\n解析崩溃了 原因:\n%@\n", exception);
        return;
    }
    @finally {
    }
}

@end
