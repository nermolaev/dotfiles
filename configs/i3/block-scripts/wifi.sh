#!/bin/sh

if [ -n "$1" ]; then
	iface_name=$1
else
	iface_name=$(ip route | grep -oP 'dev w[\w\d]+' | cut -d ' ' -f 2 | sort | uniq)
	if [ -z "$iface_name" ]; then
		exit
	fi
fi

if [ -n "$2" ]; then
	addr_name=$2
else
	addr_name='inet '
fi

ip_addr=$(ip addr show $iface_name | grep "$addr_name" | cut -d ' ' -f 6 | cut -d '/' -f 1)
text="$iface_name $ip_addr"

quality=$(grep $iface_name /proc/net/wireless | awk '{ print int($3 * 100 / 70) }')
if [ -n "$quality" ]; then
	text="$text ($quality%)"
fi

# long/short text
echo "$text"
echo "$text"

# color - green/yellow/red based on percentage
if [ "$ip_addr" = 'down' ]; then
	echo "#ff3333"
elif [ -n "$quality" ]; then
	if [ $quality -gt 50 ]; then
		hexint=$(echo "255 - ($quality - 50) / 50 * 255" | bc -l)
		hexchar=$(printf '%02x' $hexint 2> /dev/null)
		echo "#${hexchar}ff00"
	else
		hexint=$(echo "$quality / 50 * 255" | bc -l)
		hexchar=$(printf '%02x' $hexint 2> /dev/null)
		echo "#ff${hexchar}00"
	fi
else
	echo "#00ff00"
fi
