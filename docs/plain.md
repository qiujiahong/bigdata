# 系统规划

| 主机  | ip          | 说明                                     |
|-------|-------------|------------------------------------------|
| node1 | 10.170.0.7  | java、zk,hdfs(NameNode,DataNode),spark(master)          |
| node2 | 10.170.0.8  | java、zk,hdfs(SecondaryNameNode,DataNode),spark(worker) |
| node3 | 10.170.0.9  | java、zk,hdfs(DataNode) ,spark(worker)                  |
| node4 | 10.170.0.10 | java                                     |

> node1、node2、node3、node4上都增加appuser用户和用户组
> node1作为主控电脑，上传文件都上传到该文件目录下
> *  配置node1作为root用户到node2、node3、node4免密登录；
> *  配置node1作为appuser用户到node2、node3、node4免密登录；
