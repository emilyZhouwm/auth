//
//  WMFacebookManager.m
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "WMFacebookManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface WMFacebookManager ()

@property (nonatomic, assign) BOOL isOK;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) WMAuthBlock respBlcok;
@property (nonatomic, copy) WMUserInfoImgBlock userInfoImgBlcok;

@property (strong, nonatomic) FBSDKLoginManager *loginManager;
//@property (strong, nonatomic) FBSDKGraphRequest *ret;

@end

@implementation WMFacebookManager

+ (BOOL)isAppInstalled
{
    return TRUE;
}

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WMFacebookManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.loginManager = [[FBSDKLoginManager alloc] init];
    }
    return self;
}

+ (void)activateApp
{
    [FBSDKAppEvents activateApp];
}

+ (void)registerApp:(UIApplication *)application withOptions:(NSDictionary *)launchOptions
{
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
}

+ (void)sendAuthWithBlock:(WMAuthBlock)resultBlock
          withUserInfoImg:(WMUserInfoImgBlock)infoBlock
{
    WMFacebookManager *manager = [WMFacebookManager manager];
    manager.respBlcok = resultBlock;
    manager.userInfoImgBlcok = infoBlock;

    [manager.loginManager logInWithReadPermissions:@[@"public_profile"] //@[@"email"]
                                           handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"Facebook error:%@", error);
            if (resultBlock) {
                resultBlock([NSError errorWithDomain:@"Facebook登录失败" code:error.code userInfo:nil], @"0", @"0");
            }
        } else if (result.isCancelled) {
            if (resultBlock) {
                resultBlock([NSError errorWithDomain:@"用户取消Facebook登录" code:-1 userInfo:nil], @"0", @"0");
            }
        } else {
            if ([FBSDKAccessToken currentAccessToken]) {
                if (resultBlock) {
                    resultBlock(nil, [[FBSDKAccessToken currentAccessToken] userID], @"0");
                }
                if (infoBlock) {
                    FBSDKProfile *profile = [FBSDKProfile currentProfile];
                    if (profile) {
                        FBSDKProfilePictureView *avatarImg = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                        [avatarImg setProfileID:profile.userID];

                        infoBlock(profile.name, avatarImg);
                    }
                }
            }
        }
    }];
}

+ (BOOL)handleOpenURL:(NSURL *)url
          application:(UIApplication *)application
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

+ (BOOL)isUserInfo
{
    WMFacebookManager *manager = [WMFacebookManager manager];
    return manager.isOK;
}

+ (NSString *)getUserName
{
    WMFacebookManager *manager = [WMFacebookManager manager];
    return manager.nickName;
}

+ (NSString *)getUserAvatar
{
    WMFacebookManager *manager = [WMFacebookManager manager];
    return manager.iconUrl;
}

@end
