#!/bin/bash

# You can add this script to your crontab in order to run automatically with a set interval
HOMEDIR="/home/vagrant"
CLIPATH=$(echo $HOMEDIR"/Desktop")
CONFIGPATH=$(echo $HOMEDIR"/.darkpaycoin")
RPCUSER=$(cat $CONFIGPATH/darkpaycoin.conf | grep rpcuser | cut -d = -f 2)
RPCPASS=$(cat $CONFIGPATH/darkpaycoin.conf | grep rpcpassword | cut -d = -f 2)
CONFIGFILE="masternode.conf"
CONFIG=$(echo $CONFIGPATH/$CONFIGFILE)
LOGFILE=$(echo $CONFIGPATH"/node_activation.log")

# You need to have a file with a list of already running and synced hot nodes with a single space between the values
# ALIAS ADDRESS PRIVATE_KEY
# when the file is empty, the script will generate an error
HOTMNLIST="hotmasternodes.txt"

TMPLIST="tmplist.tmp"
PIDFILE="darkpaycoind.pid"
PID=$(cat $CONFIGPATH/$PIDFILE)

BALANCE=$(./darkpaycoin-cli -rpcuser=$RPCUSER -rpcpassword=$RPCPASS listunspent | underscore select ".amount" | underscore reduce 'total+value' --outfmt text | cut -d . -f 1)

if [ $BALANCE -lt 10000 ]; then
	echo $(date)" Spendable balance lower than 10k ($BALANCE), too bad..." >> $LOGFILE
	exit 0
else
	echo $(date)" Spendable balance higher than 10k ($BALANCE), initiating node activation." >> $LOGFILE
	# getting masternode data from hot masternode list
	MNLINE=$(head -n 1 $HOTMNLIST)
	if [ -z "$MNLINE" ]; then
		echo $(date)" Error: no more hot nodes in $HOTMNLIST, exiting..." >> $LOGFILE
		exit 1
	fi
	ALIAS=$(echo $MNLINE | cut -d " " -f 1)
	echo $(date)" Using $ALIAS as alias..." >> $LOGFILE
	MNADDRESS=$(echo $MNLINE | cut -d " " -f 2)
	echo $(date)" Using $MNADDRESS as masternode address..." >> $LOGFILE
	PRIVKEY=$(echo $MNLINE | cut -d " " -f 3)
	echo $(date)" Adding the provided private key..." >> $LOGFILE
	tail -n +2 $HOTMNLIST > $TMPLIST
	rm $HOTMNLIST && mv $TMPLIST $HOTMNLIST
	echo $(date)" Removing masternode $ALIAS from hot masternode list..." >> $LOGFILE

	# sending collateral
	ADDRESS=$(./darkpaycoin-cli -rpcuser=$RPCUSER -rpcpassword=$RPCPASS getaccountaddress $ALIAS)
	echo $(date)" Generated alias $ALIAS in wallet..." >> $LOGFILE
	TXID=$(./darkpaycoin-cli -rpcuser=$RPCUSER -rpcpassword=$RPCPASS sendtoaddress $ADDRESS 10000)
	echo $(date)" Just send 10k DKPC to collateral address $ADDRESS..." >> $LOGFILE

	# checking collateral transaction id for output index
	echo $(date)" Will sleep for 10 seconds, so the collateral tx can get its first confirmation..." >> $LOGFILE
	sleep 10
	CONFIRMATIONS=$(./darkpaycoin-cli -rpcuser=$RPCUSER -rpcpassword=$RPCPASS gettransaction $TXID | underscore select .confirmations --outfmt text)
	echo $(date)" Checking number of confirmations for collateral tx..." >> $LOGFILE
	while [ "$CONFIRMATIONS" -eq "0" ]
	do
		sleep 5
		CONFIRMATIONS=$(./darkpaycoin-cli -rpcuser=$RPCUSER -rpcpassword=$RPCPASS gettransaction $TXID | underscore select .confirmations --outfmt text)
	done
	echo $(date)" Number of confirmations for collateral tx is $CONFIRMATIONS..." >> $LOGFILE
	OUTPUTINDEX=$(./darkpaycoin-cli -rpcuser=$RPCUSER -rpcpassword=$RPCPASS masternode outputs | underscore values --outfmt text | grep "$TXID" | cut -d , -f 2 | cut -d : -f 2 | cut -c '01')
	echo $(date)" Output index for collateral tx is $OUTPUTINDEX..." >> $LOGFILE

	# adding line to masternode config file
	NEWMNLINE=$(echo $ALIAS $MNADDRESS $PRIVKEY $TXID $OUTPUTINDEX)
	echo $(date)" Adding masternode to masternode config file..." >> $LOGFILE
	echo $NEWMNLINE | cat - $CONFIG > temp && mv temp $CONFIG

	# restarting wallet
	echo $(date)" Stopping wallet..." >> $LOGFILE
	kill $PID
	sleep 5
	cd $CLIPATH
	echo $(date)" Starting wallet..." >> $LOGFILE
	./darkpaycoin-qt & > /dev/null 2>&1

	# checking for enough confirmations of the collateral transaction, before activating
	echo $(date)" Checking until number of confirmations for collateral tx is at least 18..." >> $LOGFILE
	while [ "$CONFIRMATIONS" -lt "18" ]
	do
                sleep 60
                CONFIRMATIONS=$(./darkpaycoin-cli -rpcuser=$RPCUSER -rpcpassword=$RPCPASS gettransaction $TXID | underscore select .confirmations --outfmt text)
        done

	# activating the masternode
	echo $(date)" Number of confirmations for collateral tx is $CONFIRMATIONS... Ready to activate masternode $ALIAS.." >> $LOGFILE
	echo $(date)" Activating masternode $ALIAS..." >> $LOGFILE
        ./darkpaycoin-cli -rpcuser=$RPCUSER -rpcpassword=$RPCPASS startmasternode alias lockwallet $ALIAS
	echo $(date)" Done..." >> $LOGFILE
	echo "================================================================" >> $LOGFILE
fi
