# 安装HDFS系统

## 规划

在node1、node2、node3上安装hadoop，其中：
* dfs.namenode.secondary  node2 
* fs.default.name         node1
* hdfs_data_nodes         node1、node2、node3



## 上传文件到服务器

* 下载文件hadoop-3.2.1.tar.gz  

```bash
# wget http://archive.apache.org/dist/hadoop/common/hadoop-3.2.1/hadoop-3.1.2.tar.gz
wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
```

## 安装

* node1上执行

```BASH   

tar -xzvf hadoop-3.2.1.tar.gz -C /apps
rm -rf /apps/hadoop-3.2.1/share/doc/
rm -rf /apps/hadoop-3.2.1/*.txt
rm -rf /data/hadoop
mkdir -p /data/hadoop/name/
mkdir -p /data/hadoop/data/

# 自定义配置文件 /apps/hadoop-3.2.1/etc/hadoop/param.sh
cat << 'EOF' > /apps/hadoop-3.2.1/etc/hadoop/param.sh
export hdfs_name_node=node1
export hdfs_name_node2=node2
export hdfs_data_nodes=(node1 node2 node3)
export hdfs_nodes=(node1 node2 node3)
export java_home_var=/apps/jdk1.8.0_211
EOF

source /apps/hadoop-3.2.1/etc/hadoop/param.sh

# /apps/hadoop-3.2.1/sbin/start-dfs.sh  开始文件，配置启动用户
sed -i '/^HDFS_DATANODE_USER.*/d' /apps/hadoop-3.2.1/sbin/start-dfs.sh
sed -i '/^HDFS_DATANODE_SECURE_USER.*/d' /apps/hadoop-3.2.1/sbin/start-dfs.sh
sed -i '/^HDFS_NAMENODE_USER.*/d' /apps/hadoop-3.2.1/sbin/start-dfs.sh
sed -i '/^HDFS_SECONDARYNAMENODE_USER.*/d' /apps/hadoop-3.2.1/sbin/start-dfs.sh

sed -i '17 aHDFS_DATANODE_USER=appuser'  /apps/hadoop-3.2.1/sbin/start-dfs.sh
sed -i '17 aHDFS_DATANODE_SECURE_USER=appuser'  /apps/hadoop-3.2.1/sbin/start-dfs.sh
sed -i '17 aHDFS_NAMENODE_USER=appuser'  /apps/hadoop-3.2.1/sbin/start-dfs.sh
sed -i '17 aHDFS_SECONDARYNAMENODE_USER=appuser'  /apps/hadoop-3.2.1/sbin/start-dfs.sh

# /apps/hadoop-3.2.1/sbin/stop-dfs.sh  开始文件，配置启动用户
sed -i '/^HDFS_DATANODE_USER.*/d' /apps/hadoop-3.2.1/sbin/stop-dfs.sh
sed -i '/^HDFS_DATANODE_SECURE_USER.*/d' /apps/hadoop-3.2.1/sbin/stop-dfs.sh
sed -i '/^HDFS_NAMENODE_USER.*/d' /apps/hadoop-3.2.1/sbin/stop-dfs.sh
sed -i '/^HDFS_SECONDARYNAMENODE_USER.*/d' /apps/hadoop-3.2.1/sbin/stop-dfs.sh

sed -i '17 aHDFS_DATANODE_USER=appuser'  /apps/hadoop-3.2.1/sbin/stop-dfs.sh
sed -i '17 aHDFS_DATANODE_SECURE_USER=appuser'  /apps/hadoop-3.2.1/sbin/stop-dfs.sh
sed -i '17 aHDFS_NAMENODE_USER=appuser'  /apps/hadoop-3.2.1/sbin/stop-dfs.sh
sed -i '17 aHDFS_SECONDARYNAMENODE_USER=appuser'  /apps/hadoop-3.2.1/sbin/stop-dfs.sh


# 配置文件 /apps/hadoop-3.2.1/etc/hadoop/core-site.xml
cat << EOF > /apps/hadoop-3.2.1/etc/hadoop/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->
<configuration>
  <property>  
    <name>hadoop.tmp.dir</name>
    <value>file:/data/hadoop/tmp</value>
  </property>
  <property>
    <name>io.file.buffer.size</name>
    <value>131072</value>
  </property>
  <property>
    <!-- name>fs.dfaultFS</name -->
    <name>fs.default.name</name>
    <!-- <value>hdfs://m1:9000</value> -->
    <value>hdfs://${hdfs_name_node}:9000</value>
  </property>
  <!-- <property>
    <name>hadoop.proxyuser.root.hosts</name>
    <value>*</value>
  </property>
  <property>
    <name>hadoop.proxyuser.root.groups</name>
    <value>*</value>
  </property> -->
</configuration>
EOF

# 配置文件 /apps/hadoop-3.2.1/etc/hadoop/core-site.xml
cp /apps/hadoop-3.2.1/etc/hadoop/hadoop-env.sh /apps/hadoop-3.2.1/etc/hadoop/hadoop-env.sh.bak
cat << EOF > /apps/hadoop-3.2.1/etc/hadoop/hadoop-env.sh
export JAVA_HOME=${java_home_var}
export HADOOP_OS_TYPE=\${HADOOP_OS_TYPE:-\$(uname -s)}
EOF

# 配置文件 /apps/hadoop-3.2.1/etc/hadoop/hdfs-site.xml
cat << EOF >  /apps/hadoop-3.2.1/etc/hadoop/hdfs-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <!-- <property>
    <name>dfs.replication</name>
    <value>2</value>
  </property> -->
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/data/hadoop/name</value>
  </property>
  <property>
    <name>dfs.namenode.data.dir</name>
    <value>/data/hadoop/data</value>
  </property>
  <property>
    <name>dfs.namenode.secondary.http-address</name>
    <value>${hdfs_name_node2}:50090</value>
  </property>  
  <!-- <property>
    <name>dfs.webhdfs.enabled</name>
    <value>true</value>
  </property>  
  <property>
    <name>dfs.permissions</name>
    <value>false</value>
  </property>     -->
</configuration>
EOF

cat << EOF > /apps/hadoop-3.2.1/etc/hadoop/mapred-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <!-- <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property> -->
</configuration>
EOF

# /apps/hadoop-3.2.1/etc/hadoop/workers 
rm -rf /apps/hadoop-3.2.1/etc/hadoop/workers &&  touch /apps/hadoop-3.2.1/etc/hadoop/workers
for node in ${hdfs_nodes[@]}; do 
echo $node >> /apps/hadoop-3.2.1/etc/hadoop/workers 
done

# 配置hdfs_home
for node in ${hdfs_data_nodes[@]}; do 
echo "send to $node ......";
ssh root@$node "sed -i '/HDAOOP_HOME_VAR/d' /etc/profile"
ssh root@$node "sed -i '/HDAOOP_PATH_VAR/d' /etc/profile"
ssh root@$node "echo 'export HADOOP_HOME=/apps/hadoop-3.2.1  # HDAOOP_HOME_VAR ' >> /etc/profile"
ssh root@$node "echo 'export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin  # HDAOOP_PATH_VAR ' >> /etc/profile"
ssh root@$node "source /etc/profile"
done


# 同步数据到点2、3
cd /apps/
rm -rf hadoop-3.2.1_new.tar.gz
tar -czvf hadoop-3.2.1_new.tar.gz hadoop-3.2.1/*
unset array
array=(node2 node3 )
for node in ${array[@]}; do 
echo "send to $node ......";
ssh root@$node "rm -rf /apps/hadoop-3.2.1 "
ssh root@$node "rm -rf hadoop-3.2.1_new.tar.gz "
scp  hadoop-3.2.1_new.tar.gz  root@$node:~
ssh root@$node "tar -xzvf  hadoop-3.2.1_new.tar.gz -C /apps"
ssh root@$node "rm -rf /data/hadoop/ "
ssh root@$node "rm -rf hadoop-3.2.1_new.tar.gz "
ssh root@$node "mkdir -p /data/hadoop/name/ "
ssh root@$node "mkdir -p /data/hadoop/data/ "
done
rm -rf hadoop-3.2.1_new.tar.gz

# 修改文件权限
for node in ${hdfs_nodes[@]}; do 
echo "clear $node . set owner of the files ......";
ssh root@$node   "chown -R appuser:appuser   /apps/hadoop-3.2.1/"
ssh root@$node   "chown -R appuser:appuser   /data/hadoop/"
ssh root@$node   "rm -rf    /data/hadoop/data/*"
ssh root@$node   "rm -rf    /data/hadoop/name/*"
done

```

