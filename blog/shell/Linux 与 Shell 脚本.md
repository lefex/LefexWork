# Linux 命令与 Shell 脚本

###【Linux文件处理 Day1】
前几天主要介绍了正则表达式的使用方法，这一期打算介绍一些 Linux 命令和 Shell 脚本，这些知识虽然不是我们必须要掌握的，但是它可以提高工作效率，而且这些知识对于开发者来说都是通用的，Android，iOS，后端，前端等，都需要一些 Linux 和正则表达式的知识。对于iOS开发者来说，Linux 的一些操作命令是薄弱环节，作者打算花费几天时间总结一下这方面的知识，旨在能够帮助更多同学不再害怕“命令”。如果在文中有不正确的地方，希望同学们能指点小弟一下。

【特别说明】下文提到所有的命令行的根路径均为：/Users/wangsuyan/desktop/linux，使用 `man 某个命令` ，比如 `man rm`，可以查看详细使用。

- 绝对路径：从根目录开始的全路径，一定是以 "/" 开头的；
pwd : 当前所在的目录，pwd：/Users/wangsuyan/desktop/linux，这个路径也称为绝对路径；
- . : 表示当前目录，pwd 可以显示当前所在的目录；
- .. : 上一级目录，/Users/wangsuyan/desktop/linux 的上一级目录为：/Users/wangsuyan/desktop；
- touch : 创建文件，touch lefe.js，创建文件 lefe.js，如果当前目录下已经有文件 lefe.js 文件，将修改 lefe.js 文件的创建时间；创建文件所在的目录不能包含没有创建的文件夹；
- rm：移除文件，rm lefe.js 将移除 lefe.js 文件；
- mv: 移动文件，mv lefe.js ../lefe2.js 将 lefe.js 文件移动到上一级目录，并重命名为 lefe2.js，lefe.js 文件将不在原目录下；
- cat: 查看文件内容，cat lefe.js 查看 lefe.js 的内容；
- head: 查看文件的内容，默认为前 10 行，head lefe.js 查看文件的前 10 行内容；
- head -n 20 lefe.js 查看文件的前 20 行内容；
- tail: 查看文件的内容，默认为末尾 10 行，tail lefe.js 查看文件的末尾 10 行内容；tail -n 20 lefe.js 查看文件的末尾 20 行内容；
- cd（change directory）: 进入文件目录；
- mkdir(make directory): 创建目录，mkdir lefe 创建文件夹 lefe，mkdir -p lefe/lefe2/lefe3 创建多个目录；
- rmdir(remove directory): 移除目录，rmdir lefe 删除 lefe 目录，将提升 
- rmdir: lefe: Directory not empty ，rmdir 只能删除目录中无文件的时候，使用 rm -r lefe 可以删除 lefe 目录及其所有的子目录；
- cp: 复制目录到指点目录中，cp lefe.js ../ 复制 lefe.js 文件到指定的目录中，cp -r lefe ../ 复制目录到指点目录；
- ls: 显示当前目录下的目录，ls -l : 显示文件的详细信息，ls -a 显示目录下所有文件或文件夹，包含隐藏的文件;
- chmod: 改变文件的权限，chomd +x ./lefe.sh 改 lefe.sh 的添加执行权限，一般运行脚本前需要给脚本添加此权限；
- file: 查看文件的类型，file lefe: lefe: directory，是目录文件；
- find: 查找文件；
- gzip: 压缩文件，gzip lefe.js 压缩 lefe.js 文件；
- gunzip: 解压文件，gunzip lefe.js.gz；
- tar: 压缩文件及其子文件，tar -zcvf lefe.tgz ./lefe 压缩文件夹 lefe 为 lefe.tgz, tar -zxvf ./lefe.tgz 解压 lefe.tgz 文件；

###【Linux字符处理 Day2】
- |：管道，两个命令之间可以使用管道符“|”链接，它可以把一个命令的输入作为下一个命令的输出；
- grep: 搜索文本,
- grep day lefe.js 搜索 lefe.js 文件中的 day；
- grep -n day lefe.js 搜索 lefe.js 文件中的 day，可以显示文本所出现的行；
- grep -i day lefe.js 搜索 lefe.js 文件中的 day，忽略大小写；
- grep -c day lefe.js 搜索 lefe.js 文件中的 day 出现的次数；
- grep -v day lefe.js 搜索 lefe.js 文件中不包含 day 的行；
- sort: 文本排序
- cat sort.js | sort 对文本进行排序；
- cat sort.js | sort -r 对文本进行反向排序；
- cat sort.js | sort -n 对文本进行排序，指定为数字，比如: 2，12，3 如果不使用参数 -n 排序结果为 12, 2, 3；反之为 2, 3, 12：
- uniq: 删除重复的行，一般与 sort 配合使用，先排序，然后多结果进行去重；
- cat lefe.js | sort | uniq 显示没有重复的行；
- tr: 文本转换
- cat lefe.js | tr -d 'day'：删除 lefe.js 文件中的 'd','a' 和 ‘y’；
- paste: 文本合并
- paste -d '>' lefe.js sort.js：合并 lefe.js 和 sort.js 文件，是以行合并的，使用 '>' 链接两个文件中的行；
- find: 查找文件，find 查找路径 -name 文件名
- find ~/Desktop/linux -name 'lefe.js'：查找 ~/Desktop/linux 下文件名为 lefe.js 的文件；
- find ~/Desktop/linux -name '*.js'：查找 ~/Desktop/linux 下后缀为 ‘js’ 的文件；

