#!/bin/bash

# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'


#server config function
functionserver () {
read -p "how many folders do you wanna share? " b
for (( i=1 ; i<=$b ; i++ ));
 	do
                read -p "I wanna share : " share
		
		permisions
			
                conf0="$share  `hostname -I | cut -d " " -f 1`/`ifconfig | grep broadcast | head -1 | cut -d " " -f 13`$permision"
                if [ $i == 1 ]; then
                        echo $conf0>exports
                else

                        echo $conf0>> exports
                fi
	done

cat exports
read -p 'is it ok?
yes = 1  no = 2  :  ' c
if [ $c == 1 ]; then
	cat exports >/etc/exports
        systemctl restart nfs-kernel-server
        systemctl status nfs-kernel-server
elif [ $c == 2 ]; then
                echo -e "${magenta}please run the script again${clear}"
fi
}

#permisions control function
permisions () {

	permision="("

                 
                read -p "read and write : 1   read only : 2   ?  " perm0
                
		if [ $perm0 == 1 ]; then
                        permision=$permision"rw"
		elif [ $perm0 == 2 ]; then
			permision=$permision"ro"
		else 
		        echo -e "${red}wrong input${clear}"	
			
		fi

		read -p "synchronizing  yes : 1  no : 2  ? " perm1
 


                if [ $perm1 == 1 ]; then
                        permision=$permision",sync"
		elif [ $perm1 != 2 ]; then
		        echo -e "${red}wrong input${clear}"	
		fi

                
		read -p "subtree_check  yes : 1  no : 2  ? " perm2

		if [ $perm2 == 1 ]; then
			permision=$permision",subtree_check"
		elif [ $perm2 != 2 ]; then
		        echo -e "${red}wrong input${clear}"	
		fi
		
		permision=$permision")"


}

#install and update nfs on server function
installserver () {
        echo -e "${yellow} update and install nfs-kernel-server : ${clear}"
        echo " "
        sudo apt update && apt install nfs-kernel-server
        echo " "
        echo -e "${yellow} completed ${clear}"
        echo " "
}



#install and update nfs on client function
clientinstall () {
	echo " "
        echo -e "${yellow} update and install nfs-common : ${clear}"
        echo " "
        #sudo apt update && apt install nfs-common
        apt install nfs-common
        echo " "
        echo -e "${yellow} completed ${clear} "
        echo " "
}



#client config function
clientfunction () {
        echo " "
        read -p "what is the ip ? " p
        showmount --exports $p
	if [ $? != 0 ]; then
		echo -e "${red}please check your ip again${clear}"
		exit
	fi
	read -p "mount in : " addr


        for (( i=2 ; i<=`showmount --exports $p | wc -l` ; i++ ));
        do

		echo -e ${yellow} $p:`showmount --exports $p | head -$i | tail +$i | cut -d " " -f 1` "will mount on" $addr/`showmount --exports $p | head -$i | tail +$i | cut -d " " -f 1 | rev | cut -d "/" -f 1 | rev` ${clear}
        done

read -p "yes : 1   no : 2
is it all correct? " beingsure

if [ $beingsure == 1 ]; then


        for (( i=2 ; i<=`showmount --exports $p | wc -l` ; i++ ));
        do

                mkdir -p $addr/`showmount --exports $p | head -$i | tail +$i | cut -d " " -f 1 | rev | cut -d "/" -f 1 | rev`

                mount $p:`showmount --exports $p | head -$i | tail +$i | cut -d " " -f 1`  $addr/`showmount --exports $p | head -$i | tail +$i | cut -d " " -f 1 | rev | cut -d "/" -f 1 | rev`

                echo $p:`showmount --exports $p | head -$i | tail +$i | cut -d " " -f 1` "mounted on"  $addr/`showmount --exports $p | head -$i | tail +$i | cut -d " " -f 1 | rev | cut -d "/" -f 1 | rev`
        done



elif [ $beingsure == 2 ]; then
	echo -e "${magenta}please run the script again${clear}"
else 
	echo -e "${red}wrong input${clear}"
fi

}
echo " "
echo -e "${green}*******************************"
echo -e "*** auto-nfs  version 0.0.1 ***"
echo -e "*******************************${clear}"
echo " "
read -p "server : 1    client : 2
are you a server or client : " a


if [ $a == 1 ]; then
	echo " "
	read -p "yes : 1   No : 2
I wanna update or install nfs-kernel-server : " c

	if [ $c == 1 ]; then
		installserver
		functionserver
	elif [ $c == 2 ]; then
		functionserver
	fi

	
elif [ $a == 2 ]; then
        echo " "
        read -p "yes : 1   No : 2
I wanna update or install nfs-common : " c

        if [ $c == 1 ]; then
                clientinstall
                clientfunction
        elif [ $c == 2 ]; then
                clientfunction
        fi

else 
	echo -e "${red}its invalid${clear}"
fi
