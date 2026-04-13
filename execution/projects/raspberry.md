---
type: [note]
tags: [Embedded] [Raspberry]
---

## Raspberry Pi 4B

1. 烧写镜像

    下载树莓派镜像烧录软件：https://www.raspberrypi.com/software/
    选择镜像，选择sd卡。设置(右下角图标):打开ssh，wifi。
    烧录(烧录完后不要格式化!!)

2. 固定IP

    (无屏幕)上电。等待30秒。用IP扫描软件确定树莓派IP地址。用ssh连接树莓派:
    用户名：pi
    密码：raspberry (默认) 在烧录镜像可配置

    固定IP：(编辑文件/etc/dhcpcd.conf)
    `sudo nano /etc/dhcpcd.conf`
    有线配置：
    ```
    interface eth0
    static ip_address=192.168.1.109/24
    static routers=192.168.1.1
    static domian_name_servers=114.114.114.114 8.8.8.8
    ```
    (114.114.114.114是国内的较快速的DNS服务器 8.8.8.8 是谷歌的DNS服务器)
    无线配置：
    ```
    interface wlan0
    static ip_address=192.168.1.110/24
    static routers=192.168.1.1
    static domian_name_servers=114.114.114.114 8.8.8.8
    ```

3. 修改resolv.config文件(域名 系统解析器(DNS Resolver))

    `sudo nano /etc/resolv.conf`: (全部删除，改为：)
    ```
    nameserver 114.114.114.114
    nameserver 8.8.8.8
    ```

4. 更新源

    https://blog.csdn.net/weixin_45469072/article/details/124054729
    https://zhuanlan.zhihu.com/p/662655035

    ```bash
    # 备份
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo cp /etc/apt/sources.list.d/raspi.list /etc/apt/sources.list.d/raspi.list.bak
    # 查看系统架构、版本
    uname -m
    lsb_release  -a
    ```

    - Bullseye

        修改/etc/apt/sources.list (用清华源)(软件更新源)
        `sudo nano /etc/apt/sources.list`
        (编辑sources.list文件，删除原文件所有内容，用以下内容取代：)
        ```
        deb [arch=armhf] http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ bullseye main non-free contrib rpi
        deb-src http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ bullseye main non-free contrib rpi
        ```
        修改/etc/apt/sources.d/raspi.list(软件更新源)
        `sudo nano /etc/apt/sources.list.d/raspi.list`
        (编辑raspi.list文件，删除原文件所有内容，用以下内容取代：)
        `deb http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ bullseye main`

    - Debian 12 aarch64

        修改/etc/apt/sources.list (用清华源)(软件更新源)
        `sudo nano /etc/apt/sources.list`
        (编辑sources.list文件，删除原文件所有内容，用以下内容取代：)
        ```
        deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
        deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
        ```
        修改/etc/apt/sources.d/raspi.list(软件更新源)
        `sudo nano /etc/apt/sources.list.d/raspi.list`
        (编辑raspi.list文件，删除原文件所有内容，用以下内容取代：)
        `deb https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ bookworm main`

    更新
    `sudo apt-get update && sudo apt-get upgrade`
    <br>
    > ~~清华源公钥：
      首先，运行以下命令获取清华大学 raspbian 软件源的公钥：
      gpg --recv-keys --keyserver keyserver.ubuntu.com 9165938D90FDDD2E
      接下来，将公钥添加到 APT 的密钥环中：
      gpg --export --armor 9165938D90FDDD2E | sudo apt-key add -
      或者，你也可以使用 apt-key 工具：
      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9165938D90FDDD2E~~

    > 报错:
    > Reading package lists... Done
    > E: Could not get lock /var/lib/apt/lists/lock. It is held by process 1424 (packagekitd)
    > N: Be aware that removing the lock file is not a solution and may break your system.
    > E: Unable to lock directory /var/lib/apt/lists/
    > 结束进程：sudo kill -9 1424

5. 安装NTP进行自动对时

    ```bash
    # 安装NTP：
    sudo apt-get install ntpdate
    # 启用NTP：
    sudo timedatectl set-ntp true
    # 修改本地时区：在这一步，选择“Asia->Shanghai”
    sudo dpkg-reconfigure tzdata
    # 查看时间是否正确：
    date
    ```

6. 打开VNC，设置分辨率，扩大磁盘空间

    `sudo raspi-config` - 进入配置界面，进行如下设置:

        VNC: Interfacing Options -> VNC
        设置分辨率： Display Options -> Reloluation
                   Display Options -> VNC Resolution
        扩大磁盘空间： Advancd Options -> Expand Filesystem
        打开串口终端： Interfacing Options ->  Serial Port

    重启系统: `reboot`

7. Screen

    ```bash
    安装screen:
    sudo apt-get update
    sudo apt-get install screen
    ```

    相关命令：
    | 动作             | 命令                              | 示例                                                                 |
    |------------------|-----------------------------------|----------------------------------------------------------------------|
    | 新建screen窗口   | screen -S <name>                  | 例：screen -S task1                                                  |
    | 后台运行         | 先按下 Ctrl+a 随后再按 d          | 会提示：[detached from ****]                                         |
    | 显示所有screen窗口 | screen -ls                        | 会显示：8465.task1 (Detached) 说明task1已经在后台                    |
    | 进入指定的screen窗口 | screen -x <screen name or port> | 例：screen -x task1 或 screen -x 8465                                |
    | 退出并关闭后台   | kill screen port                  | kill 8465 也可以先进入screen窗口在窗口中输入 exit                   |

