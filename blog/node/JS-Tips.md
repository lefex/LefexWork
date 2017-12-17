## 遍历对象的所有属性

```
function showProps(obj, objName) {
  var result = "";
  for (var i in obj) {
    if (obj.hasOwnProperty(i)) {
        result += objName + "." + i + " = " + obj[i] + "\n";
    }
  }
  return result;
}

var car = {
	name: "Lefe",
	from: 'BeiJing'
};

// 所有的属性
var result = showProps(car, 'car');
console.log(result);

// 所有的属性
console.log(Object.keys(car));

// 该方法返回一个数组，它包含了对象 o 所有拥有的属性
console.log(Object.getOwnPropertyNames(car));
```

## 添加属性
给普通的 JS 对象添加属性:

```
var car = {
	name: "Lefe",
	from: 'BeiJing'
};

car.sign = 'Very good';
```
但是对于 Mongodb 中的对象，不可直接添加属性，需要在 Schema 中定义后才可以添加属性。

## 参考
[JS 对象](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Guide/Working_with_Objects)

[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
