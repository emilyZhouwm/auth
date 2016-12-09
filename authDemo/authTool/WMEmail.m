//
//  WMEmail.m
//  authDemo
//
//  Created by zwm on 2016/12/9.
//  Copyright © 2016年 zwm. All rights reserved.
//

#import "WMEmail.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@implementation WMEmailData


@end

@interface WMEmail () <MFMailComposeViewControllerDelegate>

@property (nonatomic, copy) WMShareBlock shareBlock;
@property (nonatomic, strong) MFMailComposeViewController *picker;

@end

@implementation WMEmail

+ (BOOL)canSendMail
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        return [mailClass canSendMail];
    }
    return FALSE;
}

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WMEmail alloc] init];
    });
    return manager;
}

+ (void)shareEmail:(NSArray<WMEmailData *> *)datas
             title:(NSString *)title
       description:(NSString *)description
            result:(WMShareBlock)result
{
    [[WMEmail manager] shareEmail:datas title:title description:description result:result];
}

- (void)shareEmail:(NSArray<WMEmailData *> *)datas
             title:(NSString *)title
       description:(NSString *)description
            result:(WMShareBlock)result
{
    _picker = [[MFMailComposeViewController alloc] init];
    __weak typeof(self) weakself = self;
    self.picker.mailComposeDelegate = weakself;
    _shareBlock = result;
    
    [_picker setSubject:title];
    
    // 发送附件
    for (NSInteger i=0; i<datas.count; i++) {
        WMEmailData *temp = datas[i];
        [_picker addAttachmentData:temp.data mimeType:temp.type fileName:temp.name];
    }
    
    [_picker setMessageBody:description isHTML:NO];
    
    [[WMEmail topViewController] presentViewController:_picker animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    NSString *ret = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            ret = @"取消邮件发送";
            break;
        case MFMailComposeResultSaved:
            ret = @"取消邮件发送";
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            ret = @"邮件发送失败";
            break;
        default:
            ret = @"没有发送邮件";
            break;
    }
    if (_shareBlock) {
        _shareBlock(ret ? [NSError errorWithDomain:@"ret" code:-9999 userInfo:nil] : nil);
    }
    __weak typeof(self) weakself = self;
    [[WMEmail topViewController] dismissViewControllerAnimated:YES completion:^{
        weakself.picker = nil;
    }];
}

#pragma mark - private
// 顶层controller
+ (UIViewController *)topViewController
{
    return [WMEmail topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [WMEmail topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)rootViewController;
        return [WMEmail topViewControllerWithRootViewController:nav.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [WMEmail topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end