8. [树莓派热点](https://tech.biko.pub/post#/rpi-setup-share-wifi)

    > 树莓派共享 WiFi 在线配置工具： https://tech.biko.pub/tool#/rpi-share-wifi

    ```bash
    sudo systemctl stop hostapd
    sudo systemctl unmask hostapd
    sudo systemctl enable hostapd
    sudo systemctl start hostapd
    sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
    ```

9. [网站服务器](https://blog.csdn.net/weixin_39591031/article/details/122344892)

    ```bash
    # 下载 nginx
    sudo apt install nginx
    # 删除原有文件
    sudo rm /var/www/html/index.nginx-debian.html
    将你的web文件拷贝进该文件夹
    sudo /etc/init.d/nginx start(开启nginx)
    # 安装cpolar (内网穿透)
    curl -L https://www.cpolar.com/static/downloads/install-release-cpolar.sh | sudo bash
    # 检查是否安装成功
    cpolar version
    # 在cpolar官网注册账号并登录，获取账号特有的认证token。
    (https://link.zhihu.com/?target=https%3A//www.cpolar.com/)
    cpolar authtoken NjE1YjJkMWMtMDBjMy00ODhhLTlhOWEtNDEzYTllMGYzMGMw (token)
    # 开启 http 端口
    cpolar http 80
    # 远程ssh (tcp://17.tcp.cpolar.top:12585)
    cpolar tcp 22
    ```

10. USB摄像头

    ```bash
    # 连接并测试USB摄像头
    # (查看设备文件: ls /dev/video*)
    lsusb
    # 抓拍(下载fswebcam)
    sudo apt-get install fswebcam
    fswebcam /dev/video0 ~/image.jpg
    # 摄像
    sudo apt-get install luvcview
    luvcview -s 640x480
    ```

11. 3.5寸显示屏

    ```bash
    git clone https://github.com/goodtft/LCD-show.git
    chmod -R 755 LCD-show
    cd LCD-show/			# 必须进入LCD-show目录
    sudo ./LCD35-show # 完成后会重启
    # 旋转
    cd LCD-show/
    sudo ./rotate.sh 90
    ```

12. code-server

    前往：https://github.com/coder/code-server/releases
    下载：code-server_x.x.x_armhf.deb(code-server_4.8.3_armhf.deb)
    将下载的包发送到树莓派

    cd 到 deb 包所在的位置，输入：
    `sudo dpkg -i code-server_x.x.x_armhf.deb`

    配置文件
    `sudo nano ~/.config/code-server/config.yaml`

    删除全部，修改为：
    ```
    bind-addr: 192.x.x.x:8080 #你的IP
    auth: password
    password: xxx #你想要的密码
    cert: false
    ```

    启动code-server(不要用vscode输入该指令：error Please specify at least one file or folder)
    `code-server`

    访问code-server
    http://192.168.1.110:8080

13. [CSI摄像头](https://www.labno3.com/2021/08/10/build-a-raspberry-pi-webcam-server-in-minutes)

```bash
# 首先打开树莓派终端，对树莓派进行更新：
sudo apt-get update
sudo apt-get upgrade
# 1.1	打开树莓派的配置界面：
sudo raspi-config
Interfacing Options -> Legacy Camera
# 1.2	拍照功能: -t 1000(延迟一秒,毫秒为单位); -o a.jpg
raspistill -o a.jpg -t 1000
# 1.3	录像功能: 录制一段十秒钟的名为b.h264的视频，且分辨率为1280x720
raspivid -o b.h264 -t 10000 -w 1280 -h 720
# 1.4	监控功能: 安装motion
sudo apt-get install motion
# 允许 motion 后台运行: 添加 “start_motion_daemon=yes”
sudo nano /etc/default/motion
```

> 配置 motion: `sudo nano /etc/motion/motion.conf`
> 找出以下几行，并更新为：
> daemon on
> stream_localhost off
> 注意：运动物体出现在画面使视频变卡，修改下面两行配置
> picture_output off
> movie_output off
> 可选：
> stream_maxrate 100
> framerate 30
> minimum_motion_frames
> width 640
> height 480


```bash
# 设置成开机自动运行：
`sudo nano /etc/rc.local`
在 `exit 0` 前添加 `motion` , 保存，就会开机自动运行了。
# 关闭 motion 进程
sudo killall -TERM motion
# 启动服务: 在Pi的IP地址上查看网络摄像头视频了
sudo service motion start
# 开启motion
sudo motion
# 停止服务
sudo service motion stop
# 重新启动服务
sudo service motion restart
```

### Issues

1. vscode无法连接ssh：过程试图写入的管道不存在

    原因:ssh的密钥不对
    解决方案: 把本地的 `C:\Users\user_name\.ssh\known_hosts` 删掉，然后重新连接

2. SD卡问题：请将磁盘插入“U盘”

    [“磁盘损坏“](https://blog.csdn.net/u013116210/article/details/119256858)

