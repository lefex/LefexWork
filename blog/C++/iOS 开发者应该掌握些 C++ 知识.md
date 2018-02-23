# iOS 开发者应该掌握些 C++ 知识

作为一名 iOS 开发者，最近由于开发音频播放器需要一些 C++ 的知识，便开始学习 C++ 知识。看完2本C++的书后，对它有一些了解，这里分享给有需要的同学，如果写的有不妥的地方，还望指出。后续会利用学到的C++知识对 FreeStreamer 这个音频播放器写一篇分析其实现原理的文章。本文主要围绕 FreeStreamer 这个库用到的 C++ 语法来讲解。

iOS 开发当中，偶尔会使用到 C++ 的知识，然而大多数同学每遇到这个问题时，选择逃避。如果从头开始学习C++语法，会花费很多时间，如同笔者一样，花费很多时间了解基础的知识。

Objective-C 和 C++ 都是基于 C 语言而设计的，它们都具有面向对象的能力。在学习 C++ 知识之前，我们先了解下 Objective-C++，它可以把 C++ 和 Objective-C 结合起来使用，如果把两门语言的优点结合起来使用是不是会更好？腾讯开源的数据库 WCDB 是一个很好的例子，它不仅有 C++ 而且还有 Objective-C++。

## 本文主要内容：

- 类（Class）的定义与使用
- 命名空间
- 内存管理
- 继承
- 构造函数和析构函数
- virtual 关键字
- 静态成员与静态函数
- 运算符重载
- 打印日志
- 实例

### 类（Class）

类在面向对象中非常重要，在 Objective-C 中，所有的 Class 必需继承自 NSObject 类，当创建一个类的时候，它会包含一个 .h 和 一个 .m 文件，我们以定义一个 Person 类为例：

```
/* Person.h */
#import <Foundation/Foundation.h>

@interface Person : NSObject

@end


/* Person.m */
#import "Person.h"

@implementation Person

@end
```

而 C++ 中，创建一个类也会有一个头文件 `Person.hpp` 和实现文件 `Person.cpp` 。

```
/* Person.hpp */
#include <stdio.h>

class Person {
    
};

/* Person.cpp */
#include "Person.hpp"

```

从上面的例子我们可以看到，OC 和 C++ 定义类主要有以下不同：

- 在实现文件中，C++ 中没有 `@implementation Person @end`;
- OC 中每个类需要继承自 NSObject；
- C++ 中使用 #include 导入其它文件中的代码，而 OC 使用 #import 导入其它文件代码，使用 #import 保证每个文件中不会重复导入，而使用 #include 需要开发者保证不要重复导入。

```
class Person {
public:
    int age;
    bool isChild();
private:
    float height;
    bool isNomalHeight();
};
```

Person 类中定义了一个公有的成员变量 age 和 一个成员函数 isChild。一个私有的成员变量 height 和一个成员函数 isNomalHeight 。在 C++ 中可以定义某个变量或函数的作用范围，如果使用时超出作用范围编译器将会报错。而在 OC 中既使在 .h 文件中没有定义某个函数，我们任然可以调用，所以在 OC 中经常会出现以 _ 或某个前缀开头的私有函数。

Person 类的实现：

```
bool Person::isChild(){
    return age >= 18;
}

bool Person::isNomalHeight(){
    return height >= 170;
}
```
其中 `::` 表示 isChild 函数属于 Person 类，它告诉编译器从哪里找到函数 isChild。

定义了一个 Person 类，使用的时候和 OC 会有一些不同。

**OC中只能创建堆上的对象**

```
Person *aPerson = [[Person alloc] init];
aPerson.age = 18;
```

**在栈上创建一个 Person**

```
Person aPerson;
aPerson.age = 18;
NSLog(@"age == %@", @(aPerson.age));    

2018-02-19 12:12:20.252108+0800 C++Demo[2480:84138] age == 18
```

**在堆上创建一个 Person**

