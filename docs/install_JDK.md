# 安装JDK

## 准备工作

* 准备安装jdk脚本到m1的目录/tmp/jdk.sh , 脚本内容如下

```bash
#!/bin/bash
java_home_var=/apps/jdk/
profile_path=/etc/profile
#profile_path=profile2
# 获得参数传入,输入到 变量 java_home_var start 
if test -n "$1"
then
  java_home_var=$1
fi
# 获得参数传入 end
function handle_null(){
  path_var="";
  echo JAVA_HOME null;
  path_var=$(cat $profile_path | grep 'export PATH=' | awk -F'=' '{print $2}')
  echo path: $path_var
  if test -z "$path_var"
  then
     echo no JAVA_HOME no PATH
     echo "export JAVA_HOME=$java_home_var" >> $profile_path
     echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> $profile_path
  else
     echo no JAVA_HOME have PATH
     path_var=$(cat $profile_path | grep 'export PATH=' | awk -F'=' '{print $2}')
     echo $path_var
     echo "export JAVA_HOME=$java_home_var" >> $profile_path
     sed -i '/^export PATH=/d' $profile_path
     echo "export PATH=\$JAVA_HOME/bin:$path_var" >> $profile_path
  fi
  source $profile_path
  return ;
}

# main 主函数
if test -z "$JAVA_HOME1"
then
  handle_null
else
  echo "have JAVA_HOME. Do nothing";
fi
echo done...
```

* 准备jdk文件到m1,在m1下执行 

```bash
curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O \
 'http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz'
```  


## 分发jdk，并安装

```bash
# 分配文件到其他主机
array=(m2 m3  m4)
for node in ${array[@]}; do 
echo "send to $node ......";
scp /tmp/jdk-8u211-linux-x64.tar.gz root@$node:/tmp
scp /tmp/jdk.sh root@$node:/tmp
done
# 安装
array=(m1 m2 m3  m4)
for node in ${array[@]}; do 
echo "$node ......";
ssh root@$node "mkdir /apps/"
ssh root@$node "tar -xzvf /tmp/jdk-8u211-linux-x64.tar.gz -C /apps/"
ssh root@$node "ln -s /apps/jdk* /apps/jdk"
ssh root@$node "sh /tmp/jdk.sh"
done
```