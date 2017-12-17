### 说明
本文是作者[Lefe](http://www.jianshu.com/p/88957fad1226)所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。
### 正文
这里记录了[Lefe](http://www.jianshu.com/p/88957fad1226)使用Git遇到的一些问题。
#### 1.Git与GitHub是完全不同的
> Git is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency.        

GitHub就是一个网站，或者说是一个全球最大的开源社区，世界一流的公司都在GitHub上创建他们的开源项目。它使用Git进行版本控制。
#### 2.提交自己的代码到GitHub，为什么不需要账号密码
还记得创建项目之后需要添加一个 `public key`，也就是说Github使用`SSH`,让你不再需要密码，直接提交代码。生成一个公钥，只要执行命令行`sudo ssh-keygen`，即可生成一个叫`id_rsa.pub`和`id_rsa`，它保存到目录`/Users/wangsuyan/.ssh`下。`cat id_rsa.pub`即可找到公钥，全选后添加到GitHub上即可。
#### 3.Git客户端
- **SourceTree**：这个是[Lefe](http://www.jianshu.com/p/88957fad1226)使用过最好的Git客户端。它界面简洁，采用扁平化的设计，很符合苹果的设计风格。

![sorceTree.png](http://upload-images.jianshu.io/upload_images/1664496-5255c44894c2503a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

####4.Git服务端
- **[GitHub](https://github.com/lefex)**：如果免费使用，只能提交一些公开的库，如果想创建私有库，那只能交保护费了。

- **[GitLab](https://gitlab.com/)**：允许创建私有库

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)