```
Person *aPerson = new Person();
aPerson->age = 18;
NSLog(@"aPerson age == %@", @(aPerson->age));
delete aPerson;

2018-02-19 12:16:25.432998+0800 C++Demo[2525:88221] aPerson age == 18
```

### 命名空间

在 C++ 中有命名空间的概念，可以帮助开发者在开发新的软件组件时不会与已有的软件组件产生命名冲突，而在 OC 中却没有命名空间的概念，我们常以前缀来与第三方库区分。它的定义为：

```
namespace 命名空间的名字 { }
```

我们将上面定义的类加上命名空间：

```
namespace Lefex {
    class Person {
    public:
        int age;
        bool isChild();
    private:
        float height;
        bool isNomalHeight();
    };
}

namespace Lefex {
    bool Person::isChild(){
        return age >= 18;
    }
    
    bool Person::isNomalHeight(){
        return height >= 170;
    }
}
```

那么使用时必须加上命名空间：

```
Lefex::Person aPerson;
aPerson.age = 18;   
NSLog(@"age == %@", @(aPerson.age)); 
```

### 内存管理

在 OC 中使用引用计数来管理内存，当引用计数为 0 时，内存空间将被释放。而 C++ 中需要开发者自己管理内存。理解 C++ 的内存管理，我们有必要先了解一下栈内存和堆内存。

- 栈内存：它分配的大小是固定的，当一个函数执行时，将为某些变量分配存储空间，当函数执行完成后将释放其对应的存储空间。
- 堆内存：它会随着应用的运行，使用的空间逐步增加，分配的存储空间需要开发者自己释放。

```
void Person::ageMemory(){
  int stackAge = 20;
  
  int *heapAge = (int *)malloc(sizeof(int));
  *heapAge = 20;
  free(heapAge);
}
```

stackAge 为栈内存，不需要开发者自己释放内存，当 ageMemory 函数执行完成后 stackAge 将被释放。heapAge 为堆空间，当函数 ageMemory 执行完成后，它不会释放，需要开发者手动释放。


下面这个例子是创建了一个 Person 对象，它使用的是堆内存，需要使用 delete 释放其内存空间。这里需要注意访问堆对象时使用 `->` 访问它的成员或者方法，而访问栈对象时使用 `.` 访问它的成员或者方法。

在 OC 中，当一个对象为 nil 时调用一个方法时 [nil doSomeThing] , 程序并不会执行 doSomeThing 方法，而在 C++ 中，NULL-> doSomeThing ，程序将 crash。

```
Lefex::Person *aPerson = new Lefex::Person();
aPerson->age = 18;
NSLog(@"age == %@", @(aPerson->age));
NSLog(@"is a child: %@", @(aPerson->isChild()));
delete aPerson;
```

### 继承

C++ 中支持多继承，也就是说一个类可以继承多个类。而在 OC 中只能使用单继承。与 OC 中不同的一点就是增加了修饰符（比如：public），这样用来限制继承的属性和方法的范围。

```
// 男人
class Man: public Lefex::Person {
    
};

// 女人
class Woman: public Lefex::Person {
    
};

// 人妖
class Freak: public Man, public Woman {

};

```

### 构造函数和析构函数

构造函数通常在 OC 中使用的是 init，而在 C++ 中默认的构造函数是于类名相同的函数。比如类 Person 的默认构造函数是 `Person()`，自定义一个构造函数 `Person(int age, int height)` 。在 OC 中析构函数如 dealloc，而在 C++ 中是函数 `~Person()`，当一个类被释放后，析构函数会自动执行。

```
// 默认构造函数
Person::Person(){
    printf("Init person");
}

// 初始化列表构造函数
Person::Person()
    :age(0),
    height(0),
    m_delegate(0){
      printf("Init person\n");
}

// 自定义构造函数   
Person::Person(int age, int height){
    this->age = age;
    this->height = height;
}
 
// 析构函数   
Person::~Person(){
    printf("Dealloc person");
}
```

虚析构函数：为了保证析构函数可以正常的被执行，引入了虚析构函数，一般基类中的析构函数都是虚析构函数。定义方式如下。

