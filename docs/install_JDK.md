# 安装JDK

## 准备工作

* 准备安装包``jdk-8u211-linux-x64.tar.gz``，上传到root目录下
* 准备安装jdk脚本到node1的目录/root/jdk.sh , 脚本内容如下

```bash
cat << 'EOF' > /root/jdk.sh
mkdir -p /apps
tar -xzvf jdk-8u211-linux-x64.tar.gz -C /apps/
sed -i '/java_home_var/d' /etc/profile
sed -i '/java_path_var/d' /etc/profile
echo "export JAVA_HOME=/apps/jdk1.8.0_211  # java_home_var " >> /etc/profile
echo "export PATH=\$PATH:\$JAVA_HOME/bin  # java_path_var " >> /etc/profile
source /etc/profile
EOF
chmod +x jdk.sh

```


## 分发JDK，并安装

```bash
# 分配文件到其他主机
array=(node2 node3 node4)
for node in ${array[@]}; do 
echo "send to $node ......";
scp jdk-8u211-linux-x64.tar.gz root@$node:/root
scp jdk.sh root@$node:/root
done
# 安装
array=(node1 node2 node3 node4)
for node in ${array[@]}; do 
echo "$node ......";
ssh root@$node "sh ./jdk.sh"
done
```



