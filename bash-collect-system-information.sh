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
}

main
