


* [大数据基本概念](docs/introduce.md)
* [安装JDK](docs/install_JDK.md)
* [安装HDFS系统](docs/install.md)

<!-- #PermitRootLogin yes -->

less /etc/ssh/ssh_config 

```bash
# 允许root远程登录
sed -i 's/^#PermitRootLogin.*$/PermitRootLogin yes/g' /etc/ssh/sshd_config  
# 允许密码验证
sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/g' /etc/ssh/sshd_config  
# 允许免密远程登录
sed -i 's/^#PubkeyAuthentication.*$/PubkeyAuthentication yes/g' /etc/ssh/sshd_config  
systemctl restart sshd.service
```

```
# 配置ansible ssh密钥登陆
ssh-keygen -t rsa -b 2048 回车 回车 回车
ssh-copy-id $IP #$IP为本虚机地址，按照提示输入yes 和root密码
```
 