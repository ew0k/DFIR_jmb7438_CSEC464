#! /bin/bash
# Grab forensic info from a system

main() {
    echo "====================Time======================="
    current_time=$(date +%H:%M:%S\ %Z)
    echo "Current Time: $current_time" | tee -a output.csv

    uptime=$(uptime --pretty)
    echo "Uptime: $uptime" | tee -a output.csv
    echo "==============================================="
    echo
    

    echo "===================OS Info====================="
    os_version=$(uname -a)
    echo "OS Version: $os_version" | tee -a output.csv
    echo "==============================================="
    echo

    echo "============System Hardware Specs=============="
    cpu_info=$(lscpu | grep "Model name" | awk '{print $3, $4, $5}')
    echo "CPU Info: $cpu_info" | tee -a output.csv
    
    ram_size=$(grep MemTotal /proc/meminfo | awk '{print $2/(1024*1024) " GB"}')
    echo "RAM Size: $ram_size" | tee -a output.csv

    total_hdd_size=$(lsblk --output SIZE -n | head -n 1 | cut -c 2-)
    echo "HDD Size: $total_hdd_size" | tee -a output.csv

    hard_drives=$(lsblk | awk '{if ($6 == "disk") print $1}' | sed ':a;N;$!ba;s/\n/, /g')
    echo "Hard Drives: $hard_drives" | tee -a output.csv
    echo "==============================================="
    echo
    
    echo "=========Hostname and Domain==================="
    hostname=$(hostname)
    echo "Hostname: $hostname" | tee -a output.csv

    domain=$(domainname)
    echo "Domain: $domain" | tee -a output.csv
    echo "==============================================="
    echo
    
    echo "=================User Info====================="
    users=$(awk -F ":" '{print "User: " $1 ", UID: " $3 ", GID: " $4 }' /etc/passwd) 
    echo -e "User Info:\n$users" | tee -a output.csv

    login_history=$(last)
    echo -e "User Login History:\n$login_history" | tee -a output.csv
    echo "==============================================="
    echo

    echo "=============Start at boot====================="
    services_on_boot=$(systemctl list-unit-files --type=service | grep enabled | awk '{print $1}' | sed ':a;N;$!ba;s/\n/, /g')

    echo "Services on Boot: $services_on_boot" | tee -a output.csv
    echo "==============================================="
    echo

    echo "==========List of Scheduled Task==============="
    task_list_cron=$(crontab -l)
    if [ ${#task_list_cron} -le 1 ]; then echo "Task List: None" | tee -a output.csv
    else echo -e "Task List (cron):\n$task_list_cron" | tee -a output.csv
    fi
    echo "==============================================="
    echo

    echo "==================Network======================"
    arp_table=$(arp) 
    echo -e "ARP Table:\n$arp_table" | tee -a output.csv

    mac_addresses=$(ip -o link | awk '{print $2,$(NF-2)}')
    echo -e "MAC Addresses:\n$mac_addresses" | tee -a output.csv

    routing_table=$(route -n)
    echo -e "Routing Table:\n$routing_table" | tee -a output.csv

    interfaces=$(netstat -i | tail -n+3 | awk '{print $1}')
    ipv4_addresses=$(ip addr | awk '/^[0-9]+:/ {sub(/:/,"",$2); iface=$2 }/^[[:space:]]*inet / {split($2, a, "/"); print iface": "a[1]}' | sed ':a;N;$!ba;s/\n/, /g')
    ipv6_addresses=$(ip addr | awk '/^[0-9]+:/ {sub(/:/,"",$2); iface=$2 }/^[[:space:]]*inet6 / {split($2, a, "/"); print iface": "a[1]}' | sed ':a;N;$!ba;s/\n/, /g')
    echo "IPv4 Addresses: $ipv4_addresses" | tee -a output.csv
    echo "IPv6 Addresses: $ipv6_addresses" | tee -a output.csv

    dhcp_server=$(grep "option dhcp-server-identifier" /var/lib/dhcp/dhclient.leases | sort -u | awk '{print $3}' | sed 's/;//g')
    echo "DHCP Server: $dhcp_server" | tee -a output.csv

    dns_server=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
    echo "DNS Server: $dns_server" | tee -a output.csv

    default_gateways=$(ip r | grep default | awk '{print $5 ": " $3}' | sed ':a;N;$!ba;s/\n/, /g')
    echo "Default Gateways: $default_gateways" | tee -a output.csv
    
    # NOTE: NEED SUDO PRIVS FOR OUTPUT
    listening_services=$(sudo netstat -plnt)
    echo -e "Listening Services:\n$listening_services" | tee -a output.csv

    # NOTE: NEED SUDO PRIVS FOR OUTPUT
    established_services=$(sudo netstat -pnt | grep -E '(State|ESTABLISHED)')
    echo -e "Established Services:\n$established_services" | tee -a output.csv

    printers=$(lpstat -p 2> /dev/null)
    if [ ${#printers} -le 1 ]; then echo "Printers: None" | tee -a output.csv
    else echo -e "Printers:\n$printers" | tee -a output.csv
    fi
    echo "==============================================="
    echo

    echo "=============Installed Software================"
    yum=$(which yum)
    dpkg=$(which dpkg)
    pacman=$(which pacman)
    dnf=$(which dnf)
    installed_software=""

    if [[ ! -z $yum ]]; then
        installed_software=$(yum list installed)
    elif [[ ! -z $dpkg ]]; then
        installed_software=$(dpkg -l)
    elif [[ ! -z $pacman ]]; then
        installed_software=$(pacman -Q)
    elif [[ ! -z $dnf ]]; then
        installed_software=$(dnf list installed)
    fi
    echo -e "Installed Software:\n$installed_software" | tee -a output.csv
    echo "==============================================="
    echo

    echo "================Process List==================="
    processes=$(ps -eo cmd,pid,ppid,fname,user)
    echo -e "Process List:\n$processes" | tee -a output.csv
    echo "==============================================="
    echo
    
    echo "=================Driver List==================="
    drivers=$(modinfo $(lsmod | tail -n +2 | awk '{print $1}'))
    echo -e "Driver List:\n$drivers" | tee -a output.csv
    echo "==============================================="
    echo

    home_directories=$(ls /home)
    for usr in $home_directories;
    do
        echo "==================User: $usr==================="
        echo -e "$usr Documents:\n\t$(ls /home/$usr/Documents/ | sed ':a;N;$!ba;s/\n/, /g')" | tee -a output.csv
        echo -e "$usr Downloads:\n\t$(ls /home/$usr/Downloads/ | sed ':a;N;$!ba;s/\n/, /g')" | tee -a output.csv
        echo "==============================================="
        echo
    done
    
    echo "==================Other Info==================="
    # NOTE: NEED SUDO PRIVS FOR OUTPUT
    shadow=$(sudo cat /etc/shadow)
    echo -e "/etc/shadow:\n$shadow" | tee -a output.csv
    
    # NOTE: NEED SUDO PRIVS FOR OUTPUT
    iptables=$(sudo iptables -L)
    echo -e "iptables:\n$iptables" | tee -a output.csv
    
    # NOTE: NEED SUDO PRIVS FOR OUTPUT
    sudoers=$(sudo cat /etc/sudoers)
    echo -e "Sudoers:\n$sudoers" | tee -a output.csv
    echo "==============================================="
    echo
    
    if [[ $EUID -ne 0 ]]; then
        echo "NOTE: you did not run this script as root. The following may not be accurate:"
        echo -e "\tListening Services"
        echo -e "\tEstablished Services"
        echo -e "\t/etc/shadow"
        echo -e "\tiptables"
        echo -e "\tSudoers"
    fi

    #email=""
    #echo "Enter email if desired (Enter for no email): "
    read -p "Enter email if desired (Enter nothing for no email): " email
    if [ ${#email} -le 1 ]; then 
        echo "No email" | tee -a output.csv
    else 
        mail -s "Forensics Output" $email
        echo -e "Emailed to: $email" | tee -a output.csv
    fi


}

main
