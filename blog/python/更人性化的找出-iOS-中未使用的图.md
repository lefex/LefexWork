![unImage.png](http://upload-images.jianshu.io/upload_images/1664496-995b0f732a9287a5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 痛点
删除 iOS 项目中没有用到的图片市面上已经有很多种方式，但是我试过几个都不能很好地满足我的需求，因此使用 Python 写了这个脚本，它可能也不能很好的满足你的需求，因为这种静态查找始终会存在问题，每个人写的代码风格不一，导致匹配字符不一。所以只有掌握了脚本的写法，才能很好的满足自己的需求。如果你的项目中使用 OC，而且使用纯代码布局，使用这个脚本完全没有问题。当然你可以修改脚本来达到自己的需求。本文主要希望能够帮助更多的读者节省更多时间做一些有意义的工作，避免那些乏味重复的工作。

###如何使用：

- 1.修改 DESPATH 为你项目的路径；
- 2.直接在脚本所在的目录下，打开终端执行 python unUseImage.py，这里的 unUseImage.py 为脚本文件名。你可以在 [这里](https://github.com/lefex/TCZLocalizableTool/blob/master/LocalToos/unUseImage.py) 找到脚本文件；
- 3.执行完成后，桌面会出现一个 `unUseImage` 文件夹。文件夹中的 `error.log` 文件记录了可能存在未匹配到图片的文件目录，`image.log` 记录了项目中没使用的图片路径，`images` 存放了未使用到的图片。

###重要提示：

当确认 `images` 文件夹中含有正在使用的图时，复制图片名字到 `EXCEPT_IMAGES` 中，再次执行脚本，确认 `images` 文件夹中不再包含使用的图后，修改 `IS_OPEN_AUTO_DEL` 为 `True`，执行脚本，脚本将自动清除所有未使用的图。

###脚本：

```
# coding=utf-8 

import os
import re
import shutil

# 是否开启自动删除，开启后当检查到未用到的图，
# 将自动被删除。建议确认所有的图没用后开启
IS_OPEN_AUTO_DEL = False

# 将要解析的项目名称 
DESPATH = "/Users/wangsuyan/desktop/project/Shopn/Shopn"

# 可能检查出错的图片，需要特别留意下
ERROR_DESPATH = "/Users/wangsuyan/Desktop/unUseImage/error.log"

# 解析结果存放的路径
WDESPATH = "/Users/wangsuyan/Desktop/unUseImage/image.log"

# 项目中没有用到的图片
IMAGE_WDESPATH = "/Users/wangsuyan/Desktop/unUseImage/images/"

# 目录黑名单，这个目录下所有的图片将被忽略
BLACK_DIR_LIST = [
    DESPATH + '/ThirdPart', # Utils 下所有的文件将被忽略 
]

# 已知某些图片确实存在，比如像下面的图，脚本不会自动检查出，需要手动加入这个数组中
# NSString *name = [NSString stringWithFormat:@"loading_%d",i];
# UIImage *image = [UIImage imageNamed:name];
EXCEPT_IMAGES = [
    'loading_',
    'launch-guide'
]

# 项目中所有的图
source_images = dict()
# 项目中所有使用到的图
use_images = set()
# 异常图片
err_images = set()

# 目录是否在黑名单中 BLACK_DIR_LIST
def isInBlackList(filePath):
    if os.path.isfile(filePath):
        return filename(filePath) in BLACK_DIR_LIST
    if filePath:
        return filePath in BLACK_DIR_LIST
    return False

# 是否为图片
def isimage(filePath):
    ext = os.path.splitext(filePath)[1]
    return ext == '.png' or ext == '.jpg' or ext == '.jpeg' or ext == '.gif'

# 是否为 APPIcon
def isappicon(filePath):
    return 'appiconset' in filePath

def filename(filePath):
    return os.path.split(filePath)[1]

def is_except_image(filePath):
    name = filename(filePath)
    for item in EXCEPT_IMAGES:
        if item in name:
            return True
    return False

def auto_remove_images():
    f = open(WDESPATH, 'r')
    for line in f.readlines():
        path = DESPATH + line.strip('\n')
        if not os.path.isdir(path):
            if 'Assets.xcassets' in line:
                path = os.path.split(path)[0]
                if os.path.exists(path):
                    shutil.rmtree(path)
            else:
                os.remove(path)


def un_use_image(filePath):
    if re.search(r'\w@3x.(png|jpg|jpeg|gif)', filePath):
        return

    if re.search(r'\w(@2x){0,1}.(png|jpg|jpeg|gif)', filePath):
        exts = os.path.splitext(filePath)
        result = (filename(filePath).replace('@2x', '')).replace(exts[1],'')
        source_images[result] = filePath

def find_image_name(filePath):
    f = open(filePath)
    for index, line in enumerate(f):
        line = line.strip()
        regx = r'\[\s*UIImage\s+imageNamed\s*:\s*@"(.+?)"'
        matchs = re.findall(regx, line)
        if matchs:
            for item in matchs:
                use_images.add(item)
        else:
            err_matchs = re.findall(r'\[UIImage imageNamed:', line)
            if err_matchs:
                name = filename(filePath)
                for item in err_matchs:
                    err_images.add(str(index + 1) + ':' + name + '\n' + line + '\n')

def find_from_file(path):
    paths = os.listdir(path)
    for aCompent in paths:
        aPath = os.path.join(path, aCompent)
        if isInBlackList(aPath):
            print('在黑名单中，被自动忽略' + aPath)
            continue
        if os.path.isdir(aPath):
            find_from_file(aPath)
        elif os.path.isfile(aPath) and isimage(aPath) and not isappicon(aPath) and not is_except_image(aPath):
            un_use_image(aPath)
        elif os.path.isfile(aPath) and os.path.splitext(aPath)[1]=='.m':
            find_image_name(aPath)

if __name__ == '__main__':
    if os.path.exists(IMAGE_WDESPATH):
        shutil.rmtree(IMAGE_WDESPATH)

    os.makedirs(IMAGE_WDESPATH)

    wf = open(WDESPATH, 'w')
    find_from_file(DESPATH)
    for item in set(source_images.keys()) - use_images:
        value = source_images[item]
        wf.write(value.replace(DESPATH, '') + '\n')
        ext = os.path.splitext(value)[1]
        shutil.copyfile(value, IMAGE_WDESPATH + item + ext)

    wf.close()

    ef = open(ERROR_DESPATH, 'w')
    for item in err_images:
        ef.write(item)
    ef.close()

    if IS_OPEN_AUTO_DEL:
        auto_remove_images()
```

### 推荐阅读

[【iOS 国际化】如何把国际化时需要3天的工作量缩减到10分钟](http://www.jianshu.com/p/2c77f0d108c3)

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
