# Instructions
## Must be run as root
## Must use Ubuntu 16.04
## Run commands below
### - Step 1
wget https://raw.githubusercontent.com/Umbracoindevs/UMBv2_multi-tor-node/master/umbra_multinode_tor_swap.sh && chmod +x umbra_multinode_tor_swap.sh
### - Step 2
./umbra_multinode_tor_swap.sh -t
### - Step 3
Follow prompts

# Multiple tor nodes
## stop/start .service incase of bug (should only happen when starting a second node)
### systemctl stop umbra.service
### systemctl stop umbra1.service
### systemctl start umbra.service
### systemctl start umbra1.service
