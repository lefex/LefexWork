### 说明
本文是作者[Lefe](http://www.jianshu.com/p/88957fad1226)所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。
###正文
还是15年的时候研究过MongoDB，过了一年，发现把以前学的都忘记了，最近做一个项目用到了MongoDB，不得不从头学起啊。
##### 1.搭建MongoDB数据库服务器（本地 Mac）
- 直接在官网上下载 MongoDB，下载好这个安装包后
- 解压刚才下载的安装包
- 把解压后的文件放到 /usr/local/ 目录下，[Lefe](http://www.jianshu.com/p/88957fad1226) 所用的目录是 `/usr/local/mongodb/`
- 在 `/usr/local/mongodb/`目录下创建 目录 `data/db`
- 启动数据库，进入目录/usr/local/mongodb/bin，输入：`./mongod --dbpath=/usr/local/mongodb/data/db/`

#### 2.服务器（腾讯云）
但是这仅仅是本地的，如果在服务器上安装呢？那么需要命令行工具，但是流程是一样的：

- 下载 mongodb 包
官网下载地址：[https://www.mongodb.com/download-center?jmp=nav#community](https://www.mongodb.com/download-center?jmp=nav#community)

`$ curl -O https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1404-3.2.9.tgz`

- 解压
`$ tar -zxvf mongodb-linux-x86_64-ubuntu1404-3.2.9.tgz`

- 重命名并移动到安装目录
`sudo mv mongodb-linux-x86_64-3.0.6/ /usr/local/mongodb`

- 在 `/usr/local/mongodb/`目录下创建 目录 `data/db`
- 启动数据库，进入目录/usr/local/mongodb/bin，输入：`./mongod --dbpath=/usr/local/mongodb/data/db/`

##### 3.IDE工具
- `robomongo`:Mac下.robomongo这个只支持mongo2.6,不支持mongo3.0版本。这个比较坑，关键他显示不出来数据也没个提示，我还以为我数据库有问题呢。
- `Studio 3T`:这个比较好用，一下就感觉很高大上的样子。


##### 参考：
[HcySunYang](http://hcysun.me/2015/11/21/Mac%E4%B8%8B%E4%BD%BF%E7%94%A8brew%E5%AE%89%E8%A3%85mongodb/)
[Linux平台安装MongoDB](http://www.runoob.com/mongodb/mongodb-linux-install.html)

[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
