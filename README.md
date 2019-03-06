# Darkpay Script Repository  
This repository consists of some bash scripts that are helpful for DarkPay Masternode owners. Every script will have it's own desciption below.  

## dpc_mn_tor_multi_install.sh  
Installation script for masternodes running on Tor and/or for installing several masternodes on the same vps. 

**Installation**  

## genconf.sh  
Script that will generate your masternode.conf lines for you. You only need to add the collateral transaction id and output id.  

## activate_node.sh  
Script that will check your wallet's balance and that will activate a hot masternode automatically when the balance hits 10k.  

**Prerequisites**  
underscore-cli  

Add the following to your darkpaycoin.conf of your wallet and change the ... for values of your own:  
rpcallow=127.0.0.1  
rpcuser=...  
rpcpassword=...  
rpcport=6668  
server=1  
listen=1  

Restart your wallet.  

**Installation of prerequisites**  
*Ubuntu*  
    sudo su  
    apt-get update && apt-get install nodejs  
    apt-get install npm  
    ln -s /usr/bin/nodejs /usr/bin/node  
    npm install -g underscore-cli  
    exit  
