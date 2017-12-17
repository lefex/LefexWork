![图片发自简书App](http://upload-images.jianshu.io/upload_images/1664496-8dd82280baa88ffb.jpg)

工作中很多同学已经会使用 Git 了，然而对各个概念比较模糊，这里主要理清 Git 中的各个概念，更好的理解 Git。如果你还不知道如何使用 Git，可以参考 @廖雪峰 [廖雪峰](https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000) 的文章。我也是一名 Git 菜鸟，看完 @画渣程序猿mmoaay 写的 Git 教程后，自己利用业余时间从头学习了 Git。更多内容可以参考[官网](https://git-scm.com/)。

## 命令行

使用 Git 时，我们完全可以利用 Git 命令行来完成我们的工作，但是通常情况下使用Git工具比较方便。比如：SoureTree。但是有时候不得不使用命令行，所以还是踏踏实实学习一下 Git 命令吧，当然详细的命令可以参考[官方文档]((https://git-scm.com/))。

- git init: 初始化一个空的 Git。在桌面上创建一个文件夹，然后创建一个空的 Git，执行完 `git init` 命令后，会新建一个隐藏的文件夹 `.git`。

```
$ mkdir lefeGit
$ cd lefeGit
$ git init
```
`lefeGit` 相当于一个仓库（repository）也称为我们的工作区，这里的文件将被 git 管理。

- git add: 把工作区的内容提交到暂存区；

```
$ touch lefe.js // 创建一个 lefe.js 文件
$ git add lefe.js // 把 lefe.js 文件修改的内容提交到暂存区
$ git add * // 把当前工作区所以修改过的内容一次提交到暂存区
```

- git commit: 把当前修改的内容提交到当前分支；

```
$ vi lefe.js // 编辑 lefe.js 文件
$ git add * // 把 lefe.js 文件修改的内容提交到暂存区
$ git commit -m 'add lefe' // 把当前修改的内容提交到当前分支，初始化git
的时候，会默认创建一个 master 分支，-m 后是提交时的备注
```

- git log: 显示从最近到最远的提交日志
- git log --pretty=oneline: 显示从最近到最远的提交日志，单行显示
- git reflog: 查看命令历史

```
$ git log
commit a7fcde1af5f78af8e44290f3951bb159a9bbcac0 (HEAD -> master)
Author: wangsuyan <wsyxyxs@126.com>
Date:   Thu Nov 2 16:23:35 2017 +0800

    add lefe
    
$ git log --pretty=oneline
a7fcde1af5f78af8e44290f3951bb159a9bbcac0 (HEAD -> master) add lefe
```

- git checkout -- file： 修改未提交到暂存区的文件

```
$ git checkout lefe.js // 撤销还没有提交到暂存区的更改，这是被修改的内容还在工作区中
```

- git reset HEAD file： 修改添加到暂存区的文件

```
$ git reset HEAD lefe.js // 撤销修改的文件到暂存区
$ git checkout lefe.js // 撤销对 lefe.js 文件的修改
```

- git reset --hard HEAD^: 回到上一次提交的
- git reset --hard HEAD～100: 回到前100次提交的
- git reset --hard b3a2ba0d9f92d3f: 回退到指定的版本

```
$ git reset --hard HEAD^
HEAD is now at a7fcde1 add lefe
```

- git status: 查看修改的状态

```
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   lefe.js

no changes added to commit (use "git add" and/or "git commit -a")
```

- git diff: 查看文件的差异

```
$ git diff
diff --git a/lefe.js b/lefe.js
index b245919..8999741 100644
--- a/lefe.js
+++ b/lefe.js
@@ -1 +1,2 @@
  Hello lefe
+wsy
```

- git clone：克隆一个仓库到本地，当你在远程仓库创建一个库后，使用 git clone 把项目克隆到本地；

```
$ git clone git@github.com:lefex/wsyLefe.git
```

- git remote add orgin git@github.com:lefex/wsyLefe.git 本地仓库关联一个远程库；

```
// 当你本地创建一个仓库后，需要提交到远程仓库时，就需要把本地仓库和远程仓库进行关联，这样就可以把本地的代码提交到远程仓库了，orgin 为远程仓库的名字，可以自定义
$ git remote add orgin git@github.com:lefex/gitLearn.git 
// 查看所关联的远程仓库
$ git remote -v
orgin	git@github.com:lefex/wsyLefe.git (fetch)
orgin	git@github.com:lefex/wsyLefe.git (push)
// 如果本地已经关联了远程仓库，需要删除后重新关联，当然也可以同时关联多个远程仓库
$ git remote rm origin
// 由于第一次提交，远程仓库是空的，需要把远程master仓库和本地的master仓库关联起来，以后可以直接使用 git push 来提交代码
$ git push -u orgin master
```

- HEAD: 指向当前分支；

- git checkout -b dev: 创建一个 dev 分支，并切换到 dev 分支；

```
$ git checkout -b dev
$ git branch hot  // 创建 hot 分支
$ git checkout hot // 切换到 hot 分支
$ git branch // 查看所有分支
$ git merge hot // 合并 hot 分支到当前分支
$ git branch -d hot // 删除 hot 分支
```

- 如果分支合并时出现冲突，git 使用 <<<<<<< HEAD， ======= 和 >>>>>>> dev 标记冲突的分支，HEAD 表示当前分支，dev 表示 dev 分支；

```
 Hello lefe
<<<<<<< HEAD
wsy add master
=======
add dev
>>>>>>> dev
```

- 当你正在dev分支上开发一个新功能时，突然老板说线上有个 bug 必须修复一下，然后提交个版本。咋办，新功能还需要1天才能写完，还不能提交。使用 git stash 可以暂存你所修改的内容。然后从主分支新建一个分支来修改bug，修改完后与主分支合并，bug修改完后可以继续开发新功能。git stash list 查看暂存的内容，git stash pop 恢复暂存的内容，也可以使用 git stash apply 恢复暂存的内容，但是恢复后，stash内容并不删除，你需要用git stash drop来删除。


- git push origin master: 把本地的修改提交到远程，origin 为远程分支，master 为本地分支；

- git pull: 从远程拉去内容；

- git tag: 给某次提交打一个标签，比如给每一提交的版本打一个标签，方便以后查找；

```
// 给当前提交的代码打一个名字为 v0.1 的 tag，默认是打在最新一次提交的位置
$ git tag v0.1

// 查看所有的 tag
$ git tag
v0.1
v0.2

// 查看提交记录
$ git log --pretty=oneline --abbrev-commit
48cd742 (HEAD -> master, tag: v0.2, tag: v0.1, orgin/master) chang lefe.js remot
8c2fd8e create lefe.js file

// 某一次提交版本后，忘记了打 tag，可以使用这个命令给某一次提交打 tag
$ git tag v0.01 8c2fd8e

// 提交tag的备注信息 -a：标签名 -m：备注信息
$ git tag -a v0.3 -m '0.3 version release'

// 删除标签
$ git tag -d v0.2
Deleted tag 'v0.2' (was 48cd742)

// 把某个 tag 提交给远程仓库
$ git push orgin v0.1
// 提交所有的 tag 到远程仓库
$ git push orgin --tags

// push 这个tag不小心打错了，并提交到了远程仓库，需要删除，先删除本地，在从远程仓库删除
$ git tag -d push
$ git push orgin :refs/tags/push

```

- git show: 显示某个 tag 的详细信息

```
$ git show v0.01
commit 8c2fd8ecec2f65f58ac1a531203ce520a78229d3 (tag: v0.01)
Author: wangsuyan <wsyxyxs@126.com>
Date:   Fri Nov 3 11:21:31 2017 +0800

    create lefe.js file

diff --git a/lefe.js b/lefe.js
new file mode 100644
index 0000000..37b455a
--- /dev/null
+++ b/lefe.js
@@ -0,0 +1 @@
+Hello lefe
```

- 如何提交代码到别人的仓库中（以 Github 为例）
fork 别人的代码到自己的账号下，从自己的账号下克隆刚才fork的项目，修改后提交到自己的代码仓库，如果需要提交给别人的代码中，需要发起一个 pull request，别人同意后，你的代码将出现在别人的仓库中。

- .gitignore：忽略要提交的文件
如果某些文件不希望提交到仓库中，可以使用 `.gitignore` 文件忽略它。[.gitignore](https://github.com/github/gitignore/blob/master/Objective-C.gitignore)

## Git Flow

![图片发自简书App](http://upload-images.jianshu.io/upload_images/1664496-d3069d37f257248b.jpg)

#### 简单介绍
Gitflow 是一个非常成功的分支模型，它主要分为2个（master, develop）主要的分支和3个（feature, release, hotfix）辅助分支。SourceTree 已经集成了它。它主要有以下几个分支组成：

- master
生产环境分支，它是非常稳定的版本，一但处于develop分支的代码没问题以后，将会被合并到这个分支用来发布代码。也就是说它处于随时待命的状态。

- develop
开发分支，最新的开发状态，它是基于 master 分支的，一旦开发完毕后，将被合并（merge）到 master 分支上。

- feature
功能分支，它是基于 develop 分支的，一旦功能开发完成，将被合并（merge）到 develop 分支

- release
发布分支，它是基于 develop 分支的，主要用来修改 bug，修改完 bug 后将被合并到 develop 和 master 分支。主要是测试版本供测试人员测试。 

- hotfix
补丁分支，基于 master 分支的，等不到新功能版本发布，必须发布一个布丁，bug 修复完成后将被合并到 master 分支，同时 hotfix 分支将被删除。

#### 使用

安装参考[这里](https://github.com/nvie/gitflow)

- 初始化 `git flow init`，这个命令主要创建了2个主要的分支(master 和 develop)，当使用 `git branch` 查看时，发现它创建了 2 个分支，并把当前分支切换到了 develop 分支。


- 假如想开发登录模块，使用`$ git flow feature start login`，主要创建并切换到 `feature/login` 分支，这时就可以在这个分支上开始工作了。当把登陆模块完成后，使用 `git flow feature finish login` 结束任务，它主要把 `feature/login` 分支合并到了 `develop` 分支，并删除了 `feature/login` 分支，同时切换到了 `develop` 分支。


- 开发完成后需要发布版本，`git flow release start 0.1.0` 将创建并切换到 `release/0.1.0` 分支，如果中途有 bug 可以修改，修改完成后 `git flow release finish '0.1.0` 发布版本，这时将切换到主分支。 

```
$ git flow release finish '0.1.0'
Switched to branch 'master'
Deleted branch release/0.1.0 (was c4958ec).

Summary of actions:
- Latest objects have been fetched from 'origin'
- Release branch has been merged into 'master'
- The release was tagged '0.1.0'
- Release branch has been back-merged into 'develop'
- Release branch 'release/0.1.0' has been deleted
```
- 当有紧急 bug 需要处理时，使用 `git flow hotfix start bugFix`，这时将创建并切换到`hotfix/bugFix `分支，当修复完成后，使用 `git flow hotfix finish bugFix` 结束 bug 的修复。

```
$ git flow hotfix finish 'bugFix'

Summary of actions:
- Latest objects have been fetched from 'origin'
- Hotfix branch has been merged into 'master'
- The hotfix was tagged 'bugFix'
- Hotfix branch has been back-merged into 'develop'
- Hotfix branch 'hotfix/bugFix' has been deleted
```

**注意** 使用 Gitflow 并不会把代码自动提交到远程仓库，需要自己收到提交。远程仓库只有`master` 和 `develop` 分支，`feature`，`release` 和 `hotfix` 分支并不提交到远程仓库，仅本地自己使用。

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
