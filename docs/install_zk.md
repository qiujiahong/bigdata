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

# 配置JAVA_HOME环境变量
array=(node1 node2 node3)
for node in ${array[@]}; do 
echo "$node ......config file";
ssh root@$node   "sed -i '/java_home_var/d' /apps/apache-zookeeper-3.5.6-bin/bin/zkEnv.sh"
ssh root@$node   "sed -i '1 aexport JAVA_HOME=/apps/jdk1.8.0_211  # java_home_var'  /apps/apache-zookeeper-3.5.6-bin/bin/zkEnv.sh"
done
```

## 启动服务

```BASH 
array=(node1 node2 node3)
for node in ${array[@]}; do 
echo "$node ......start zookeeper";
ssh root@$node   "chown -R appuser:appuser   /apps/apache-zookeeper-3.5.6-bin/"
# 注意这里是使用非root启动
ssh appuser@$node   "/apps/apache-zookeeper-3.5.6-bin/bin/zkServer.sh start"
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

array=(node1 node2 node3)
for node in ${array[@]}; do 
echo "$node ......send the systemd file to other nodes.";
scp -r /etc/systemd/system/zookeeper.service root@$node:/etc/systemd/system/
ssh root@$node   "systemctl daemon-reload"
ssh root@$node   "systemctl enable zookeeper"
done 

```

*  启动 
```BASH
array=(node1 node2 node3)
for node in ${array[@]}; do 
echo "$node ......start zookeeper";
ssh root@$node   "systemctl daemon-reload"
ssh root@$node   "systemctl start zookeeper"
done 

```


## 检查状态

```BASH 
array=(node1 node2 node3)
for node in ${array[@]}; do 
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
array=(node1 node2 node3)
for node in ${array[@]}; do 
echo "$node ......stop zookeeper";
ssh root@$node   "systemctl stop zookeeper"
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
