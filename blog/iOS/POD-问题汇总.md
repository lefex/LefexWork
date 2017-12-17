### 说明
本文是作者[Lefe](http://www.jianshu.com/p/88957fad1226)所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。
###正文
http://www.cnblogs.com/HMJ-29/p/6066612.html
1、先切换gem源

gem sources --remove https://rubygems.org/

gem source -a https://gems.ruby-china.org

查看是否切换成功

gem source -l

打印出*** CURRENT SOURCES ***

           https://gems.ruby-china.org

就说明切换成功，如果还是官方的源, 请手动重启电脑尝试

2、接下来就可以开始升级了cocoapods了

sudo gem install -n /usr/local/bin cocoapods --pre

3、然后敲下

pod --version

出现

1.2.0.beta.1

恭喜你, 安装成功

4、剩下的就是设置pod仓库了

pod setup

至此, 已经升级到cocoapods1.1.1了, 可以愉快的把玩Swift3.0的一些三方库了
2.cocopod升级到指定的1.1.1版本

a、在终端输入：sudo gem uninstall cocoapods输出下面

Select gem to uninstall:

1. cocoapods-1.1.0.rc.2

2. cocoapods-1.2.0.beta.1

3. All versions

>‘在此处输入要删除的版本，如：2’会输出下面

Successfully uninstalled cocoapods-1.1.1

b、在终端输入：sudo gem install cocoapods -v 1.1.1

输出：Fetching: cocoapods-1.1.1.gem (100%)

ERROR:  While executing gem ... (Errno::EPERM)

Operation not permitted - /usr/bin/pod

c、上面的方法不行，那咱们就换一种输入：sudo gem install -n /usr/local/bin cocoapods -v 1.1.1

输出：Successfully installed cocoapods-1.1.1

Parsing documentation for cocoapods-1.1.1

Installing ri documentation for cocoapods-1.1.1

1 gem installed

d、输入pod --version查看一下版本号

输出：1.1.1

成功解决ERROR:  While executing gem ... (Errno::EPERM) Operation not permitted - /usr/bin/pod问题，就可以使用1.1.1版本了

[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
