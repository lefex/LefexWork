# 为什么我还在写 CocoaPods 的教程

`CocoaPods` 已经出现很多年了，相信很多同学都会使用，但是你真的知道 `CocoaPods` 是如何工作的吗？

## RubyGems

> The RubyGems software allows you to easily download, install, and use ruby software packages on your system. The software package is called a “gem” which contains a packaged Ruby application or library.

> 人们特别是电脑工程师们，常常从机器着想。他们认为：“这样做，机器就能运行的更快；这样做，机器运行效率更高；这样做，机器就会怎样怎样怎样。”实际上，我们需要从人的角度考虑问题，人们怎样编写程序或者怎样使用机器上应用程序。我们是主人，他们是仆人 ———— Ruby设计初衷

`CocoaPods` 是使用 Ruby 语言编写的一个作为 iOS 的包管理工具，而 [RubyGems](http://guides.rubygems.org/) 是 Ruby 的包管理工具。安装 `CocoaPods` 需要包管理工具 `RubyGems ` 安装，而 `RubyGems ` 是 Mac 自带的工具。关于`RubyGems`的更多信息，可以参考 [官方文档](http://guides.rubygems.org/) 。不过，[RubyGems](http://guides.rubygems.org/) 中的 Gems 在国内访问速度很慢，不过可以使用 [Ruby China](https://ruby-china.org/)。如果你想大体了解 Ruby，可以看这篇文章 [Ruby](http://saito.im/slide/ruby-new.html)。读到这里相信你对安装 `CocoaPods` 已经有了一定的了解。 

`CocoaPods` 会被安装到 `/Users/wangsuyan/.cocoapods/repos`

## Git

掌握 `CocoaPods` ，需要了解一些 Git 的基本知识，当然你需要至少有一个代码托管平台，比如 GitHub。当然 [这篇文章](http://rogerdudler.github.io/git-guide/index.zh.html) 讲的很不错。下面主要说明与这篇文章相关的内容。

- git add -A   
把文提交到暂存区，等待提交

- git commit -m "代码提交信息"   
提交代码到 HEAD，现在，你的改动已经提交到了 HEAD，但是还没到你的远端仓库

- git tag 1.0   
给当前要提交的版本打个标签

- git push --tags   
提交所有的 tag 到远端仓库


## Pod init 

它首先需要判断当前目录有没有 `XCODEPROJ` 项目，如果没有直接报错；若果有单个 `XCODEPROJ` 项目，会直接创建一个 `podfile` 文件；如果有多个`XCODEPROJ` 项目，需要指定一个项目，否则会报错：

> [!] Multiple Xcode projects found, please specify one

## Podfile

经过 `Pod init` 后会生成一个 `Podfile` 文件。它是一种规范，描述了一个或多个Xcode项目（target）的依赖关系。

最简单的 `Podfile` 文件，它仅仅给 Target lefeKit 添加一个 SDWebImage 库。

```
platform :ios, '9.0'
target 'lefeKit' do
  pod 'SDWebImage'
end
```

- *`use_frameworks!`*

使用 Swift 或者动态库时需要

- *版本，比如：`pod 'SDWebImage', '~> 3.7.0'`*

假如 `SDWebImage ` 目前只有下列版本： 

```
4.1.0, 4.0.0, 4.0.0-beta2, 4.0.0-beta, 
3.8.2, 3.8.1, 3.8.0, 3.7.6, 3.7.5, 3.7.4, 3.7.3, 3.7.2, 3.7.1, 3.7.0, 3.6, 3.5.4, 3.5.2, 3.5.1, 3.5,3.4, 3.3, 3.2, 3.1, 3.0, 
2.7.4, 2.7, 2.6, 2.5, 2.4
```

那么 `pod 'SDWebImage', '~> 3.7.0'` 只会安装 `3.7.6` 版本，也就是最后一个 `.` 的最高版本；

`pod 'SDWebImage', '> 3.7.0'` 安装大于 `3.7.0` 版本，当然有 `>=`, `<=` 和 `<`

`pod 'SDWebImage', '3.7.6'` 指定版本为 `3.7.6`

- *`:path`* 指定本地的 Pod 库

`pod 'FLoatDemo', :path => '~/Desktop/TestDemo/FLoatDemo'`

这里的地址不是随便一个目录就可以，必须是一个 Pod 库，不然会报错

```
No podspec found for `FLoatDemo` in `~/Desktop/TestDemo/FLoatDemo`
```

- *指定来源*

如果第三方库不能满足您项目的需求，那么你可以 `Fork`一份，来修改第三方代码。

```
pod 'SDWebImage', :git => 'https://github.com/lefex/SDWebImage.git', :commit => '94cdb773d74967f7ba2feecf0d151012bd965fde'
```

还可以有：`:branch`， `:tag => '3.1.1'`

- *Subspecs*

某个库可能很大，但是你仅仅需要某一部分，你只需要导入你需要的那部分即可，比如:

![SDWebimage.png](http://upload-images.jianshu.io/upload_images/1664496-fc7ddc88c80849af.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如何我们只需要 `pod ‘SDWebImage/Core’`  
也可以：`pod 'SDWebImage', :subspecs => ['Core', 'GIF']`

- 去除警告  

去除全部警告  
inhibit\_all\_warnings!    

去除某个库的警告   
pod 'SDWebImage', '~> 4.1.0', :inhibit_warnings => true

## pod install

如果修改了 `Podfile` 文件，那么执行 `pod install`。执行 `pod install` 后，会根据 Podfile 中的描述来安装所依赖的库。这时会生成很多文件。

- *Podfile.lock* 

这个文件主要用来锁定 Pods 库的版本。保证组内成员所使用的三方库都是统一版本。如果处理不当，这里很可能发生冲突，而且比较严重。

- *Manifest.lock* 

是 Podfile.lock 的副本，每次只要生成 Podfile.lock 时就会生成一个一样的 Manifest.lock 存储在 Pods 文件夹下。在每次项目 Build 的时候，会跑一下脚本检查一下 Podfile.lock 和 Manifest.lock 是否一致，如果不一致就抛出异常。这是它的脚本。

```
diff "${PODS_PODFILE_DIR_PATH}/Podfile.lock" "${PODS_ROOT}/Manifest.lock" > /dev/null
if [ $? != 0 ] ; then
    # print error to STDERR
    echo "error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation." >&2
    exit 1
fi
# This output is used by Xcode 'outputs' to avoid re-running this script phase.
echo "SUCCESS" > "${SCRIPT_OUTPUT_FILE_0}"
```


## pod update

仅仅把 Pods 更新到新的版本时需要。比如 `lefeKit` 项目中当前 `SDWebImage` 的版本为 *3.7.0*，这时我修改 Podfile 文件为：`pod 'SDWebImage', '>3.6.0'`，执行 `pod install` 后，本地的 `SDWebImage` 的版本任然为 *3.7.0* 。当执行 `pod update` 后变为 *4.1.0*

## 发布一个 Pod 库

**创建**

下面以 `lefeKit` 为例，说明创建私有库的过程。

- pod lib create lefeKit
这时需要输入提示问题，按照[官方文档](https://guides.cocoapods.org/making/using-pod-lib-create) 逐步完成；
- 登录自己的 github，创建一个名叫 `lefeKit` 的项目；
- 修改 `lefeKit.podspec` 文件，
`s.source           = { :git => 'https://github.com/lefex/lefeKit.git', :tag => s.version.to_s }` 需要是你在 github 上创建的项目地址；`s.homepage = 'https://github.com/lefex/lefeKit'`
- 根目录下（lefeKit）创建目录 `Classes`
- `pod lib lint` 检查`lefeKit.podspec` 文件是否有错，成功则显示 `lefeKit passed validation`；
- 一切无误后，执行 `pod trunk push lefeKit.podspec`
- `pod trunk me` 可以查看我注册的信息

这些步骤不是所有的都有先后顺序，创建私有库，关键是创建 `xxx.podspec` 文件和一个 `Repository`，让 `xxx.podspec` 关联到 `Repository`。

发布成功的提示为：

```
--------------------------------------------------------------------------------
 🎉  Congrats

 🚀  lefeKit (1.0.0) successfully published
 📅  August 28th, 21:58
 🌎  https://cocoapods.org/pods/lefeKit
 👍  Tell your friends!
--------------------------------------------------------------------------------
```

**更新私有库**

- 修改 `lefeKit.podspec` 文件中的版本号；
- tag tat 1.0.0，添加一个 tag；
- git push --tags
- `pod lib lint`
- `pod trunk push lefeKit.podspec`

**错误总结**

<font color=red>Authentication token is invalid or unverified. Either verify it with the email that was sent or register a new session.</font>

遇到这个错误说明你还没有注册账号，注册一个邮箱 `pod trunk register wsyxyxs@126.com`


<font color=red>WARN  | url: The URL (https://github.com/lefex1/lefeKit) is not reachable</font>

确保地址可以正确访问 `https://github.com/lefex1/lefeKit` 应为 `https://github.com/lefex1/lefeKit`
 
<font color=red>ERROR | [iOS] file patterns: The `source_files` pattern did not match any file.</font>

找不到资源文件，在根目录下创建 `Classes` 文件夹，并创建文件。`s.source_files = 'lefeKit/Classes/**/*'`
  
<font color=red>[!] Unable to find a pod with name, author, summary, or description matching `lefeKit`</font>

这个是本地缓存的问题：
清理缓存 `rm -rf ~/Library/Caches/Cocoapods`，执行 `pod setup`

## 技巧
所有命令后添加 `--verbose`，会显示更多的调试信息。


## 感谢
[关于 Podfile.lock 带来的痛](http://www.samirchen.com/about-podfile-lock)

[BY Blog](http://qiubaiying.top/2017/03/08/CocoaPods%E5%85%AC%E6%9C%89%E4%BB%93%E5%BA%93%E7%9A%84%E5%88%9B%E5%BB%BA/)

[pluto-y](http://www.pluto-y.com/cocoapod-private-pods-and-module-manager/)

[Cocoapods](https://guides.cocoapods.org/)

[Ruby China](https://ruby-china.org/)
