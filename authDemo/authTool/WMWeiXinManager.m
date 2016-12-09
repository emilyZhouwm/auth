//
//  WMWeiXinManager.m
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "WMWeiXinManager.h"
#import "WXApiObject.h"
#import "WXApi.h"

#import "WMNetwork.h"

typedef void (^NetSuccessBlock)(NSString *resultString);
typedef void (^NetFailedBlock)(NSString *resultString);

@interface WMWeiXinManager () <WXApiDelegate>

@property (nonatomic, assign) BOOL isOK;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) WMAuthBlock respBlcok;
@property (nonatomic, copy) WMUserInfoBlock userInfoBlcok;
@property (nonatomic, copy) WMShareBlock shareBlock;

@end

@implementation WMWeiXinManager

+ (void)shareFirend:(NSString *)title
        description:(NSString *)description
              thumb:(UIImage *)image
                url:(NSString *)url
             result:(WMShareBlock)result
{
    [WMWeiXinManager share:title des:description thumb:image url:url isFriends:NO result:result];
}

+ (void)shareFirends:(NSString *)title
               thumb:(UIImage *)image
                 url:(NSString *)url
              result:(WMShareBlock)result
{
    [WMWeiXinManager share:title des:@"" thumb:image url:url isFriends:YES result:result];
}

+ (void)share:(NSString *)title
          des:(NSString *)description
        thumb:(UIImage *)image
          url:(NSString *)url
    isFriends:(BOOL)isFriends
       result:(WMShareBlock)result
{
    WMWeiXinManager *manager = [WMWeiXinManager manager];
    manager.shareBlock = result;

    WXMediaMessage *msg = [WXMediaMessage message];
    msg.title = title;
    msg.description = description;
    [msg setThumbImage:image];

    WXWebpageObject *webPage = [WXWebpageObject object];
    webPage.webpageUrl = url;
    msg.mediaObject = webPage;

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = msg;
    if (isFriends) {
        req.scene = WXSceneTimeline;    // 朋友圈
    } else {
        req.scene = WXSceneSession;     // 好友
    }
    [WXApi sendReq:req];
}

+ (void)shareMusic:(NSString *)title
               des:(NSString *)description
             thumb:(UIImage *)image
               url:(NSString *)url
         isFriends:(BOOL)isFriends
            result:(WMShareBlock)result
{
    WMWeiXinManager *manager = [WMWeiXinManager manager];
    manager.shareBlock = result;
    
    WXMediaMessage *msg = [WXMediaMessage message];
    msg.title = title;
    msg.description = description;
    [msg setThumbImage:image];
    
    WXMusicObject *musicObj = [WXMusicObject object];
    musicObj.musicUrl = url;
    //musicObj.musicDataUrl = url;
    msg.mediaObject = musicObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = msg;
    if (isFriends) {
        req.scene = WXSceneTimeline;// 朋友圈
    } else {
        req.scene = WXSceneSession; // 好友
    }
    [WXApi sendReq:req];
}

// 分享文件
+ (void)shareFile:(NSData *)file
           result:(WMShareBlock)result
{
    WMWeiXinManager *manager = [WMWeiXinManager manager];
    manager.shareBlock = result;
    
    WXMediaMessage *msg = [WXMediaMessage message];
    
    WXFileObject *fileObj = [WXFileObject object];
    fileObj.fileData = file;
    fileObj.fileExtension = @"mp3";
    msg.mediaObject = fileObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = msg;
    req.scene = WXSceneSession; // 好友
    [WXApi sendReq:req];
}

// 分享图片
+ (void)shareImg:(NSData *)image
           thumb:(UIImage *)thumb
       isFriends:(BOOL)isFriends
          result:(WMShareBlock)result
{
    WMWeiXinManager *manager = [WMWeiXinManager manager];
    manager.shareBlock = result;
    
    WXMediaMessage *msg = [WXMediaMessage message];
    if (thumb) {
        [msg setThumbImage:thumb];
    }
    
    WXImageObject *imgObject = [WXImageObject object];
    imgObject.imageData = image;
    msg.mediaObject = imgObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = msg;
    if (isFriends) {
        req.scene = WXSceneTimeline;// 朋友圈
    } else {
        req.scene = WXSceneSession; // 好友
    }
    [WXApi sendReq:req];
}

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WMWeiXinManager alloc] init];
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

+ (void)sendAuthWithBlock:(WMAuthBlock)result
             withUserInfo:(WMUserInfoBlock)block
           withController:(UIViewController *)viewController
{
    WMWeiXinManager *manager = [WMWeiXinManager manager];
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
    return [WXApi handleOpenURL:url delegate:[WMWeiXinManager manager]];
}

+ (BOOL)isUserInfo
{
    WMWeiXinManager *manager = [WMWeiXinManager manager];
    return manager.isOK;
}

+ (NSString *)getUserName
{
    WMWeiXinManager *manager = [WMWeiXinManager manager];
    return manager.nickName;
}

+ (NSString *)getUserAvatar
{
    WMWeiXinManager *manager = [WMWeiXinManager manager];
    return manager.iconUrl;
}

