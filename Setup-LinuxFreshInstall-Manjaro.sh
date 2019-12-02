###-setup-###
#Run as normal user with sudo in front
#!/bin/bash
#Auto choose best mirrors with fastest response and accessable. 
pacman-mirrors --fasttrack
#install vim
pacman -Syu
pacman -S vim
#create vim file
echo "syntax on" >> ~/.vimrc
echo "colorscheme slate" >> ~/.vimrc
#copy .vimrc to root
cp ~/.vimrc /root/
#add aliases to .backrc
echo "alias sudo='sudo '" >> ~/.bashrc
echo "alias vi='vim'" >> ~/.bashrc
echo "alias ..='cd ..'" >> ~/.bashrc
#enable ufw - Uncomplicated Firewall
#ufw allow 22 #only needed if accessing remotely
ufw enable
#install ncdu - NCurses Disk Usage
pacman -S ncdu