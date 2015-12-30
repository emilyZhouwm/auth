//
//  FacebookAuthManager.m
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "FacebookAuthManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FacebookAuthManager()

@property (nonatomic, assign) BOOL isOK;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) AuthBlock respBlcok;
@property (nonatomic, copy) UserInfoImgBlock userInfoImgBlcok;

@property (strong, nonatomic) FBSDKLoginManager *loginManager;
//@property (strong, nonatomic) FBSDKGraphRequest *ret;

@end

@implementation FacebookAuthManager

+ (BOOL)isAppInstalled
{
    return TRUE;
}

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FacebookAuthManager alloc] init];
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

+ (void)sendAuthWithBlock:(AuthBlock)resultBlock
          withUserInfoImg:(UserInfoImgBlock)infoBlock
{
    FacebookAuthManager *manager = [FacebookAuthManager manager];
    manager.respBlcok = resultBlock;
    manager.userInfoImgBlcok = infoBlock;

    [manager.loginManager logInWithReadPermissions: @[@"public_profile"]//@[@"email"]
                                           handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"Facebook error:%@", error);
            if (resultBlock) {
                resultBlock(NO, @"Facebook登录失败");
            }
        } else if (result.isCancelled) {
            if (resultBlock) {
                resultBlock(NO, @"用户取消Facebook登录");
            }
        } else {
            if ([FBSDKAccessToken currentAccessToken]) {
                if (resultBlock) {
                    resultBlock(YES, [[FBSDKAccessToken currentAccessToken] userID]);
                }
                if (infoBlock) {
                    FBSDKProfile *profile = [FBSDKProfile currentProfile];
                    if (profile) {
                        FBSDKProfilePictureView *avatarImg = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                        [avatarImg setProfileID:profile.userID];
                    
                        infoBlock(profile.name, avatarImg);
                    }
                    //NSString *avatar = [profile imagePathForPictureMode:FBSDKProfilePictureModeSquare size:CGSizeMake(100, 100)];
//                    NSString *tStr = [NSString stringWithFormat:@"me/%@/picture", profile.userID];
//                    
//                    manager.ret = [[FBSDKGraphRequest alloc] initWithGraphPath:tStr parameters:@{@"type" : @"square",
//                                                                                                 @"width" : @"100",
//                                                                                                 @"height" : @"100"}];
//                    [manager.ret startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                        if (!error) {
//                        //UIImage *ii = [UIImage imageWithData:result];
//                        //infoBlock(profile.name, avatarImg);
//                        }
//                    }];
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
    return  [[FBSDKApplicationDelegate sharedInstance] application:application
                                                           openURL:url
                                                 sourceApplication:sourceApplication
                                                        annotation:annotation];
}

+ (BOOL)isUserInfo
{
    FacebookAuthManager *manager = [FacebookAuthManager manager];
    return manager.isOK;
}

+ (NSString *)getUserName
{
    FacebookAuthManager *manager = [FacebookAuthManager manager];
    return manager.nickName;
}

+ (NSString *)getUserAvatar
{
    FacebookAuthManager *manager = [FacebookAuthManager manager];
    return manager.iconUrl;
}


@end
