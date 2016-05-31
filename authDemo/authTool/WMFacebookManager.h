//
//  WMFacebookManager.h
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WMAuthManager.h"

@interface WMFacebookManager : NSObject

+ (BOOL)isAppInstalled;

+ (void)registerApp:(UIApplication *)application withOptions:(NSDictionary *)launchOptions;
+ (void)activateApp;

+ (BOOL)handleOpenURL:(NSURL *)url
          application:(UIApplication *)application
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation;

+ (void)sendAuthWithBlock:(WMAuthBlock)result
          withUserInfoImg:(WMUserInfoImgBlock)block;

+ (BOOL)isUserInfo;
+ (NSString *)getUserName;
+ (NSString *)getUserAvatar;

@end