#pragma mark -
- (void)onReq:(BaseReq *)req
{
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode == WXSuccess) {
            // temp.state 慎重的话校验state
            [self getOpenIDNetwork:((SendAuthResp *)resp).code];
        } else {
            if (resp.errCode == WXErrCodeAuthDeny) {
                if (self.respBlcok) {
                    self.respBlcok([NSError errorWithDomain:@"用户拒绝微信授权" code:resp.errCode userInfo:nil], @"0", @"0");
                }
            } else if (resp.errCode == WXErrCodeUserCancel) {
                if (self.respBlcok) {
                    self.respBlcok([NSError errorWithDomain:@"用户取消微信授权" code:resp.errCode userInfo:nil], @"0", @"0");
                }
            } else {
                if (self.respBlcok) {
                    self.respBlcok([NSError errorWithDomain:@"微信授权失败" code:resp.errCode userInfo:nil], @"0", @"0");
                }
            }
        }
    } else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (resp.errCode == WXSuccess) {
            if (self.shareBlock) {
                self.shareBlock(nil);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"微信分享失败" code:resp.errCode userInfo:nil];
            if (resp.errCode == WXErrCodeUserCancel) {
                error = [NSError errorWithDomain:@"用户取消微信分享" code:resp.errCode userInfo:nil];
            }
            if (self.shareBlock) {
                self.shareBlock(error);
            }
        }
    }
}

- (void)getOpenIDNetwork:(NSString *)code
{
    NSDictionary *postDic = @{@"appid" : WXAppKey,
                              @"secret" : WXSecret,
                              @"code" : code,
                              @"grant_type" : @"authorization_code"};
    __weak __typeof(self) weakself = self;
    [WMNetwork requestWithFullUrl:@"https://api.weixin.qq.com/sns/oauth2/access_token?" withParams:postDic andBlock:^(id data, NSError *error) {
        if (error) {
            if (weakself.respBlcok) {
                weakself.respBlcok([NSError errorWithDomain:@"微信授权失败，网络错误" code:error.code userInfo:nil], @"0", @"0");
            }
        } else {
            [weakself parseOpenID:data];
        }
    }];
}

- (void)parseOpenID:(NSDictionary *)dic
{
    // 优先解析错误码 {"errcode":40029,"errmsg":"invalid code"}
    if ([dic objectForKey:@"errcode"]) {
        // 出现错误
        NSString *errmsg = [dic objectForKey:@"errmsg"];
        NSLog(@"%@", errmsg);
        NSInteger code = [[dic objectForKey:@"errcode"] integerValue];
        if (self.respBlcok) {
            self.respBlcok([NSError errorWithDomain:@"微信授权失败" code:code userInfo:nil], @"0", @"0");
        }
    } else {
        //if (self.respBlcok) {
        //    self.respBlcok(YES, [dic objectForKey:@"openid"], @"0");
        //}
        // 假如需要的是unionID
        [self getUnionIDWithOpenID:[dic objectForKey:@"openid"]
                             token:[dic objectForKey:@"access_token"]];
        if (self.userInfoBlcok) {
            // 授权成功，取用户信息
            [self getUserInfo:[dic objectForKey:@"openid"]
                     andToken:[dic objectForKey:@"access_token"]];
        }
    }
}

- (void)getUnionIDWithOpenID:(NSString *)openID token:(NSString *)token
{
    NSDictionary *postDic = @{@"access_token" : token,
                              @"openid" : openID};

    __weak __typeof(self) weakself = self;
    [WMNetwork requestWithFullUrl:@"https://api.weixin.qq.com/sns/userinfo?" withParams:postDic andBlock:^(id data, NSError *error) {
        if (error) {
            if (weakself.respBlcok) {
                weakself.respBlcok([NSError errorWithDomain:@"微信授权失败，网络错误" code:error.code userInfo:nil], @"0", @"0");
            }
        } else {
            [weakself parseUnionID:data];
        }
    }];
}

- (void)parseUnionID:(NSDictionary *)dic
{
    // 优先解析错误码 {"errcode":40029,"errmsg":"invalid code"}
    if ([dic objectForKey:@"errcode"]) {
        // 出现错误
        NSString *errmsg = [dic objectForKey:@"errmsg"];
        NSLog(@"%@", errmsg);
        NSInteger code = [[dic objectForKey:@"errcode"] integerValue];
        if (self.respBlcok) {
            self.respBlcok([NSError errorWithDomain:@"微信授权失败" code:code userInfo:nil], @"0", @"0");
        }
    } else {
        if (self.respBlcok) {
            self.respBlcok(nil, [dic objectForKey:@"openid"], [dic objectForKey:@"unionid"]);
        }
    }
}

- (void)getUserInfo:(NSString *)openid andToken:(NSString *)token
{
    NSDictionary *postDic = @{@"access_token" : token,
                              @"openid" : openid};
    __weak __typeof(self) weakself = self;
    [WMNetwork requestWithFullUrl:@"https://api.weixin.qq.com/sns/userinfo?" withParams:postDic andBlock:^(id data, NSError *error) {
        if (error) {
        } else {
            // 优先解析错误码 {"errcode":40029,"errmsg":"invalid code"}
            if ([data objectForKey:@"errcode"]) {
                // 出现错误
                weakself.isOK = FALSE;
            } else {
                weakself.isOK = TRUE;
                weakself.nickName = [data objectForKey:@"nickname"];
                weakself.iconUrl = [data objectForKey:@"headimgurl"];
                if (weakself.userInfoBlcok) {
                    weakself.userInfoBlcok(weakself.nickName, weakself.iconUrl);
                }
            }
        }
    }];
}

@end