###【Shell 脚本 Day3】
经过前几天对 Linux 命令的学习，已经掌握了大部分常用的命令，但是如果想要做的更好，可以学习一下 Shell 脚本，它可以把多条命令按自己的方式来执行。它可以提高我们的工作效率。比如最常见的是 pod install 命令，每次需要在终端输入：

```
cd /Users/wangsuyan/Desktop/project/Kmart
pod install
```
这种输入需要我们切换到项目的根目录，我们往往不记得自己项目的目录，查找时比较耗时。我们完全可以使用一个脚本（podlgsk.sh），直接执行（./podlgsk.sh）。

```
#!/bin/bash
cd /Users/wangsuyan/desktop/project/Kmart
pod install
```

执行（执行前需要给脚本执行权限，chmod +x podlgsk.sh）：

```
$ ./podlgsk.sh
```
感受到脚本的“魅力”后，我们可以感受一下 @唐巧_body 查找未使用的图片的 shell 脚本。关于查找项目中未使用的图片也可以参考这里的 Python 脚本，用了你就会爱上它（开玩笑呢，别当真）。

```
#!/bin/sh

cd /Users/wangsuyan/Desktop/project/Kmart
PROJ=`find . -name '*.xib' -o -name '*.[mh]'`

for png in `find . -name '*.png'`
do
    name=`basename $png`
    if ! grep -qhs "$name" "$PROJ"; then
        echo "$png is not referenced"
    fi
done
```
【解析】
1. cd /Users/wangsuyan/Desktop/project/Kmart，进入项目所在的目录；
2. 查找项目中所有 png 图片；
3. 遍历所有的 png 图片，使用 grep 命令查找项目中是否使用过该图片，如果未使用将打印出 xxx is not referenced；


【知识点】
cd 命令（进入项目的根目录）；
find 命令（查找符合要求的文件，这里注意查找 xib，.h 和 .m 文件）；
grep 命令（查找文本内容）；
正则表达式，比如：'*.[hm]' 和 '*.xib'。 **关于正则表达式的使用，上一期已经专门介绍了**；
Shell 脚本中的 for 循环，if 条件判断。

了解了 Shell 脚本的使用后，下一次将介绍一些它的基本语法，帮助读者可以看懂 Shell 脚本。

###【Shell 脚本 Day4】
使用 Pod 的同学经常会遇到 `"error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation."` 错误，其实是 `[CP] Check Pods Manifest.lock` 这个脚本所起的作用。

Pod 中有 Manifest.lock 和 Podfile.lock 这两个文件，只要这两个文件的内容不一样就会报错上面这个错误。Podfile.lock 是大家共用的文件（用来保证我们每个人的Pod库版本一样），而Manifest.lock是本地的文件（自己用）。而【图2】中这个脚本正是做这样的事情。

解释下这个脚本：
shell 脚本总是以：`#!/bin/bash` 或者 `#!/bin/sh` 开头，它主要告诉系统执行这个文件需要那个解释器，进入 /bin 目录下可以看到 bash 和 sh 解释器；

- diff 命令：判断两个文件的不同，比如 diff /Users/lefe/Desktop/project/Kmart/Podfile.lock /Users/lefe/Desktop/project/Kmart/pods/Manifest.lock >~/Desktop/shell.log 比较两个文件的不同，并重定向到 shell.log 文件中；
- \> 重定向符号，可以把输出命令输出到某个文件中而不是控制台；
- echo 是脚本的输出，相当于 printf；
- exit 1 退出，有了这个命令 Xcode 就会报错，你可以在 Xcode 中新建一个脚本，试试下面这个脚本：

```
echo "This is a test shell created by Lefe_x"
exit 1
```
- $?： 指上条命令执行的结果，也就是 diff 执行的结果；

- 下面是 shell 中的 if 语句：
```
if 条件 ; then
fi
```

如何在终端执行脚本：
假如有个叫 `podlgsk.sh` 的脚本，只要给予它执行权限（`chmod +x podlgsk.sh`），注意只需要给一次执行权限就行，下次运行脚本时就不需要给予执行权限了，然后直接 `./podlgsk.sh` 即可。


[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
