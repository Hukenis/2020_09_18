# MYSQL概述

mysql：可用性、拓展性、体积小、支持并发、支持多语言、支持多开发语言、开源、隔离特性

### 数据类型

存入值的类型、用的存储空间、定长或变长、如果比较和排序、是否支持索引；越简单的数据类型，后期维护越简单。

数值型

```
精确数据
int、decimal
近似数据
float、double、real

整型数据
- tinyint 微整型
- smallint 小整型
- mediuint 中整型
- int 整型
- bigint 大整型

- deciaml 定点数据
- float 单精度浮点数据
- double 双精度浮点型
- bit 按位存储
```

字符型

```
定长
char(#)、binary
变长
varchar(#)、varbinary、text、blob

字符串型
# 不区分大小写
- char 定长  		  【255字符】
- varchar 变长 	【65535字符】

- tinytext     【255】
- text 		     【65535】
- medtext	【十六万多】
- longtext   【一亿多】

# 字节字符串_区分大小写	
- binary 定长  		//用的少了
- varbinary 变长

- tinyblob 微大对象
- blob 标准对象
- medblob 中等对象
- longblob 长对象

ENUM  枚举类;给出一个集合以供选择
SET 	  集合类
```

SQL_mode模型

```
# 当输入非法字符时采取的动作
ANSI QUOTES     		     双引号和反引号的作用相同
IGNORE_SPACE   			    忽略多余的内建字符
STRICT_ALL_TABLES         内建表中违反字符规则的不允填入
STRICT_TRANS_TABLRS   不允在支持事务的表中加入非法数据

# 检查SQL模型
show global variables like 'sql_mode';
```

时间类型

```
时间
date、time、datetime、timestamp 
```

检查mysql支持的字符集和排序规则

```
# 检查支持的所有字符集
show character set ;  

# 检查各个字符集的排序规则
show collocation 
```

### MYSQL服务器变量

```
# 全局变量，与用户无关
- 检查变量 
  show [变量范围]  variables 
  show global variables
  
  select @@[设定范围].[变量名]
  select @@global.sql_mode
  
- 设定方式     SET <global> [变量名称] = '[变量值]'
  SET global sql_mode = 'STRICT_ALL_TABLES'
  
  
# 会话变量，与用户有关；调整时立即生效，只对当时会话有效。
- 检查变量
  show [变量范围]  variables 
  show session variables 
  
  select @@[设定范围].[变量名]
  select @@session.sql_mode
  
- 设定方式   SET <session> [变量名称] = '[变量值]'
  SET session sql_mode = 'STRICT_ALL_TABLES'
```

### SQL：结构化查询语言

##### DML：数据操作语言，增删改查

##### DDL：数据定义语言。create；drop；alter

```
数据库操作

- 创建 CREATE，可指定数据类型以及排序规则
  create  [ database | schema ]  db_name  [ character set =xxx ] [ collate =xxx ] ; 
  create datebase test_huken_db character set 'gbk'  collate =gbk_chinese_ci ;

- 修改 ALTER，
  alter  [ database | schema ]  db_name  [ character set =xxx ] [ collate =xxx ] ; 

  旧版本迁移到新版时，需要升级数据字典，使用ALTER
  alter  upgrade  [ database | schema ]  db_name dirctory name 

- 删除DROP
  drop  [ database | schema ]  db_name 

# 一般不会给数据库重命名，流程比较麻烦；所以起名字需要谨慎。
```

```
数据表操作

- 创建 CREATE
  - 自定义创建空表,可指定字段名称，字段定义（数据类型、索引、主键、唯一键等），指定存储引擎 ENGINE [=] engine_name 
     create tables [ if not exist ] tb_name ( col_name col_definition , constraint )
     create table test_db ( id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY , Name CHAR(20) NOT NULL , Age TINYINT NOT NULL )  ;
     create table test_db ( id INT UNSIGNED NOT NULL AUTO_INCREMENT  , Name CHAR(20) NOT NULL , Age TINYINT NOT NULL , PRIMARY KEY( id, name ) , UNIQUE(Name) , INDEX (Age))  ;
     
  - 指定模板查询数据并创建
    create table new_db select * from  old_db  where id <=5 ;
    create table test_db2 select * from test_db where id <=5 ;

  - 指定模板克隆空表
    create table new_db  like   old_db ;
    create table test_db3 like  test_db ; 
    
----
- 查询表结构 SHOW & DESC
  show tables status like 'tb_name' ;
  desc  tb_name ;
  
- 查询表的索引属性 
  show indexes from tb_name 

----
- 删除表 DROP
  drop  tb_name 
  
- 表插入字段 INSERT
  insert into tb_name (Name) values ('hukenis'),('huken'),('hukkken');
  
----
- 修改表 ALTER
  - alter table  test_db change 

- 修改表内字段名
  - alter table  db_name  change 旧字段名 新字段名 字段定义 ;
  - alter table  test_db change id ID varchar(50) NOT NULL ;
- 新增字段
  - alter table db_name  ADD 新字段名 类型  默认值设定 'date-xx-xx'
  - alter table test_db    ADD timedate date '1900-01-01'
```



