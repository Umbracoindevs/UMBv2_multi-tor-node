#!/bin/bash

# this script uses the Pushover app to send notifications. See https://pushover.net for more information and to get your username and token.
token=""
user=""

vps_name="N10"
load_treshold="10"

if  darkpaycoin-cli -datadir=/root/.darkpaycoin masternode status ; then
    array[0]=$(darkpaycoin-cli -datadir=/root/.darkpaycoin masternode status | underscore select ".status" --outfmt text)
else
    array[0]="0"
fi

for i in {1..3}
do
    if  darkpaycoin-cli -datadir=/root/.darkpaycoin$i masternode status ; then
        array[$i]=$(darkpaycoin-cli -datadir=/root/.darkpaycoin$i masternode status | underscore select ".status" --outfmt text)
    else
        array[$i]="0"
    fi
done

load=$(cat /proc/loadavg | awk '{$1=$1};1' | cut -d " " -f 3)
load_int=$(echo $load | cut -d . -f 1)
message=""

if [[ "$load_int" -gt "$load_treshold" ]]; then
        message="VPS $vps_name has load of $load"
fi

count=0

for item in ${array[*]}
do
    if [[ "$item" -ne "4" ]]; then
       count=$((count + 1))
    fi
done

if [[ "$count" -ne "0" ]]; then
    message="$message
VPS $vps_name has $count activated mn's offline"
fi

if [[ -n "$message" ]]; then
    curl -s --form-string "token=$token" --form-string "user=$user" --form-string "message=$message" https://api.pushover.net/1/messages.json
fi

