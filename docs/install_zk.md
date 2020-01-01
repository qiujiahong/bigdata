# 安装zk

## 计划

在node1、node2、node3上安装zk 

## 上传文件到服务器

* [apache-zookeeper-3.5.6-bin.tar.gz](http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.5.6/apache-zookeeper-3.5.6-bin.tar.gz)

```
wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.5.6/apache-zookeeper-3.5.6-bin.tar.gz
```


## 安装 


```bash 
# 安装文件
array=(node1 node2 node3)
for((i=1;i<=${#array[*]};i++)); do 
num=$(($i-1))
echo "${array[$num]}......start";
scp apache-zookeeper-3.5.6-bin.tar.gz root@$node:/root
ssh root@$node "rm -rf /apps/apache-zookeeper-3.5.6-bin/"
ssh root@$node "tar -xzvf /root/apache-zookeeper-3.5.6-bin.tar.gz -C /apps/"
ssh root@$node "rm -rf /root/apache-zookeeper-3.5.6-bin.tar.gz"
ssh root@${array[$num]} "mkdir -p /apps/apache-zookeeper-3.5.6-bin/data"
ssh root@${array[$num]} "mkdir -p /apps/apache-zookeeper-3.5.6-bin/logs"
ssh root@${array[$num]} "echo $i > /apps/apache-zookeeper-3.5.6-bin/data/myid"
ssh root@${array[$num]} "rm -rf apache-zookeeper-3.5.6-bin.tar.gz"
ssh root@${array[$num]} "echo ${array[$num]}......end"
ssh root@${array[$num]} "cat /apps/apache-zookeeper-3.5.6-bin/data/myid"
ssh root@${array[$num]} "echo ${array[$num]}......end"
done ;

# 配置文件
array=(node1 node2 node3)
for node in ${array[@]}; do 
echo "$node ......config file";
ssh root@$node "mkdir -p /apps/apache-zookeeper-3.5.6-bin/data"
ssh root@$node "mkdir -p /apps/apache-zookeeper-3.5.6-bin/logs"
ssh  root@$node "rm -rf /apps/apache-zookeeper-3.5.6-bin/conf/zoo.cfg"
ssh  root@$node "cp /apps/apache-zookeeper-3.5.6-bin/conf/zoo_sample.cfg /apps/apache-zookeeper-3.5.6-bin/conf/zoo.cfg"
ssh root@$node  "sed -i \"s/^dataDir=.*/dataDir=\/apps\/apache-zookeeper-3.5.6-bin\/data/g\" /apps/apache-zookeeper-3.5.6-bin/conf/zoo.cfg"
ssh root@$node  "sed -i \"s/^dataLogDir=.*/dataLogDir=\/apps\/apache-zookeeper-3.5.6-bin\/logs/g\" /apps/apache-zookeeper-3.5.6-bin/conf/zoo.cfg"
ssh root@$node   "echo 'dataLogDir=/apps/apache-zookeeper-3.5.6-bin/logs' >>  /apps/apache-zookeeper-3.5.6-bin/conf/zoo.cfg"
ssh root@$node   "echo 'server.1=node1:2888:3888' >>  /apps/apache-zookeeper-3.5.6-bin/conf/zoo.cfg"
ssh root@$node   "echo 'server.2=node2:2888:3888' >>  /apps/apache-zookeeper-3.5.6-bin/conf/zoo.cfg"
ssh root@$node   "echo 'server.3=node3:2888:3888' >>  /apps/apache-zookeeper-3.5.6-bin/conf/zoo.cfg"
done

```


## 卸载

```bash
array=(node1 node2 node3)
for((i=1;i<=${#array[*]};i++)); do 
num=$(($i-1))
echo "${array[$num]}......";
ssh root@${array[$num]} "rm -rf apache-zookeeper-3.5.6-bin.tar.gz"
ssh root@$node "rm -rf /apps/apache-zookeeper-3.5.6-bin/"
done ;
```