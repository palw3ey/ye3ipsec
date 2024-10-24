# Prerequisite

***It is recommended to have at least basic knowledge of Linux commands, containers and VPN networks.***

## Open needed ports in your firewall

```bash

# Allow outgoing
sudo iptables -A OUTPUT -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow incomming ISAKMP and NAT-T
sudo iptables -A INPUT -p udp -m multiport --dports 500,4500 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p udp -m multiport --sports 500,4500 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow incomming IP protocol 50 for Encapsulated Security Protocol (ESP)
sudo iptables -A INPUT -p esp -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p esp -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow incomming IP protocol 51 for Authentication Header (AH). (for ip6tables replace -p by -m)
sudo iptables -A INPUT -p ah -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p ah -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow server to reach remote dns, crl and ocsp
sudo iptables -A OUTPUT -p tcp -m multiport --dports 80,8080 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT  -p tcp -m multiport --sports 80,8080 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT  -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT  -p tcp --sport 53 -m state --state ESTABLISHED -j ACCEPT

# To make persistent :
# sudo netfilter-persistent save

# If you use ipv6, just use the same commands by replacing the word iptables by ip6tables
```

## Set runtime status of some kernel parameters 

```bash
# ip forwarding 
sudo sysctl -w net.ipv4.ip_forward=1 
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo sysctl -w net.ipv6.conf.default.forwarding=1

# router advertisements
sudo sysctl -w net.ipv6.conf.all.accept_ra=2
sudo sysctl -w net.ipv6.conf.default.accept_ra=2

# ndp
sudo sysctl -w net.ipv6.conf.all.proxy_ndp=1
sudo sysctl -w net.ipv6.conf.default.proxy_ndp=1

# for rootless podman, unprivileged ping
sudo sysctl -w "net.ipv4.ping_group_range=0 2000000"

# for rootless podman, unprivileged port
sudo sysctl -w net.ipv4.ip_unprivileged_port_start=0

# to not accept ICMP redirects
sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
sudo sysctl -w net.ipv6.conf.all.accept_redirects=0
sudo sysctl -w net.ipv4.conf.all.send_redirects=0
sudo sysctl -w net.ipv6.conf.all.send_redirects=0

# These commands are non persistent = they do not survive a system reboot. To make persistent add a file to this directory /etc/sysctl.d/ containing one key=value per line.
```

## Install Podman (with crun and pasta) on Ubuntu 24.04.1 LTS
```bash
sudo apt update; sudo apt install podman crun passt
```

## Install Docker on Ubuntu 24.04.1 LTS
```bash
sudo apt update; sudo apt install docker.io;
# configuration
sudo groupadd docker; sudo usermod -aG docker $USER; newgrp docker; sudo systemctl enable --now docker
```
