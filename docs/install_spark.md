# 安装spark



## 计划


## 上传文件 

```BASH 
wget https://downloads.lightbend.com/scala/2.12.10/scala-2.12.10.tgz
wget http://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-3.0.0-preview2/spark-3.0.0-preview2-bin-hadoop3.2.tgz
```


## 安装 

* 自定义配置文件  

```BASH 
# 自定义配置文件 /apps/hadoop-3.1.2/etc/hadoop/param.sh
mkdir -p /root/param/
cat << 'EOF' > /root/param/spark.sh
export spark_master_node_host=node1
export spark_slave_nodes=(node2 node3)
export spark_nodes=(node1 node2 node3)
export java_home_var=/apps/jdk1.8.0_211
EOF
source /root/param/spark.sh

 

* 同步文件  

```BASH
for node in ${spark_nodes[@]}; do 
echo "send to $node ......";
scp scala-2.12.10.tgz root@node:/tmp/
scp spark-3.0.0-preview2-bin-hadoop3.2.tgz root@node:/tmp/
scp /root/param/spark.sh root@node:/tmp/

# ssh root@$node "sed -i '/hdfs_home_var/d' /etc/profile"
done  
```


* 安装scala 

```bash 
tar -xzvf scala-2.12.10.tgz  -C /apps/
# 添加scala 环境变量
sed -i '/SCALA_HOME_VAR/d' /etc/profile
sed -i '/SCALA_PATH_VAR/d' /etc/profile
echo "export SCALA_HOME=/apps/scala-2.12.10/  # SCALA_HOME_VAR " >> /etc/profile
echo "export PATH=\$PATH:\$SCALA_HOME/bin  # SCALA_PATH_VAR " >> /etc/profile
source /etc/profile
# 验证是否安装成功，如果安装成功，则返回成功
scala -version

```


* 安装spark   

```bash
tar -xzvf spark-3.0.0-preview2-bin-hadoop3.2.tgz -C /apps/
# SPARK_HOME
sed -i '/SPARK_HOME_VAR/d' /etc/profile
sed -i '/SPARK_PATH_VAR/d' /etc/profile
echo "export SPARK_HOME=/apps/spark-3.0.0-preview2-bin-hadoop3.2/  # SPARK_HOME_VAR " >> /etc/profile
echo "export PATH=\$PATH:\$SPARK_HOME/bin  # SPARK_PATH_VAR " >> /etc/profile
source /etc/profile

# 配置文件
rm -rf /apps/spark-3.0.0-preview2-bin-hadoop3.2/conf/spark-env.sh
cp /apps/spark-3.0.0-preview2-bin-hadoop3.2/conf/spark-env.sh.template /apps/spark-3.0.0-preview2-bin-hadoop3.2/conf/spark-env.sh
cat << EOF >> /apps/spark-3.0.0-preview2-bin-hadoop3.2/conf/spark-env.sh
export SCALA_HOME=/apps/scala-2.12.10/
export JAVA_HOME=$java_home_var
export HADOOP_HOME=/apps/hadoop-3.1.2/
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop
export SPARK_HOME=/apps/spark-3.0.0-preview2-bin-hadoop3.2/
export SPARK_MASTER_HOST=$spark_master_node_host
export SPARK_LOCAL_IP=$spark_master_node_host
export SPARK_EXECUTOR_MEMORY=1G
EOF

```


## 启动


## 检查

```BASH
# 访问日志，查看端口为 8080 ，用浏览器访问网页。
http://192.168.2.11:8080/
```



## 卸载

```bash 
for node in @{spark_nodes[@]}; do 
sed -i '/SCALA_HOME_VAR/d' /etc/profile
sed -i '/SCALA_PATH_VAR/d' /etc/profile
sed -i '/SPARK_HOME_VAR/d' /etc/profile
sed -i '/SPARK_PATH_VAR/d' /etc/profile
source /etc/profile
rm -rf /apps/spark-3.0.0-preview2-bin-hadoop3.2/
rm -rf /apps/scala-2.12.10/
done 
```