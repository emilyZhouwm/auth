//
//  WMEmail.h
//  authDemo
//
//  Created by zwm on 2016/12/9.
//  Copyright © 2016年 zwm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMAuthManager.h"

@interface WMEmailData : NSObject

@property (nonatomic, strong) NSData *data;// 附件数据
@property (nonatomic, copy) NSString *type;// 附件类型 @"audio/mp3"、@"image/jpeg"
@property (nonatomic, copy) NSString *name;// 附件名字 @"share.mp3"、@"share.jpg"

@end

@interface WMEmail : NSObject

/// 是否能发送邮件
/// @"没有检测到系统邮箱，请先配置一个"
+ (BOOL)canSendMail;

/// 分享文件、链接到邮件
///  @param datas       邮件附件
///  @param title       邮件标题
///  @param description 邮件内容
///  @param result      回调是否成功，error为nil成功，失败error.domain原因
+ (void)shareEmail:(NSArray<WMEmailData *> *)datas
             title:(NSString *)title
       description:(NSString *)description
            result:(WMShareBlock)result;

@end
