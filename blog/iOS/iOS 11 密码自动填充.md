【 iOS 11 】
UITextFile 和 UITextView 的 textContentType 属性新加了 UITextContentTypeUsername 和 UITextContentTypePassword 类型，这样当你登录 APP 时可以自动填充你的账号和密码，前提是你保存过密码到 Safi 或 钥匙串。App 可以和你的网站进行关联，如果在网站上登录过，可以自动填充密码和账户到你的 APP。

```
_textField.textContentType = UITextContentTypeUsername;
_textField.textContentType = UITextContentTypePassword;
```

自动记住你选择的键盘类型。比如在【密语】中，你和 A 聊天用英文，切换到英文键盘；和 B 聊天，切换到中文键盘；那么当你退出聊天后。与 A 再次聊天时，显示的是英文键盘，与 B 聊天显示的是中文键盘。你只需要在 UIViewController 中实现：

```
- (NSString *)textInputContextIdentifier
{
    return self.conversation.conversationId;
}
```

把存储在 Safi 和 钥匙串中的密码自动填充到 APP 中，可以使用 Touch ID 和密码进行登录。
iOS 11 中 APP 可以使用手机里已保存的密码，进行填充
启发式算法 自动填充密码

Xcode - Capabilities - Associated Domains 

设置 - 账户与密码 - 应用与网站密码 - 添加密码和域名

与不同的用户聊天，会记录不同的聊天键盘，设置唯一标示符
想输入一个地址，打开地图选中一个地址，返回自己的 APP ，QuickType 上既可以显示刚才的地址

让输入更智能

[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