### 约束&键

​	约束和键一般是看作一个东西，但其中是由差别的；键的定义要比前者大得多，但是平时使用一般不会特别注意。

##### 阈约束

##### 外键约束

##### 主键约束

##### 唯一约束

### 关系型数据库

表<==存储引擎<==数据文件

*关系型数据库，是指采用了关系模型来组织数据的数据库*，其以行和列的形式存储数据，以便于用户理解，关系型数据库这一系列的行和列被称为表，一组表组成了数据库。

##### 关系运算

投影：只输出指定字段

选择：只输出符合条件的行

自然连接

笛卡尔乘积

并集：并集合运算

### 存储查询的原理

##### 查询管理器

​	DML解释器

​	DDL解释器

​	查询执行解释器

##### 存储管理器

​	权限、完整性管理器

​	事务管理器

​	文件管理器

​	缓冲区管理器

### 交互接口以及进程通信

有丰富的接口可用  SQL、DBA、程序员、其他应用接入操作；C/S架构及其mysql协议完成底层设计，mysqld(server)与mysql(client)通过套接字文件mysql.sock进行交互。

##### 单进程多线程实现多用户的权限隔离

守护线程

应用线程

#### 关于表描述符的高速缓存

```

```

# MYSQL编译安装

### 	cmake 环境部署

```
cmake  . LH  # 编译获取帮助，展示可选项
```



# MYSQL初始化操作

```
mysqld --initialize --user=mysql --console
```

# MYSQL工具

### mysql 客户端工具

```
# 命令行模式选项
-u 		username
-p 		'passwd'
-H 		host_address
-D 		# 作用等于 --database
--port 		   # 指定端口
--protocol  { tcp | socket | pipe | memory }  # 指定协议
--database  DATEBASE 		# 指定接入的数据库
--html  使用html格式显示表格式
--xml   使用xml格式显示表格式


# 批处理模式 
mysql < /PATH/xxx.sql

# 一些操作命令
\c 终止执行
\r 重现连接
\d 定义结束符
\g 无需结束符直接执行
\G 结果以竖排方式显示
\p 当前执行的命令
\!  执行shell命令
\W 显示警告信息
\w  不显示警告信息
\#  对新建对象支持补全
rehash 全局补全开启   # 数据库支持命令补全


# 获取帮助
help  关键字 {create ··} 
```

##### mysqladmin 用户管理工具

```
mysqladmin [option] command [arg]  [command [arg]] ···
mysqladmin [选项] 命令 [命令子参数]  [命令 [名字子参数]] ···

# 修改密码 passwd 
mysqladmin -uroot -p passwd 'NEW_PASSWD'

# 创建数据库 create 
mysqladmin create  <new_database>

# 删除数据库 drop
mysqladmin drop <database>

# 测试数据库存活  ping 
mysqladmin -uroot -p -h xxx.xxx.xxx.xxx ping

# 检查服务器上所有的mysql线程
mysqladmin processlist

# 检查mysql服务器 状态
mysqladmin status  [--sleep num]  [--count num]

# 检查mysql状态变量
mysqladmin extended-status 

# 检查服务器变量
mysqladmin variables

# 刷新授权表
mysqladmin flush-privileges

# 关闭所有已开打的表
mysqladmin flush-tables

# 清除所有线程缓存
mysqladmin flush-threads

# 重置服务器变量数据
mysqladmin flush-status

# 二进制和中级日志的滚动
mysqladmin flush-logs

# 清楚服务器内部连接信息
mysqladmin flush-hosts

# 杀死mysqld
mysqladmin kill

# 关闭所有表并且刷新滚动日志
mysqladmin refresh 

# 关闭服务器进程
mysqladmin shutdown 

# 检查版本以及状态信息
mysqladmin version 

# 启动/关闭从服务器复制功能
mysqladmin start-slave
mysqladmin stop-slave
```

##### mysqlcheck 数据库检查工具

##### mysqldump 数据导入导出工具

```
# 一般作为备份工具使用
```

##### mysqlimport 数据导入工具

```
-u 		username
-p 		'passwd'
-H 		host_address
--port 		   # 指定端口
--protocol  { tcp | socket | pipe | memory }  # 指定协议
```

# percona

为mysql提供性能优化等的专业公司

percona-xbrackup 物理备份工具等

