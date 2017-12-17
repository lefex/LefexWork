翻译 [regexper](https://regexper.com/documentation.html)

### 阅读铁路图

使用 `Regexper` 生成的图片通常被称为“铁路图”。它很直接地描述了在正则表达式有时出现非常复杂的情况，比如嵌套循环和可选元素。阅读这些铁路图最简单的方式是从左向右沿着线阅读。如果遇到一个分支，可以选择跟踪多天路径中的任意一条（这些路径也可以返回到图的前面的部分）。为了使字符串能够成功地匹配图表中的正则表达式，您必须能够在从左到右移动图表时完成每个部分，并将整个图贯穿到底。

![example.png](http://upload-images.jianshu.io/upload_images/1664496-8f45ca73f413bce7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

作为一个例子，这个表达式可以匹配 "Lions and tigers and bears. Oh my!" 和 "Lions, tigers, and bears. Oh my!" （使用或者不使用逗号）。图表首先匹配 "Lions" ; 你不可处理自己的输入，也就是说开头必须是 "Lions"。然后你可以选择逗号或者 "and" 。无论你输入什么，它必须包含 "tigers"。接下来是一个可选的逗号（你可以选择使用逗号或者直接绕过它）。最终字符串必须以 " and bears. Oh my!" 结束。

### 图表的基本部分

- 直接常量

直接常量匹配确定的文本中的字符串。它们使用浅蓝色的框表示，内容被添加双引号。

![literals.png](http://upload-images.jianshu.io/upload_images/1664496-c0b4dcbdeb9eb69c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 转义序列

转义序列显示在绿色的框中，并且包含了匹配到的字符的描述。

![escape_sequences.png](http://upload-images.jianshu.io/upload_images/1664496-aca149d21485425b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 任意字符

任意字符和转义序列相似，它仅仅匹配单个字符。

![any_character.png](http://upload-images.jianshu.io/upload_images/1664496-a872dd8482ca044e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 字符集

字符集将匹配或不匹配集合中的单个字符。它们被显示为一个框，包含了直接常量和转义序列。顶部的标签表示包含字符集中的一个或者不包含字符集的任何一个。

![character_sets.png](http://upload-images.jianshu.io/upload_images/1664496-449c5f0bb8a3cf0c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 子表达式

子表达式用虚线环绕着，被捕获的子表达式以组数标记。

![subexpressions.png](http://upload-images.jianshu.io/upload_images/1664496-e8f7ac4687ef3a94.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
