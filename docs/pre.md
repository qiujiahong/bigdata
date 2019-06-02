#  准备工作

## 允许远程登录 

* 修改文件 /etc/ssh/ssh_config , m1 m2 m3 m4

```bash
# 允许root远程登录
sed -i 's/^#PermitRootLogin.*$/PermitRootLogin yes/g' /etc/ssh/sshd_config  
# 允许密码验证
sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/g' /etc/ssh/sshd_config  
# 允许免密远程登录
sed -i 's/^#PubkeyAuthentication.*$/PubkeyAuthentication yes/g' /etc/ssh/sshd_config  
systemctl restart sshd.service
```

## 配置hosts(m1 m2 m3 m4)

* /etc/hosts  

```bash
cat > /etc/hosts << EOF 
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.20.11 m1
192.168.20.12 m2
192.168.20.13 m3
192.168.20.14 m4
EOF
```

## 配置免密登录

* m1 上执行 

```bash
# 配置ansible ssh密钥登陆  命令后面三个  回车 回车 回车
ssh-keygen -t rsa -b 2048 
# 按照提示输入yes 和root密码
ssh-copy-id root@m1
ssh-copy-id root@m2
ssh-copy-id root@m3
ssh-copy-id root@m4
```


## 关闭防火墙

```

```

 