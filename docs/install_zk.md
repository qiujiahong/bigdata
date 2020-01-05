# 安装zk

## 规划

在node1、node2、node3上安装zk 

## 上传文件到服务器

* [apache-zookeeper-3.5.6-bin.tar.gz](http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.5.6/apache-zookeeper-3.5.6-bin.tar.gz)

```
wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.5.6/apache-zookeeper-3.5.6-bin.tar.gz
```

## 安装 

```bash 
#  安装zk,准备文件(控制机上执行) 
## 自定义配置文件 
cat << 'EOF' > param_zk.sh
export zk_nodes=(node1 node2 node3)
export java_home_var=/apps/jdk1.8.0_211
EOF
source param_zk.sh

rm -rf apache-zookeeper-3.5.6-bin
tar -xzvf apache-zookeeper-3.5.6-bin.tar.gz
mkdir -p apache-zookeeper-3.5.6-bin/data
mkdir -p apache-zookeeper-3.5.6-bin/logs

# zkEnv.sh
sed -i "/java_home_var/d" apache-zookeeper-3.5.6-bin/bin/zkEnv.sh
sed -i "1 aexport JAVA_HOME=$java_home_var  # java_home_var"  apache-zookeeper-3.5.6-bin/bin/zkEnv.sh

cat << EOF > apache-zookeeper-3.5.6-bin/conf/zoo.cfg
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/apps/apache-zookeeper-3.5.6-bin/data
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1
dataLogDir=/apps/apache-zookeeper-3.5.6-bin/logs
EOF

for((i=1;i<=${#zk_nodes[*]};i++)); do 
  num=$(($i-1))
  echo "${zk_nodes[$num]}......start";
  echo "server.$i=${zk_nodes[$num]}:2888:3888" >> apache-zookeeper-3.5.6-bin/conf/zoo.cfg
done ;

```

```bash 
# 同步文件 
rm -rf apache-zookeeper-3.5.6-bin_new.tar.gz
tar -czvf apache-zookeeper-3.5.6-bin_new.tar.gz apache-zookeeper-3.5.6-bin/*
for node in ${zk_nodes[@]}; do 
echo "send to $node ......";
scp apache-zookeeper-3.5.6-bin_new.tar.gz root@$node:/tmp/
ssh root@$node "tar -xzvf /tmp/apache-zookeeper-3.5.6-bin_new.tar.gz -C /apps/"
ssh root@$node "sed -i '/ZOOKEEPER_HOME_VAR/d' /etc/profile"
ssh root@$node "sed -i '/ZOOKEEPER_PATH_VAR/d' /etc/profile"
ssh root@$node "echo 'export ZOOKEEPER_HOME=/apps/apache-zookeeper-3.5.6-bin/   # ZOOKEEPER_HOME_VAR ' >> /etc/profile"
ssh root@$node "echo 'export PATH=\$PATH:\$ZOOKEEPER_HOME/bin                     # ZOOKEEPER_PATH_VAR ' >> /etc/profile"
# clear install package
ssh root@$node "rm -rf /tmp/apache-zookeeper-3.5.6-bin_new.tar.gz"
done 
rm -rf spark-3.0.0-preview2-bin-hadoop3.2_new.tar.gz

# myid
for((i=1;i<=${#zk_nodes[*]};i++)); do 
  num=$(($i-1))
  echo "${zk_nodes[$num]}......start";
  ssh root@${zk_nodes[$num]} "echo $i > /apps/apache-zookeeper-3.5.6-bin/data/myid"
done ;

# 修改文件所有权
for node in ${zk_nodes[@]}; do 
echo "$node ......start zookeeper";
ssh root@$node   "chown -R appuser:appuser   /apps/apache-zookeeper-3.5.6-bin/"
done 

```



## 设置开机启动 

* 编辑启动文件``/etc/systemd/system/zookeeper.service``   

```bash  
cat << EOF > /etc/systemd/system/zookeeper.service
[Unit]
Description=zookeeper.service
After=network.target
[Service]
Type=forking
Environment=ZOO_LOG_DIR=/apps/apache-zookeeper-3.5.6-bin/logs
Environment=PATH=/apps/jdk1.8.0_211/bin:/apps/jdk1.8.0_211/jre/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/root/bin
ExecStart=/apps/apache-zookeeper-3.5.6-bin/bin/zkServer.sh start
ExecStop=/apps/apache-zookeeper-3.5.6-bin/bin/zkServer.sh stop
ExecReload=/apps/apache-zookeeper-3.5.6-bin/bin/zkServer.sh restart
PIDFile=/apps/apache-zookeeper-3.5.6-bin/data/zookeeper_server.pid
User=appuser
[Install]
WantedBy=multi-user.target
EOF

for node in ${zk_nodes[@]}; do 
echo "$node ......send the systemd file to other nodes.";
scp -r /etc/systemd/system/zookeeper.service root@$node:/etc/systemd/system/
ssh root@$node   "systemctl daemon-reload"
ssh root@$node   "systemctl enable zookeeper"
done 

```

##  启动服务
```BASH
for node in ${zk_nodes[@]}; do 
echo "$node ......start zookeeper";
ssh root@$node   "systemctl daemon-reload"
ssh root@$node   "systemctl start zookeeper"
done 

```


## 检查状态

```BASH 
for node in ${zk_nodes[@]}; do 
echo "$node ...............check zookeeper status......................";
ssh root@$node   "/apps/jdk1.8.0_211/bin/jps | grep QuorumPeerMain"
ssh root@$node   "/apps/apache-zookeeper-3.5.6-bin/bin/zkServer.sh status"
ssh root@$node   "systemctl status zookeeper"
echo "$node ................check zookeeper status end..................";
echo ""
echo ""
done
```

## 停止服务

```BASH 
# systemd关闭zookeeper
for node in ${zk_nodes[@]}; do 
echo "$node ......stop zookeeper";
ssh root@$node   "systemctl stop zookeeper"
done 
```

## 卸载

```bash

for node in ${zk_nodes[@]}; do 
echo "$node ......stop zookeeper";
ssh root@$node "rm -rf apache-zookeeper-3.5.6-bin.tar.gz"
ssh root@$node "rm -rf /apps/apache-zookeeper-3.5.6-bin/"
ssh root@$node "systemctl stop zookeeper"
ssh root@$node "systemctl disable zookeeper"
ssh root@$node "rm -rf /etc/systemd/system/zookeeper.service"
ssh root@$node "systemctl daemon-reload"
ssh root@$node "sed -i '/ZOOKEEPER_HOME_VAR/d' /etc/profile"
ssh root@$node "sed -i '/ZOOKEEPER_PATH_VAR/d' /etc/profile"
done 

```  
