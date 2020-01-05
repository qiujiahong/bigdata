# 安装spark



## 计划

在node1、node2、node3上安装spark，其中：
* master          node1 
* slave           node2、node3

> 需要再master 上做所有slave节点的免密登录


## 上传文件 

```BASH 
wget https://downloads.lightbend.com/scala/2.12.10/scala-2.12.10.tgz
wget http://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-3.0.0-preview2/spark-3.0.0-preview2-bin-hadoop3.2.tgz
```


## 安装scala 

```bash 
#  安装scala,准备文件(控制机上执行) 
## 自定义配置文件 
cat << 'EOF' > param_spark.sh
export spark_master_node_host=node1
export spark_slave_nodes=(node2 node3)
export spark_nodes=(node1 node2 node3)
export java_home_var=/apps/jdk1.8.0_211
EOF
source param_spark.sh

## 分发安装文件
for node in ${spark_nodes[@]}; do 
echo "send to $node ......";
ssh root@$node "rm -rf /apps/scala*"
scp param_spark.sh root@$node:/tmp/
scp scala-2.12.10.tgz root@$node:/tmp/
ssh root@$node "tar -xzvf /tmp/scala-2.12.10.tgz  -C /apps/"
ssh root@$node "sed -i '/SCALA_HOME_VAR/d' /etc/profile"
ssh root@$node "sed -i '/SCALA_PATH_VAR/d' /etc/profile"
ssh root@$node "echo 'export SCALA_HOME=/apps/scala-2.12.10  # SCALA_HOME_VAR ' >> /etc/profile"
ssh root@$node "echo 'export PATH=\$PATH:\$SCALA_HOME/bin      # SCALA_PATH_VAR ' >> /etc/profile"
ssh root@$node "source /etc/profile && echo $PATH && scala -version"
### 清理文件
ssh root@$node "rm -rf /tmp/scala-2.12.10.tgz"
done  

```

## 安装spark 

* 在控制机上准备文件    

```BASH 
# 安装文件
rm -rf spark-3.0.0-preview2-bin-hadoop3.2
tar -xzvf spark-3.0.0-preview2-bin-hadoop3.2.tgz 
# 配置文件spark-env.sh
rm -rf spark-3.0.0-preview2-bin-hadoop3.2/conf/spark-env.sh
cp spark-3.0.0-preview2-bin-hadoop3.2/conf/spark-env.sh.template spark-3.0.0-preview2-bin-hadoop3.2/conf/spark-env.sh
cat << EOF >> spark-3.0.0-preview2-bin-hadoop3.2/conf/spark-env.sh
export SCALA_HOME=/apps/scala-2.12.10/
export JAVA_HOME=$java_home_var
export HADOOP_HOME=/apps/hadoop-3.1.2
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop
export SPARK_HOME=/apps/spark-3.0.0-preview2-bin-hadoop3.2
export SPARK_MASTER_HOST=$spark_master_node_host
export SPARK_LOCAL_IP=$spark_master_node_host
export SPARK_EXECUTOR_MEMORY=1G
EOF
# 配置文件slaves
rm -rf spark-3.0.0-preview2-bin-hadoop3.2/conf/slaves 
for node in ${spark_slave_nodes[@]}; do 
echo "write $node to slaves...";
echo "$node" >> spark-3.0.0-preview2-bin-hadoop3.2/conf/slaves
done 

```
 


* 同步文件  

```BASH

tar -czvf spark-3.0.0-preview2-bin-hadoop3.2_new.tar.gz spark-3.0.0-preview2-bin-hadoop3.2/*
for node in ${spark_nodes[@]}; do 
echo "send to $node ......";
scp spark-3.0.0-preview2-bin-hadoop3.2_new.tar.gz root@$node:/tmp/
ssh root@$node "tar -xzvf /tmp/spark-3.0.0-preview2-bin-hadoop3.2_new.tar.gz -C /apps/"
ssh root@$node "sed -i '/SPARK_HOME_VAR/d' /etc/profile"
ssh root@$node "sed -i '/SPARK_PATH_VAR/d' /etc/profile"
ssh root@$node "echo 'export SPARK_HOME=/apps/spark-3.0.0-preview2-bin-hadoop3.2   # SPARK_HOME_VAR ' >> /etc/profile"
ssh root@$node "echo 'export PATH=\$PATH:\$SPARK_HOME/bin        # SPARK_PATH_VAR ' >> /etc/profile"
# clear install package
ssh root@$node "rm -rf /tmp/spark-3.0.0-preview2-bin-hadoop3.2_new.tar.gz"
done 

rm -rf spark-3.0.0-preview2-bin-hadoop3.2_new.tar.gz

# slave配置文件微调
for node in ${spark_slave_nodes[@]}; do 
ssh root@$node " sed -i '/SPARK_LOCAL_IP=/d' /apps/spark-3.0.0-preview2-bin-hadoop3.2/conf/spark-env.sh"
done 

```

## 启动

```bash
# 启动 spark_master_node上执行 
ssh root@$spark_master_node_host "/apps/spark-3.0.0-preview2-bin-hadoop3.2/sbin/start-all.sh"
```


## 检查

```BASH
# 检查进程是否存在
ssh root@$spark_master_node_host "source /etc/profile && jps | grep Master"

for node in ${spark_slave_nodes[@]}; do 
echo "check work nodes procress: $node"
ssh root@$node "source /etc/profile && jps | grep Worker"
done 

spark-shell --master node1://master:7077

# 访问日志，查看端口为 8080 ，用浏览器访问网页。
http://192.168.2.11:8080/
```



## 卸载

```bash 
for node in ${spark_nodes[@]}; do 
echo "Remove spark from $node...."
ssh root@$node "sed -i '/SCALA_HOME_VAR/d' /etc/profile"
ssh root@$node "sed -i '/SCALA_PATH_VAR/d' /etc/profile"
ssh root@$node "sed -i '/SPARK_HOME_VAR/d' /etc/profile"
ssh root@$node "sed -i '/SPARK_PATH_VAR/d' /etc/profile"
ssh root@$node "source /etc/profile"
rm -rf /apps/spark-3.0.0-preview2-bin-hadoop3.2
rm -rf /apps/scala-2.12.10
rm -rf /tmp/scala-*
done 
```