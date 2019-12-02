###########setup
#!/bin/bash
#Install latest updates
apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove
#install vim
apt install vim
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
ufw enable
#install ncdu - NCurses Disk Usage
apt install ncdu
#Install cherrytree
apt install cherrytree
#install nmap
apt install nmap
#install keepass
apt install keepass2