## 启动

```bash 
source /apps/hadoop-3.2.1/etc/hadoop/param.sh
# 格式化namenode，如果是重启，则不需要执行
echo "format the namenode............................................."
ssh appuser@$hdfs_name_node "/apps/hadoop-3.2.1/bin/hdfs namenode -format"
sleep 10

# 3.启动hdfs集群,打开hdfs集群，在namenode上执行，需要namenode到datanode做了免密登录
source /etc/profile
start-dfs.sh
```

## 检查

* 命令检查
```bash

hdfs dfsadmin -report

source /apps/hadoop-3.2.1/etc/hadoop/param.sh
# 检查进程
echo "$hdfs_name_node NameNode:"
ssh root@$hdfs_name_node "/apps/jdk1.8.0_211/bin/jps | grep NameNode"

echo " @$hdfs_name_node2 SecondaryNameNode:"
ssh root@$hdfs_name_node2 "/apps/jdk1.8.0_211/bin/jps | grep SecondaryNameNode"

for node in ${hdfs_data_nodes[@]}; do 
echo "${node} DataNode:"
ssh root@$node " /apps/jdk1.8.0_211/bin/jps | grep DataNode"
done 

```

* 页面检查  

```bash 
#访问页面: http://192.168.2.11:9870 (其中ip是namenode的地址),在该网页上能够看到datanode状态及容量。或者使用命令
curl http://127.0.0.1:9870
```

