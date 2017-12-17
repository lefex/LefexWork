【如何找出国际化文件(xxxx.strings)中未国际化的文件】

国际化的时候难免会由于不小心，会出现某个 .strings 文件中存在没有添加的国际化字符串。比如某个项目中支持中文和英文。在中文国际化文件（zh-Hans.lproj/Localizable.strings）中含有 ：
"HOM_home" = "首页";
"GRB_groupBuy" = "团购";
"SHC_shopnCart" = "购物车";
"PER_personal" = "我的";

而在英文国际化文件（en.lproj/Localizable.strings）中含有 ：
"HOM_home" = "home";
"PER_personal" = "my";

这样导致，英文环境下，SHC_shopnCart 和 GRB_groupBuy 未国际化，使用这个脚本会检测出这些错误。

【如何使用】

1.修改 DESPATH 为你项目的路径；
2.直接在脚本所在的目录下，打开终端执行 python checkLocalizable.py，这里的 checkLocalizable.py 为脚本文件名。你可以在这里 https://github.com/lefex/TCZLocalizableTool/blob/master/LocalToos/checkLocalizable.py 找到脚本文件；
3.执行完成后，桌面会出现一个文件 checkLocalizable.log，记录了未国际化的行：

/en.lproj/Localizable.strings
SHC_shopnCart
GRB_groupBuy

截止到目前，关于国际化的一些技巧，到这里基本告一段落了。下一篇打算写一篇关于正则表达式的，记录了我学习正则表达式的一些方法技巧，从此脱离复制粘贴，可以看懂，还可以写正则表达式。

可以从这里 https://github.com/lefex/TCZLocalizableTool 找到以前的记录：
【如何1秒找出国际化文件(en.lproj/Localizable.strings)语法错误】
【找出项目中未国际化的文本】
【如何把国际化时需要3天的工作量缩短到10分钟】


[喜欢我的文章，欢迎关注我 @Lefe_x](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)







