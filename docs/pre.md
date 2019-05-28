#  准备工作

## 允许远程登录

* 修改文件 /etc/ssh/ssh_config 

```bash
# 允许root远程登录
sed -i 's/^#PermitRootLogin.*$/PermitRootLogin yes/g' /etc/ssh/sshd_config  
# 允许密码验证
sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/g' /etc/ssh/sshd_config  
# 允许免密远程登录
sed -i 's/^#PubkeyAuthentication.*$/PubkeyAuthentication yes/g' /etc/ssh/sshd_config  
systemctl restart sshd.service
```

## 配置免密登录


```bash
# 配置ansible ssh密钥登陆  命令后面三个  回车 回车 回车
ssh-keygen -t rsa -b 2048 
# 按照提示输入yes 和root密码
ssh-copy-id root@m1
ssh-copy-id root@m2
ssh-copy-id root@m3
ssh-copy-id root@m4
```
 