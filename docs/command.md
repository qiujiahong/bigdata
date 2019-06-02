# HDFS客户端


## 客户端的形式


hdfs的客户端有多种形式：
1、网页形式
2、命令行形式
3、客户端在哪里运行，没有约束，只要运行客户端的机器能够跟hdfs集群联网


## hdfs客户端的常用操作命令

* 上传文件到hdfs中  
```bash 
hadoop fs -put /local/file  /aaa
```

* 下载文件到客户端本地磁盘  

```bash 
hadoop fs -get /hdfs中的路径   /本地磁盘目录
```
* 在hdfs中创建文件夹  
```bash
hadoop fs -mkdir  -p /aaa/xxx
```

* 移动hdfs中的文件（更名）
```bash
hadoop fs -mv /hdfs的路径1  /hdfs的另一个路径2
```

* 复制hdfs中的文件到hdfs的另一个目录  
```bash
hadoop fs -cp /hdfs路径_1  /hdfs路径_2
```

* 删除hdfs中的文件或文件夹
```bash
hadoop fs -rm -r /aaa
```

* 查看hdfs中的文本文件内容 
```bash
hadoop fs -cat /demo.txt
hadoop fs -tail -f /demo.txt
```

* 列举hdfs某一目录下的文件
```
hadoop fs -ls /
```