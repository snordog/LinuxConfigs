#Backup
pacman -Qqe > file.txt


#!/bin/sh
#Restore
for pkgName in $(cat file.txt)
do
	pacman -S --force --noconfirm $pkgName
done
echo "Reinstalled all packages."
