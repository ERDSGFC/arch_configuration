#!/bin/bash
#定义用户名称和密码
USER_NAME="qin"
USER_PASSWORD="asdfjj"
#定义日志文件
LOG_FILE="init.log"
RECORD_LOG="> init.log 2>&1"
#定义打印函数
printMsg(){
    if [ $1 -eq $2 ];then
        echo -e "\033[32m[ ###########${3}########### ]\033[0m"
    else
        echo -e "\033[31m[ ###########${4}###########  ]\033[0m"
        exit 1
    fi
}

myEcho(){
    echo -e "\033[32m[ ###########${3}########### ]\033[0m"
}
#检查网络
echo -e "\033[1m[ ###########网络检测########### ]\033[0m"
net_status=`curl -I -s --connect-timeout 5 www.baidu.com -w %{http_code} |tail -n1`
printMsg $net_status 200 "网络正常" "网络异常，连接网络后再安装"

#安装 reflector
echo -e "\033[1m[ ###########安装reflector########### ]\033[0m"
#两种不同的直接通用安装方式
# pacman -S --noconfirm reflector
echo "[ ###########安装refector########### ]" > ${LOG_FILE} 2>&1
yes | pacman -S reflector >> ${LOG_FILE} 2>&1
printMsg $? 0 安装reflect成功 安装reflector失败
# 选择最快的镜像源
# reflector --verbose -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist
# 选择中国最快的镜像
Result=`sed -n '/generated by Reflector/p' /etc/pacman.d/mirrorlist` 
if [ -z "$Result" ];then
    # 备份
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.back
    echo "[ ###########选择最快镜像########### ]" >> ${LOG_FILE} 2>&1
    reflector --verbose --country 'China' -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist >> ${LOG_FILE} 2>&1
fi

#安装 ex-eqect
echo -e "\033[1m[ ###########安装expect########### ]\033[0m"
echo "[ ###########安装expect########### ]" >> ${LOG_FILE} 2>&1
yes | pacman -S expect >> ${LOG_FILE} 2>&1
printMsg $? 0 安装expect成功 安装expect失败

# 安装常用软件 vim wget tcpdump git openssh openssl
echo -e "\033[1m[ ###########安装常用软件########### ]\033[0m"
echo "[ ###########安装常用软件########### ]" >> ${LOG_FILE} 2>&1
yes | pacman -S vim wget tcpdump git openssh openssl >> ${LOG_FILE} 2>&1
printMsg $? 0 常用软件安装成功 常用软件安装失败

# 设置中文社区仓库
echo -e "\033[1m[ ###########设置社区仓库########### ]\033[0m"
echo "[ ###########设置社区仓库########### ]" >> ${LOG_FILE} 2>&1
ArchLinuxCn=`sed -n '/\[archlinuxcn\]/p' /etc/pacman.conf`
if [[ -z $ArchLinuxCn ]]
then
    sed -i '$,/#Server/a[archlinuxcn]\nServer = https://mirrors.cqu.edu.cn/archlinuxcn/$arch' /etc/pacman.conf
    pacman --noconfirm -Syu archlinuxcn-keyring yay >> ${LOG_FILE} 2>&1
    printMsg $? 0 设置社区仓库成功 设置社区仓库失败
else
    echo -e "\033[33m[ ###########已经设置社区仓库########### ]\033[0m"
fi

#添加新用户qin
echo -e "\033[1m[ ###########添加新用户${USER_NAME}########### ]\033[0m"
echo "[ ###########添加新用户${USER_NAME}########### ]" >> ${LOG_FILE} 2>&1
echo "[ ###########新用户密码${USER_PASSWORD}########### ]" >> ${LOG_FILE} 2>&1
USER=`cat /etc/passwd | grep ^qin`
if [[ -z $USER ]]
then
    useradd -m ${USER_NAME}
    `which expect` <<-EOF
    set timeout -1
    spawn passwd qin
    expect {
        "New password:*" { send "${USER_PASSWORD}\r"; exp_continue }
        "Retype new password:*" { send "${USER_PASSWORD}\r"}
    }
    expect eof
EOF
else
    echo -e "\033[33m[ ###########用户${USER_NAME}已经存在########### ]\033[0m"
fi	
#加入特权
echo -e "\033[1m[ ###########加入特权########### ]\033[0m"
USER_SUDO=`sed -n "/${USER_NAME} ALL=(ALL:ALL) ALL/p" /etc/sudoers`
if [[ -z $USER_SUDO ]]
then
    sed -i "/root ALL=(ALL:ALL) ALL/a${USER_NAME} ALL=(ALL:ALL) ALL" /etc/sudoers
    printMsg $? 0 添加特权成功 设置特权失败
else
    echo -e "\033[33m[ ###########无需设置特权########### ]\033[0m"
fi	

#中文本土化
echo -e "\033[1m[ ###########本土化########### ]\033[0m"
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/;s/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
unset LANG
source /etc/profile.d/locale.sh
printMsg $? 0 本地化成功 本地话失败
echo -e "\033[1m[ ###########安装字体########### ]\033[0m"
echo "[ ###########安装字体########### ]" >> ${LOG_FILE} 2>&1
pacman -S --noconfirm noto-fonts-cjk >> ${LOG_FILE} 2>&1
#安装桌面环境
echo -e "\033[1m[ ###########安装桌面环境########### ]\033[0m"
echo "[ ###########安装桌面环境########### ]" >> ${LOG_FILE} 2>&1
pacman -S --noconfirm xorg xorg-xinit bspwm sxhkd polybar nitrogen picom lightdm lightdm-webkit2-greeter alacritty chromium fcitx5-im fcitx5-chinese-addons fcitx5-material-color >> ${LOG_FILE} 2>&1
# pacman -S --noconfirm xorg xorg-xinit bspwm sxhkd polyber dmenu rofi nitrogen picom xfce4-terminal lightdm lightdm-webkit2-greeter alacritty chromium fcitx5-im fcitx5-chinese-addons fcitx5-material-color >> ${LOG_FILE} 2>&1
#su ${USER_NAME} -c "${USER_PASSWORD}"
chmod 777 xorg.sh
#su ${USER_NAME} bash -c "source ./xorg.sh"
su ${USER_NAME} -s /usr/bin/bash ./xorg.sh

