# 准备ssh免密登录


* node1上执行添加hosts

```bash

cat <<  EOF >> /etc/hosts
10.170.0.7   node1
10.170.0.8  node2
10.170.0.9  node3
10.170.0.10 node4
EOF

# 配置秘钥
ssh-keygen -t rsa
ssh-copy-id root@node1
ssh-copy-id root@node2
ssh-copy-id root@node3
ssh-copy-id root@node4


# 分发host到其他节点
array=(node2 node3 node4)
for node in ${array[@]}; do 
echo "$node ......";
ssh root@$node "echo '10.170.0.7   node1' >> /etc/hosts"
ssh root@$node "echo '10.170.0.8   node2' >> /etc/hosts"
ssh root@$node "echo '10.170.0.9   node3' >> /etc/hosts"
ssh root@$node "echo '10.170.0.10   node4' >> /etc/hosts"
done

```

