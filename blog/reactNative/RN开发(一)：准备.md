### 说明
本文是作者 [Lefe](http://www.jianshu.com/p/88957fad1226) 所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。

>React Native相信大家都不陌生，多多少少会听到它的传闻。最近由于公司在做电商项目，遇到很多需要及时处理的问题，比如某个商品需要打折，某个商品需要促销，对于那些多变的界面，使用H5做，用户体验比较差。为了满足这一需求，来研究下RN。 [React Native 中文网](https://reactnative.cn/ )

### 环境搭建
这个比较简单，由于以前学习Node很多环境配置过，在配置RN的时候没有花费太多的时间。不过遇到一个问题就是在执行 `react-native init AwesomeProject`的时候如果你没有更改NPM源的话，它会一直卡着，所以建议更换NPM源，[淘宝源](https://npm.taobao.org/).

###基础
学习RN的时候，其实直接看 [官方文档](http://facebook.github.io/react-native/docs/getting-started.html)  比较靠谱，这样会让你少走一些弯路，以免被别人带到别处，如果看不懂英文，没关系这里还有 [中文版](http://reactnative.cn/) 。基础部分主要建设了一下几部分：
- Prpos(属性):可以给组件添加自定义的属性，当然也可以使用组件自带的属性

```
import React, { Component } from 'react';
import { 
  AppRegistry,  
  View, 
  Image, 
  Text,
  StyleSheet
} from 'react-native';

class Greeting extends Component {
  render() {
    return (
      // 使用 this.props 获取属性的组件的属性
      <Text> Name: {this.props.name}, address: {this.props.address}!</Text>
      );
  }
}

class ImageComponent extends Component {

  render() {
    let pic = {
      url: 'http://www.7xsm.net/upload/img/59/5977EE1CE18AB4CCAF6A616A50147B03.jpg'
    };

    return (
      // source style 为Image自带的属性
      <Image source = {pic} style = {{width: 300, height: 300}} />
    );
  }
}

class AwesomeProject extends Component {
  render() {
    return (
    <View style={{alignItems: 'center', marginTop: 64}}>
     <Greeting name = 'WSY' address = 'BeiJing'/>
     <Greeting name = 'Lefe' address = 'XingHe'/>
     <Greeting name = 'BX' address = 'HuShi'/>
     <ImageComponent />
    </View>
    );
  }
}

AppRegistry.registerComponent('AwesomeProject', () => AwesomeProject);
```

- State(状态):

```
import React, { Component } from 'react';
import { 
  AppRegistry,  
  View, 
  Text,
  StyleSheet
} from 'react-native';

class Blink extends Component {
  constructor(props) {
    super(props);
    this.state = {showText: true};

    setInterval( () => {
      this.setState({showText: !this.state.showText});
    }, 1000);
  }

  render() {
    let display = this.state.showText ? this.props.text : ' ';

    return (
      <Text>{display}</Text>
    );
  }
}

class AwesomeProject extends Component {
  render() {
    return(
    <View style={{marginTop: 64}}>
      <Blink text = 'I am lefe, an iOS developer. Welocome to React Native' />
    </View>
    );
  }
}


AppRegistry.registerComponent('AwesomeProject', () => AwesomeProject);

```
- Height and Width(宽、高):`flex`动态缩放
- Styles(样式表): 添加多个样式表的时候使用`[]`

```
import React, { Component } from 'react';
import {
  AppRegistry, 
  StyleSheet, 
  Text,
  View
} from 'react-native';

const styles = StyleSheet.create({
  bigblue: {
    color: 'blue',
    fontWeight: 'bold',
    fontSize: 30,
  },
  size: {
    width: 300,
    height: 400
  },
  flexStyle: {
    flex: 1
  }
});

class AwesomeProject extends Component {
  render(){
    return (
      <View style={styles.flexStyle}>
        <Text style={styles.bigblue}>I am lefe, an iOS developer</Text>
        <Text style={[styles.bigblue, styles.size]}>I am lefe, an iOS developer</Text>
      </View>
    );
  };
}


AppRegistry.registerComponent('AwesomeProject', () => AwesomeProject);

```
- Layout with Flexbox:
- Handing Text Input:
- Using a ScrollView:
- Using a ListView:
- Networking:
- Using navigators:

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
