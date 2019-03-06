#!/bin/bash

NAME="Node 0"
ADDRESS=$(cat /root/.darkpaycoin/darkpaycoin.conf | grep masternodeaddr | cut -d = -f 2 | cut -d : -f 1)

IPV6REGEX='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'

if [[ $ADDRESS =~ $IPV6REGEX ]]; then
    ADDRESS="[$ADDRESS]"
fi

PRIVATE_KEY=$(cat /root/.darkpaycoin/darkpaycoin.conf | grep privkey | cut -d = -f 2)
echo $NAME $ADDRESS":6667" $PRIVATE_KEY

MN_NUMBER=$(ls /root | grep darkpaycoind | wc -l)
((MN_NUMBER--))

for i in $(seq 1 $MN_NUMBER)
do
    NAME="Node $i"
    ADDRESS=$(cat /root/.darkpaycoin$i/darkpaycoin.conf | grep masternodeaddr | cut -d = -f 2 | cut -d : -f 1)
    if [[ $ADDRESS =~ $IPV6REGEX ]]; then
        ADDRESS="[$ADDRESS]"
    fi
    PRIVATE_KEY=$(cat /root/.darkpaycoin$i/darkpaycoin.conf | grep privkey | cut -d = -f 2)
    echo $NAME $ADDRESS":6667" $PRIVATE_KEY
done


