# 准备ssh免密登录


* node1~node4添加hosts

```
cat <<  EOF >> /etc/hosts
192.168.20.11  node1
192.168.20.12  node2
192.168.20.13  node3
192.168.20.14  node4
EOF
```

* 笔记本上执行

```bash 
ssh-keygen -t rsa
ssh-copy-id  root@node1
ssh-copy-id  root@node2
ssh-copy-id  root@node3
ssh-copy-id  root@node4
```

