### 说明
本文是作者[Lefe](http://www.jianshu.com/p/88957fad1226)所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。
###正文
使用Node的时候你可以选择你自己的数据库，比如MongoDB，MySQL。再使用的都是都需要搭建一个数据库服务器。搭建一个数据库服务器对于小白用户来说很头疼。本文主要介绍MySQL数据库的搭建过程。
##### 1.搭建安装MySQL数据库服务器
搭建的时候仔细看这两篇文章，他会告诉你如何搭建
[搭建MySQL文章一](http://www.cnblogs.com/macro-cheng/archive/2011/10/25/mysql-001.html)
[搭建MySQL文章二](http://www.jianshu.com/p/fd3aae701db9)

##### 2.查看数据库
如果你想查看数据库中的数据，那么你需要一个数据库客户端，这里提供两个客户端。
[MYSQLWorkBench](http://itbilu.com/nodejs/npm/NyPG8LhlW.html)
[Sequel Pro](http://www.sequelpro.com/):这个感觉比较好用

##### 3.Node中使用
链接方法一：
```
var connection = mysql.createConnection(configure.mysql);
connection.connect( function(err) {
    if (err) {
        console.error('error connecting: ' + err.stack);
        return;
    }
    console.log('connected as id ' + connection.threadId);
    });
```
##### 4.安装好MySQL服务器后，需要在偏好设置中启动服务
链接数据库服务器的时候一定要先启动服务，安装MySQL的时候一定记得初始密码。

[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
