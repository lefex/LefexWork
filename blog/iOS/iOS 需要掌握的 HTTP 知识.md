# iOS 需要掌握的 HTTP 知识

> 本文主要通过阅读《图解HTTP》一书后的总结。

对 HTTP 知识一直缺少一些系统的学习，但平时工作中经常与 HTTP 打交道，故打算对 HTTP 知识进行一次全面的学习。《图解HTTP》主要围绕以下知识点进行展开：

- 了解Web及网络基础
- 简单的HTTP协议
- HTTP报文内的HTTP信息
- 返回结果的HTTP状态码
- 与HTTP协作的Web服务器
- HTTP首部
- 确保Web安全的HTTPS
- 确认访问用户身份的认证
- 基于HTTP的功能追加协议
- 构建Web内容的技术
- Web的攻击技术

## 了解Web及网络基础

TCP/IP可以理解为TCP和IP协议，也可以理解为它是在IP协议通信过程中，使用到的协议族统筹。TCP/IP协议族按层次分为4层：应用层、传输层、网络层和数据链路层。这样分层后的好处，如果某个协议发生改变，只需改变某一层即可。

- 应用层：提供应用服务时通信的活动，我们今天的主角HTTP协议就处于这层；
- 传输层：提供处于两台计算机之间的数据传输，主要有 TCP（Transmission Control Protocol）和 UDP（User Data Protocol）两种协议；
- 网络层（IP协议）：用于处理网络上流动的数据包。数据包时网络传输的最小数据单位。
- 数据链路层：用来处理网络连接的硬件部分。

