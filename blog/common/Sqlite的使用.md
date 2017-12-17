### 说明
本文是作者[Lefe](http://www.jianshu.com/p/88957fad1226)所创，转载请注明出处，如果你在阅读的时候发现问题欢迎一起讨论。本文会不断更新。
###正文
> 对于iOS应用，我相信有很多人还选择使用sqlite作为数据的持久化操作，但是对于一个还没有接触过sqlite的同学难免会有点不知所措，我记得我曾经刚接触sqlite的时候，花费了不少时间。那是的我不知道如何连变查询，如何创建表，如何使用聚合函数等等。下面这篇文章希望能帮助你少走一些弯路。

### 一、数据类型：

如果你在创建表的时候，需要指定某个字段的数据类型，下面是一些基本的数据类型，当然这里我没有一一列出，只列出了常用的一些。
- text:文本是字符数据              // ’3.14’
- integer：整形，比如枚举值   // 314
- real: 实数的十进制数值         // 3.14
- boolean:布尔型
- varchar:字符型
- NULL：表示没有值              // NULL

###二、终端使用技巧：

当你学习使用sqlite的时候，直接在终端输入（这里以mac为例）：sqlite3 database_name，按回车键，比如：<code>sqlite3 wsy.db</code>，不过在使用的过程中有一些技巧帮你更好的查看数据，比如找到创建的所有表，创建表所使用的SQL语句，显示表中的数据的时候连同列名一块显示，等等。

`.header on` 查询时将显示列名；   
`.mode column` 显示模式为列显示模式  
`.width 20` 调整列宽  
`.timer on` 显示运行某个SQL花费的时间  
`.schema teacher` teacher表创建的SQL语句，前提是你需要创建一张teacher表  
`.tables` 显示所有的表  
`.show` 显示所有配置信息  
`.help` 查看更多技巧  

注意：如果不执行`.header on`，执行`.mode column`和`.width 20`将不会起作用


###三、创建数据表：
会使用终端创建数据库后，你可以直接创建表，当然这里只是为了演示，在真正的开发过程中，可以使用sqlite自己分装一系列操作数据的方法。如果为了省时省力，可以直接使用FMDB。根据实际情况，创建表的时候需要注意哪些字段是主键，哪些字段需要添加约束，表之间如何关联。
为表添加约束：  
创建数据库表的时候可以为表添加约束，这样可以避免非法数据插入到数据库中  
－`NOT NULL`: 确保一列不能有NULL值；  
－`DEFAULT`: 提供一列的默认值；   
－`UNIQUE`: 确保某一列所有值不同(唯一)；   
－`PRIMARY KEY`: 主键，唯一标识数据库表中的各行记录；   
－`CHECK`: CHECK约束，确保一列中的所有值满足一定条件。

**1.创建teacher表，主键（ PRIMARY KEY）为id**  
`CREATE TABLE IF NOT EXISTS teacher(id VARCHAR(20) PRIMARY KEY, name TEXT, age INT, sex INT);`  

**2.创建teacher表，主键（ PRIMARY KEY）为id，且不能为null，name不能为null，age必须大于0，sex默认的是0**  
`CREATE TABLE IF NOT EXISTS teacher(id VARCHAR(20) PRIMARY KEY NOT NULL, name TEXT NOT NULL, age INT CHECK(age>0), sex INT DEFAULT 0);`  

**3.创建teacher表，主键（ PRIMARY KEY）为(id, name)，复合主键，创建表的时候可以使用复合主键，保证复合主键中的一列唯一即可，比如(1,wsy),(2,wsy),(1,ws)都是合法的值**  
`CREATE TABLE IF NOT EXISTS teacher(id VARCHAR(20) NOT NULL,name TEXT NOT NULL, age INT, sex INT DEFAULT 0, PRIMARY KEY(id, name));`

**例子：**  
- 打开终端（以mac为例），输入：sqlite3 wsy.db，点击回车
- 输入创建表的sql语句，记得一定要加分号：
`CREATE TABLE IF NOT EXISTS teacher(id VARCHAR(20),
 name TEXT NOT NULL, age INT CHECK(age>0), sex INT DEFAULT 0,  PRIMARY KEY(id, name));`  
- 向teacher表中插入数据：  
sqlite> `INSERT INTO teacher(id, name, age, sex) VALUES (1234, 'wsy', 25, 1);`  
sqlite> `INSERT INTO teacher(id, name, age, sex) VALUES (1234, 'wsy', 25, 1);`

**主键约束，不能插入一样的数据**  
Error: UNIQUE constraint failed: teacher.id, teacher.name

**CHECK约束，年龄必须大于0**  
sqlite> `INSERT INTO teacher(id, name, age, sex) VALUES (1235, 'wsy', -10, 1);`  
Error: CHECK constraint failed: teacher

**默认值：sex没有插入，默认值为0，由于复合主键的原因，(1235, 'wsy', 20)可以插入**  
sqlite> `INSERT INTO teacher(id, name, age) VALUES (1235, 'wsy', 20);`
sqlite> `SELECT *FROM teacher;`

id      |    name     |   age     |    sex       

1235     |   wsy     |    20      |    0    

**NOT NULL约束：name不能为空**  
sqlite> `INSERT INTO teacher(id, age) VALUES (1235, 20);`  
Error: NOT NULL constraint failed: teacher.name

**最后数据库中的表中的数据如下**   id          name        age         sex       
----------  ----------  ----------  ----------
1234        wangsuyan   25          1         
1234        wsy         25          1         
1235        wsy         20          0         
Run Time: real 0.000 user 0.000158 sys 0.000087


###四、插入数据
建好表以后就可以想表中插入数据，当然可以一次性插入一行或者多行数据。

格式：
INSERT INTO table_name(column_list) VALUES (value_list);
向某个表中插入数据，column_list是以逗号分割的字段名称，value_list是用逗号分割的值，这些值必须与column_list中的一一对应。

向teacher表中插入一条记录:
INSERT INTO teacher(id, name, age, sex) VALUES (1234, 'wangsuyan', 25, 1);

插入数据的时候也可以省略字段名称（列名）,字段名称必须和值一一对应
INSERT INTO teacher VALUES (1236, 'wsy', 25, 1);

可以一次性插入多条记录：
CREATE TABLE IF NOT EXISTS temp_teacher (userId TEXT PRIMARY KEY, age INT);
DISTINCT 是为了去重，userId是主键，如果在插入数据中遇到约束错误，那么所有的数据将插入失败
INSERT INTO temp_teacher SELECT DISTINCT id, age FROM teacher;

userId      age       
----------  ----------
1234        25        
1235        20        
1236        25   

插入某一列中的某条数据
INSERT INTO temp_teacher VALUES(1237, (SELECT age FROM teacher WHERE id=1237));

###五、查询数据
数据查询在数据库操作中起到了很大的作用，巧妙的使用SQL语句会减少很多的数据处理操作。SELECT命令用一系列子句将很多关系操作组合到一起，每个子句代表一种特定的关系操作。

格式：
SELECT [DISTINCT] HEADING
FROM tables
WHERE predicate
GROUP BY columns
HAVING predicate
ORDER BY columns
LIMIN count,offset

常用的SELECT语句：
1、查询表中所有数据：
sqlite> SELECT *FROM teacher;
id          name        age         sex       
----------  ----------  ----------  ----------
1234        wangsuyan   25          1         
1234        wsy         25          1         
1235        wsy         20          0         
1236        wsy         25          1         
1237        wangsuyan   25          1         
1238        good        25          1         
1238        hello       25          1         
1239        hello       26          1         
Run Time: real 0.000 user 0.000175 sys 0.000089

2、按条件查询
sqlite> SELECT *FROM teacher WHERE id=1234 AND name=‘wsy’;
id          name        age         sex       
----------  ----------  ----------  ----------
1234        wsy         25          1     

3、去重，去掉重复的字段,注意以下语句的不同
SELECT DISTINCT *FROM teacher;
SELECT DISTINCT id, name FROM teacher;

sqlite> SELECT DISTINCT name FROM teacher;
name      
----------
wangsuyan 
wsy       
good      
hello  

4、聚合函数的使用
<1>查询数据行数
sqlite> SELECT COUNT(*) FROM teacher;
COUNT(*)  
----------
8 
<2>查询数据行数，起一个别名为count
sqlite> SELECT COUNT(*) AS count FROM teacher;
count     
----------
8

<3>最大值,最大年龄
sqlite> select MAX(age) FROM teacher;
MAX(age)  
----------
26 

<4>最小值,最小年龄
sqlite> SELECT MIN(age) as minAge FROM teacher;
minAge    
----------
20 

<5>平均年龄
sqlite> SELECT AVG(age) FROM teacher;
AVG(age)  
----------
24.5 

<6>求和
sqlite> SELECT SUM(age) FROM teacher;
SUM(age)  
----------
196

<7>绝对值
sqlite> SELECT ABS(5), ABS(-15), ABS(NULL), ABS(0), ABS(“ABC");
ABS(5)      ABS(-15)    ABS(NULL)   ABS(0)      ABS('ABC')
----------  ----------  ----------  ----------  ----------
5           15                      0           0.0   

<8>大写，小写，长度
sqlite> SELECT UPPER(name), LOWER(name), LENGTH(name) FROM teacher;

UPPER(name)  LOWER(name)  LENGTH(name)
----------  -----------  ------------
WANGSUYAN   wangsuyan    9           
WSY         wsy          3           
WSY         wsy          3           
WSY         wsy          3           
WANGSUYAN   wangsuyan    9           
GOOD        good         4           
HELLO       hello        5           
HELLO       hello        5   

5、查询最后插入的行：
sqlite> SELECT last_insert_rowid();

6、模糊查询
LIKE:模糊查询，_表示一个，%表示多个或一个
例如：查询第二个字母为“s”的姓名
sqlite> SELECT *FROM teacher WHERE name LIKE '_s%';
id          name        age         sex       
----------  ----------  ----------  ----------
1234        wsy         25          1         
1235        wsy         20          0         
1236        wsy         25          1  

7、排序,查询teacher表中所有数据，并且按age降序排列，默认为升序排列
sqlite> SELECT *FROM teacher ORDER BY age DESC;
id          name        age         sex       
----------  ----------  ----------  ----------
1239        hello       26          1               
1234        wsy         25          1         
…       
1235        wsy         20          0  

8、Limit:查询限制数量，offset查询结果中的偏移量
sqlite> SELECT *FROM teacher LIMIT 2 OFFSET 2;
id          name        age         sex       
----------  ----------  ----------  ----------
1235        wsy         20          0         
1236        wsy         25          1         

###六、连表查询

   连表查询最重要的是两个之间有链接条件，所以设计表的时候需要考虑到表之间的关联。
废话不多说，通过例子说明，这里创建了一张任务表(task)，和文件表(file),一个任务会有一个或多个附件:
任务表（task）:
文件表(file):
任务表的创建，及添加数据：
sqlite> CREATE TABLE IF NOT EXISTS task(taskId varchar(30) NOT NULL, name TEXT NOT NULL, content TEXT, PRIMARY KEY(taskId));

sqlite> INSERT INTO task VALUES(1234, 'work', 'work together');
sqlite> INSERT INTO task VALUES(1235, 'write document', 'Please write document’);
sqlite> INSERT INTO task VALUES(1236, 'play', 'Please play');

taskId      name                  content             
----------  --------------------  --------------------
1234        work                   work together
1235        write document         Please write document
1236        play                   Please play

文件表的创建，及添加数据：
sqlite> CREATE TABLE IF NOT EXISTS file(fileId varchar(30) NOT NULL, name TEXT NOT NULL, taskId varchar(30) NOT NULL, PRIMARY KEY(fileId, taskId));

sqlite> INSERT INTO file VALUES('f1234', 'ppt', 1234);
sqlite> INSERT INTO file VALUES('f1235', 'word', 1234);
sqlite> INSERT INTO file VALUES('f1236', 'pdf', 1235);
sqlite> INSERT INTO file VALUES('f1237', 'image', 1235);
sqlite> INSERT INTO file VALUES('f1238', 'text', 1235);

fileId      name                  taskId              
----------  --------------------  --------------------
f1234       ppt                   1234                
f1235       word                  1234                
f1236       pdf                   1235                
f1237       image                 1235                
f1238       text                  1235

以上是所有的准备工作，下表开始使用连表查询：

- **内链接**:
   WHERE 携带的条件查询相当于内链接，当然你可以使用（INNER JOIN ON）只查询满足条件的数据，例如：只有task.taskId=file.taskId才算合法数据
sqlite> SELECT task.taskId, task.name, file.fileId, file.name, file.taskId FROM task, file WHERE task.taskId=file.taskId;

taskId      name        fileId      name        taskId    
----------  ----------  ----------  ----------  ----------
1234        work        f1234       ppt         1234      
1234        work        f1235       word        1234      
1235        write docu  f1236       pdf         1235      
1235        write docu  f1237       image       1235      
1235        write docu  f1238       text        1235      
Run Time: real 0.000 user 0.000195 sys 0.000075

- **外链接**：
   会找到所有与左表对应的数据，如果没有将为空，例如：task＝1236没有file，但结果也返回了task＝1236的数据



task表作为左表：
sqlite> SELECT task.taskId, task.name, file.fileId, file.name, file.taskId FROM task LEFT JOIN file ON task.taskId=file.taskId;
taskId      name            fileId      name        taskId    
----------  --------------  ----------  ----------  ----------
1235        write document  f1236       pdf         1235      
1235        write document  f1237       image       1235      
1235        write document  f1238       text        1235      
1234        work            f1234       ppt         1234      
1234        work            f1235       word        1234      
1236        paly 

task作为右表：
sqlite> SELECT task.taskId, task.name, file.fileId, file.name, file.taskId FROM file LEFT JOIN task ON task.taskId=file.taskId;
taskId      name        fileId      name        taskId    
----------  ----------  ----------  ----------  ----------
1234        work        f1234       ppt         1234      
1234        work        f1235       word        1234      
1235        write docu  f1236       pdf         1235      
1235        write docu  f1237       image       1235      
1235        write docu  f1238       text        1235 

- **复合查询**：
UNION：查询A和B中，非重复的值，比如A(1,2),B(1,3)->(1,2,3)
UNION ALL:比如A(1,2),B(1,3)->(1,2,1,3)
sqlite> SELECT taskId FROM file UNION SELECT taskId FROM task;

INTERSECT:交集，A(1,2),B(1,3)->(1)
sqlite> SELECT taskId FROM file INTERSECT SELECT taskId FROM task;

EXCEPT:差集，A(1,2),B(1)->(2)
sqlite> SELECT taskId FROM task EXCEPT SELECT taskId FROM file;

- **子查询**：
SELECT语句中又嵌套了SELECT语句
sqlite> SELECT *FROM task WHERE taskId IN(SELECT DISTINCT taskId FROM file);
taskId    
----------
1234      
1235 

查询任务中附件的个数：
SELECT *, (SELECT COUNT(fileId) FROM file WHERE task.taskId=taskId) AS file_count FROM task;
taskId      name            content                      file_count
----------  --------------  ---------------------------  ----------
1235        write document  Please write document today  3         
1234        work            work together                2         
1236        play            Please play                  0         

###七.数据更新

如果对插入数据库中的数据更新，执行update操作。
格式：
UPDATE table SET update_list WHERE predicate;

以teacher表为例：   
更新id＝1234的年龄为28，sex＝0
sqlite> UPDATE teacher SET age=28, sex=0 WHERE id=1234;

主键不能更新
sqlite> UPDATE teacher SET name=haha WHERE id=1234;
sqlite> UPDATE teacher SET name='haha', id=1240 WHERE sex=0;
sqlite> UPDATE teacher SET id='haha' WHERE sex=0;
Error: UNIQUE constraint failed: teacher.id, teacher.name

###八、数据删除：

删除数据中的数据
例如：删除id＝1234的数据
sqlite> DELETE FROM teacher WHERE id=1234;

###九、修改表：

格式：
ALTER TABLE table_name {RENAME TO name | ADD COLUMN column_name 约束}

为teacher表添加一列address，默认值为空字符串
sqlite> ALTER TABLE teacher ADD COLUMN address TEXT DEFAULT ‘';

修改teacher表为teacher2
sqlite> ALTER TABLE teacher RENAME TO teacher2;

注意表的主键是不能修改的；

###十、创建索引：

索引是一种用来在某种条件下加速查询的结构。但是创建索引后，数据表的大小会增大，而且可能会降低insert、update的操作速度，因为修改表的同时，数据库也必须修改对应的索引。所有创建索引的时候，要选择执行查询比较频繁的字段。

格式：
CREATE INDEX [UNIQUE] index_name ON table_name (columns)

index_name:索引的名字
table_name:表名字
columns:索引的列名，列之间用逗号隔开
[UNIQUE]:表示创建的是唯一索引,它是可选的

例如给teacher表创建一个索引：
sqlite> CREATE INDEX teacher_id ON teacher(id);


删除索引：
sqlite> DROP INDEX index_name;


###十一、创建视图：
视图也叫虚拟表，是从基本表中动态产生的数据。

在连表查询中的内连接，使用：
sqlite> SELECT task.taskId, task.name, file.fileId, file.name, file.taskId FROM task, file WHERE task.taskId=file.taskId;

来查询数据，但是如果有很多这样的情况，你会感到很厌烦，那么创建视图是一个很好的选择：
sqlite> CREATE VIEW task_file AS SELECT task.taskId, task.name, file.fileId, file.name, file.taskId FROM task, file WHERE task.taskId=file.taskId;

这样你可以直接在视图中查找：
sqlite> SELECT *FROM task_file;

taskId      name        fileId      name:1      taskId:1  
----------  ----------  ----------  ----------  ----------
1234        work        f1234       ppt         1234      
1234        work        f1235       word        1234      
1235        write docu  f1236       pdf         1235      
1235        write docu  f1237       image       1235      
1235        write docu  f1238       text        1235      
Run Time: real 0.000 user 0.000202 sys 0.000075


###十二、事务：

   事务定义了一组SQL命令的边界，这组命令或者作为一个整体被全部执行，或者都不执行。比如银行转账，A想B转账500，A账户减少500，B账号多500，如果在转账的过程中电力中断或者其他意外情况发生，那么必须中断此次操作。

一个事务的例子：
开始执行一个事务：
sqlite> begin;
删除表teacher2中所有数据：
sqlite> delete from teacher2;
查询teacher2表中数据，无数据
sqlite> select *from teacher2;
回滚，这里也可以是commint,提交后将执行删除操作
sqlite> rollback; 
查询teacher2表中数据，结果如下：
sqlite> select *from teacher2;
id          name        age         sex       
----------  ----------  ----------  ---------- 
1235        wsy         20          0                           
1236        wsy         25          1                                             
1238        good        25          1                       
1238        hello       25          1                        
1239        hello       26          1           


###十三、数据完整性

数据完整性用于定义和保护表内部或表之间的数据关系，主要有以下四种完整性:  
**1.域完整性**  
控制字段内的值，也就是字段值遵从赋予的规定，比如添加约束  
默认值：
CREATE TABLE student(id TEXT, name TEXT DEFAULT ‘UNKNOWN’);  
另外默认值可以是:  
date not null default current_date // 2015-12-22   
time not null default current_time // 00:59:05   
timestamp not null default current_timestamp // 2015-12-22 01:00:16  

**2.实体完整性**  
数据库中表的行必须在某种方式上是唯一的，这就是主键的功能。实体完整性基本保持表中的数据是可寻址的，如果找不到数据，那还有什么意义？

- 唯一性约束：（UNIQUE)   
要求一个或一组字段的所有值均不相同，如果插入重复的值，数据库将引发一个非法约束的错误。CREATE TABLE student(id TEXT, name TEXT, age INT, UNIQUE(id, name));

- 主键约束：  
当你定义一个表的时候，总会指定一个主键，不管你有没有指定，都会有一个rowid来充当主键。你可以使用SQL语句找到它：SELECT rowid FROM student;

- NOT NULL约束：  
插入或更新数据时不能为NULL

- CHECK约束：  
允许定义表达式来验证要插入或者更新的字段值是否满足表达式，如果不满足讲不能插入。

**3.用户自定义完整性**


###十四、一些技巧：
- 执行语句的时候添加：explain query plan,可以查询计划

- sqlite_master表是系统表，它包含所有表，视图，索引和触发器的信息
sqlite> select *from sqlite_master;

- 表的信息
sqlite> pragma table_info(teacher2);

- 索引的信息：
sqlite> pragma index_info(taskId_index);

- 如果一列数据的数据类型不一样，排序将按照以下方式排序：
NULL，INTEGER, REAL, TEXT, BLOB

###十五、写在最后

   由于项目对数据库采取了加密，每次出现bug的时候总想到数据库中找一下数据是否异常，可使用sqlite工具的时候必须下载包，然后找到数据库，这时打开数据库，发现数据库是加密的，即使输入正确的密码也不能查看数据库中的数据，每次感觉很头疼。最后实在没办法，自己写了一个查看数据库的小工具（ 
 [ PMFMDB-iOS ](https://github.com/lefex/PMFMDB-iOS)），写的很粗糙，不过一直使用，感觉还行。

===== 我是有底线的 ======
[喜欢我的文章，欢迎关注我的新浪微博 Lefe_x，我会不定期的分享一些开发技巧](http://www.weibo.com/5953150140/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1)
![](http://upload-images.jianshu.io/upload_images/1664496-e409f16579811101.jpg)
