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
# 设置壁纸
mkdir $HOME/wallpaper
cp ./wallpaper.png $HOME/wallpaper/wallpaper.png
nitrogen --set-zoom-fill $HOME/wallpaper/wallpaper.png

#配置桌面
mkdir -p $HOME/.config/bspwm $HOME/.config/sxhkd $HOME/.config/alacritty $HOME/.config/polybar

cp ./bspwm/bspwmrc.default $HOME/.config/bspwm/bspwmrc
cp ./sxhkd/sxhkdrc.default $HOME/.config/sxhkd/sxhkdrc
cp ./polybar/config.default $HOME/.config/polybar/config.ini
cp ./.xinitrc $HOME/.xinitrc
cp ./.xprofile $HOME/.xprofile
# cp /usr/share/doc/bspwm/examples/bspwmrc $HOME/.config/bspwm
# cp /usr/share/doc/bspwm/examples/sxhkdrc $HOME/.config/sxhkd
# cp /usr/share/doc/polybar/examples/config.ini $HOME/.config/polybar


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
chmod +x $HOME/.config/polybar/launch.sh

# We use Alacritty's default Linux config directory as our storage location here.
mkdir -p ~/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
IFS='\n'
echo -e "import = [\n    \"~/.config/alacritty/themes/themes/monokai.toml\"\n]" > ~/.config/alacritty/alacritty.toml


