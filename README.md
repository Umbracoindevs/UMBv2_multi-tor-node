```
Umbracoindevs  BTC: 19D8BLAx3YCJme5GxNaUEtfKfHpBEbMX5L
Umbracoindevs  BCH: qp5zn73h8sur7ashfzvx4ykswu3rzx388uepz6gr23
```


Feel free to use my reflink to signup and receive a bonus w/ vultr or digitalocean:

<a href="https://m.do.co/c/43df5222d849"><img src="https://imgur.com/eUm6zkt.png"></a>

<a href="https://www.vultr.com/?ref=7607572"><img src="https://www.vultr.com/media/banner_2.png" width="468" height="60"></a>

# Instructions
## Must be run as root
## Must use Ubuntu 16.04
## Run commands below
### - Step 1
```
wget https://raw.githubusercontent.com/Umbracoindevs/UMBv2_multi-tor-node/master/umbra_multinode_tor_swap.sh && chmod +x umbra_multinode_tor_swap.sh
```
### - Step 2
```
./umbra_multinode_tor_swap.sh -t
```
### - Step 3
Follow prompts

# Multiple tor nodes
## stop/start .service incase of bug (should only happen when starting a second node)
```
systemctl stop umbra.service
systemctl stop umbra1.service
systemctl start umbra.service
systemctl start umbra1.service
```
