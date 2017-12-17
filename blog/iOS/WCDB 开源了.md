### WCDB 开源了

如果APP对数据库要求不太高的情况下，可以直接使用 FMDB，而如果对数据库这块要求比较高的情况下，那么就需要优化数据库。一百条数据，没问题，1千条，几千万条呢？如果你的数据库还没问题，说明优化的比较好。而对于一个IM APP 来说，达到几百万条数据是很正常的，尤其是微信，数据量如此大的情况下还能做到如此的流畅。Lefe 曾经分析过微信的数据库，[这篇文章](http://www.jianshu.com/p/68e9f22f9680) 有介绍。好消息，微信的数据库框架尽然开源了。

> WCDB是一个高效、完整、易用的移动数据库框架，基于SQLCipher，支持iOS, macOS和Android

### 使用：
如果仅仅是想了解咋么使用 WCDB，我想直接看官方文档就可以了，[官方文档](https://github.com/Tencent/wcdb/wiki/iOS+macOS%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B)。lefe 只是想通过一个例子来验证他是否可以满足一个基本的 IM APP。一个基本的 IM APP 应该有以下几个表：

- 会话表

conId | conType  | draft | msgId
----|------|----  | ---
会话id | 会话类型 | 草稿 | 消息Id

- 消息表

msgId | type | content | time | state | from | to
----|------|---- | --- | --- | --- | --- | ----
消息id | 消息类型 | 内容 | 时间 | 发送状态 | 发送者 | 接收者

- 群组表

groupId | name  | creater 
----|------|----  | ---
群组id | 群名称 | 创建者 

- 好友表

friendId | nickname  | icon 
----|------|----  | ---
好友id | 昵称 | 头像 
