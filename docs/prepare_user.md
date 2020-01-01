
# 应用用户

```bash
# 执行如下名创建应用用户
array=(node1 node2 node3 node4)
for node in ${array[@]}; do 
echo "$node ......";
ssh root@$node "groupadd appuser"
ssh root@$node "useradd -g appuser appuser"
ssh root@$node "mkdir -p /apps"
done



array=(node1 node2 node3 node4)
for node in ${array[@]}; do 
echo "$node ......";
ssh root@$node "groupadd appuser"
ssh root@$node "useradd -g appuser appuser"
ssh root@$node "mkdir -p /apps"
ssh root@$node "echo '123456' | passwd --stdin appuser "
done

# 配置秘钥 node1上root执行
ssh-copy-id appuser@node1
ssh-copy-id appuser@node2
ssh-copy-id appuser@node3
ssh-copy-id appuser@node4

# 配置秘钥 node1上appuser执行
su appuser
ssh-keygen -t rsa
ssh-copy-id appuser@node1
ssh-copy-id appuser@node2
ssh-copy-id appuser@node3
ssh-copy-id appuser@node4
exit

```
