---
type: [note]
tags: [Linux] [Centos]
---



**常用命令**

```
# 查看系统版本
cat /etc/centos-release
```


## Centos 7.7

### Setup
https://blog.csdn.net/ly5826/article/details/110002648

### Installation

1. 安装 vcs
https://blog.csdn.net/qq_38113006/article/details/120803926



### Setting

1. 

2. 


### Issue

1. 共享文件夹不挂载

    ```bash
    sudo mkdir /mnt/hgfs
    echo '.host:/ /mnt/hgfs fuse.vmhgfs-fuse allow_other 0 0' | sudo tee -a /etc/fstab
    mount -a
    ```

2. 用户没有 sudo 权限

    ```bash
    # 切换到 root 用户
    su root
    # 添加 sudo 权限
    usermod -aG wheel username
    # 注销并重新登录
    exit
    ```

3. Could not retrieve mirrorlist