![WechatIMG2.jpeg](https://upload-images.jianshu.io/upload_images/1664496-d66701260d9a0b71.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**TCP协议**

提供了可靠的字节流传输服务。为了保证数据送达目标处，它采用3次握手策略。

- 发生端发送一个带SYN标志的数据包给对方；
- 对方接收到后，回传一个带有 SYN/ACK 标志的数据包以示数据已送达；
- 最后，发送方回传一个带 ACK 标志的数据包，表示“握手”结束。

HTTP协议与DNS，TCP和IP协议的关系可以用图来说名：

![31521347532_.pic.jpg](https://upload-images.jianshu.io/upload_images/1664496-2a33eb16bdece0ea.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


**URI**

URI（Uniform Resource Identifier统一资源标识符）

- Uniform：规定统一的格式方便处理不同类型的资源；
- Resource：可标识的任何东西；
- Identifier：标识符，可标示的对象。

URI 就是由某个协议方案表示的资源定位标识符。其中协议方案是指访问资源所使用协议类型名称，比如 http，ftp 等。其主要作用就是定位互联网上的资源。

URL（Uniform Resource Locator 统一资源定位符），它主要表示互联网上的资源，可见 URL 时 URI 的子集。

```
http://user:pass@www.lefe.com:80/dir/index.html?uid=1#ch1
协议方案名://登录信息:服务器地址:服务器端口/带层次的文件夹路径?查下字符串#片段标识符
```

## 简单的HTTP协议

HTTP 协议用于客户端和服务端之间的通信。由客户端主动发起请求，服务端做出响应并返回给客户端。客户端和服务端的报文信息如下：

**客户端**

```
<!--方法 URI 协议版本-->
POST /form/index.html HTTP/1.1

<!--请求首部字段-->
Host: 192.168.1.1
Connection: kepp-alive
Content-Type: application/x-www-form-urlencode
Content-Length:16

<!--内容实体-->
name=lefex&age=37
```

**服务端**

```
<!--协议版本 状态码 状态码原因短语-->
HTTP/1.1 200 OK

<!--响应首部字段-->
Date:Tue,10
Content-Type: application/x-www-form-urlencode
Content-Length:16

<!--主体-->
<html>

```

**方法说明**

- GET 获取资源
用来请求访问已被 URI 识别的资源。
- POST 传输实体主体
用来传输实体的主体，虽然它和 GET 请求基本一样，但一般用 POST 方法进行上传数据。
- PUT 传输文件
- HEAD 获取报文首部
用于确认 URI 的有效性及资源更新的日期时间等。
- DELETE 删除文件
- OPTIONS 询问支持的方法
- TRACE 追踪请求过程中的路径

**连接**

每一次 HTTP 请求都会建立一次 TCP 链接。所有就引入了持久连接的概念（keep-alive） ，它的特点是只要任意一端没有明确提出断开链接，则保持TCP的连接状态。也就是说可以建立一次 TCP 连接进行多次请求和响应。

**管线化（pipelining）**

从前每次发送一次请求只能等上一次有响应后才能继续发送，而有了管线化可以同时发送多个请求。

**Cookie**

HTTP 是不会保留状态的协议，也就是说它不会对请求和响应做持久化处理。然而有些网站需要用户登录，即使跳转到其他页面页需要保留登录状态，所以就引入了 Cookie 的技术。

Cookie 技术通过在请求和响应报文中写入的Cookie信息来控制客户端的状态。

Set-Cookie：开始状态管理所使用的 Cookie 信息，响应首部字段
Cookie：服务器收到的Cookie信息，请求首部字段

**范围请求**

```
content-type:multipart/byteranges
```

请求部分数据：

```
Range:bytes=500-1000
<!--500之后的所有-->
Range:bytes=500-
```

## HTTP报文内的HTTP信息

用于 HTTP 协议交互的信息被称为HTTP报文，请求端的HTTP报文叫做请求报文，响应端的叫做响应报文。报文本身是由多行数据构成的字符串文本。HTTP 报文大致可分为报文首部和报文主体两块。

![41521362893_.pic.jpg](https://upload-images.jianshu.io/upload_images/1664496-32751f395a8cf21e.jpg?imageMogr2/auto-orient/strip%7CimageView/2/w/1240)

## 返回结果的HTTP状态码

状态码的职责是当客户端向服务端发送请求时，描述返回的请求结果。

- 1xx：接收的请求正在处理；
- 2xx：请求正常处理完毕
   - 204: No Content 一般只由客户端向服务端发出请求，客户端不错处理
   - 206: Partial Content 表示客户端进行了范围请求，而服务端成功执行了这部分请求
- 3xx：重定向状态码，需要附加操作以完成请求
   - 301: Move Permanently 永久重定向，
   - 302: 临时重定向
   - 303: 临时重定向，需要客户端指定用 GET 请求
   - 304: 服务端资源未发生改变
- 4xx：服务端无法处理请求
   - 400: 请求报文中存在语法错误
   - 401: 需要用户认证
   - 403: 请求的资源被服务器拒绝了
   - 404: 服务器无法找到资源
- 5xx：服务器处理请求出错
   - 500: 服务端在处理请求时发生了错误
   - 503: 服务器处于超负载货正在停机维护，无法处理请求

## 与HTTP协作的Web服务器

一台Web服务器可以搭建过个独立域名的Web网站，也可以作为通信路径上的中转服务器提升传输效率。

**代理服务器**

![51521363739_.pic.jpg](https://upload-images.jianshu.io/upload_images/1664496-d9422036fa62ee40.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## HTTP首部

HTTP协议的请求和响应报文中必定包含HTTP首部。


![61521364101_.pic.jpg](https://upload-images.jianshu.io/upload_images/1664496-599d3e8a6694340d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**通用首部字段**

请求报文和响应报文都会使用的首部。

- Content-type: 表示报文主体对象的类型；
- Cache-Control: 控制缓存的行为，也就是服务器提供的缓存策略；
`Content-type: no-cache` 直接获取最新资源，不需要缓存数据，中间的缓存服务器必须把客户端的请求发送给源服务器。
- Connection: 逐跳首部，连接的管理；
`Connection: Keep-Alive` 表示建立的 TCP 链接时持久的链接；
- Date：创建报文的日期；
- Pragma：no-cache 客户端要求所有的中间服务器不返回缓存的资源；
- Trailer：报文末端首部一览，事先说明报文主体后记录了哪些首部字段；
- Transfer-Encoding：报文主体传输编码方式；
- Upgrade：升级为其它协议，用于检查 HTTP 协议及其它协议是否可使用更的的版本进行通信；
- Via：代理服务的相关信息，为了追踪客户端与服务器之间的请求和响应报文的传输路径；
- Warning：错误通知。

**请求首部字段**

客户端向服务端发送请求报文中所使用的字段。

- Accept：用户代理可处理的媒体类型，告诉服务器客户端需要的资源类型；
`Accept: text/html;q=0.6,application/xml;q=0.8`, q 表示优先级，默认为 1.0；
- Accept-Charset：优先的字符集；
- Accept-Encoding：告知服务端客户端的内容编码及内容编码的顺序；
`Accept-Encoding：gzip` 使用 gzip 的压缩格式；
- Accept-Language：用于告诉服务器客户端需要的自然语言集，以及优先级；
- Authoriaztion：Web认证信息；
- Expect：期待服务器的特定行为；
- From：用户的电子邮箱；
- Host：请求资源所在的服务器，包含主机名和端口；
- if-Match：附带条件的请求，如果你能满足我的需求我就接受你的请求，比较实体的标记（ETag，它是与资源关联的值，如果资源更新这个值也会更新），如果符合客户端的标记则接受请求；
- if-Modified-Since: 比较资源的更新时间；
- if-None-Match: 比较实体标记，与 if-Match 相反；
- if-Range：资源未更新时发送实体 Byte 的范围请求；
- if-Unmodified-Since:比较资源的更新时间；
- Max-Forwards:最大转发数，告诉服务端最多经过的中间服务器个数；
- Proxy-Authorization:代理服务器要求客户端的认证信息，接受到代理服务器的认证后，客户端用这个字段告诉服务器认证的信息；
- Range：实体的字节范围请求，断点下载需要这个字段；
- Referer：对请求中URI的原始获取方，告诉服务器请求的原始资源的 URI；
- TE：传输编码的优先级；
- User_Agent：HTTP客户端程序信息；

**响应首部字段**

由服务端向客户端发送报文中所使用的字段。

- Accept-Ranges：是否接受自己范围请求，告诉客户端是否接受范围请求，如果为 None 则表示不接受，bytes 表示接受
- Age：告诉客户端源服务器在多久前创建了响应，单位为秒
- ETag：资源的匹配信息，资源更新后这个值就会发生改变
- Location：令客户端重定向指定的 URI
- Proxy-Authenticate：代理服务器对客户端的认证信息
- Retry-After：对再次发起请求的时机要求，告诉客户端多久之后在来发送请求
- Server：HTTP服务器安装的信息
- Vary：代理服务器缓存的管理信息
- WWW-Authenticate：服务器对客户端的认证信息

**实体首部字段信息**

包含在请求报文和响应报文中实体部分所使用的首部。

- Allow：资源可支持的 HTTP 方法
- Content-Encoding: 实体主体使用的编码方式
- Content-Language:实体主体的自然语言
- Content-Length:实体主体的大小（单位：字节），本次传输数据的大小
- Content-Location:表示资源的URI
- Content-MD5:实体主体的报文摘要，是一串由MD5算法生成的值，其目的在于检查报文主体在传输过程中是否保持完整
- Content-Range:实体主体的位置范围，以字节为单位
- Content-Type:实体主体的媒体类型
- Expires:告诉客户端资源的过期日期
- Last-Modified:资源的最后修改日期


## 确保Web安全的HTTPS

与 SSL（Secure Socket Layer 安全套接层）组合使用的 HTTP 被称为 HTTPS。也称为通信的加密。也可以使用 HTTP 传输加密的内容，这种方式要求客户端和服务端都具有加密解密的机制。

HTTP 可以是任意客户端发起的请求，服务的服务验证请求的客户端，客户端也无法确认数据是否为服务端返回的。

- 无法确认请求的服务器是否真实
- 无法确认客户端是否真实
- 无法确认是否具有访问权限
- 无法确认请求来自何方

证书是由值得信任的第三方机构颁发，用来证明客户端和服务端是实际存在的。

客户端发送请求时需要通过正式确认服务器是否为安全的。

HTTP 无法确认内容是否被篡改，可能请求过程中遭到了中间人攻击。

HTTP+加密+认证+完整性保护 = HTTPS

SSL 独立与 HTTP 协议，HTTPS 就是 HTTP 先和 SSL 通信，SSL 再和 TCP 协议通信。

HTTPS 使用共享密钥和公开密钥加密两者并用的混合加密机制。由于对称加密速度比非对称加密速度快，所以使用非对称加密传输对称加密的密钥。

无法证实公开密钥的真假。如何确认收到的公钥是原本预想的那台服务器发行的公钥呢？这就引出了数字证书的概念。数字证书机构是客户端和服务的都信任的的第三方机构。

服务端向第三方证书机构申请证书 - 拿到证书给客户端下发 - 客户端验证证书是否合法 - 确保公钥正确

使用 OpenSSL 这套开源程序，每个人都可以构建一套属于自己的认证机构，但是在互联网上不可信任。独立构建的认证机构叫做自认证机构。

为什么浏览器会直接访问到 HTTPS 的内容？多数浏览器已植入被受信任的证书。

![11521370536_.pic.jpg](https://upload-images.jianshu.io/upload_images/1664496-228e26b154fc87ff.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 确认访问用户身份的认证

**BASIC认证**

需要认证时，返回code为401的状态码，客户端输入账号和密码，经过base64编码后添加到Authoriaztion：头部，完成认证。这种方式不安全。用户密码直接明文传输。

**DIGEST认证**

比 BASIC认证 安全，密码会经过加密处理的。

**SSL认证**

每个客户端会由服务端提前下发一个认证证书。每次认证时需要提供证书，及用户的账号和密码，可以保证客户端是合法的。

**基于表单认证**

目前大多数都在使用的认证方式。客户端提供登录页面，用户输入账号和密码，通过HTTPS传输账号密码。

## 基于HTTP的功能追加协议

**Ajax**

（Asynchronous JavaScript and XML）异步 JavaScript 与 XML 技术。是一种有效的 JavaScript 和 DOM（Document Object Model，文档对象模型）的操作。可以做到页面的局部刷新。

DOM 可以用来操作 HTML 中的部分元素来达到修改该元素的属性，这时需要使用脚本语言（JavaScript）。

**WebSocket**

Web浏览器和服务器之间全双工通信标准。一旦 Web 服务器与客户端之间建立起 WebSocket 协议的通信连接，之后所有的通信都依靠这个专用协议进行。通信过程中可以互相发送 JSON，XML，HTML 或图片等任意格式的数据。

主要特点：

- 推送功能：支持服务端和客户端的推送功能，这样服务端可以直接发送数据，而不必等待客户端的请求。
- 减少通信亮：一旦建立起连接，就一直保持连接的

## 构建Web内容的技术

这部分内容主要讲网页 HTML。

## Web的攻击技术

主要介绍了常见的安全攻击。


[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)