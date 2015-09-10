![](./facebook.gif)

请使用自己的配置

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
    [WMAuthManager sendAuthType:WMAuthFacebook
                      withBlock:^(BOOL isOK, NSString *openID) {
                          [weakself login:isOK withInfo:openID withType:@"facebook"];
                      }
                   withUserInfo:nil
                withUserInfoImg:^(NSString *userName, UIView *userAvatar) {
                    [weakself showUserInfo:userName withAvatarImg:userAvatar];
                }
                 withController:self];
```