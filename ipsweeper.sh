#!/bin/bash

# Check if a network was specified
if [ $# -eq 0 ]; then
  echo "Please specify a network to scan in CIDR notation (e.g. 10.10.10.0/24)"
  exit 1
fi

# Save the specified network to a variable
network=$1

# Extract the base IP address and subnet mask from the specified network
ip_address=$(echo $network | cut -d'/' -f1)
subnet_mask=$(echo $network | cut -d'/' -f2)

# Calculate the range of IP addresses in the specified network
num_hosts=$((2**(32-$subnet_mask)))
start_ip=$(ipcalc $network | grep HostMin | awk '{print $2}')
end_ip=$(ipcalc $network | grep HostMax | awk '{print $2}')

# Convert the start and end IP addresses to integers
start_int=$(echo $start_ip | awk -F"." '{print $1*256*256*256 + $2*256*256 + $3*256 + $4}')
end_int=$(echo $end_ip | awk -F"." '{print $1*256*256*256 + $2*256*256 + $3*256 + $4}')

# Loop through all the IP addresses in the specified network
for i in $(seq $start_int $end_int); do
  # Convert the integer back to an IP address
  ip=$(echo "$i" | awk '{print int($1/256/256/256)"."int($1/256/256%256)"."int($1/256%256)"."int($1%256)}')

  # Use ping to check if the host is alive
  ping -c 1 -W 1 $ip > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    # Host is alive, print its IP address
    echo $ip
  fi
done



