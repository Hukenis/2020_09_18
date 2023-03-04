#  MYSQL

--------

## A.概述

#### 1.关系型数据库

​	MySQL是一个**[关系型数据库管理系统](https://baike.baidu.com/item/关系型数据库管理系统/696511?fromModule=lemma_inlink)**，由瑞典[MySQL AB](https://baike.baidu.com/item/MySQL AB/2620844?fromModule=lemma_inlink) 公司开发，属于 [Oracle](https://baike.baidu.com/item/Oracle?fromModule=lemma_inlink) 旗下产品。MySQL 是最流行的[关系型数据库管理系统](https://baike.baidu.com/item/关系型数据库管理系统/696511?fromModule=lemma_inlink)之一，在 [WEB](https://baike.baidu.com/item/WEB/150564?fromModule=lemma_inlink) 应用方面，MySQL是最好的 [RDBMS](https://baike.baidu.com/item/RDBMS/1048260?fromModule=lemma_inlink) (Relational Database Management System，关系数据库管理系统) 应用软件之一。

​	MySQL是一种关系型数据库管理系统，关系数据库将数据保存在不同的表中，而不是将所有数据放在一个大仓库内，这样就增加了速度并提高了灵活性。

#### 2.数据类型

##### 	2-1 数值

| 类型         | 大小                                     | 范围（有符号）                                               | 范围（无符号）                                               | 用途            |
| :----------- | :--------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :-------------- |
| TINYINT      | 1 Bytes                                  | (-128，127)                                                  | (0，255)                                                     | 小整数值        |
| SMALLINT     | 2 Bytes                                  | (-32 768，32 767)                                            | (0，65 535)                                                  | 大整数值        |
| MEDIUMINT    | 3 Bytes                                  | (-8 388 608，8 388 607)                                      | (0，16 777 215)                                              | 大整数值        |
| INT或INTEGER | 4 Bytes                                  | (-2 147 483 648，2 147 483 647)   常用                       | (0，4 294 967 295)                                           | 大整数值        |
| BIGINT       | 8 Bytes                                  | (-9,223,372,036,854,775,808，9 223 372 036 854 775 807)      | (0，18 446 744 073 709 551 615)                              | 极大整数值      |
| FLOAT        | 4 Bytes                                  | (-3.402 823 466 E+38，-1.175 494 351 E-38)，0，(1.175 494 351 E-38，3.402 823 466 351 E+38) | 0，(1.175 494 351 E-38，3.402 823 466 E+38)                  | 单精度 浮点数值 |
| DOUBLE       | 8 Bytes                                  | (-1.797 693 134 862 315 7 E+308，-2.225 073 858 507 201 4 E-308)，0，(2.225 073 858 507 201 4 E-308，1.797 693 134 862 315 7 E+308) | 0，(2.225 073 858 507 201 4 E-308，1.797 693 134 862 315 7 E+308) | 双精度 浮点数值 |
| DECIMAL      | 对DECIMAL(M,D) ，如果M>D，为M+2否则为D+2 | 依赖于M和D的值，字符串的浮点，金融计算常用                   | 依赖于M和D的值                                               | 小数值          |

##### 	2-2 字符串

| 类型       | 大小                  | 用途                            |
| :--------- | :-------------------- | :------------------------------ |
| CHAR       | 0-255 bytes           | 定长字符串                      |
| VARCHAR    | 0-65535 bytes         | 变长字符串                      |
| TINYBLOB   | 0-255 bytes           | 不超过 255 个字符的二进制字符串 |
| TINYTEXT   | 0-255 bytes           | 短文本字符串                    |
| BLOB       | 0-65 535 bytes        | 二进制形式的长文本数据          |
| TEXT       | 0-65 535 bytes        | 长文本数据                      |
| MEDIUMBLOB | 0-16 777 215 bytes    | 二进制形式的中等长度文本数据    |
| MEDIUMTEXT | 0-16 777 215 bytes    | 中等长度文本数据                |
| LONGBLOB   | 0-4 294 967 295 bytes | 二进制形式的极大文本数据        |
| LONGTEXT   | 0-4 294 967 295 bytes | 极大文本数据                    |

#####     2-3 时间

| 类型      | 大小 ( bytes) | 范围                                                         | 格式                | 用途                     |
| :-------- | :------------ | :----------------------------------------------------------- | :------------------ | :----------------------- |
| DATE      | 3             | 1000-01-01/9999-12-31                                        | YYYY-MM-DD          | 日期值                   |
| TIME      | 3             | '-838:59:59'/'838:59:59'                                     | HH:MM:SS            | 时间值或持续时间         |
| YEAR      | 1             | 1901/2155                                                    | YYYY                | 年份值                   |
| DATETIME  | 8             | '1000-01-01 00:00:00' 到 '9999-12-31 23:59:59'               | YYYY-MM-DD hh:mm:ss | 混合日期和时间值         |
| TIMESTAMP | 4             | '1970-01-01 00:00:01' UTC 到 '2038-01-19 03:14:07' UTC结束时间是第 **2147483647** 秒，北京时间 **2038-1-19 11:14:07**，格林尼治时间 2038年1月19日 凌晨 03:14:07 | YYYY-MM-DD hh:mm:ss | 混合日期和时间值，时间戳 |

#####     2-4 NULL 

​	空值，有诗云：我来问道无余说，云在青霄水在瓶。古人云：万事从无，而非有。

#### 3.字段&元组&主键&外键&统配符

每个字段由若干按照某种界限划分的相同数据类型的数据项组成，通常在表中为“列”，某一个列的一个特征，或者说是属性、内容；

字段属性

| unsigned       | 无符号的整数、声明此列不得为负数                 |
| -------------- | ------------------------------------------------ |
| zorefill       | 默认使用0填充不足的位数，例：00001               |
| auto_increment | 通常用作唯一主键的整数，可以设定起始值和自增步长 |
| not null       | 非空                                             |
| default        | 无数据填充时自动生成指定的默认值                 |

元组：记录的另一种称谓，事物特征的组合，可以描述一个具体的事物

主键：有唯一标识信息的事物

外键：一个执行另一个表的指针、

统配符

| **通配符**                   | 描述                       |
| ---------------------------- | -------------------------- |
| %                            | 代表零个或多个字符         |
| _                            | 仅替代一个字符             |
| [charlist]                   | 字符列中的任何单一字符     |
| [^charlist] 或者 [!charlist] | 不在字符列中的任何单一字符 |

#### 4.数据库引擎

[MyISAM](https://baike.baidu.com/item/MyISAM?fromModule=lemma_inlink) 是MySQL 5.0 之前的默认数据库引擎，最为常用。拥有较高的插入，查询速度，但不支持[事务](https://baike.baidu.com/item/事务?fromModule=lemma_inlink)

[InnoDB](https://baike.baidu.com/item/InnoDB?fromModule=lemma_inlink) 事务型数据库的首选引擎，支持ACID事务，支持行级锁定, MySQL 5.5 起成为默认数据库引擎

#####  4-1 事务

​	事务（Transaction），一般是指要做的或所做的事情。在计算机术语中是指访问并可能更新数据库中各种[数据项](https://baike.baidu.com/item/数据项/3227309?fromModule=lemma_inlink)的一个程序[执行单元](https://baike.baidu.com/item/执行单元/22689638?fromModule=lemma_inlink)(unit)。事务通常由[高级数据库](https://baike.baidu.com/item/高级数据库/1439366?fromModule=lemma_inlink)操纵语言或[编程语言](https://baike.baidu.com/item/编程语言/9845131?fromModule=lemma_inlink)（如SQL，C++或[Java](https://baike.baidu.com/item/Java/85979?fromModule=lemma_inlink)）书写的[用户程序](https://baike.baidu.com/item/用户程序/7450916?fromModule=lemma_inlink)的执行所引起，并用形如**begin transaction**和**end transaction**语句（或[函数调用](https://baike.baidu.com/item/函数调用/4127405?fromModule=lemma_inlink)）来界定。事务由事务开始(**begin transaction**)和事务结束(**end transaction**)之间执行的全体操作组成。

#####  4-2 ACID 特性

​	acid 是 为保证[事务](https://baike.baidu.com/item/事务?fromModule=lemma_inlink)（transaction）是正确可靠的，所必须具备的四个特性

- Atomicity（原子性）：一个事务（transaction）中的所有操作，要么全部完成，要么全部不完成，不会结束在中间某个环节。事务在执行过程中发生错误，会被恢复（Rollback）到事务开始前的状态。
- Consistency（一致性）：在事务开始之前和事务结束以后，数据库的完整性没有被破坏。这表示写入的资料必须完全符合所有的预设规则，这包含资料的精确度、串联性以及后续数据库可以自发性地完成预定的工作。
- Isolation（隔离性）：数据库允许多个并发事务同时对其数据进行读写和修改的能力，隔离性可以防止多个事务并发执行时由于交叉执行而导致数据的不一致。事务隔离分为不同级别，包括读未提交（Read uncommitted）、读提交（read committed）、可重复读（repeatable read）和串行化（Serializable）。
- Durability（持久性）：事务处理结束后，对数据的修改就是永久的，即便系统故障也不会丢失

## B.语言

MySQL所使用的 SQL 语言是用于访问[数据库](https://baike.baidu.com/item/数据库/103728?fromModule=lemma_inlink)的最常用标准化语言。

语言使用一般流程为： DDL 创库创表  、 DML 写入、修改表数据、DQL 查询数据 、DCL 创建数据库用户、权限管理

--------

#### 1.定义语言DDL

##### 	1-1创建数据库

```sql
-- CREATE DATABASES [ IF NOT EXISTS ] DATABASE_NAME;
-- [ 可 选\填 项 ]，不代表实操时要写中括号，仅在本文作可选项的标记。
-- eg:
create database `TEST_huken`;
create database if not exists  `TEST_huken`;
```

##### 	1-2使用数据库

```sql
-- USE DATABASE_NAME；
-- eg:
use `TEST_huken`
```

##### 	1-3删除数据库

```sql
-- DROP DATABASE  DATABASE_NAME; 		直接删除库本体及其中所有
-- eg: 
drop  database `TEST_huken`;
```

##### 	1-4创建表

```sql
-- CREATE TABLE  [ IF NOT EXISTS ]  'TABLE_NAME ' ( FIELD_NAME  FIELD_TYPE(length)  NOT NUILL   FIELD_ATTRIBUTE [COMMENT 'this is test command'] );

-- CREATE TABLE  [ IF NOT EXISTS ]  '表名 ' ( 
--  字段名1  字段类型(length字段长度)  DEFAULT “默认填充字段，也可以为NULL”   字段属性  [COMMENT '注释'] );
--  字段名2  字段类型(length字段长度)  DEFAULT “默认填充字段，也可以为NULL”   字段属性  [COMMENT '注释'] );
--  字段名3  字段类型(length字段长度)  DEFAULT “默认填充字段，也可以为NULL”   字段属性  [COMMENT '注释'] );
--  ) [表类型] [字符集设定] [注释]

-- 以运维角度来看，创表命令是不常用的，研发或者DBA会写出贴合业务逻辑的创表语句交给运维去部署sql环境。

-- eg：
  create table if  not exists  `test_students_table3` (
  `id`  int(10) not null auto_increment,
  `name` varchar(30) not null default  'no name!' comment 'name',
  `passwd` varchar(20) not null default '123456' comment 'passwd',
  `sex` varchar(2) not null default 'ca' comment 'sex',
  `birth` datetime default null comment 'birthday',
  `address` varchar(100) default null comment 'address',
  `email` varchar(50) default null comment 'email',
   PRIMARY KEY (`id`)
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

##### 	1-4表的删除 &清空

```sql
-- DROP TABLES TABLE_NAME;      			删除表本体
-- DELEDE TABELS TABLE_NAME;   		      仅清空表内容
-- TRUNCATE TABLES TABLE_NAME;  	   清空表内容的同时将主键序列重置

-- eg:
drop 	   tables 	`TEST_huken`;
truncate tables    `TEST_huken`; 
delete    tables 	`TEST_huken`;  # delete 属于DML语言，介于对表删除的操作，理解起来可以有直接删除表本体和仅清空内容· 两种意义，故于此展示。
```

##### 	1-5 表字段修改

```SQL
 ALTER TABLE
# 表重命名 
	-- ALTER TABLE   `OLD_TABLE_NAME`        RENAME      `NEW_TABLE_NAME`;   		
#  删除字段、列
	-- ALTER TABLE `TABLE_NAME`  DROP 	  `FIELD_NAME`;											  
#  字段类型重制
	-- ALTER TABLE `TABLE_NAME`  MODIFY  `FIELD_NAME` 	 FIELD_YTPE(length);
#  添加字段
	-- ALTER TABLE `TABLE_NAME`  ADD   	   `FIELD_NAME`   FIELD_TYPE(length);
#  字段重命名
	-- ALTER TABLE `TABLE_NAME`  CHANGE `OLD_FIELD_NAME`  `NEW_FIELD_NAME`;
	
-- eg
# table rename
alter table  `TEST_student_table` rename `TEST_table`;
# drop field 
alter table  `TEST_table` drop `age`;
# add field 
alter table  `TEST_table` add   `age`  varchar(100);
# modify field
alter table  `TEST_table` modify `age`  char(20);
# field rename 
alter table `TEST_table` change `age` `bge`;
```

#### 2.数据操控语言DML

数据操纵语言DML主要有三种形式：

##### 	2-1 插入：INSERT

```SQL
-- INSERT INTO `TABLE_NAME`(FIELD) VALUES ('VAR'),('VAR2'),('VAR3');
-- INSERT INTO `TABLE_NAME`(FIELD_X,FIELD_C,FIELD_V) VALUES ('X1','C1','V1'),('X2','C2','V2'),('X3','C3','V3');
-- INSERT INTO `表名`  (字段名1，字段名2，字段名3) VALUES ('值1'),('值2'),('值3');  
注意：插入的值，每一个逗号是一行，每个括号里的值对应前面所指定的字段名
-- eg
insert into `TEST_students`(name,email,sex) values ('huken','huken@163.com','男'),('jincang','842602@qq.com','女');

+----+--------+--------+-----+---------------------+---------------+--------------+------+
| id | name   | passwd | sex | birth   | address       | email        | age  |
+----+--------+--------+-----+---------------------+---------------+--------------+------+
|  2 | jincang  | 114514| 女  | NULL| NULL   | Cang@163.com | NULL |
|  1 | huken | 114514 | 男  | NULL | NULL | huken@163.com  | NULL |
+----+--------+--------+-----+---------------------+---------------+--------------+------+
```

##### 	2-2 更新：UPDATE

```SQL
# 修改表内存在的数据
-- UPDATE `TABLE_NAME` SET `FIELD_NAME` = 'NEW_VAR'  WHERE  CONDITION
-- UPDATE `TABLE_NAME` SET `FIELD_NAME` = 'NEW_VAR'  WHERE  `FIELD_NAME` = 'EXIST_VAR'
-- UPDATE  `表名`  SET `字段名` = '新值'  WHERE  条件
-- UPDATE  `表名`  SET `字段名` = '新值'  WHERE `字段名` = '已存在值'；
使用where 精准定位要修改的字段
-- eg
update test set  `name` = 'Gingc' where `name` = 'Kingcang';

+----+-------+--------+-----+-------+---------+---------------+------+
| id | name  | passwd | sex | birth | address | email         | age  |
+----+-------+--------+-----+-------+---------+---------------+------+
|  1 | huken | 114514 | ca  | NULL  | NULL    | huken@163.com | NULL |
|  2 | Gingc | 114514 | ca  | NULL  | NULL    | Cang@163.com  | NULL |
+----+-------+--------+-----+-------+---------+---------------+------+
```

##### 	2-3 删除：DELETE

```SQL
# 删除表内数据
-- DELETE FROM `TABLE_NAME` WHERE  CONDITION 
-- DELETE FROM `TABLE_NAME` WHERE `FIELD_NAME` = 'EXIST VAR';
-- DELETE FROM `表名` WHERE  条件
-- DELETE FROM `表名` WHERE `字段名` = '存在值';
使用where 精准定位要修改的字段
-- delete from  `表名` ;  如果不指定条件，将清洗掉所有数据！
-- eg
delete from  `test`  where `name`='huken';

+----+-------+--------+-----+-------+---------+--------------+------+
| id | name  | passwd | sex | birth | address | email        | age  |
+----+-------+--------+-----+-------+---------+--------------+------+
|  2 | Gingc | 114514 | ca  | NULL  | NULL    | Cang@163.com | NULL |
+----+-------+--------+-----+-------+---------+--------------+------+
```

#### 3.数据库控制语言DCL

数据控制语言DCL用来授予或回收访问数据库的某种特权，并控制
数据库操纵事务发生的时间及效果，对数据库实行监视等。如：

##### 	3-1 GRANT：授权

```SQL
ON 			 赋权
REVOKE   夺权
-- GRANT CREATE,SELECT,INSERT,UPDATE,XX_PRIVILEGE  ON   `DATABASE_NAME`.`TABLENAME` TO USER_NAME@IPADDR  IDENTIFIED BY 'PASSWD';
-- GRANT CREATE,SELECT,INSERT,UPDATE,XX_PRIVILEGE  REVOKE  `DATABASE_NAME`.`TABLENAME` TO USER_NAME@IPADDR  IDENTIFIED BY 'PASSWD';
-- GRANT 权限  ON   `数据库名`.`表名` TO 用户名@ip地址  IDENTIFIED BY '密码';
-- GRANT 权限  REVOKE   `数据库名`.`表名` TO 用户名@ip地址  IDENTIFIED BY '密码';

-- eg
# 将所有库表的所有操作权限 赋予/剥夺    GITLAB用户
grant  all   on  *.*   to GITLAB
grant  all   revoke *.*   TO GITLAB

# 将库TEST_HUKEN中 test_table 表 的 所有操作权限  赋予/剥夺   GITLAB用户
grant  all   on  `TEST_HUKEN`.`test_table`   to GITLAB
grant  all   revoke   `TEST_HUKEN`.`test_table`   to GITLAB
```

#### 4.数据库查询语言DQL

数据库的重点操作是查询，对数据库的多数操作也是查。

数据查询语言DQL基本结构是由SELECT子句，FROM子句，WHERE

##### 	4-1 区间查询

```SQL
-- SELECT	 `FIELD_A`,`FIELD_B`,`FILED_C` 				   FROM    `TABLE_NAME` 
-- SELECT	 `字段_A`,`字段_B`,`字段_C` 		     			 FROM    `表名`

# 区间查询 
-- SELECT   `FIELD_A`,`FIELD_B`   FROM `TABLE_NAME`   WHERE  `FIELD_A`  >= 114514    AND    `FIELD_A` <= 999999;
-- SELECT   `FIELD_A`,`FIELD_B`   FROM `TABLE_NAME`   WHERE  `FIELD_A`    BETWEEN  114514   AND  99999;
```

##### 	4-2 查非取反

```SQL
-- SELECT	 `FIELD_A`,`FIELD_B`,`FILED_C` 				   FROM    `TABLE_NAME` 
-- SELECT	 `字段_A`,`字段_B`,`字段_C` 		     			 FROM    `表名`

# 查非，取反
-- SELECT   `FIELD_A`,`FIELD_B`   FROM `TABLE_NAME`   WHERE  `FIELD_A`  != 114514
-- SELECT   `FIELD_A`,`FIELD_B`   FROM `TABLE_NAME`   WHERE  NOT  `FIELD_A` = 114514
```

##### 	4-3 查空&非空

```SQL
-- SELECT	 `FIELD_A`,`FIELD_B`,`FILED_C` 				   FROM    `TABLE_NAME` 
-- SELECT	 `字段_A`,`字段_B`,`字段_C` 		     			 FROM    `表名`

# 查空&非空
-- SELECT   *   FROM `TABLE_NAME`   WHERE  NOT  `FIELD_A`  IS NULL
-- SELECT   *   FROM `TABLE_NAME`   WHERE  NOT  `FIELD_A`  IS NOT   NULL
```

##### 	4-4 LIKE查询

```SQL
-- SELECT	 `FIELD_A`,`FIELD_B`,`FILED_C` 				   FROM    `TABLE_NAME` 
-- SELECT	 `字段_A`,`字段_B`,`字段_C` 		     			 FROM    `表名`

# 模糊查询
-- SELECT   *   FROM `TABLE_NAME`   WHERE 	`FIELD_A`  LIKE  'HU%'
-- SELECT   *   FROM `TABLE_NAME`   WHERE 	`FIELD_A`  LIKE  '%HU%'
-- SELECT   *   FROM `TABLE_NAME`   WHERE 	`FIELD_A`  LIKE  'HU%'
-- SELECT   *   FROM `TABLE_NAME`   WHERE 	`FIELD_A`  LIKE  'HU_'
```

##### 	4-5 包含查询

```SQL
-- SELECT	 `FIELD_A`,`FIELD_B`,`FILED_C` 				   FROM    `TABLE_NAME` 
-- SELECT	 `字段_A`,`字段_B`,`字段_C` 		     			 FROM    `表名`

# 包含查询
-- SELECT   *   FROM `TABLE_NAME`   WHERE  `FIELD_A`  IN (001,002,003);
```

##### 	4-6 嵌套查询

```SQL
-- SELECT	 `FIELD_A`,`FIELD_B`,`FILED_C` 				   FROM    `TABLE_NAME` 
-- SELECT	 `字段_A`,`字段_B`,`字段_C` 		     			 FROM    `表名`

# 嵌套查询
-- SELECT 	`FIELD_A`,`FIELD_B`  FROM  	`TABLE_NAME`   WHERE `FIELD_A`=(SELECT DISTINCT `FIELD_C`  FROM `NAME_TABLE`  `FIELD_A` = 'GITLAB')

eg：
SELECT * FROM test_table
WHERE NOT EXISTS    (SELECT * FROM test_table  WHERE `project` IN('gitlab','nginx') and `address` = 'beijing');

SELECT `NO`,`SUBNAME`,`RESULT`
WHERE `NO`=(
	SELECT `SUBNO` FROM `SUBJECT` WHERE SUBJECT = 'NGINX'
);
```

SELECT <字段名表>
FROM <表或视图名>
WHERE <查询条件>

##### 4-7 联表查询

语法：`JOIN TABLE ON CONDITION`  只例举常用的左、右、内、三种联接方法，以及基于 左、右、内 三种联接的多表联查。 

思想：因为要查的字段不在同一张表，故利用多表中的字段交集查询，如图所示：

<img src="./image-20230303235909031.png" alt="image-20230303235909031" style="zoom: 50%;" /><img src="./image-20230304000631559.png" alt="image-20230304000631559" style="zoom:50%;" />

###### 4-7-1 左联查询

如此节示意图，可查左表以及交集的字段

```SQL
# 因为要查的字段不在同一张表，故利用多表中的字段交集查询索要的信息
# 已知公共内容的字段，common_field 简写为Com_Field，要利用Com_Field 从两个表中查询FIELD_A  FIELD_B  FILED_C FIELD_D 四个字段的内容，

SELECT `L.Com_Field`,`FIELD_A`,`FIELD_B`,`FIELD_C`,`FIELD_D`  FROM  Left_table  AS L
LEFT JOIN Right_table AS R
ON  `L.Com_Field` = `R.Com_Field`
```

###### 4-7-2 右联查询

如此节示意图，可查右表的字段

```SQL
# 因为要查的字段不在同一张表，故利用多表中的字段交集查询索要的信息
# 已知公共内容的字段，common_field 简写为Com_Field，要利用Com_Field 从两个表中查询FIELD_A  FIELD_B  FILED_C FIELD_D 四个字段的内容，

SELECT `L.Com_Field`,`FIELD_A`,`FIELD_B`,`FIELD_C`,`FIELD_D`  FROM  Left_table  AS L
RIGHT JOIN Right_table AS R
ON  `L.Com_Field` = `R.Com_Field`
```

###### 4-7-3 内联查询

如此节示意图，可查左右交集的字段

```SQL
# 因为要查的字段不在同一张表，故利用多表中的字段交集查询索要的信息
# 已知公共内容的字段，common_field 简写为Com_Field，要利用Com_Field 从两个表中查询FIELD_A  FIELD_B  FILED_C FIELD_D 四个字段的内容，

SELECT `L.Com_Field`,`FIELD_A`,`FIELD_B`,`FIELD_C`,`FIELD_D`  FROM  Left_table  AS L
INNER JOIN Right_table AS R
ON  `L.Com_Field` = `R.Com_Field`
```

###### 4-7-4 多表联查

在两表联查的基础上再叠加联查，利用多表共同的字段层层过滤出想要的字段内容

```SQL
# 因为要查的字段不在同一张表，故利用多表中的字段交集查询索要的信息
# 已知公共内容的字段，common_field 简写为Com_Field，要利用Com_Field 从多个表中查询FIELD_A  FIELD_B  FILED_C FIELD_D 四个字段的内容，

SELECT `L.Com_Field`,`FIELD_A`,`FIELD_B`,`FIELD_C`,`FIELD_D`  
FROM  Left_table  AS L
LEFT Right_table AS R
ON  `L.Com_Field` = `R.Com_Field`
INNER 3rd_table as  T
ON  `L.Com_Field` = `T.Com_Field`
```

#### 5.函数	

函数的使用方法：`md5(2023-02-04)  ==> 8d8818c8e140c64c743113f563cf750f` ，是的，我使用md5函数加密了今日日期，使用方法就是直接拿到函数，把想要处理的数据套里面。

```SQL
# 函数举例
COUNT(统计总数) 
SUM(求和)
AVG(求平均值)
MAX(求最大值)
MD5(单向指纹加密)
CURRENT_DATE(当前时间)
SYSDATE(系统时间)
SYSTEMUSER(系统用户)
VERSION(当前版本)
····
```

## C.管理

#### 1.备份

一般mysql备份策略为： 全量+增量 （同时开启二进制日志） 

##### 1-0 物理冷备份

**MySQL物理冷备份及恢复**，简单粗暴易操作

- 关闭MySQL数据库
- 使用tar命令直接打包数据库文件夹
- 直接替换现有MySQL目录即可

```bash
[root@localhost ~]#  service mysql stop
[root@localhost ~]#  mkdir /backup    		# 创建备份目录
[root@localhost ~]#  tar zcvf /backup/mysql_all-$(date +%F).tar.gz    /mysql/data/  # 对mysql数据目录进行打包
```

- 恢复

```bash
[root@localhost ~]# mkdir bak
[root@localhost ~]# mv /mysql/data/  /bak/
[root@localhost ~]# mkdir restore
[root@localhost ~]# tar zxf /backup/mysql_all-2020-01-02.tar.gz -C restore/ //恢复数据库，采用将备份数据mv成线上库文件夹的方式
[root@localhost ~]# mv restore/mysql/data  /mysql/
[root@localhost ~]# service mysql start
```

##### 	1-1 MYSQL_DUMP

###### 1-1-1 对单个库进行全量备份

```bash
mysqldump -u用户名 -p [密码] [选项] [数据库名] > /备份路径/备份文件名

eg:
mysqldump -u root -p mysql > /bakcup/mysql.sql
```

###### 1-1-2 对多个库进行全量备份

```
mysqldump -u 用户名 -p [密码] [选项] --databases 库名1 [库名2] ... > /备份路径/备份文件名

eg：
mysqldump -u root -p --databases TEST_huken TEST_table > /bakcup/mysql.sql
```

###### 1-1-3 对所有库进行完全备份

```
mysqldump -u用户名 -p [密码] [选项] --all-databases > /备份路径/备份文件名

eg:
mysqldump -u root -p --all-databases  > /bakcup/mysql-all.sql
```

###### 1-1-4 对某库单表进行备份

```
mysqldump -u 用户名-p [密码] [|选项] 数据库名 表名 > /备份路径/备份文件名

eg：
mysqldump -u root -p mysql  user> /bakcup/mysql_user.sql
```

###### 1-1-5 增量备份

增量备份的讨论是针对于优化全量备份的内生性问题提出：

- 多次全量备份时，有重复数据占耗资源
- 备份时间与恢复时间过长

但mysqldump没有直接的增量备份方案，可以使用二进制日志实现，介于篇幅，二进制日志的开启方法参看主从配置小结。

**binlog备份&恢复**

- 二进制日志保存了所有更新或者可能更新数据库的操作
- 二进制日志在启动MySQL服务器后开始记录，并在文件达到max_ binlog_ size所设置的大小或者接收到flush logs命令后重新创建新的日志文件
- 只需定时执行fush logs方法重新创建新的日志，生成=进制文件序列，并及时把这些日志保存到安全的地方就完成了一个时间段的增量备份

```bash
/prepare_bak/2017-6-4.sql  # 一般开启二进制日志时，即指定了文件位置和文件头的名字
# 预设二进制文件头为： log-bin=/PATH/mysql-bin  序列生成的文件名为  mysql-bin.xxxxxx 

# 备份
只需定时执行fush logs方法重新创建新的日志，生成=进制文件序列，并及时把这些日志保存到安全的地方就完成了一个时间段的增量备份。

# 一般恢复
mkdir /prepare_bak
mysqlbinlog  mysql-bin.000001  >/prepare_bak/2017-6-4.sql		# 重定生成sql文件

mysqldump -uroot -p </prepare_bak/2017-6-4.sql
mysql -uroot -p -e "source  /prepare_bak/2017-6-4.sql"  # -e 免交户也可以实现mysqldump的导入效果，二选一

# 检查指定时间的Binlog日志
mysqlbinlog --start-datetime "2017-6-4 11:40:00" --stop-datetime "2017-6-4 12:55:00" mysql-bin.000001  >/prepare_bak/2017-6-4.sql  

# 基于点位的两种恢复方式
指定结束点位
mysqlbinlog --stop-position='操作id' /prepare_bak/2017-6-4.sql   | mysql -u 用户名 -p 密码

指定起始点位
mysqlbinlog --start-position='操作id' /prepare_bak/2017-6-4.sql | mysql -u 用户名 -p 密码

# 基于时间点的恢复
从日志开头截止到某个时间点的恢复
mysqlbinlog  --stop-datetime='2017-6-4 12:55:00'   /prepare_bak/2017-6-4.sql  | mysql -u用户名 -p密码

从某个时间点到日志结尾的恢复
mysqlbinlog  --start-datetime='2017-6-4 11:40:00'   /prepare_bak/2017-6-4.sql  | mysql -u用户名 -p密码

从某个时间点到某个时间点的恢复
mysqlbinlog --start-datetime "2017-6-4 11:40:00" --stop-datetime "2017-6-4 12:55:00"  /prepare_bak/2017-6-4.sql    | mysql -u用户名 -p密码
```

###### 1-1-6 备份恢复

```bash
# MySQL [(none)]> source /backup/all-data.sql 		//交互界面恢复，source后面跟备份的绝对路径  
```

```bash
# mysql -u用户名-p [密码] <库备份脚本的路径			//命令行恢复，source后面跟备份的绝对路径  

eg：
mysql -u root -p < /backup/all-data.sql
mysql -uroot -p -e "source /backup/all-data.sql"	# -e 免交户也可以实现mysqldump的导入效果，二选一
```

##### 	1-2 XtraBACKUP

Xtrabackup是一个开源的免费的热备份工具，在Xtrabackup包中主要有Xtrabackup和innobakcupex两个工具。其中Xtrabackup只能备份InnoDB和XtraDB两种引擎；Innobackup则是封装了Xtrabackup，同时增加了备份MylSAM引擎功能。
Xtrabackup备份时不能备份表结构、触发器等等，也不能智能区分.idb数据库文件。另外innobakcup还不能完全支持增量备份，需要和Xtrabackup结合起来实现全备的功能

###### 1-2-0 命令行参数

```bash
innobackupex [参数] [目的地址] [源地址]

# 常用参数
--user					# 以什么用于身份进行操作
--password				# 数据库用户的密码
--port					# 数据库的端口号，默认3306
--stream				# 打包（数据流）
--defaults-file			# 指定默认配置文件，默认读取/etc/my.cnf
--no-timestamp			# 不创建时间戳文件，而改用目的地址（可以自动创建）
--copy-back				# 备份还原的主要选项
--incremental			# 使用增量备份，默认使用的完整备份
--incremental-basedir	# 与--incremental选项联合使用，该参数指定上一级备份的地址来做增量备份
--socket				# 找不到mysqlsock 文件时，手动指定
```

###### 1-2-1 全量备份

```bash
# innobackupex [参数] [目的地址] [源地址]
# 默认生成的备份文件目录是 当前的时间日期命令

eg：
[root@msql_60 ~]#  date +%F"  "%T
[root@msql_60 ~]# 1959-03-02  10-04-30

innobackupex --defaults-file=/etc/my.cnf  --socket  /usr/local/mysql/bin/mysql.sock --user=root --password=fouSpaaU8    /prepare_bak/ 
···
completed OK!
[root@msql_60 ~]#  ls  /prepare_bak/
[root@msql_60 ~]#   1959-03-02_10-05-57/
# 当打印 "completed OK!" 时，则备份成功
```

###### 1-2-2 增量备份

```bash
# innobackupex [参数] [目的地址] [源地址]
# 默认生成的备份文件目录是 当前的时间日期命令
# innobackupex  --incremental  增量文件路径 --incremental-basedir= 基础文件路径

eg：
[root@msql_60 ~]#  date +%F"  "%T
[root@msql_60 ~]# 1959-03-02  10-20-22
innobackupex ---user=root --password=fouSpaaU8  --incremental  /prepare_bak/ --incremental-basedir= /prepare_bak/1959-03-02_10-05-57
···
completed OK!

[root@msql_60 ~]#  ls  /prepare_bak/
[root@msql_60 ~]#   1959-03-02_10-20-25/
# 当打印 "completed OK!" 时，则备份成功

```

###### 1-2-4 恢复

**有一点需要注意的是，增量备份的恢复顺序：先回复增量的全量基础，然后安装从前往后时间线逐次恢复，先恢复时间最早的文件！**

```bash
# innobackupex [参数] [目的地址] [源地址]
# innobackupex --copy-back   /PATH/备份文件地址

eg：
innobackupex --copy-back   /prepare_bak/1959-03-02_10-05-57/
```

#### 2.集群&代理

​		集群[通信系统](https://baike.baidu.com/item/通信系统/1975602?fromModule=lemma_inlink)是一种用于集团调度[指挥通信](https://baike.baidu.com/item/指挥通信/4962709?fromModule=lemma_inlink)的[移动通信系统](https://baike.baidu.com/item/移动通信系统/6106654?fromModule=lemma_inlink)，主要应用在专业移动通信领域。该系统具有的可用信道可为系统的全体用户共用，具有[自动选择](https://baike.baidu.com/item/自动选择/18545718?fromModule=lemma_inlink)信道功能，它是[共享资源](https://baike.baidu.com/item/共享资源/10366244?fromModule=lemma_inlink)、分担费用、共用信道设备及服务的多用途、高效能的无线调度通信系统；

​		为什么选择横向拓展？

- 数据库服务器存在单点问题；
- 数据库服务器资源无法满足增长的读写请求；
- 高峰时数据库连接数经常超过上限

##### 	2-1 主从

​		主从架构部署比较简单，常见架构根据主从节点个数不同分成 一主多从，多主一从，双主节点等。一主多从的主从复制数据库集群架构师最基本也是最常用的一种架构部署，能够满足很多业务需求。

- 数据存在多个镜像和数据冗余，可以防止单一主机的数据丢失，提高数据的安全性。
- 如果使用mysql proxy，在业务上可以实现读写分离。即可以把一些读操作在从服务器上执行，减小主服务器的负担。
- 在从服务器上做数据备份，这样不影响主服务器的正常运行。
- 从服务器可以使用不用的存储引擎，从库上的数据表建立不同的索引，适用不同的业务场景。
- 主从设计参考:  https://www.cnblogs.com/ccywmbc/p/16614594.html   

###### 2-1-1 二进制日志开启

```bash
MSATER端
#vi /etc/my.cnf
       [mysqld]
       log-bin=mysql-bin   //[必须]启用二进制日志
       server-id=114      //[必须]服务器唯一ID，默认是1，一般取IP最后一段
--并重启之，使生效
[root@master ~]# service mysql restart 

SLEAVE端
#vi /etc/my.cnf
       [mysqld]
       log-bin=mysql-bin   //[非必须]启用二进制日志
       server-id=514      //[必须]服务器唯一ID，默认是1，一般取IP最后一段
--并重启之，使生效
[root@slave ~]# service mysql restart 
```

###### 2-1-2 MASTER创建连接用户并授权

```SQL
GRANT REPLICATION SLAVE ON *.* to 'SYNC_USER'@'%' identified by 'q123456';  # 一般不用root帐号
```

###### 2-1-3 MASTER 检查二进制文件名及节点位置

```sql
SHOW MASTER STATUS ;

  +------------------+----------+--------------+------------------+
   | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
   +------------------+----------+--------------+------------------+
   | mysql-bin.000004 |      308 |              |                  |
   +------------------+----------+--------------+------------------+
   
 # 此例回显结果为假设，真实场景回显不一样。
```

###### 2-1-4 从库指定连接，并开启SLAVE模式

```SQL
CHANGE MASTER TO MASTER_HOST='MASTER_IP',MASTER_USER='SYNC_USER',MASTER_PASSWORD='q123456'，MASTER_LOG_FILE='mysql-bin.000004',MASTER_LOG_POS=308;     //注意不要断开，308数字前后无单引号。

SLAVE START;
```

##### 	2-2 数据中间件DBLE

资料参考：https://blog.csdn.net/sing_net/article/details/103591170 

##### 2-3 集群设计&部署

**MySQL + MMM**（MMM即Multi-Master Replication Manager for MySQL）

**MHA方案**

```
软件简介
MHA（Master High Availability）目前在 MySQL 高可用方面是一个相对成熟的解决方案，它由日本 DeNA 公司的 youshimaton（现就职于 Facebook 公司）开发，是一套优秀的作为 MySQL 高可用性环境下故障切换和主从提升的高可用软件。

在 MySQL 故障切换过程中，MHA 能做到在 0~30 秒之内自动完成数据库的故障切换操作，并且在进行故障切换的过程中，MHA 能在最大程度上保证数据的一致性，以达到真正意义上的高可用。

该软件由两部分组成：MHA Manager（管理节点）和 MHA Node（数据节点）。MHA Manager 可以单独部署在一台独立的机器上管理多个 master-slave 集群，也可以部署在一台 slave 节点上。MHA Node 运行在每台 MySQL 服务器上，MHA Manager 会定时探测集群中的 master 节点，当 master 出现故障时，它可以自动将最新数据的 slave 提升为新的 master，然后将所有其他的 slave 重新指向新的 master。整个故障转移过程对应用程序完全透明。

在 MHA 自动故障切换过程中，MHA 试图从宕机的主服务器上保存二进制日志，最大程度的保证数据的不丢失，但这并不总是可行的。例如，如果主服务器硬件故障或无法通过 ssh 访问，MHA 没法保存二进制日志，只进行故障转移而丢失了最新的数据。使用 MySQL 5.5 的半同步复制，可以大大降低数据丢失的风险。MHA 可以与半同步复制结合起来。如果只有一个 slave 已经收到了最新的二进制日志，MHA 可以将最新的二进制日志应用于其他所有的 slave 服务器上，因此可以保证所有节点的数据一致性。

目前 MHA 主要支持一主多从的架构，要搭建 MHA, 要求一个复制集群中必须最少有三台数据库服务器，一主二从，即一台充当 master，一台充当备用 master，另外一台充当从库，因为至少需要三台服务器，出于机器成本的考虑，淘宝也在该基础上进行了改造，目前淘宝 TMHA 已经支持一主一从。
```

#### 3.GUI工具

**navicat**

**SQLyog**

## 附录

----------

#### A.配置文件详解

```
# 客户端设置，即客户端默认的连接参数
[client]
 
# 默认连接端口
port = 3306
 
# 用于本地连接的socket套接字
socket = /usr/local/mysql/data/mysql.sock
 
# 字符集编码
default-character-set = utf8mb4
 
# 服务端基本设置
[mysqld] 
 
# MySQL监听端口
port = 3306
 
# 为MySQL客户端程序和服务器之间的本地通讯指定一个套接字文件
socket = /usr/local/mysql/data/mysql.sock
 
# pid文件所在目录
pid-file = /usr/local/mysql/data/mysql.pid
 
# 使用该目录作为根目录（安装目录）
basedir = /usr/local/mysql
 
# 数据文件存放的目录
datadir = /usr/local/mysql/database
 
# MySQL存放临时文件的目录
tmpdir = /usr/local/mysql/data/tmp
 
# 服务端默认编码（数据库级别）
character_set_server = utf8mb4
 
# 服务端默认的比对规则，排序规则
collation_server = utf8mb4_bin
 
# MySQL启动用户。如果是root用户就配置root，mysql用户就配置mysql
user = root
 
# 错误日志配置文件(configure file)
log-error=/usr/local/mysql/data/error.log
 
secure-file-priv = null
 
# 开启了binlog后，必须设置这个值为1.主要是考虑binlog安全
# 此变量适用于启用二进制日志记录的情况。它控制是否可以信任存储函数创建者，而不是创建将导致
# 要写入二进制日志的不安全事件。如果设置为0（默认值），则不允许用户创建或更改存储函数，除非用户具有
# 除创建例程或更改例程特权之外的特权 
log_bin_trust_function_creators = 1
 
# 性能优化的引擎，默认关闭
performance_schema = 0
 
# 开启全文索引
# ft_min_word_len = 1
 
# 自动修复MySQL的myisam引擎类型的表
#myisam_recover
 
# 明确时间戳默认null方式 
explicit_defaults_for_timestamp
 
# 计划任务（事件调度器） 
event_scheduler
# 跳过外部锁定;External-locking用于多进程条件下为MyISAM数据表进行锁定
skip-external-locking
 
# 跳过客户端域名解析；当新的客户连接mysqld时，mysqld创建一个新的线程来处理请求。该线程先检查是否主机名在主机名缓存中。如果不在，线程试图解析主机名。
# 使用这一选项以消除MySQL进行DNS解析的时间。但需要注意，如果开启该选项，则所有远程主机连接授权都要使用IP地址方式，否则MySQL将无法正常处理连接请求! 
skip-name-resolve
 
 
# 1.强烈建议不配置bind-address
# 2.如果要配置bind-address的话，这个localhost不能修改，否则在初始化数据库(执行/opt/cloudera/cm/schema/scm_prepare_database.sh mysql cm cm password)时便会报错，如果/etc/my.cnf中配置了bind-address=localhost 的话，那么在CDH的安装页面中，配置连接数据库的主机名称必须为localhost。
# (原因)缺点：但是在安装hue时，“数据库主机名称”并无法使用localhost或任何主机名，所以造成无法安装hue
# 3.不配置 bind-address=localhost 的话，则使用主机名(NDOE1)作为此处的数据库主机名称
# MySQL绑定IP
#bind-address=localhost  
 
 # 为了安全起见，复制环境的数据库还是设置--skip-slave-start参数，防止复制随着mysql启动而自动启动
skip-slave-start
 
# MySQL主从复制的时候，在中止读取之前等待来自主/从连接的更多数据的秒数。 
# 当Master和Slave之间的网络中断，但是Master和Slave无法察觉的情况下（比如防火墙或者路由问题）。Slave会等待slave_net_timeout设置的秒数后，才能认为网络出现故障，然后才会重连并且追赶这段时间主库的数据。
# 1.用这三个参数来判断主从是否延迟是不准确的Slave_IO_Running,Slave_SQL_Running,Seconds_Behind_Master.优先使用用pt-heartbeat参数进行判断。
# 2.slave_net_timeout不要用默认值，设置一个你能接受的延时时间。 
slave_net_timeout = 30
 
# 设定是否支持命令load data local infile。如果指定local关键词，则表明支持从客户主机读文件
local-infile = 0
 
# 指定MySQL可能的连接数量。当MySQL主线程在很短的时间内得到非常多的连接请求，该参数就起作用，之后主线程花些时间（尽管很短）检查连接并且启动一个新线程。
# back_log参数的值指出在MySQL暂时停止响应新请求之前的短时间内多少个请求可以被存在堆栈中。
back_log = 1024
 
 
#sql_mode,定义了mysql应该支持的sql语法，数据校验等!  NO_AUTO_CREATE_USER：禁止GRANT创建密码为空的用户。
#NO_ENGINE_SUBSTITUTION 如果需要的存储引擎被禁用或未编译，可以防止自动替换存储引擎
#sql_mode='PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,NO_KEY_OPTIONS,NO_TABLE_OPTIONS,NO_FIELD_OPTIONS,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'
sql_mode = NO_ENGINE_SUBSTITUTION,NO_AUTO_CREATE_USER
 
#索引块的缓冲区大小，对【MyISAM表性能影响最大的一个参数】.决定索引处理的速度，尤其是索引读的速度。默认值是16M，通过检查状态值Key_read_requests和Key_reads，可以知道key_buffer_size设置是否合理 
key_buffer_size = 32M
 
#一个查询语句包的最大尺寸。消息缓冲区被初始化为net_buffer_length字节，但是可在需要时增加到max_allowed_packet个字节。
#该值太小则会在处理大包时产生错误。如果使用大的BLOB列，必须增加该值。
#这个值来限制server接受的数据包大小。有时候大的插入和更新会受max_allowed_packet 参数限制，导致写入或者更新失败。 
max_allowed_packet = 512M
 
#线程盏；主要用来存放每一个线程自身的标识信息，如线程id，线程运行时基本信息等等，我们可以通过 thread_stack 参数来设置为每一个线程栈分配多大的内存。 
thread_stack = 256K
 
 
#是MySQL执行排序使用的缓冲大小。如果想要增加ORDER BY的速度，首先看是否可以让MySQL使用索引而不是额外的排序阶段。
#如果不能，可以尝试增加sort_buffer_size变量的大小。 
sort_buffer_size = 16M
 
 
#是MySQL读入缓冲区大小。对表进行顺序扫描的请求将分配一个读入缓冲区，MySQL会为它分配一段内存缓冲区。read_buffer_size变量控制这一缓冲区的大小。
#如果对表的顺序扫描请求非常频繁，并且你认为频繁扫描进行得太慢，可以通过增加该变量值以及内存缓冲区大小提高其性能。 
read_buffer_size = 16M
 
 
#应用程序经常会出现一些两表（或多表）Join【例如联表查询】的操作需求，MySQL在完成某些 Join 需求的时候（all/index join）
#为了减少参与Join的“被驱动表”的读取次数以提高性能，需要使用到 Join Buffer 来协助完成 Join操作。
# 当 Join Buffer 太小，MySQL 不会将该 Buffer 存入磁盘文件，
# 而是先将Join Buffer中的结果集与需要 Join 的表进行 Join 操作，
# 然后清空 Join Buffer 中的数据，继续将剩余的结果集写入此 Buffer 中，如此往复。
# 这势必会造成被驱动表需要被多次读取，成倍增加 IO 访问，降低效率。 
join_buffer_size = 16M
 
#是MySQL的随机读缓冲区大小。当按任意顺序读取行时(例如，按照排序顺序)，将分配一个随机读缓存区。进行排序查询时，MySQL会首先扫描一遍该缓冲，以避免磁盘搜索，
#提高查询速度，如果需要排序大量数据，可适当调高该值。但MySQL会为每个客户连接发放该缓冲空间，所以应尽量适当设置该值，以避免内存开销过大。 
read_rnd_buffer_size = 32M
 
#通信缓冲区在查询期间被重置到该大小。通常不要改变该参数值，但是如果内存不足，可以将它设置为查询期望的大小。
#（即，客户发出的SQL语句期望的长度。如果语句超过这个长度，缓冲区自动地被扩大，直到max_allowed_packet个字节。）
net_buffer_length = 16K
 
#当对MyISAM表执行repair table或创建索引时，用以缓存排序索引；设置太小时可能会遇到” myisam_sort_buffer_size is too small” 
myisam_sort_buffer_size = 128M
 
#默认8M，当对MyISAM非空表执行insert … select/ insert … values(…),(…)或者load data infile时，使用树状cache缓存数据，每个thread分配一个；
#注：当对MyISAM表load 大文件时，调大bulk_insert_buffer_size/myisam_sort_buffer_size/key_buffer_size会极大提升速度 
bulk_insert_buffer_size = 32M
 
#thread_cahe_size线程池，线程缓存。用来缓存空闲的线程，以至于不被销毁，如果线程缓存在的空闲线程，需要重新建立新连接，
#则会优先调用线程池中的缓存，很快就能响应连接请求。每建立一个连接，都需要一个线程与之匹配。 
thread_cache_size = 384
 
#工作原理： 一个SELECT查询在DB中工作后，DB会把该语句缓存下来，当同样的一个SQL再次来到DB里调用时，DB在该表没发生变化的情况下把结果从缓存中返回给Client。
#在数据库写入量或是更新量也比较大的系统，该参数不适合分配过大。而且在高并发，写入量大的系统，建系把该功能禁掉。 
query_cache_size = 0
 
#决定是否缓存查询结果。这个变量有三个取值：0,1,2，分别代表了off、on、demand。 
query_cache_type = 0
 
#它规定了内部内存临时表的最大值，每个线程都要分配。（实际起限制作用的是tmp_table_size和max_heap_table_size的最小值。）
#如果内存临时表超出了限制，MySQL就会自动地把它转化为基于磁盘的MyISAM表，存储在指定的tmpdir目录下 
tmp_table_size = 1024M
 
#独立的内存表所允许的最大容量.# 此选项为了防止意外创建一个超大的内存表导致用尽所有的内存资源. 
max_heap_table_size = 512M
 
#mysql打开最大文件数 
open_files_limit = 10240
 
#MySQL无论如何都会保留一个用于管理员（SUPER）登陆的连接，用于管理员连接数据库进行维护操作，即使当前连接数已经达到了max_connections。
#因此MySQL的实际最大可连接数为max_connections+1；
#这个参数实际起作用的最大值（实际最大可连接数）为16384，即该参数最大值不能超过16384，即使超过也以16384为准；
#增加max_connections参数的值，不会占用太多系统资源。系统资源（CPU、内存）的占用主要取决于查询的密度、效率等；
#该参数设置过小的最明显特征是出现”Too many connections”错误； 
max_connections = 2000
 
#用来限制用户资源的，0不限制；对整个服务器的用户限制 
max-user-connections = 0
 
#max_connect_errors是一个MySQL中与安全有关的计数器值，它负责阻止过多尝试失败的客户端以防止暴力破解密码的情况。max_connect_errors的值与性能并无太大关系。
#当此值设置为10时，意味着如果某一客户端尝试连接此MySQL服务器，但是失败（如密码错误等等）10次，则MySQL会无条件强制阻止此客户端连接。 
max_connect_errors = 100000
 
#表描述符缓存大小，可减少文件打开/关闭次数； 
table_open_cache = 5120
 
#interactive_time -- 指的是mysql在关闭一个交互的连接之前所要等待的秒数(交互连接如mysql gui tool中的连接 
interactive_timeout = 86400
 
#wait_timeout -- 指的是MySQL在关闭一个非交互的连接之前所要等待的秒数
wait_timeout = 86400
 
#二进制日志缓冲大小
#InnoDB存储引擎是支持事务的，实现事务需要依赖于日志技术，为了性能，日志编码采用二进制格式。
# 那如何记日志呢？有日志的时候，就直接写磁盘？
#磁盘的效率是很低的，如果你用过Nginx，一般Nginx输出access log都是要缓冲输出的。因此，记录二进制日志的时候，我们也需要考虑Cache
#但是Cache不是直接持久化，面临安全性的问题——因为系统宕机时，Cache中可能有残余的数据没来得及写入磁盘。因此，Cache要权衡，要恰到好处：
#既减少磁盘I/O，满足性能要求；又保证Cache无残留，及时持久化，满足安全要求。 
binlog_cache_size = 16M
 
 
#开启慢查询 
slow_query_log = true
 
#慢查询地址
slow_query_log_file = /usr/local/mysql/data/slow_query_log.log
 
#MySQL能够记录执行时间超过参数long_query_time 设置值的SQL语句，默认不记录。
long_query_time = 1
 
#记录管理语句和没有使用index的查询记录
log-slow-admin-statements
log-queries-not-using-indexes
 
 
# 主从复制配置 *****************************************************
# *** Replication related settings ***
 
#在复制方面的改进就是引进了新的复制技术：基于行的复制。简言之，这种新技术就是关注表中发生变化的记录，而非以前的照抄 binlog 模式。
#从 MySQL 5.1.12 开始，可以用以下三种模式来实现：
#基于SQL语句的复制(statement-based replication, SBR)
#基于行的复制(row-based replication, RBR)
#混合模式复制(mixed-based replication, MBR)。
#相应地，binlog的格式也有三种：STATEMENT，ROW，MIXED。
#注意 MBR模式中，SBR模式是默认的。
binlog_format = ROW
 
# 为每个session 最大可分配的内存，在事务过程中用来存储二进制日志的缓存。 
#max_binlog_cache_size = 102400
 
#开启二进制日志功能，binlog数据位置
log-bin = /usr/local/mysql/data/binlog/mysql-bin
 
log-bin-index = /usr/local/mysql/data/binlog/mysql-bin.index
 
#relay-log日志记录的是从服务器I/O线程将主服务器的二进制日志读取过来记录到从服务器本地文件，
#然后SQL线程会读取relay-log日志的内容并应用到从服务器
relay-log = /usr/local/mysql/data/relay/mysql-relay-bin
 
#binlog传到备机被写到relaylog里，备机的slave sql线程从relaylog里读取然后应用到本地。 
relay-log-index = /usr/local/mysql/data/relay/mysql-relay-bin.index
 
 
# *******************主要配置*********************
# 【主服务器配置】
 
#服务端ID，用来高可用时做区分
server-id = 1
 
# 不同步哪些数据库
#binlog-ignore-db = mysql
#binlog-ignore-db = sys
#binlog-ignore-db = binlog
#binlog-ignore-db = relay
#binlog-ignore-db = tmp
#binlog-ignore-db = test
#binlog-ignore-db = information_schema
#binlog-ignore-db = performance_schema
 
# 只同步哪些数据库，除此之外，其他不同步
#binlog-do-db = game
 
# 【从服务器配置】
 
#服务端ID，用来高可用时做区分
#server-id = 2
 
# 不同步哪些数据库
#replicate-ignore-db = mysql
#replicate-ignore-db = sys
#replicate-ignore-db = relay
#replicate-ignore-db = tmp
#replicate-ignore-db = test
#replicate-ignore-db = information_schema
#replicate-ignore-db = performance_schema
 
# 只同步哪些数据库，除此之外，其他不同步
#replicate-do-db = game
 
 
# *******************主要配置*********************
 
#log_slave_updates是从服务器将从主服务器收到的更新记入到从服务器自己的二进制日志文件中。 
log_slave_updates = 1
 
#二进制日志自动删除的天数。默认值为0,表示“没有自动删除”。启动时和二进制日志循环时可能删除。
expire-logs-days = 15
 
#如果二进制日志写入的内容超出给定值，日志就会发生滚动。你不能将该变量设置为大于1GB或小于4096字节。 默认值是1GB。
max_binlog_size = 128M
 
#replicate-wild-ignore-table参数能同步所有跨数据库的更新，比如replicate-do-db或者replicate-ignore-db不会同步类似
#replicate-wild-ignore-table = mysql.%
 
#设定需要复制的Table
#replicate-wild-do-table = db_name.%
 
#复制时跳过一些错误;不要胡乱使用这些跳过错误的参数，除非你非常确定你在做什么。当你使用这些参数时候，MYSQL会忽略那些错误，
#这样会导致你的主从服务器数据不一致。 
#slave-skip-errors = 1062,1053,1146
 
#这两个参数一般用在主主同步中，用来错开自增值, 防止键值冲突 
auto_increment_offset = 1
auto_increment_increment = 2
 
#将中继日志的信息写入表:mysql.slave_realy_log_info 
relay_log_info_repository = TABLE
 
#将master的连接信息写入表：mysql.salve_master_info
master_info_repository = TABLE
 
#中继日志自我修复；当slave从库宕机后，假如relay-log损坏了，导致一部分中继日志没有处理，则自动放弃所有未执行的relay-log，
#并且重新从master上获取日志，这样就保证了relay-log的完整性
relay_log_recovery = on
# 主从复制配置结束 *****************************************************
 
 
# *** innodb setting ***
#InnoDB 用来高速缓冲数据和索引内存缓冲大小。 更大的设置可以使访问数据时减少磁盘 I/O。
innodb_buffer_pool_size = 128M
 
#单独指定数据文件的路径与大小
innodb_data_file_path = ibdata1:10M:autoextend
 
#每次commit 日志缓存中的数据刷到磁盘中。通常设置为 1，意味着在事务提交前日志已被写入磁盘， 事务可以运行更长以及服务崩溃后的修复能力。
#如果你愿意减弱这个安全，或你运行的是比较小的事务处理，可以将它设置为 0 ，以减少写日志文件的磁盘 I/O。这个选项默认设置为 0。
innodb_flush_log_at_trx_commit = 2
 
#sync_binlog=n，当每进行n次事务提交之后，MySQL将进行一次fsync之类的磁盘同步指令来将binlog_cache中的数据强制写入磁盘。 
#sync_binlog = 1000
 
#对于多核的CPU机器，可以修改innodb_read_io_threads和innodb_write_io_threads来增加IO线程，来充分利用多核的性能 
innodb_read_io_threads = 8
innodb_write_io_threads = 8
 
#限制Innodb能打开的表的数量
innodb_open_files = 1000
 
#开始碎片回收线程。这个应该能让碎片回收得更及时而且不影响其他线程的操作
innodb_purge_threads = 1
 
#InnoDB 将日志写入日志磁盘文件前的缓冲大小。理想值为 1M 至 8M。大的日志缓冲允许事务运行时不需要将日志保存入磁盘而只到事务被提交(commit)。
#因此，如果有大的事务处理，设置大的日志缓冲可以减少磁盘I/O。 
innodb_log_buffer_size = 8M
 
 #日志组中的每个日志文件的大小(单位 MB)。如果 n 是日志组中日志文件的数目，那么理想的数值为 1M 至下面设置的缓冲池(buffer pool)大小的 1/n。较大的值，
#可以减少刷新缓冲池的次数，从而减少磁盘 I/O。但是大的日志文件意味着在崩溃时需要更长的时间来恢复数据。 
innodb_log_file_size = 128M
 
#指定有三个日志组 
innodb_log_files_in_group = 3
 
#在回滚(rooled back)之前，InnoDB 事务将等待超时的时间(单位 秒) 
#innodb_lock_wait_timeout = 120
 
#innodb_max_dirty_pages_pct作用：控制Innodb的脏页在缓冲中在那个百分比之下，值在范围1-100,默认为90.这个参数的另一个用处：
#当Innodb的内存分配过大，致使swap占用严重时，可以适当的减小调整这个值，使达到swap空间释放出来。建义：这个值最大在90%，最小在15%。
#太大，缓存中每次更新需要致换数据页太多，太小，放的数据页太小，更新操作太慢。 
innodb_max_dirty_pages_pct = 75
 
#innodb_buffer_pool_size 一致 可以开启多个内存缓冲池，把需要缓冲的数据hash到不同的缓冲池中，这样可以并行的内存读写。 
innodb_buffer_pool_instances = 4
 
#这个参数据控制Innodb checkpoint时的IO能力 
innodb_io_capacity = 500
 
#作用：使每个Innodb的表，有自已独立的表空间。如删除文件后可以回收那部分空间。
#分配原则：只有使用不使用。但ＤＢ还需要有一个公共的表空间。 
innodb_file_per_table = 1
 
#当更新/插入的非聚集索引的数据所对应的页不在内存中时（对非聚集索引的更新操作通常会带来随机IO），会将其放到一个insert buffer中， #当随后页面被读到内存中时，会将这些变化的记录merge到页中。当服务器比较空闲时，后台线程也会做merge操作 
innodb_change_buffering = inserts
 
#该值影响每秒刷新脏页的操作，开启此配置后，刷新脏页会通过判断产生重做日志的速度来判断最合适的刷新脏页的数量； 
innodb_adaptive_flushing = 1
 
#数据库事务隔离级别 ，读取提交内容 
transaction-isolation = READ-COMMITTED
 
#innodb_flush_method这个参数控制着innodb数据文件及redo log的打开、刷写模式
#InnoDB使用O_DIRECT模式打开数据文件，用fsync()函数去更新日志和数据文件。 
innodb_flush_method = fsync
 
#默认设置值为1.设置为0：表示Innodb使用自带的内存分配程序；设置为1：表示InnoDB使用操作系统的内存分配程序。 
#innodb_use_sys_malloc = 1
 
 
 
[mysqldump]
#它强制 mysqldump 从服务器查询取得记录直接输出而不是取得所有记录后将它们缓存到内存中
quick
 
#限制server接受的数据包大小;指代mysql服务器端和客户端在一次传送数据包的过程当中数据包的大小 
max_allowed_packet = 512M
 
#TCP/IP和套接字通信缓冲区大小,创建长度达net_buffer_length的行
net_buffer_length = 16384
 
 
[mysql]
#auto-rehash是自动补全的意思
auto-rehash
 
 
[isamchk]
#isamchk数据检测恢复工具
key_buffer = 256M
sort_buffer_size = 256M
read_buffer = 2M
write_buffer = 2M
 
 
 
[myisamchk]
#使用myisamchk实用程序来获得有关你的数据库桌表的信息、检查和修复他们或优化他们
key_buffer = 256M
sort_buffer_size = 256M
read_buffer = 2M
write_buffer = 2M
 
 
[mysqlhotcopy]
#mysqlhotcopy使用lock tables、flush tables和cp或scp来快速备份数据库.它是备份数据库或单个表最快的途径,完全属于物理备份,但只能用于备份MyISAM存储引擎和运行在数据库目录所在的机器上.
#与mysqldump备份不同,mysqldump属于逻辑备份,备份时是执行的sql语句.使用mysqlhotcopy命令前需要要安装相应的软件依赖包.
interactive-timeout
```

