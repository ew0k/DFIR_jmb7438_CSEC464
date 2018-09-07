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
    current_time=$(date +%H:%M:%S\ %Z)
    echo "Current Time: $current_time"

    uptime=$(uptime --pretty)
    echo "Uptime: $uptime"

    os_version=$(uname -a)
    echo "OS Version: $os_version"

    cpu_info=$(lscpu | grep "Model name" | awk '{print $3, $4, $5}')
    echo "CPU Info: $cpu_info"
    
    ram_size=$(grep MemTotal /proc/meminfo | awk '{print $2/(1024*1024) " GB"}')
    echo "RAM Size: $ram_size"

    total_hdd_size=$(lsblk --output SIZE -n | head -n 1 | cut -c 2-)
    echo "HDD Size: $total_hdd_size"

    hard_drives=$(lsblk | awk '{if ($6 == "disk") print $1}' | sed ':a;N;$!ba;s/\n/, /g')
    echo "Hard Drives: $hard_drives"

    # Need to list mounted file systems

    hostname=$(hostname)
    echo "Hostname: $hostname"

    domain=$(domainname)
    echo "Domain: $domain"

    # Need to do "List of all users" section
    users=$(awk -F ":" '{print "User: " $1 ", UID: " $3 ", GID: " $4 }' /etc/passwd)
    echo -e "User Info:\n$users"

    services_on_boot=$(systemctl list-unit-files --type=service | grep enabled | awk '{print $1}' | sed ':a;N;$!ba;s/\n/, /g')

    echo "Services on Boot: $services_on_boot"

    task_list_cron=$(crontab -l)
    if [ ${#task_list_cron} -le 1 ]; then echo "Task List: None"; exit
    else echo "Task List (cron): $task_list_cron"
    fi

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
}

main
