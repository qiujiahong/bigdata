# 准备虚拟机

## 准备虚拟机

* ``mkdir vagrant``创建虚拟机目录


* 准备入下``vagrant/Vagrantfile``脚本


```ruby 
Vagrant.configure("2") do |config|
    config.vm.provision "shell", inline: "echo Hello"
    config.vm.provision "shell", inline: "su"
    config.vm.provision "shell", inline: "sudo echo '123456' | passwd --stdin root "
  
    config.vm.define "node1" do |node1|
        node1.vm.box = "centos/7"
        node1.vm.box_version = "1811.02"
        node1.vm.network "private_network", ip: "192.168.20.11"
        node1.vm.provider "virtualbox" do |v|
          v.memory = 2048
          v.cpus = 2
        end
    end
    
      
      config.vm.define "node2" do |node2|
        node2.vm.box = "centos/7"
        node2.vm.box_version = "1811.02"
        node2.vm.network "private_network", ip: "192.168.20.12"
        node2.vm.provider "virtualbox" do |v|
          v.memory = 2048
          v.cpus = 2
        end
      end
    
      config.vm.define "node3" do |node3|
        node3.vm.box = "centos/7"
        node3.vm.box_version = "1811.02"
        node3.vm.network "private_network", ip: "192.168.20.13"
        node3.vm.provider "virtualbox" do |v|
          v.memory = 2048
          v.cpus = 2
        end
      end
    
      config.vm.define "node4" do |node4|
        node4.vm.box = "centos/7"
        node4.vm.box_version = "1811.02"
        node4.vm.network "private_network", ip: "192.168.20.14"
        node4.vm.provider "virtualbox" do |v|
          v.memory = 2048
          v.cpus = 2
        end
    end
end
```

* 启动服务器   

```
vagrant up 
```

* 依次登录服务器，修改ssh配置  

```bash
# 登录服务器 node1 node2 node3 node4
vagrant ssh node1
# 切换用户
su root
# 修改文件  PasswordAuthentication yes
vi /etc/ssh/sshd_config
# 重启ssh 服务
systemctl restart sshd.service
```

## 配置ssh 免密登录  


* 笔记本添加入下hosts

```
cat <<  EOF >> /etc/hosts
192.168.20.11  node1
192.168.20.12  node2
192.168.20.13  node3
192.168.20.14  node4
EOF
```

* node1上执行

```bash 
ssh-keygen -t rsa
ssh-copy-id  root@node1
ssh-copy-id  root@node2
ssh-copy-id  root@node3
ssh-copy-id  root@node4
```

