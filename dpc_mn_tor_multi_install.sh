#!/bin/bash

#TMP_FOLDER=$(mktemp -d)
MN_NUMBER=$(ls /root | grep darkpaycoind | wc -l)
CONFIG_FILE='darkpaycoin.conf'
COIN_CLI='darkpaycoin-cli'
COIN_PATH='/usr/local/bin/'
COIN_TGZ='https://github.com/DarkPayCoin/darkpay/releases/download/v3.1.99/DarkPay-3.1.99-LINUX64.zip'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
CHAIN_LINK='https://darkpaycoin.io/utils/dpc_fastsync.zip'
CHAIN='dpc_fastsync.zip'
COIN_DAEMON_STANDARD="darkpaycoind"
#TOR=0

BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
RED='\e[38;5;202m'
GREY='\e[38;5;245m'
GREEN="\033[0;32m"
NC='\033[0m'
MAG='\e[1;35m'


function set_globals(){
    if [[ "$MN_NUMBER" == "0" ]]; then
      MN_NUMBER=""
      MN_NUMBER_PLACEHOLDER=0
      RPC_PORT=6668
    else
      MN_NUMBER_PLACEHOLDER=$MN_NUMBER
      RPC_PORT="100$MN_NUMBER"
    fi
    COIN_NAME="darkpaycoin$MN_NUMBER"
    CONFIGFOLDER="/root/.$COIN_NAME"
    COIN_DAEMON="darkpaycoind$MN_NUMBER"
    if [ "$TOR" == "1" ]; then
        NODEIP=127.0.0.1
        if [[ "$MN_NUMBER" != "" ]]; then
            TOR_PROXY_NR=$(expr $MN_NUMBER / 5)
            COIN_PORT="500$MN_NUMBER"
            RPC_PORT="600$MN_NUMBER"
        else
            TOR_PROXY_NR=0
            COIN_PORT="5000"
            RPC_PORT="6000"
        fi
        TOR_CONTROL_PORT="9"$TOR_PROXY_NR"51"
        TOR_OR_PORT="9"$TOR_PROXY_NR"01"
        TOR_PROXY_PORT="9"$TOR_PROXY_NR"50"
        TOR_CONFIG_FILE="/etc/tor/torrc$TOR_PROXY_NR"
    else
        NODEIP=$(curl -s4 icanhazip.com)
        COIN_PORT=6667
    fi
}


function usage() {
    echo ""
    echo "Usage: ./dpc_mn_tor_multi_install.sh -t | -h"
    echo "    -t  Installs node as Tor hidden service"
    echo "    -h  Prints this help"
    echo ""
}

