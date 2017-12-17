### 说明
本文是作者[Lefe](http://www.jianshu.com/p/88957fad1226)所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。
### 正文
由于公司近期在做一个电商项目，由于项目更新迭代快，为了防止意外情况，加入了热修复框架 [JSPatch](https://github.com/bang590/JSPatch) ，这个框架确实不错，很好的解决了我的问题，具体使用方法可以查看官方文档，作者已经介绍的很详细了，这里不再赘述。但是使用的过程中，难免会遇到一些问题，下面就是我遇到的一些问题：
#### 服务端如何实现
服务端可以使用官方的，这样仅仅需要客户端集成 JSPatch(https://github.com/bang590/JSPatch)， 服务端不需要任何处理，当然你需要交点钱。其实如果自己实现也很简单，注意以下两点，第一、防止你的代码被别人篡改，第二、做好补丁的版本控制。主要有以下步骤：
- 服务端拿到JS补丁后转换成二进制流data，经过MD5后使用RSA加密；
- 客户端下载补丁文件后转换成二进制流data，生产MD5，与解密出来的MD5进行对比，如果相等，说明补丁文件没有被篡改；
- 做好版本控制，不是每次都需要下载补丁    

#### 下载补丁后发现客户端执行的还不是补丁文件，而是没修改过的代码
下载后的补丁文件可能还没有被执行，需要重启APP，把启动补丁服务要放到APP启动的地方。
#### 不懂JS咋么办？使用[JSPatchConvertor](https://github.com/bang590/JSPatchConvertor)可以不？
不懂JS只能学习了，了解基本的语法。使用[JSPatchConvertor](https://github.com/bang590/JSPatchConvertor)可以转换一部分，有一部分还需要自己转换，比如常量，枚举，宏等。
#### 如何使用Safair调试
作者这里没有详细的说明，这里补充一下。
- 在safari中显示【开发】菜单
![1.png](http://upload-images.jianshu.io/upload_images/1664496-5b906b413c2f7f0f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
- 直接运行APP，APP启动后在开发菜单中会显示【JSContext】
![2.png](http://upload-images.jianshu.io/upload_images/1664496-4f76fa974f2204d0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
- 点击【JSContext】后即可调出调试模式
![3.png](http://upload-images.jianshu.io/upload_images/1664496-6e408180171ea411.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#### OC与JS转换例子
网上找了很多，大多数是直接拿到官方的例子，而没有真正的实践，[Lefe](http://www.jianshu.com/p/88957fad1226)在这里浪费了很多时间
- 函数带有普通参数和Block参数的函数如何转换
````
[[SNFLoginServer sharedInstance] logLoginWithCellphone:_telView.textField.text pwd:_pwdView.textField.text authCode:@"" unionId:@"" loginType:LOGLoginTypeCellphone complete:^(NSError * _Nonnull aError, NSDictionary * _Nonnull result) {
}];
````
````
SNFLoginServer.sharedInstance().logLoginWithCellphone_pwd_authCode_unionId_loginType_complete(self.telView().textField().text(), 
  self.pwdView().textField().text(), "", "", 4, block("NSError * , NSDictionary *", function (aError, result) {
}));
````
- for循环
js中的for循环与OC有很大区别，[Lefe](http://www.jianshu.com/p/88957fad1226)使用Node（如果你对Node感兴趣，可以查看此项目 
 [ iMetalk/TCZNodeServer ](https://github.com/iMetalk/TCZNodeServer)）亲自测试了一下，以下是测试结果：
````
var testDict = [
{name: 'lefe_wsy', sex: 1, data: [{icon: "http://www.baidu.com"}]}, 
{name: 'lefe_wsy2', sex: 2, data: [{icon: "http://www.baidu.com"}]}
];
for(var index in testDict){
	console.log("index: " + index);
	console.log("testDict[index]: " + testDict[index]);
	console.log("testDict[index].name: " + testDict[index].name);
	var datas = testDict[index].data;
	for(var dataIndex in datas){
		console.log("data icon:" + datas[dataIndex].icon);
	}
}
````
运行结果为：
````
index: 0
testDict[index]: [object Object]
testDict[index].name: lefe_wsy
data icon:http://www.baidu.com
index: 1
testDict[index]: [object Object]
testDict[index].name: lefe_wsy2
data icon:http://www.baidu.com
````
- 遍历数组中的Model，只可以使用 for (var index = 0; index < count; index++) 

```
require('JSModel');
defineClass('SHOShopListViewController', {
       testJspatchArray: function() {
       var count = self.jspatchModels().count();
       var modes = self.jspatchModels().toJS();
       for (var index = 0; index < count; index++) {
          var jsModel = modes[index];
          jsModel.setName("newTest");
          jsModel.setSex("newSex");

          var name = jsModel.name().toJS();
        
       }
   },
});
```
- 操作NSArray，NSDictionry和NSString时需要注意时OC类型还是JS类型，如果需要JS类型，需要通过 toJS() 方法来转换

```
var name = jsModel.name().toJS();
```

- integerValue 报错，如果遇到这种情况建议使用JS中的方法parseInt()，使用parseInt()时注意它的参数是JS类型的参数。
```
if (parseInt(self.buyNum().toJS()) <= 0) {
       self.setBuyNum("1");
  }
```
- 使用Model的时候，记得要：require('modelName')，否则取不到他的属性。
```
require('SHCGoodNorms');
```
- 使用OC的字典的时候，可以使用OC字典对应的方法
```
var normDict = aNorm.stock().objectForKey(self.normStr());
```

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