```
virtual ~Person();

Person::~Person(){
    printf("person dealloc called \n");
}
```

### virtual 关键字

虚函数是一种非静态的成员函数，定义格式：

```
virtual <类型说明符> <函数名> { 函数体 }
```

纯虚函数：是一种特殊的虚函数，这是一种没有具体实现的虚函数，定义格式：

```
virtual <类型说明符> <函数名> (<参数表>)=0；
```
抽象类：它是一个不能有实例的类，这样的类唯一用途在于被继承。一个抽象类中至少具有一个虚函数，它主要的作用来组织一个继承的层次结构，并由它提供一个公共的根。

有了抽象类和纯虚函数，就可以实现类似于 OC 中的 delegate。

```
// 相当于 OC 中的代理
class  Person_delegate {
public:
    // =0 表示无实现
    virtual void ageDidChange()=0;
};

// 继承了 Person_delegate，Woman 类真正实现了 Person_delegate 的纯虚函数
class Woman: public Lefex::Person, public Lefex::Person_delegate {
public:
    Woman();
    void ageDidChange();
};
```

综上可以看到它于 OC 中实现的思路一致。

### 静态成员与静态函数

静态成员使用 static 修饰，只对其进行一次赋值，将一直保留这个值，直到下次被修改。

在 Person 类中定义一个静态变量 weight。

```
static int weight;
```

使用时直接：`Person::weight;` 即可访问静态变量。

静态成员函数与静态成员的定义一致。

```
static float currentWeight();
```

需要注意的是，在静态成员函数中，不可以使用非静态成员。

调用：

```
Person::currentWeight();
也可以：
aPerson->currentWeight();
```

### 运算符重载

有时候利用系统的运算符作自定义对象之间的比较的时候，不得不对运算符进行重载。

定义：

```
类型 operator op(参数列表) {}
```

“类型”为函数的返回类型，函数名是 “operator op”，由关键字 operator 和被重载的运算符op组成。“参数列表”列出该运算符所需要的操作数。

例子：

```
// Person 类中定义 Person 是否相等。
bool operator==(Person &){
    if (this->age == person.age) {
        return true;
    }
    return false;
};
```


```
+ (void)operatorOverload
{
    Lefex::Person aPerson;
    aPerson.age = 18;
    
    Lefex::Person aPerson2;
    aPerson2.age = 18;
    
    if (aPerson == aPerson2) {
        NSLog(@"aPerson is equal to aPerson2");
    } else {
        NSLog(@"aPerson is not equal to aPerson2");
    }
}
```

### 打印日志

C++ 中打印日志需要导入库 `#include <iostream>`。

- \n 和 endl 效果一样都是换行；
- 打印多个使用 << 拼接；

```
void Woman::consoleLog(){
    std::cout<< "Hello Lefe_x\n";
    std::cout<< "Hello " << "Lefe_x\n";
    int age = 20;
    std::cout<< "Lefe_x age is " << age << std::endl;
}
```

打印结果：

```
Hello Lefe_x
Hello Lefe_x
Lefe_x age is 20
```

### 实例

下面这段代码摘自 `FreeStreamer` 中的 `audio_queue.h`，有部分重复的知识点有删减。建议读者仔细看看下面的代码，看看有没有看不懂的地方。

```

namespace astreamer {

class Audio_Queue_Delegate;
    
class Audio_Queue {
public:
    Audio_Queue_Delegate *m_delegate;
    Audio_Queue();
    virtual ~Audio_Queue();
    
    void start();

private:
    void cleanup();
    static void audioQueueOutputCallback(void *inClientData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer);
};
      
class Audio_Queue_Delegate {
public:
    virtual void audioQueueStateChanged(Audio_Queue::State state) = 0;
    virtual void audioQueueFinishedPlayingPacket() = 0;
};

} // namespace astreamer
```

### 总结

总的来说，这些内容是最基本的语法知识，希望可以帮你入门 C++。

===== 我是有底线的 ======

[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