* 存储文件检查,更多命令详细看[HDFS客户端](command.md)   

```bash 
su appuser 
# 创建一个文件夹，在查看该目录
hadoop fs -mkdir  -p /aaa/bbb
hadoop fs -ls /aaa
# 写入一个文件，然后再查看文件
cd /data/hadoop
echo "1111www" > 1.file 
hadoop fs -put 1.file  /aaa/bbb
hadoop fs -ls /aaa/bbb
hadoop fs -cat /aaa/bbb/1.file
```

## 停止

```bash 
# 关闭hdfs集群，在namenode[node1]上执行，需要namenode到datanode做了免密登录
stop-dfs.sh
```

## 卸载

```bash

for node in ${hdfs_nodes[@]}; do 
echo "send to $node ......";
ssh root@$node "sed -i '/HDAOOP_HOME_VAR/d' /etc/profile"
ssh root@$node "sed -i '/HDAOOP_PATH_VAR/d' /etc/profile"
ssh root@$node "rm -rf /apps/hadoop-3.2.1/"
ssh root@$node "rm -rf /data/hadoop/"
ssh root@$node "source /etc/profile"
done  

```

## 其他命令

```BASH
# 关闭hdfs集群，在namenode上执行，需要namenode到datanode做了免密登录
stop-dfs.sh
# 打开hdfs集群，在namenode上执行，需要namenode到datanode做了免密登录
start-dfs.sh
# 启动namenode 
hdfs --daemon start namenode
# 启动datanode 
hdfs --daemon start datanode
# 停止namenode 
hdfs --daemon start namenode
# 停止datanode 
hdfs --daemon start datanode
hdfs --daemon start secondarynamenode
hdfs --daemon stop secondarynamenode
```