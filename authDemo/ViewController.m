//
//  ViewController.m
//  autoDemo
//
//  Created by zwm on 15/5/14.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "ViewController.h"
#import "WMAuthManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - click
- (IBAction)facebookBtnClick:(UIButton *)sender
{
    __weak typeof(self) weakself = self;
    [WMAuthManager sendAuthType:WMAuthFacebook
                      withBlock:^(BOOL isOK, NSString *openID) {
                          [weakself login:isOK withInfo:openID withType:@"facebook"];
                      }
                   withUserInfo:nil
                withUserInfoImg:^(NSString *userName, UIView *userAvatar) {
                    [weakself showUserInfo:userName withAvatarImg:userAvatar];
                }
                 withController:self];
}

- (IBAction)weixinBtnClick:(UIButton *)sender
{
    __weak typeof(self) weakself = self;
    [WMAuthManager sendAuthType:WMAuthWeixin
                      withBlock:^(BOOL isOK, NSString *openID) {
                          [weakself login:isOK withInfo:openID withType:@"weixin"];
                      }
                   withUserInfo:^(NSString *userName, NSString *userAvatar) {
                       [weakself showUserInfo:userName withAvatar:userAvatar];
                    }
                withUserInfoImg:nil
                 withController:self];
}

- (IBAction)weiboBtnClick:(UIButton *)sender
{
    // 如果不判断安装，没安装会自动弹出SDK自带的Webview进行授权
    //if ([WMAuthManager isAppInstalled:WMAuthWeibo]) {
        __weak typeof(self) weakself = self;
        [WMAuthManager sendAuthType:WMAuthWeibo
                          withBlock:^(BOOL isOK, NSString *openID) {
                              [weakself login:isOK withInfo:openID withType:@"sinaweibo"];
                          }
                       withUserInfo:^(NSString *userName, NSString *userAvatar) {
                           [weakself showUserInfo:userName withAvatar:userAvatar];
                       }
                    withUserInfoImg:nil
                     withController:nil];
//    } else {
//        // 嵌入式输入账号密码模式
//    }
}

- (IBAction)tencentBtnClick:(UIButton *)sender
{
    // 如果不判断安装，没安装会自动弹出SDK自带的Webview进行授权
    //if ([WMAuthManager isAppInstalled:WMAuthTencent]) {
        __weak typeof(self) weakself = self;
        [WMAuthManager sendAuthType:WMAuthTencent
                          withBlock:^(BOOL isOK, NSString *openID) {
                              [weakself login:isOK withInfo:openID withType:@"qq"];
                          }
                       withUserInfo:^(NSString *userName, NSString *userAvatar) {
                           [weakself showUserInfo:userName withAvatar:userAvatar];
                       }
                    withUserInfoImg:nil
                     withController:nil];
//    } else {
//        // 嵌入式输入账号密码模式
//    }
}

#pragma mark -
- (void)showUserInfo:(NSString *)userName withAvatarImg:(UIView *)userAvatar
{
    _nameLbl.text = userName;
    [self.view addSubview:userAvatar];
    //[_avatarImg setImage:userAvatar];
}

- (void)showUserInfo:(NSString *)userName withAvatar:(NSString *)userAvatar
{
    _nameLbl.text = userName;
    [_avatarImg setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userAvatar]]]];
}

- (void)login:(BOOL)isOK withInfo:(NSString *)openID withType:(NSString *)type
{
    if (isOK) {
        [self login:openID withType:type];
    } else {
        //  错误提示
        _nameLbl.text = openID;
    }
}

- (void)login:(NSString *)openID withType:(NSString *)type
{
    // 可以登录了，结合后端给的链接，走后面的流程
    _nameLbl.text = [NSString stringWithFormat:@"openID:%@", openID];
}

@end
