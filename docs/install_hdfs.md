# 安装HDFS系统

## 计划

在node1、node2、node3上安装hadoop，其中：
* dfs.namenode.secondary  node2 
* fs.default.name         node1
* hdfs_data_nodes         node1、node2、node3




## 上传文件

* 下载文件hadoop-3.1.2.tar.gz  

```bash
wget http://archive.apache.org/dist/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz
```

## 安装

* node1上执行

```BASH   

tar -xzvf hadoop-*.tar.gz -C /apps
rm -rf /apps/hadoop-3.1.2/share/doc/
rm -rf /apps/hadoop-3.1.2/*.txt

mkdir -p /data/hadoop/name/
mkdir -p /data/hadoop/data/

# 自定义配置文件 /apps/hadoop-3.1.2/etc/hadoop/param.sh
cat << 'EOF' > /apps/hadoop-3.1.2/etc/hadoop/param.sh
export hdfs_name_node=node1
export hdfs_name_node2=node2
export hdfs_data_nodes=(node1 node2 node3)
# hdfs_name_node hdfs_data_nodes 合并
export hdfs_nodes=(node1 node2 node3)
export java_home_var=/apps/jdk1.8.0_211
EOF

source /apps/hadoop-3.1.2/etc/hadoop/param.sh

# 配置文件 /apps/hadoop-3.1.2/etc/hadoop/core-site.xml
cat << EOF > /apps/hadoop-3.1.2/etc/hadoop/core-site.xml
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

# 配置文件 /apps/hadoop-3.1.2/etc/hadoop/core-site.xml
cp /apps/hadoop-3.1.2/etc/hadoop/hadoop-env.sh /apps/hadoop-3.1.2/etc/hadoop/hadoop-env.sh.bak
cat << 'EOF' > /apps/hadoop-3.1.2/etc/hadoop/hadoop-env.sh
export JAVA_HOME=${java_home_var}
export HADOOP_OS_TYPE=${HADOOP_OS_TYPE:-$(uname -s)}
EOF
sed -i s@\${java_home_var}@$java_home_var@g /apps/hadoop-3.1.2/etc/hadoop/hadoop-env.sh

# 配置文件 /apps/hadoop-3.1.2/etc/hadoop/hdfs-site.xml
cat << EOF >  /apps/hadoop-3.1.2/etc/hadoop/hdfs-site.xml
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

cat << EOF > /apps/hadoop-3.1.2/etc/hadoop/mapred-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <!-- <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property> -->
</configuration>
EOF

# 配置hdfs_home
array=(node1 node2 node3 )
for node in ${array[@]}; do 
echo "send to $node ......";
ssh root@$node "sed -i '/hdfs_home_var/d' /etc/profile"
ssh root@$node "sed -i '/hdfs_path_var/d' /etc/profile"
ssh root@$node "echo 'export HADOOP_HOME=/apps/hadoop-3.1.2  # hdfs_home_var ' >> /etc/profile"
ssh root@$node "echo 'export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin  # hdfs_path_var ' >> /etc/profile"
ssh root@$node "source /etc/profile"
done




# 同步数据到点2、3
cd /apps/
rm -rf hadoop-3.1.2_new.tar.gz
tar -czvf hadoop-3.1.2_new.tar.gz hadoop-3.1.2/*
array=(node2 node3 )
for node in ${array[@]}; do 
echo "send to $node ......";
ssh root@$node "rm -rf /apps/hadoop-3.1.2 "
ssh root@$node "rm -rf hadoop-3.1.2_new.tar.gz "
scp  hadoop-3.1.2_new.tar.gz  root@$node:~
ssh root@$node "tar -xzvf  hadoop-3.1.2_new.tar.gz -C /apps"
ssh root@$node "mkdir -p /data/hadoop/name/ "
ssh root@$node "mkdir -p /data/hadoop/data/ "
done
rm -rf hadoop-3.1.2_new.tar.gz

# 
# array=(node2 node3 )
# for node in ${array[@]}; do 
# echo "send to $node ......";
# ssh root@$node "ls /apps"
# done

```

## 启动

```bash 
# 修改文件权限
# array=(node1 node2 node3 )
array=${hdfs_nodes[@]}
for node in ${array[@]}; do 
echo "clear $node . set owner of the files ......";
ssh root@$node   "chown -R appuser:appuser   /apps/hadoop-3.1.2/"
ssh root@$node   "chown -R appuser:appuser   /data/hadoop/"
ssh root@$node   "rm -rf    /data/hadoop/data/*"
ssh root@$node   "rm -rf    /data/hadoop/name/*"
done

# 3.启动hdfs集群,打开hdfs集群，在namenode上执行，需要namenode到datanode做了免密登录
sudo appuser
start-dfs.sh

# source /apps/hadoop-3.1.2/etc/hadoop/param.sh
# echo "wait for 10 seconds before format............................................."
# sleep 10
# ssh appuser@$hdfs_name_node "/apps/hadoop-3.1.2/bin/hdfs namenode -format"
# echo "wait for 5 seconds start hdfs............................................."
# sleep 10
# echo "start namenode............................................."
# ssh appuser@$hdfs_name_node "/apps/hadoop-3.1.2/bin/hdfs --daemon start namenode && /apps/jdk1.8.0_211/bin/jps | grep NameNode"
# sleep 5

# echo "start secondnamenode............................................."
# ssh appuser@$hdfs_name_node2 "/apps/hadoop-3.1.2/bin/hdfs --daemon start secondarynamenode && /apps/jdk1.8.0_211/bin/jps | grep SecondaryNameNode"

# echo "start datanode............................................."
# for node in ${hdfs_data_nodes[@]}; do 
# ssh appuser@$node "/apps/hadoop-3.1.2/bin/hdfs --daemon start  datanode | /apps/jdk1.8.0_211/bin/jps | grep DataNode"
# done 
```

## 检查

* 命令检查
```bash

source /apps/hadoop-3.1.2/etc/hadoop/param.sh
echo "check the NameNode ............................................."
ssh appuser@$hdfs_name_node "/apps/jdk1.8.0_211/bin/jps | grep NameNode"

echo "check the SecondaryNameNode............................................."
ssh appuser@$hdfs_name_node2 "/apps/jdk1.8.0_211/bin/jps | grep SecondaryNameNode"

echo "check the DataNode............................................."
for node in ${hdfs_data_nodes[@]}; do 
echo "${node}"
ssh appuser@$node " /apps/jdk1.8.0_211/bin/jps | grep DataNode"
done 
echo "check end............................................."

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

array=(node1 node2 node3 )
for node in ${array[@]}; do 
echo "send to $node ......";
ssh root@$node "sed -i '/hdfs_home_var/d' /etc/profile"
ssh root@$node "sed -i '/hdfs_path_var/d' /etc/profile"
ssh root@$node "rm -rf /apps/hadoop-3.1.2/"
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