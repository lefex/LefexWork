# 说明
本文是作者[Lefe](http://www.jianshu.com/p/88957fad1226)所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。

# 正文
微信绝对是在IM领域的领军人物，无论是从性能还是用户体验方面，它都是非常棒的。所以作者打算拆一拆微信的包，一探究竟。本文主要从数据库方面来聊一聊微信数据库的设计，也许有不对的地方，希望读者可以指出。微信的数据库中主要记录了消息，好友，漂流瓶，表情的数据，至于朋友圈这种数据，

## 一、如何获取微信的数据库
-  1.手机连接到iTunes，把手机的数据加密备份，记得要记住密码，数据恢复的时候会用到，然后点击立即备份，等待备份完成。

![屏幕快照 2017-03-12 上午9.59.36.png](http://upload-images.jianshu.io/upload_images/1664496-68a6738416ab3053.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 2.把刚才备份的数据导出，[Lefe](http://www.jianshu.com/p/88957fad1226)使用的是 [iPhone Backup Extractor](http://www.iphonebackupextractor.com/free-download/)，使用免费版的就可以，不过有10秒的广告和每次只能导出4个文件的限制。下载后直接安装，用USB连接到手机，打开  [iPhone Backup Extractor](http://www.iphonebackupextractor.com/free-download/)。将会显示：

![屏幕快照 2017-03-12 上午10.11.08.png](http://upload-images.jianshu.io/upload_images/1664496-204f8b57c631210c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

输入密码后点击，【Check】，点击后耐心等待，时间比较长。

- 3.找到微信的包，在目录Application Domains/com.tencent.xin/{UUID}/DB/MM.sqlite下，直接将MM.sqlite导出即可。

![屏幕快照 2017-03-12 上午10.36.20.png](http://upload-images.jianshu.io/upload_images/1664496-152f647738e09cb0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## 二、分析数据库
- 1.下载sqlite数据库工具 [SqliteStudio](https://sqlitestudio.pl/index.rvt)，有了这个工具，我们就可以看到数据库中的数据了。关于这个客户端的使用，[Lefe](http://www.jianshu.com/p/88957fad1226)就不一一介绍了。

- 2.添加数据库，数据库整体结构如下：

![数据库.png](http://upload-images.jianshu.io/upload_images/1664496-2ad1dd846faaa58a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 3.通过观察数据库可以发现，微信会根据每一个会话创建一张表。`Chat_006ea3832f24de6e294058a8046a7041`，这是一张聊天表，`006ea3832f24de6e294058a8046a7041`应该是根据某一规则生成的一个会话ID，来唯一标记一个会话。这张表中记录了与某一个人或者某个群的聊天信息。如果有对方消息，将会生成另外一张表`ChatExt2_006ea3832f24de6e294058a8046a7041`，这张表中仅记录了对方的聊天记录。具体记录如下：
**Chat_006ea3832f24de6e294058a8046a7041 表中的数据：**

![屏幕快照 2017-03-12 上午10.45.58.png](http://upload-images.jianshu.io/upload_images/1664496-27ebc07167eb62ed.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

字段说明：
``
CREATE TABLE Chat_006ea3832f24de6e294058a8046a7041 (
    TableVer   INTEGER DEFAULT 1, // 表的版本，应该是数据表升级使用
    MesLocalID INTEGER PRIMARY KEY AUTOINCREMENT, // 本地消息ID，是主键，这里会有与沙盒中的数据有关联
    MesSvrID   BIGINT  DEFAULT 0, // 服务端的消息ID
    CreateTime INTEGER DEFAULT 0, // 创建时间
    Message    TEXT, // 具体消息内容，这里可以是普通字符串，也可以是XML文件，具体不知道微信使用XML文件有什么好处
    Status     INTEGER DEFAULT 0, // 消息状态，比如发送失败，成功，正在发送
    ImgStatus  INTEGER DEFAULT 0, // 图片的状态
    Type       INTEGER, // 消息类型
    Des        INTEGER // 是否为自己发的消息
);
``
**ChatExt2_006ea3832f24de6e294058a8046a7041表中数据**

![屏幕快照 2017-03-12 上午10.52.51.png](http://upload-images.jianshu.io/upload_images/1664496-1d51d8f3611b48c9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这张表中的数据不知道具体做什么业务逻辑，不过估计是和服务端的一个交互，它仅仅和发消息有关。

- 4.索引，如果想提高查询速度，创建索引是必不可少的，微信消息表中的索引主要有：

![屏幕快照 2017-03-12 上午11.45.57.png](http://upload-images.jianshu.io/upload_images/1664496-15fd7ee8cabbdcbc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 三、对于不确定字段的消息使用XML
不知道微信出于何种目的使用XML来存储消息而不是用Json。这是一条语音消息的XML，主要记录与语音相关的一些数据。
``<msg>
  <voicemsg endflag="1" length="5191" voicelength="2765" clientmsgid="413732333061346137623033623761000210050311171040be667d4103" fromusername="wxid_hhu2ojejexmy22" downcount="0" cancelflag="0" voiceformat="4" forwardflag="0" bufid="435693659307967035"/>
</msg>
``
## 四、沙盒与数据库的关系
关键点就是ID:`006ea3832f24de6e294058a8046a7041`和`MesLocalID`，寻找沙盒中的文件会根据这两个ID来找到对应的资源文件，比如音频和视频。这样可以很方便的找到某一条消息对应的资源。

![屏幕快照 2017-03-12 上午11.06.10.png](http://upload-images.jianshu.io/upload_images/1664496-15595f066fcd4987.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
## 五、好友表
``
CREATE TABLE Friend (
    TableVer     INTEGER DEFAULT 1, // 表的版本
    UsrName      TEXT    NOT NULL PRIMARY KEY ON CONFLICT REPLACE,// 用户名，唯一
    NickName     TEXT, // 昵称
    Uin          INTEGER DEFAULT 0,
    Email        TEXT,
    Mobile       TEXT,
    Sex          INTEGER DEFAULT 0,
    FullPY       TEXT,
    ShortPY      BLOB,
    Img          TEXT,
    Type         INTEGER DEFAULT 0,
    LastChatTime INTEGER DEFAULT 0, // 最后聊天时间
    Draft        TEXT // 草稿
);
``
这里主要说明一下：`PRIMARY KEY ON CONFLICT REPLACE`，这句话的意思是说如果冲突了，就替换的。

微信的好友表是把所有的用户放到了一张表，不管是好友还是非好友。这张表中包含的用户有好友，群组，公众号等，总的来说是客户端所有用户的一个集合，想想做密语的时候，为什么要多个表呢？如果是一个表，是不取所有用户的昵称，头像等信息时就不需要进行连表查询了。而且仅使用一个 Model 既可以搞定，这样不会设置到不同用户 Model 之间的转换。

还有一个问题比较好奇，微信用户的头像不会及时更新，只有进入详情后会更新。
它有个字段叫 imgStatus 标记着头像的当前状态，猜测是为了更新头像用。

```
CREATE TABLE Friend (
    userName               TEXT    PRIMARY KEY ON CONFLICT REPLACE,
    type                   INTEGER DEFAULT 0,
    certificationFlag      INTEGER DEFAULT 0,
    imgStatus              INTEGER DEFAULT 0,
    encodeUserName         TEXT,
    dbContactLocal         BLOB,
    dbContactOther         BLOB,
    dbContactRemark        BLOB, // 昵称或好友的备注
    dbContactHeadImage     BLOB,
    dbContactProfile       BLOB,
    dbContactSocial        BLOB,
    dbContactChatRoom      BLOB, // 所有群成员
    dbContactBrand         BLOB,
    _packed_DBContactTable BLOB
);
```

## 六、消息表类型
通过下面对微信消息的分析可以得出以下结论：
微信消息类型主要分为：

- 系统消息：1000
- 文本消息，包含小表情：1
- 图片消息，相机中的照片和配置有不同，从相册中发送的消息中会保留一个 MMAsset，如同 PAAset：3
- 位置消息： 48
- 语音消息：34
- 名片消息，公众号名片和普通名片用的是同一种类型：42
- 大表情：47
- 分享消息，这种消息会含有多种类型，比如分享的收藏，分享的小程序，微信红包等等。这种消息类型可以避免不断添加多种消息类型，像这种预先定义一种消息类型，预留一些字段，这样产品添加消息类型的时候，UI 可以任意组合：49

### 系统消息

```
type: 1000
content: 你邀请武卓、田向阳、memory、刘运新加入了群聊
```


### 文本消息

```
type: 1
content: 测试个东西，不要发消息[微笑]
```

### 图片消息

```
type: 3
content:

<msg>
  <img 
  hdlength="0" 
  length="25739" 
  cdnbigimgurl=""
  cdnmidimgurl="加密过的 url" 
  aeskey="7dae3aef046a444d88a5cc679738c10b" 
  cdnthumburl="加密过的 url" 
  cdnthumblength="3312" 
  cdnthumbwidth="120" 
  cdnthumbheight="70" 
  cdnthumbaeskey="7dae3aef046a444d88a5cc679738c10b" 
  encryver="1" 
  md5="69b3f7f0554618cc5ad94b0924dcb79d"/>
  
  <MMAsset>
    <m_assetUrlForSystem><![CDATA[34340C09-0423-4DDC-AEC7-5AEABD083C28/L0/001]]></m_assetUrlForSystem>
    <m_isNeedOriginImage>0</m_isNeedOriginImage>
    <m_isFailedFromIcloud>0</m_isFailedFromIcloud>
    <m_isLoadingFromIcloud>0</m_isLoadingFromIcloud>
  </MMAsset>
</msg>
```

### 相机图片

```
type：3
content: 

<msg>
  <img 
  hdlength="590953" 
  length="61171" 
  cdnbigimgurl="加密过的 url" 
  cdnmidimgurl="加密过的 url"
   aeskey="6d7f1c6d4e4d4bd3a2f94994646ebc17" 
   cdnthumburl="加密过的 url" 
   cdnthumblength="3540" 
   cdnthumbwidth="67" 
   cdnthumbheight="120" 
   cdnthumbaeskey="6d7f1c6d4e4d4bd3a2f94994646ebc17" 
   encryver="1" 
   md5="e8510edd66d6594c560fcd32be886ad5"/>
</msg>
```

### 位置消息：

```
type: 48
content:

<msg>
<location 
x="39.955407" 
y="116.458604" 
scale="15.010000" 
label="北京市朝阳区三元桥天元港中心(东三环北路)" 
poiname="朝阳区三元桥天元港中心(东三环北路)" 
maptype="roadmap" 
infourl="" 
fromusername="" />
</msg>
```

### 微信红包（发）
type: 49
content: 

```
<msg>
  <appmsg appid="" sdkver="0">
    <title>微信红包</title>
    <des>我给你发了一个红包，赶紧去拆! 祝：恭喜发财，大吉大利！</des>
    <action/>
    <type>2001</type>
    <showtype>0</showtype>
    <soundtype>0</soundtype>
    <mediatagname/>
    <messageext/>
    <messageaction/>
    <content/>
    <contentattr>0</contentattr>
    <url>https://wxapp.tenpay.com/mmpayhb/wxhb_personalreceive?showwxpaytitle=1&msgtype=1&channelid=1&sendid=1000039401201707207016154830099</url>
    <lowurl/>
    <dataurl/>
    <lowdataurl/>
    <appattach>
      <totallen>0</totallen>
      <attachid/>
      <emoticonmd5/>
      <fileext/>
      <cdnthumbaeskey/>
      <aeskey/>
    </appattach>
    <extinfo/>
    <sourceusername/>
    <sourcedisplayname/>
    <thumburl>http://wx.gtimg.com/hongbao/1701/hb.png</thumburl>
    <md5/>
    <statextstr/>
    <wcpayinfo>
      <paysubtype>10001</paysubtype>
      <feedesc><![CDATA[(null)]]></feedesc>
      <transcationid><![CDATA[(null)]]></transcationid>
      <transferid><![CDATA[(null)]]></transferid>
      <invalidtime>0</invalidtime>
      <effectivedate>0</effectivedate>
      <begintransfertime>0</begintransfertime>
      <templateid>7</templateid>
      <url><![CDATA[https://wxapp.tenpay.com/mmpayhb/wxhb_personalreceive?showwxpaytitle=1&msgtype=1&channelid=1&sendid=1000039401201707207016154830099]]></url>
      <nativeurl><![CDATA[wxpay://c2cbizmessagehandler/hongbao/receivehongbao?msgtype=1&channelid=1&sendid=1000039401201707207016154830099&sendusername=wxid_5lg2yjtnadtk21&transid=8fb3e6d42021e3496f471c0e9652f1f0e80f669946d0e33b9e5b2d5f2412a3442ffacce6c5f2cc4a291fb39ff52acdd8]]></nativeurl>
      <iconurl><![CDATA[http://wx.gtimg.com/hongbao/1701/hb.png]]></iconurl>
      <locallogoicon><![CDATA[c2c_hongbao_icon_cn]]></locallogoicon>
      <receivertitle><![CDATA[恭喜发财，大吉大利]]></receivertitle>
      <sendertitle><![CDATA[红包已被领完]]></sendertitle>
      <hinttext><![CDATA[(null)]]></hinttext>
      <scenetext><![CDATA[微信红包]]></scenetext>
      <sceneid>1002</sceneid>
      <redenvelopetype>-1</redenvelopetype>
      <redenvelopereceiveamount>-1</redenvelopereceiveamount>
      <senderdes><![CDATA[查看详情]]></senderdes>
      <receiverdes><![CDATA[领取红包]]></receiverdes>
      <total_fee><![CDATA[(null)]]></total_fee>
      <fee_type><![CDATA[(null)]]></fee_type>
      <innertype>0</innertype>
      <paymsgid><![CDATA[1000039401201707207016154830099]]></paymsgid>
      <pay_memo><![CDATA[(null)]]></pay_memo>
      <imageid><![CDATA[]]></imageid>
      <imageaeskey><![CDATA[]]></imageaeskey>
      <imagelength>0</imagelength>
      <newaa>
        <billno><![CDATA[(null)]]></billno>
        <newaatype>0</newaatype>
        <launchertitle><![CDATA[(null)]]></launchertitle>
        <receivertitle><![CDATA[(null)]]></receivertitle>
        <receiverlist><![CDATA[(null)]]></receiverlist>
        <payertitle><![CDATA[(null)]]></payertitle>
        <payerlist><![CDATA[(null)]]></payerlist>
        <notinertitle><![CDATA[(null)]]></notinertitle>
        <launcherusername><![CDATA[(null)]]></launcherusername>
      </newaa>
    </wcpayinfo>
  </appmsg>
  <fromusername>wxid_5lg2yjtnadtk21</fromusername>
  <appinfo>
    <version>0</version>
    <appname/>
    <isforceupdate>1</isforceupdate>
  </appinfo>
</msg>
```

### 好友领取红包

```
type: 1000
content:

![](SystemMessages_HongbaoIcon.png)  刘运新领取了你的<_wc_custom_link_ color="#FD9931" href="weixin://weixinhongbao/opendetail?sendid=1000039401201707207016154830099">红包</_wc_custom_link_>

![](SystemMessages_HongbaoIcon.png)  memory领取了你的<_wc_custom_link_ color="#FD9931" href="weixin://weixinhongbao/opendetail?sendid=1000039401201707207016154830099">红包</_wc_custom_link_>

![](SystemMessages_HongbaoIcon.png)  田向阳领取了你的<_wc_custom_link_ color="#FD9931" href="weixin://weixinhongbao/opendetail?sendid=1000039401201707207016154830099">红包</_wc_custom_link_>，你的红包已被领完 

```

### 语音消息

```
type: 34
content:
<msg>
<voicemsg voicelength="3920" voiceformat="4" forwardflag="0" />
</msg>

```

### 名片消息

```
type: 42
content:

<msg 
username="wxid_0td2kgz84pg921" 
nickname="memory" 
fullpy="memory" 
shortpy="" 
alias="xuehaoxia1111" 
imagestatus="3" 
scene="17" 
province="山东" 
city="中国" 
sign="" 
sex="2" 
certflag="0" 
certinfo="" 
brandIconUrl="" 
brandHomeUrl="" 
brandSubscriptConfigUrl="" 
brandFlags="0" 
regionCode="CN_Shandong_Yantai"/>

```

### 转发收藏消息

```
type:
content: 和 微信红包（发）消息格式一样

```

### 大表情

```
type: 47
content:
<msg>
  <emoji 
  md5="11454a2b7038f07a5512f9c62daac0cf" 
  type="2" 
  len="14732"
  productid="com.tencent.xin.emoticon.person.stiker_14749712227df9bdb9bfc1cd40" 
  width="240" 
  height="240"/>
  <gameext type="0" content="0"/>
</msg>
```

### 分享小程序

```
type: 49
content: 和 微信红包（发）消息格式一样
```

### 公众号名片

```
type: 42
content: 和普通名片消息的结构一样
```

## 七、总结
关于IM本地数据库中的消息表非常重要，微信采用了分表的方式来提高性能及速度，但是对于小型的IM APP来说，这种设计方式会增加操作的复杂度，比如全局搜索。但是通过这次分析微信的数据库，我们可以借鉴他的优点。比如对于不确定的字段个数，可以作为一个XML来保存成一个字段，或者JSON，消息和本地的资源更好的联系起来。

本文主要参考：
https://github.com/Unknwon/wuwen.org/issues/15
http://www.race604.com/sqlite-insert-or-replace/


===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