function display_logo() {

echo -e "                                                                                                                                                     
       \e[38;5;52m      .::::::::::::::::::::::::::::::::::..                                        
       \e[38;5;202m   ..::::c:cc:c:c:c:c:c:c:c:c:c:c:c:cc:c::::.                                      
          .:.                                    ::.                                      
          .:c:                                   c::                                       
           .:c:                                 c::                                       
            .:c:                               cc:                                        
             .:c:                             c::                                         
              .:c:                           c::                                         
               .:c:                         c::                                            
                .:cc                       c::                                            
                 .:cc                     c::                                              
                  .:cc                   c::                                               
                   .:cc                 c::                                                
                    .:cc               c::                                                 
                     .:cc             c::                                                  
                      .::c           c:.                                                   
                       .:cc         c::                                                    
                        .::c       c:.                                                     
                         .::c     c:.                                                      
                           ::c.  c:.                                                       
                             .:.:.            \e[0m                                               
 
888888ba                    dP       \e[38;5;202m 888888ba                    \e[0m
88     8b                   88       \e[38;5;202m 88     8b                   \e[0m
88     88 .d8888b. 88d888b. 88  .dP  \e[38;5;202ma88aaaa8P' .d8888b. dP    dP \e[0m
88     88 88'   88 88'   88 88888     \e[38;5;202m88        88    88 88    88 \e[0m
88    .8P 88.  .88 88       88   8b.  \e[38;5;202m88        88.  .88 88.  .88 \e[0m
8888888P   88888P8 dP       dP    YP  \e[38;5;202mdP         88888P8  8888P88 \e[0m
                                                  \e[38;5;202m             88\e[0m
                                                  \e[38;5;202m        d8888P  \e[0m
"
sleep 0.5
}

function start_installation() {
echo -e "
▼ DarkPayCoin Installer v2.0 proudly put on steroids by the community
---------------------------------------------------------------------
"

echo -e "${GREY}Welcome to $COIN_NAME VPS setup script for your masternode${NC}"

}

function purge_old_installation() {

echo -e "
▼ DarkPayCoin Installer v2.0 proudly put on steroids by the community
---------------------------------------------------------------------
"

    echo -e "${GREY}Welcome to $COIN_NAME VPS setup script for your masternode${NC}"

    echo -e "${GREY}Searching and removing old $COIN_NAME files and configurations${NC}"
    #kill wallet daemon
	sudo killall $COIN_DAEMON > /dev/null 2>&1
    #remove old ufw port allow
    sudo ufw delete allow $COIN_PORT/tcp > /dev/null 2>&1
    #remove old files
    sudo rm $COIN_CLI $COIN_DAEMON $CHAIN> /dev/null 2>&1
    sudo rm -rf ~/.$COIN_NAME > /dev/null 2>&1
    #remove binaries and $COIN_NAME utilities
    cd /usr/local/bin && sudo rm $COIN_CLI $COIN_DAEMON > /dev/null 2>&1 && cd
    echo -e "${GREEN}* Done${NONE}";
}



function download_node() {
  mkdir /root/.darkpaycoin
  echo -e "${GREY}Downloading and Installing VPS $COIN_NAME Daemon${NC}"
  cd $TMP_FOLDER >/dev/null 2>&1
  wget -q $COIN_TGZ
  compile_error
  unzip $COIN_ZIP >/dev/null 2>&1
  compile_error
#  cd linux
  chmod +x $COIN_DAEMON
  chmod +x $COIN_CLI
  cp $COIN_DAEMON $COIN_PATH
#  cp $COIN_DAEMON /root/
  cp $COIN_CLI $COIN_PATH
#  cp $COIN_CLI /root/
  cd ~ >/dev/null 2>&1
	#download chain
   echo -e "${GREY}Downloading and Installing fast sync pack, please be patient and wait till the end of process...${NC}"
	wget -q $CHAIN_LINK
     echo -e "${GREY}Extracting fast sync pack, please be patient and wait till the end of process...${NC}"

	unzip $CHAIN
  cp -r blocks /root/.darkpaycoin
  cp -r chainstate /root/.darkpaycoin
  cp peers.dat /root/.darkpaycoin
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}

function copy_daemon() {
  echo -e "${GREY}Copying and Installing VPS $COIN_NAME Daemon${NC}"
  cd /root >/dev/null 2>&1
  cp $COIN_DAEMON_STANDARD $COIN_DAEMON >/dev/null 2>&1
  cp $COIN_DAEMON $COIN_PATH >/dev/null 2>&1
  mkdir $CONFIGFOLDER >/dev/null 2>&1
  sleep 2
  mkdir $CONFIGFOLDER/chainstate >/dev/null 2>&1
  mkdir $CONFIGFOLDER/blocks >/dev/null 2>&1
  cd /root/.darkpaycoin/blocks/ >/dev/null 2>&1
  cp -R * $CONFIGFOLDER/blocks/ >/dev/null 2>&1
  sleep 2
  cd /root/.darkpaycoin/chainstate/
  cp -R * $CONFIGFOLDER/chainstate/ >/dev/null 2>&1
  sleep 2
  clear
}

function configure_systemd() {
if [ "$TOR" == "1" ]; then
	EXSTART="ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER -proxy=$NODEIP:$TOR_PROXY_PORT -externalip=$ONION_ADDRESS:6667 -listen"
else
	EXSTART="ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER"
fi

  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target
[Service]
User=root
Group=root
Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid
$EXSTART
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}

function configure_tor_systemd() {
  cat << EOF > /etc/systemd/system/tor$TOR_PROXY_NR.service
[Unit]
Description=Tor$TOR_PROXY_NR service
#After=network.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/tor -f $TOR_CONFIG_FILE
ExecReload = /bin/kill -HUP
ExecStop = /bin/kill -INT
ExecReload=/bin/true
TimeoutSec = 60s

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start tor$TOR_PROXY_NR.service
  systemctl enable tor$TOR_PROXY_NR.service >/dev/null 2>&1

}


function create_config() {
#mkdir $CONFIGFOLDER >/dev/null 2>&1
RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
if [ "$TOR" == "1" ]; then
PROXY_STRING="proxy=127.0.0.1:$TOR_PROXY_PORT"
fi


  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
rpcport=$RPC_PORT
port=$COIN_PORT
$PROXY_STRING
listen=1
server=1
daemon=1
addnode=136.243.185.4:6667
addnode=46.101.231.40:6667
addnode=67.99.220.116:6667
addnode=206.189.173.84:6667
addnode=142.93.97.228:6667
EOF
}

function create_key() {
  echo -e "${YELLOW}Enter your ${RED}$COIN_NAME Masternode GEN Key${NC}. Or press enter generate new Genkey"
  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
    if [[ "$MN_NUMBER" == "" ]]; then
      $COIN_PATH$COIN_DAEMON -daemon
      sleep 30
      if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
        echo -e "${RED}$COIN_NAME server couldn not start. Check /var/log/syslog for errors.${NC}"
        exit 1
      fi
    fi
    COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
    if [ "$?" -gt "0" ]; then
      echo -e "${RED}Wallet not fully loaded. Let us wait and try again to generate the GEN Key${NC}"
      sleep 30
      COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
    fi
    $COIN_PATH$COIN_CLI stop
  fi
  clear
}

function check_tor_install() {
  echo -e "Checking ${GREEN}Tor installation${NC}"
  TOR_RETURN_CHECK=$(curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ | cat | grep -m 1 Congratulations | wc -l)
  if [[ $TOR_RETURN_CHECK != "1" ]]; then
    TOR_NOT_INSTALLED=true
    echo -e "${RED}No running Tor instance found. Will continue with installation of Tor...${NC}"
    sleep 2
  else
    TOR_NOT_INSTALLED=false
    echo -e "${GREEN}Tor proxy instance found running at port 9050. No further action needed.${NC}"
    sleep 2
  fi
  clear
}

function prepare_tor_install() {
  echo -e "Preparing sources.list for installing ${GREEN}Tor${NC}"
  sleep 2
  cat << EOF >> /etc/apt/sources.list
deb https://deb.torproject.org/torproject.org xenial main
deb-src https://deb.torproject.org/torproject.org xenial main
EOF
}

function install_tor() {
  echo -e "Adding libs needed for ${GREEN}Tor${NC}"
  apt-get -y install apt-transport-https gnupg2 dirmngr >/dev/null 2>&1
  prepare_tor_install
  echo -e "Installing keys needed for ${GREEN}Tor${NC}"
  curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
  gpg2 --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
#  gpg2 --keyserver pool.sks-keyservers.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
#  gpg2 --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add - 
  echo -e "Updating sources before installing ${GREEN}Tor${NC}"
  apt-get update >/dev/null 2>&1
  echo -e "Installing ${GREEN}Tor${NC}"
  apt-get -y install tor deb.torproject.org-keyring >/dev/null 2>&1
  if [ "$?" -gt "0" ];then
    echo -e "${RED}Tor was not installed installed properly. Try to install Tor manually by running the following commands.${NC}"
    echo -e "${RED}apt-get install apt-transport-https gnupg2${NC}"
    echo -e "${RED}nano /etc/apt/sources.list${NC}"
    echo -e "${RED}In that file add the following 2 lines:${NC}"
    echo -e "${RED}deb https://deb.torproject.org/torproject.org xenial main${NC}"
    echo -e "${RED}deb-src https://deb.torproject.org/torproject.org xenial main${NC}"
    echo -e "${RED}gpg2 --keyserver pool.sks-keyservers.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89${NC}"
    echo -e "${RED}gpg2 --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -${NC}"
    echo -e "${RED}apt-get update${NC}"
    echo -e "${RED}apt-get install tor deb.torproject.org-keyring${NC}"
    echo -e "${RED}service tor stop${NC}"
    exit 1
  fi
  echo -e "${GREEN}Successfully installed Tor${NC}"
  sleep 3
  service tor stop >/dev/null 2>&1
  clear
}

function create_tor_config() {
  echo -e "Creating  ${GREEN}Tor config${NC}"
  mkdir /var/log/tor$TOR_PROXY_NR >/dev/null 2>&1
  chown debian-tor:adm /var/log/tor$TOR_PROXY_NR >/dev/null 2>&1
  chmod 2750 /var/log/tor$TOR_PROXY_NR >/dev/null 2>&1

  cat << EOF >> $TOR_CONFIG_FILE
## Main configuration for DKPC masternodes
RunAsDaemon 1
ClientOnly 1
SOCKSPort $TOR_PROXY_PORT
SOCKSPolicy accept 127.0.0.1/8
Log notice file /var/log/tor$TOR_PROXY_NR/notices.log
DataDirectory /var/lib/tor$TOR_PROXY_NR
ControlPort $TOR_CONTROL_PORT
CookieAuthentication 1
ORPort $TOR_OR_PORT
LongLivedPorts 6667,6668
ExitPolicy reject *:*
DisableDebuggerAttachment 0
NumEntryGuards 8

## Per DKPC nodemasternode configuration

EOF
}

function update_tor_config() {
  cat << EOF >> $TOR_CONFIG_FILE
HiddenServiceDir /var/lib/tor$TOR_PROXY_NR/$COIN_NAME/
HiddenServicePort 6667 127.0.0.1:$COIN_PORT
HiddenServiceVersion 2

EOF
}


function get_onion_address() {
  echo -e "${GREY}Stopping Tor service${NC}"
  service tor$TOR_PROXY_NR stop
  sleep 1
  echo -e "${GREY}Starting Tor service${NC}"
  service tor$TOR_PROXY_NR start
  sleep 1
  ONION_ADDRESS=$(cat "/var/lib/tor$TOR_PROXY_NR/$COIN_NAME/hostname")
  clear
}


function update_config() {
if [ "$TOR" == "1" ]; then
MASTERNODE_STRING="masternodeaddr=$ONION_ADDRESS:6667"
EXTERNALIP_STRING="externalip=$ONION_ADDRESS:6667"
else
MASTERNODE_STRING="masternodeaddr=$NODEIP:$COIN_PORT"
#EXTERNALIP_STRING="externalip=$NODEIP"
fi

IPV6REGEX='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'

if [[ $NODEIP =~ $IPV6REGEX ]]; then
    BIND_STRING="[$NODEIP]"
    MASTERNODE_STRING="masternodeaddr=[$NODEIP:$COIN_PORT]"
#    EXTERNALIP_STRING="externalip=[$NODEIP]"
else
    BIND_STRING=$NODEIP
fi

  sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
maxconnections=256
bind=$BIND_STRING
masternode=1
masternodeprivkey=$COINKEY
$MASTERNODE_STRING
$EXTERNALIP_STRING
EOF
}

function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  if [ "$TOR" != "1" ]; then
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  fi
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
  clear
}


function get_ip() {
  declare -a NODE_IPS
  declare -a USED_IPS
  if [[ "$MN_NUMBER" != "" ]]; then
    USED_IPS=$(cat /root/.darkpaycoin*/darkpaycoin.conf | grep bind | cut -d = -f 2 | tr -d [])
  fi
  for devs in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    for ips in $(ip -h address show $devs | grep inet | grep global | awk '{$1=$1};1' | cut -d " " -f 2 | cut -d / -f 1)
    do
      if [[ ${USED_IPS[*]} =~ $ips ]]; then
        sleep 0.5
      else
        NODE_IPS+=($ips)
      fi
    done
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP available (and not used for other MN). Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
  clear
}


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC} Run again to re-install"
  exit 1
fi
}


function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${RED}$COIN_NAME is already installed.${NC} Run again to re-install"
  exit 1
fi
}

function prepare_system() {
echo -e "Preparing the VPS to setup. ${GREY}$COIN_NAME Masternode${NC}"
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${PURPLE}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-add-repository -y ppa:ubuntu-toolchain-r/test
apt-get update >/dev/null 2>&1
apt-get install libzmq3-dev -y >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip libzmq5 gcc-6 g++-6
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5 gcc-6 g++-6"
 exit 1
fi
clear
}

function important_information() {
 echo
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "$COIN_NAME Masternode is up and running listening on port ${GREEN}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "VPS_IP:PORT or local port in case of Tor install ${GREEN}$NODEIP:$COIN_PORT${NC}"
 echo -e "MASTERNODE GENKEY is: ${RED}$COINKEY${NC}"
 echo -e "Please check ${RED}$COIN_NAME${NC} is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "Use ${RED}$COIN_CLI masternode status${NC} to check your MN."
 if [[ "$TOR" == "1" ]]; then
  echo -e "The ONION address of this masternode is ${GREEN}$ONION_ADDRESS:6667${NC}."
 fi
 if [[ -n $SENTINEL_REPO  ]]; then
 echo -e "${RED}Sentinel${NC} is installed in ${RED}/root/sentinel_$COIN_NAME${NC}"
 echo -e "Sentinel logs is: ${RED}$CONFIGFOLDER/sentinel.log${NC}"
 fi
}

while [ "$1" != "" ]; do
    case $1 in
        -t | --tor )            TOR=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

set_globals

function setup_node() {
  if [[ "$TOR" != "1" ]]; then
    get_ip
    enable_firewall
  fi
  create_config
  if [ "$TOR" == "1" ]; then
    if ! [ -e $TOR_CONFIG_FILE ]; then
      create_tor_config
    fi
    update_tor_config
    configure_tor_systemd
    get_onion_address
    sleep 3
  fi
  create_key
  update_config
  important_information
  configure_systemd
}


##### Main #####
clear
display_logo
start_installation
checks
if [[ "$MN_NUMBER" == "" ]]; then
  prepare_system
  download_node
else
  copy_daemon
fi
if [[ "$TOR" == "1" ]]; then
  check_tor_install
  if $TOR_NOT_INSTALLED; then
    install_tor
  fi
fi
setup_node

