---
type: [note]
tags: [Windows]
---


**常用命令**

一.	CMD
1.	常用命令
**关机、重启、注销、休眠、定时**
关机：shutdown /s
重启：shutdown /r
注销：shutdown /l
休眠：shutdown /h /f
取消关机：shutdown /a
定时关机：shutdown /s /t 3600（3600 秒后关机）
**目录操作**
切换目录，进入指定文件夹：
切换磁盘：（盘符名词+冒号）d:（进入d盘）
切换磁盘和目录：cd /d e:/test（进入e盘 test 文件夹）
进入文件夹：cd \test1\test2（进入 test2 文件夹）
返回根目录：cd \
回到上级目录：cd ..
新建文件夹：md test
显示目录内容：
显示目录中文件列表：dir
显示目录结构：tree d:\test（d 盘 test 目录）
显示当前目录位置：cd


1. [去掉创建快捷方式时的「-快捷方式」后缀与左下角的小箭头](https://zhuanlan.zhihu.com/p/652889824)
2. [Win10复制文件怎么去掉默认命名副本两字](https://www.jb51.net/os/win10/415369.html)
3. cmd 查看ip的国家
    curl cip.cc
