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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - click - 绑定
- (IBAction)boundFacebookBtnClick:(UIButton *)sender
{
    __weak typeof(self) weakself = self;
    [WMAuthManager sendAuthType:WMAuthFacebook withBlock:^(NSError *error, NSString *openID, NSString *unionID) {
        [weakself getAuth:error openID:openID unionID:unionID withType:@"facebook"];
    } withController:self];
}

- (IBAction)boundQQBtnClick:(UIButton *)sender
{
    __weak typeof(self) weakself = self;
    [WMAuthManager sendAuthType:WMAuthTencent withBlock:^(NSError *error, NSString *openID, NSString *unionID) {
        [weakself getAuth:error openID:openID unionID:unionID withType:@"qq"];
    } withController:nil];
}

- (IBAction)boundWXBtnClick:(UIButton *)sender
{
    __weak typeof(self) weakself = self;
    [WMAuthManager sendAuthType:WMAuthWeixin withBlock:^(NSError *error, NSString *openID, NSString *unionID) {
        [weakself getAuth:error openID:openID unionID:unionID withType:@"weixin"];
    } withController:self];
}

- (IBAction)boundWBBtnClick:(UIButton *)sender
{
    __weak typeof(self) weakself = self;
    [WMAuthManager sendAuthType:WMAuthWeibo withBlock:^(NSError *error, NSString *openID, NSString *unionID) {
        [weakself getAuth:error openID:openID unionID:unionID withType:@"sinaweibo"];
    } withController:nil];
}

#pragma mark - click - 分享
- (IBAction)shareQQBtnClick:(UIButton *)sender
{
    [WMAuthManager shareAuthType:WMAuthTencent title:@"分享标题" description:@"分享描述" thumb:[UIImage imageNamed:@"share_logo.jpg"] url:@"http://www.baidu.com" result:^(NSError *error) {
        if (error) {
            //[weakself showWarning:error.domain];
        } else {
            //[weakself showOK:@"已分享到QQ"];
        }
    }];
}

- (IBAction)shareWBBtnClick:(UIButton *)sender
{
    [WMAuthManager shareAuthType:WMAuthWeibo title:@"分享标题" description:@"分享描述" thumb:[UIImage imageNamed:@"share_logo.jpg"] url:@"http://www.kaomanfen.com/static/appcenter?website=toefl" result:^(NSError *error) {
        if (error) {
            //[weakself showWarning:error.domain];
        } else {
            //[weakself showOK:@"已分享到微博"];
        }
    }];
}

- (IBAction)shareWXBtnClick:(UIButton *)sender
{
    [WMAuthManager shareAuthType:WMAuthWeixin title:@"分享标题" description:@"分享描述" thumb:[UIImage imageNamed:@"share_logo.jpg"] url:@"http://www.baidu.com" result:^(NSError *error) {
        if (error) {
            //[weakself showWarning:error.domain];
        } else {
            //[weakself showOK:@"已分享到微信好友"];
        }
    }];
}

- (IBAction)shareWXFriendsBtnClick:(UIButton *)sender
{
    [WMAuthManager shareAuthType:WMAuthWeixin title:@"分享标题" description:nil thumb:[UIImage imageNamed:@"share_logo.jpg"] url:@"http://www.baidu.com" result:^(NSError *error) {
        if (error) {
            //[weakself showWarning:error.domain];
        } else {
            //[weakself showOK:@"已分享到朋友圈"];
        }
    }];
}

#pragma mark - click - 登录
- (IBAction)facebookBtnClick:(UIButton *)sender
{
    __weak typeof(self) weakself = self;
    [WMAuthManager sendAuthType:WMAuthFacebook withBlock:^(NSError *error, NSString *openID, NSString *unionID) {
        [weakself getAuth:error openID:openID unionID:unionID withType:@"facebook"];
    } withUserInfo:nil withUserInfoImg:^(NSString *userName, UIView *userAvatar) {
        [weakself showUserInfo:userName withAvatarImg:userAvatar];
    } withController:self];
}

- (IBAction)weixinBtnClick:(UIButton *)sender
{
    __weak typeof(self) weakself = self;
    [WMAuthManager sendAuthType:WMAuthWeixin withBlock:^(NSError *error, NSString *openID, NSString *unionID) {
        [weakself getAuth:error openID:openID unionID:unionID withType:@"weixin"];
    } withUserInfo:^(NSString *userName, NSString *userAvatar) {
        [weakself showUserInfo:userName withAvatar:userAvatar];
    } withUserInfoImg:nil withController:self];
}

- (IBAction)weiboBtnClick:(UIButton *)sender
{
    // 如果不判断安装，没安装会自动弹出SDK自带的Webview进行授权
    //if ([WMAuthManager isAppInstalled:WMAuthWeibo]) {
    __weak typeof(self) weakself = self;
    [WMAuthManager sendAuthType:WMAuthWeibo withBlock:^(NSError *error, NSString *openID, NSString *unionID) {
        [weakself getAuth:error openID:openID unionID:unionID withType:@"sinaweibo"];
    } withUserInfo:^(NSString *userName, NSString *userAvatar) {
        [weakself showUserInfo:userName withAvatar:userAvatar];
    } withUserInfoImg:nil withController:nil];
//    } else {
//        // 嵌入式输入账号密码模式
//    }
}

- (IBAction)tencentBtnClick:(UIButton *)sender
{
    // 如果不判断安装，没安装会自动弹出SDK自带的Webview进行授权
    //if ([WMAuthManager isAppInstalled:WMAuthTencent]) {
    __weak typeof(self) weakself = self;
    [WMAuthManager sendAuthType:WMAuthTencent withBlock:^(NSError *error, NSString *openID, NSString *unionID) {
        [weakself getAuth:error openID:openID unionID:unionID withType:@"qq"];
    } withUserInfo:^(NSString *userName, NSString *userAvatar) {
        [weakself showUserInfo:userName withAvatar:userAvatar];
    } withUserInfoImg:nil withController:nil];
//    } else {
//        // 嵌入式输入账号密码模式
//    }
}

#pragma mark -
- (void)showUserInfo:(NSString *)userName withAvatarImg:(UIView *)userAvatar
{
    _nameLbl.text = userName;
    [self.view addSubview:userAvatar];
}

- (void)showUserInfo:(NSString *)userName withAvatar:(NSString *)userAvatar
{
    _nameLbl.text = userName;
    [_avatarImg setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userAvatar]]]];
}

- (void)getAuth:(NSError *)error
         openID:(NSString *)openID
        unionID:(NSString *)unionID
       withType:(NSString *)type
{
    if (!error) {
        // 可以登录或绑定了，结合你们后端给的链接，走后面的流程
        if (unionID.length > 0 && ![unionID isEqualToString:@"0"]) {
            _nameLbl.text = [NSString stringWithFormat:@"unionID:%@", unionID];
        } else {
            _nameLbl.text = [NSString stringWithFormat:@"openID:%@", openID];
        }
    } else {
        // 错误提示
        _nameLbl.text = error.domain;
    }
}

@end
