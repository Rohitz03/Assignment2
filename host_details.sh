#!/bin/bash

ip_address=$1
username=$2
password=$3
output_file="$ip_address.txt"

# check if required arguments are provided
if [ -z "$ip_address" ] || [ -z "$username" ] || [ -z "$password" ]; 
then
  echo "Error: All IP address, username and password are required."
  echo "Usage: $0 <ip_address> <username> <password>"
  exit 1
fi


#check reachability
ping -c 1 "$ip_address" &> /dev/null
if [ $? -eq 0 ]; 
then
    echo "Success: Device $ip_address is reachable"
else
    echo "Error: Device $ip_address is not reachable"
    exit 1
fi

# check if SSH is available
if ! command -v sshpass &> /dev/null; then
    echo "Error: sshpass is not installed. Please install it before running this script."
    exit 1
fi

# check if remote SSH login is successful
if ! sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip_address "exit" &> /dev/null; then
    echo "Error: Unable to SSH to $ip_address. Please check the IP address, username and password."
    exit 1
fi


# check the OS of the remote ip_address using SSH
if sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip_address "uname -a" &> /dev/null; then
    # if the OS is Linux, get the OS name using uname
    os_name=$(sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip_address "hostnamectl | awk '/Operating System:/ {print \$3\" \"\$4\" \"\$5}'")
    echo "************************************************************************************" | tee -a "$output_file"
    echo "OS Name for $ip_address: $os_name" | tee -a "$output_file"

    os_details=$(sshpass -p "$password" ssh "$username@$ip_address" "cat /etc/*-release")
    echo "************************************************************************************" | tee -a "$output_file"
    echo "OS details of $ip_address" | tee -a "$output_file"
    echo "$os_details" | tee -a "$output_file"

    net_details=$(sshpass -p "$password" ssh "$username@$ip_address" "ip address show")
    echo "************************************************************************************" | tee -a "$output_file"
    echo "Network details of $ip_address" | tee -a "$output_file"
    echo "$net_details" | tee -a "$output_file"

    disk_details=$(sshpass -p "$password" ssh "$username@$ip_address" "lsblk")
    echo "************************************************************************************" | tee -a "$output_file"
    echo "Disk details of $ip_address" | tee -a "$output_file"
    echo "$disk_details" | tee -a "$output_file"

    mem_details=$(sshpass -p "$password" ssh "$username@$ip_address" "free -h")
    echo "************************************************************************************" | tee -a "$output_file"
    echo "Memory details of $ip_address" | tee -a "$output_file"
    echo "$mem_details" | tee -a "$output_file"

    cpu_details=$(sshpass -p "$password" ssh "$username@$ip_address" "lscpu")
    echo "************************************************************************************" | tee -a "$output_file"
    echo "CPU details of $ip_address" | tee -a "$output_file"
    echo "$cpu_details" | tee -a "$output_file"
   

elif sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip_address 'systeminfo.exe' &> /dev/null; then
    # if the OS is Windows, get the OS name using systeminfo
    os_name=$(sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip_address 'systeminfo.exe | findstr /B /C:"OS Name"')
    echo "$ip_address: $os_name" | tee -a "$output_file"

    os_details=$(sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip_address "wmic os get Caption, Version, TotalVirtualMemorySize, FreePhysicalMemory /format:list")
    echo "************************************************************************************" | tee -a "$output_file"
    echo "OS details of $ip_address" | tee -a "$output_file"
    echo "$os_details" | tee -a "$output_file"   

    disk_details=$(sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip_address "wmic logicaldisk get deviceid, freespace, size, systemname, volumename")
    echo "************************************************************************************" | tee -a "$output_file"
    echo "Disk details of $ip_address" | tee -a "$output_file"
    echo "$disk_details" | tee -a "$output_file"

    mem_details=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$ip_address" "wmic memorychip get capacity,manufacturer,speed,partnumber")
    echo "************************************************************************************" | tee -a "$output_file"
    echo "Memory details of $ip_address" | tee -a "$output_file"
    echo "$mem_details" | tee -a "$output_file"

    cpu_details=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$ip_address" "wmic cpu get name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed")
    echo "************************************************************************************" | tee -a "$output_file"
    echo "CPU details of $ip_address" | tee -a "$output_file"
    echo "$cpu_details" | tee -a "$output_file" 

    
else
    echo "Unknown operating system"
    exit 1
fi


