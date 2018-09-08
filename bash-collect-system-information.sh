#! /bin/bash

# get-date() {
#     local current_time=$(date +%H:%M:%S\ %Z)
#     echo "$current_time"
# }
# 
# get-uptime() {
#     local uptime=$(uptime --pretty)
#     echo "$uptime"
# }

main() {
    echo "====================Time======================="
    current_time=$(date +%H:%M:%S\ %Z)
    echo "Current Time: $current_time"

    uptime=$(uptime --pretty)
    echo "Uptime: $uptime"
    echo "==============================================="
    echo
    

    echo "===================OS Info====================="
    os_version=$(uname -a)
    echo "OS Version: $os_version"
    echo "==============================================="
    echo

    echo "============System Hardware Specs=============="
    cpu_info=$(lscpu | grep "Model name" | awk '{print $3, $4, $5}')
    echo "CPU Info: $cpu_info"
    
    ram_size=$(grep MemTotal /proc/meminfo | awk '{print $2/(1024*1024) " GB"}')
    echo "RAM Size: $ram_size"

    total_hdd_size=$(lsblk --output SIZE -n | head -n 1 | cut -c 2-)
    echo "HDD Size: $total_hdd_size"

    hard_drives=$(lsblk | awk '{if ($6 == "disk") print $1}' | sed ':a;N;$!ba;s/\n/, /g')
    echo "Hard Drives: $hard_drives"
    echo "==============================================="
    echo
    
    echo "=========Hostname and Domain==================="
    hostname=$(hostname)
    echo "Hostname: $hostname"

    domain=$(domainname)
    echo "Domain: $domain"
    echo "==============================================="
    echo
    
    echo "=================User Info====================="
    users=$(awk -F ":" '{print "User: " $1 ", UID: " $3 ", GID: " $4 }' /etc/passwd)
    echo -e "User Info:\n$users"

    login_history=$(last)
    echo -e "User Login History:\n$login_history"
    echo "==============================================="
    echo

    echo "=============Start at boot====================="
    services_on_boot=$(systemctl list-unit-files --type=service | grep enabled | awk '{print $1}' | sed ':a;N;$!ba;s/\n/, /g')

    echo "Services on Boot: $services_on_boot"
    echo "==============================================="
    echo

    echo "==========List of Scheduled Task==============="
    task_list_cron=$(crontab -l)
    if [ ${#task_list_cron} -le 1 ]; then echo "Task List: None"
    else echo -e "Task List (cron):\n$task_list_cron"
    fi
    echo "==============================================="
    echo

    echo "==================Network======================"
    arp_table=$(arp)
    echo -e "ARP Table:\n$arp_table"

    mac_addresses=$(ip -o link | awk '{print $2,$(NF-2)}')
    echo -e "MAC Addresses:\n$mac_addresses"

    routing_table=$(route -n)
    echo -e "Routing Table:\n$routing_table"

    interfaces=$(netstat -i | tail -n+3 | awk '{print $1}')
    ipv4_addresses=$(ip addr | awk '/^[0-9]+:/ {sub(/:/,"",$2); iface=$2 }/^[[:space:]]*inet / {split($2, a, "/"); print iface": "a[1]}' | sed ':a;N;$!ba;s/\n/, /g')
    ipv6_addresses=$(ip addr | awk '/^[0-9]+:/ {sub(/:/,"",$2); iface=$2 }/^[[:space:]]*inet6 / {split($2, a, "/"); print iface": "a[1]}' | sed ':a;N;$!ba;s/\n/, /g')
    echo "IPv4 Addresses: $ipv4_addresses"
    echo "IPv6 Addresses: $ipv6_addresses"

    dhcp_server=$(grep "option dhcp-server-identifier" /var/lib/dhcp/dhclient.leases | sort -u | awk '{print $3}' | sed 's/;//g')
    echo "DHCP Server: $dhcp_server"

    dns_server=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
    echo "DNS Server: $dns_server"

    default_gateways=$(ip r | grep default | awk '{print $5 ": " $3}' | sed ':a;N;$!ba;s/\n/, /g')
    echo "Default Gateways: $default_gateways"
    
    # NOTE: NEED SUDO PRIVS FOR OUTPUT
    listening_services=$(sudo netstat -plnt)
    echo -e "Listening Services:\n$listening_services"

    # NOTE: NEED SUDO PRIVS FOR OUTPUT
    established_services=$(sudo netstat -pnt | grep -E '(State|ESTABLISHED)')
    echo -e "Established Services:\n$established_services"

    printers=$(lpstat -p 2> /dev/null)
    if [ ${#printers} -le 1 ]; then echo "Printers: None"
    else echo -e "Printers:\n$printers"
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
    echo -e "Installed Software:\n$installed_software"
    echo "==============================================="
    echo

    echo "================Process List==================="
    processes=$(ps -eo cmd,pid,ppid,fname,user)
    echo -e "Process List:\n$processes"
    echo "==============================================="
    echo
    
    echo "=================Driver List==================="
    drivers=$(modinfo $(lsmod | tail -n +2 | awk '{print $1}'))
    echo -e "Driver List:\n$drivers"
    echo "==============================================="
    echo

    home_directories=$(ls /home)
    for usr in $home_directories;
    do
        echo "==================User: $usr==================="
        echo -e "$usr Documents:\n\t$(ls /home/$usr/Documents/ | sed ':a;N;$!ba;s/\n/, /g')"
        echo -e "$usr Downloads:\n\t$(ls /home/$usr/Downloads/ | sed ':a;N;$!ba;s/\n/, /g')"
        echo "==============================================="
        echo
    done
    
    echo "==================Other Info==================="
    # NOTE: NEED SUDO PRIVS FOR OUTPUT
    shadow=$(sudo cat /etc/shadow)
    echo -e "/etc/shadow:\n$shadow"
    
    # NOTE: NEED SUDO PRIVS FOR OUTPUT
    iptables=$(sudo iptables -L)
    echo -e "iptables:\n$iptables"
    
    # NOTE: NEED SUDO PRIVS FOR OUTPUT
    sudoers=$(sudo cat /etc/sudoers)
    echo -e "Sudoers:\n$sudoers"
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
}

main
