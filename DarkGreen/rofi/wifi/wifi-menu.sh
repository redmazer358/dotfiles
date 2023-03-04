#!/usr/bin/env bash

#Themes
dir="$HOME/.config/rofi/wifi"
menu='wifi-list'
auth='auth'

#Notify 
notify-send " 直 Looking For Wi-Fi networks...."

#Get List of wifi and place them into table
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")

#Toggle The Wifi On/Off
connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "enabled" ]]; then
	toggle="睊  Turn Off Wi-Fi"
elif [[ "$connected" =~ "disabled" ]]; then
	toggle="直  Turn On Wi-Fi"
fi

#use rofi dmenu to show the collected ssid
chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -theme ${dir}/${menu}.rasi)

#Get Name of connection
chosen_id=$(echo "${chosen_network:3}" | xargs)


#Conditions on selecting options
if [ "$chosen_network" = "" ]; then
	exit
elif [ "$chosen_network" = "直  Turn On Wi-Fi" ]; then
	nmcli radio wifi on
	notify-send " 直 Wifi Turned On!!!"

elif [ "$chosen_network" = "睊  Turn Off Wi-Fi" ]; then
	nmcli radio wifi off
	notify-send " 直 Wifi Turned Off!!! "

else
	# Message to show when connection is activated successfully
	success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
	# Get saved connections
	saved_connections=$(nmcli -g NAME connection)
	if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
		nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
	else
		if [[ "$chosen_network" =~ "" ]]; then
			wifi_password=$(rofi -dmenu -theme ${dir}/${auth}.rasi )
		fi
		nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
	fi
fi
