#!/bin/bash
#定义日志文件
LOG_FILE="/var/log/arch_init.log"
RECORD_LOG="> /var/log/arch_init.log 2>&1"
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
#配置桌面
mkdir -p $HOMER/.config/bspwm $HOME/.config/sxhkd $HOME/.config/alacritty $HOME/.config/polybar
cp ./arch_configuration/bspwm/bspwmrc.default $HOME/.config/bspwm/bspwmrc
cp ./arch_configuration/sxhkd/sxhkdrc/sxhkdrc.default $HOME/.config/sxhkd/sxhkdrc

cp ./arch_configuration/polybar/config.default $HOME/.config/polybar/config.ini
cp ./arch_configuration/.xinitrc $HOME/.xinitrc
cp ./arch_configuration/.xprofile $HOME/.xprofile
#cp /usr/share/doc/bspwm/examples/bspwmrc $HOME/.config/bspwm
#cp /usr/share/doc/bspwm/examples/sxhkdrc $HOME/.config/sxhkd
#cp /usr/share/doc/polybar/examples/config.ini $HOME/.config/polybar
#cp  /etc/X11/xinit/xinitrc $HOME/.xinitrc

cat>$HOME/.config/polybar/launch.sh<<EOF
#!/bin/bash

# 终止正在运行的 bar 实例
killall -q polybar
# 如果你所有的 bar 都启用了 ipc，你也可以使用
# polybar-msg cmd quit

# 运行 Polybar，使用默认的配置文件路径 ~/.config/polybar/config.ini
polybar mybar 2>&1 | tee -a /tmp/polybar.log & disown

echo "Polybar launched..."
EOF
chomd +x $HOME/.config/polybar/launch.sh

# We use Alacritty's default Linux config directory as our storage location here.
mkdir -p ~/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
echo "import = [\n    \"~/.config/alacritty/themes/themes/monokai.toml\"\n]" > ~/.config/alacritty/alacritty.toml
