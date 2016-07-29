#微信、微博、QQ、facebook第三方登录授权，并获得昵称和头像。 

##配置上你自己在各个第三方申请到的ID。
####使用简单。

#####欢迎关注，提交修改意见。

![](./facebook.gif)
![](./1.jpg)

请使用自己的配置  #warning 配置好Key

![](./2.png)
![](./3.png)
![](./4.png)
![](./5.png)
![](./6.png)

```
	[WMAuthManager registerApp:WMAuthAll withApplication:application withOptions:launchOptions];
    
```


```
    return [WMAuthManager handleOpenURL:url
                            application:application
                      sourceApplication:sourceApplication
                             annotation:annotation];

```

```
    [WMAuthManager activateApp];

```
    __weak typeof(self) weakself = self;
    [WMAuthManager sendAuthType:WMAuthWeixin withBlock:^(NSError *error, NSString *openID, NSString *unionID) {
        [weakself getAuth:error openID:openID unionID:unionID withType:@"weixin"];
    } withUserInfo:^(NSString *userName, NSString *userAvatar) {
        [weakself showUserInfo:userName withAvatar:userAvatar];
    } withUserInfoImg:nil withController:self];

```

```
    [WMAuthManager shareAuthType:WMAuthWeixin title:@"分享标题" description:@"分享描述" thumb:[UIImage imageNamed:@"share_logo.jpg"] url:@"http://www.baidu.com" result:^(NSError *error) {
        if (error) {
            //[weakself showWarning:error.domain];
        } else {
            //[weakself showOK:@"已分享到微信好友"];
        }
    }];

```

#9.0适配
    <key>NSAppTransportSecurity</key>
    <dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    </dict>

    <key>LSApplicationQueriesSchemes</key>
    <array>
    <string>mqqapi</string>
    <string>wtloginmqq2</string>
    <string>mqqopensdkapiV3</string>
    <string>mqqwpa</string>
    <string>mqqopensdkapiV2</string>
    <string>mqqOpensdkSSoLogin</string>
    <string>mqq</string>
    <string>mqzoneopensdkapiV2</string>
    <string>mqzoneopensdkapi19</string>
    <string>mqzoneopensdkapi</string>
    <string>mqzoneopensdk</string>
    <string>mqzone</string>
    <string>sinaweibohd</string>
    <string>sinaweibo</string>
    <string>weibosdk</string>
    <string>weibosdk2.5</string>
    <string>weixin</string>
    <string>wechat</string>
    <string>fbauth</string>
    </array>