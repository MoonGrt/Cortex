---
type: [note]
tags: [Ubuntu]
---

## Ubuntu 16.04

### Installation

1. [Instal VMware Tools](https://blog.csdn.net/cfq1491/article/details/81063472)

    Double-click the optical drive (VMware Tools) and copy the compressed file to your home directory.
    Open a terminal, navigate to your home directory, extract the files, install the software, and reboot:
    ```bash
    tar -zxvf xxx.tar.gz && cd xxx
    sudo ./vmware-install.pl (When prompted with [Y/N], enter “y”; for other prompts, press Enter)
    reboot
    ```

2. [Install VScode](https://code.visualstudio.com/Download)

    Download VSCode from the [official website](https://code.visualstudio.com/Download)
    > Download the .deb package for Ubuntu and install it using the command:

    ```bash
    sudo dpkg -i xxx.deb
    ```

1. [Installing Chinese Input](https://blog.csdn.net/a1015392344/article/details/99350608)

    ```bash
    # 1. Installation of Chinese input method support
    sudo apt-get install language-pack-zh-hans
    # 2. Install Google Input Method
    sudo apt-get install fcitx-googlepinyin
    # 3. Open the Language settings in Settings and change the keyboard input method to Fcitx
    # 4. Reboot the system
    # 5. Open the fcitx settings
    fcitx-configtool
    # 6. Add Google Input Method (click the + sign to add)
    #    Uncheck “Only show current language”
    #    Find Google Pinyin, click OK, and the addition is complete
    ```

### Issue

1. Cannot mount 64GB (128GB, etc.) volumes, when plug a USB drive.

    ```bash
    sudo apt-get install exfat-utils
    ```

---
---

## Ubuntu 20.04 & 22.04

### Setup

```bash
# 设置息屏时间, 关闭更新

# 鱼香ROS: （安装code，换系统源, python源）
wget http://fishros.com/install -O fishros && . fishros
# 官网安装 sudo dpkg -i xxx.deb

# 安装 Git, Python, net-tools, ccache
sudo apt-get -y install git python3-pip net-tools ccache
# 配置Git
git config --global user.name "MoonGrt"
git config --global user.email "1561145394@qq.com"
# ccache 替换 gcc
echo 'export PATH="/usr/lib/ccache:$PATH"' >> ~/.bashrc && source ~/.bashrc

# VScode 设置: 
# 按照插件: python, c/c++, wakatime, error lens, verilog, markdown, fitten
# 打开 Cortex 安装推荐插件
# 快捷键设置: 返回 前进

# VMware 设置共享文件夹
echo '.host:/ /mnt/hgfs fuse.vmhgfs-fuse allow_other 0 0' | sudo tee -a /etc/fstab

# 更新源 && 更新软件 && 删除多余软件
sudo apt-get update && sudo apt-get upgrade -y && sudo apt autoremove -y

# 关机并弹出镜像
sudo poweroff
```

### Installation

1. opencv

    https://blog.csdn.net/songjiangem/article/details/116498818
    https://blog.csdn.net/weixin_48476701/article/details/118877144

2. RARS - RISC-V 汇编器和运行时模拟器

    https://digitalixy.com/pass/1133258.html

3. [Vivado](https://blog.csdn.net/m0_46442410/article/details/112467118) & Petalinux

    > !!! - 保证有足够的存储 !!!

    ```bash
    # 1. 安装 Prerequisites
    sudo apt update && sudo apt install -y libncurses5
    # 2. 下载 Vivado
    # 3. 解压 Vivado 并安装
    tar -xvf Xilinx.tar
    # 4. 安装 Vivado 环境变量
    ./xsetup
    # 5. 设置环境变量
    echo 'source <install_dir>/Xilinx/Vivado/2018.3/settings64.sh' >> ~/.bashrc && source ~/.bashrc
    ```

    ```bash
    vivado <xxx.xpr>
    vivado -mode tcl
    ```

    [Vivado 安装卡在 `processing final`](https://www.bilibili.com/opus/872721892682760226)

    > Petalinux python 错误: 修改文件
    > sudo gedit /var/lib/dpkg/status
    > 将 "Pacakge: python2" 改为 "Pacakge: python"

4. clang14

    ```bash
    # 1. **添加 LLVM 的官方 GPG key**: 
    wget https://apt.llvm.org/llvm-snapshot.gpg.key
    sudo apt-key add llvm-snapshot.gpg.key
    # 2. **添加 LLVM 的 APT 源**: 
    sudo add-apt-repository "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-14 main"
    # 3. **更新软件包列表并安装 clang-14**: 
    sudo apt update
    sudo apt install clang-14 lldb-14 lld-14
    # 4. **（可选）设置 `clang` 命令默认指向 clang-14**: 
    sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-14 100
    sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-14 100
    ```

5. ccache

    > 安装 ccache 并加速 gcc

    ```bash
    sudo apt update
    sudo apt install ccache -y
    echo 'export PATH="/usr/lib/ccache:$PATH"' >> ~/.bashrc && source ~/.bashrc
    ```

    设置 ccache
    ```bash
    ccache --set-config=max_size=16G
    ccache --set-config=sloppiness=time_macros
    ccache --set-config=hash_dir=false
    ccache --set-config=compression=true
    ```

6. modelsim
  
https://blog.csdn.net/weixin_43245577/article/details/140839616
https://pan.baidu.com/s/1oNHvzMFh9pLcGAX1A3Dqjw?pwd=2301&_at_=1685846090578#list/path=%2F

7. the fuck

    ```bash
    sudo apt update && sudo apt install python3-dev python3-pip python3-setuptools
    pip3 install thefuck --user
    echo 'eval "$(thefuck --alias)"' >> ~/.bashrc && source ~/.bashrc
    ```

### Setting

1. github.com 连接设置

    > 墙外不需要设置

    修改 hosts 文件: `sudo nano /etc/hosts`, 文件末尾添加以下内容:

    ```
    140.82.112.4 github.com
    151.101.1.6 github.global.ssl.fastly.net
    151.101.65.6 github.global.ssl.fastly.net
    151.101.129.6 github.global.ssl.fastly.net
    151.101.193.6 github.global.ssl.fastly.net
    ```

2. GitHub 重定向为 "hgithub.xyz"

    配置 Git 全局 URL 重写
    ```bash
    # 设置全局 URL 重写规则
    git config --global url."https://hgithub.xyz/".insteadOf "https://github.com/"
    # 验证配置
    git config --global --get-regexp url\..*\.insteadOf
    ```
    > 这样所有 https://github.com/ 开头的 URL 会自动替换为 https://hgithub.xyz/，证书验证也能正确匹配。

    删除配置
    ```bash
    # 删除规则
    git config --global --unset url."https://hgithub.xyz/".insteadOf
    # 验证删除
    git config --global --get-regexp url\..*\.insteadOf
    ```

3. 调整 SWAP 分区容量

4. [扩展虚拟机的磁盘空间](https://www.cnblogs.com/rusthx/articles/17854510.html)

    ```bash
    df -h
    sudo apt update && sudo apt install -y gparted
    ```

5. Ubuntu 22.04 [vscode 设置黑色外框](https://blog.csdn.net/m0_64140451/article/details/126647601)

    选择: 设置 << 用户 << 窗口 << Title Bar Style << 更改选项为 “custom”

### Issue

1. 共享文件夹不挂载

    ```bash
    echo '.host:/ /mnt/hgfs fuse.vmhgfs-fuse allow_other 0 0' | sudo tee -a /etc/fstab
    ```

2. VMware 无法粘贴复制

    ```bash
    # 1. 卸载前边安装的VMware Tools
    sudo apt-get remove open-vm-tools
    sudo apt-get remove --auto-remove open-vm-tools
    sudo apt-get purge open-vm-tools
    sudo apt-get purge --auto-remove open-vm-tools
    # 2. 安装open-vmware-tools
    sudo apt-get install open-vm-tools
    sudo apt-get install open-vm-tools-desktop
    # 3. reboot
    sudo reboot
    ```

3. [无法连接网络 (网络图标丢失)](https://blog.csdn.net/weixin_43455581/article/details/121751530)

    ```bash
    sudo service network-manager stop
    sudo rm /var/lib/NetworkManager/NetworkManager.state
    sudo service network-manager start
    ```

4. [软件/依赖库的降级问题](https://blog.csdn.net/weixin_42842270/article/details/106650105)

---
---
