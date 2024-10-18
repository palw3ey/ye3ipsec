# ye3ipsec

A container IPSec server based on Strongswan and Alpine. With remote access and site to site VPN profile. Below 70 Mb. GNS3 ready.

# Simple usage

Create a remote access connection with EAP (mschapv2) authentication :

---
<details><summary>[prerequisites] Click</summary>
&nbsp;

***It is recommended to have at least basic knowledge of Linux commands, containers and VPN networks.***

Open needed ports in your firewall

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

Set runtime status of some kernel parameters 

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

If you want to use Podman (with crun and pasta), the install command is 
```bash
sudo apt update; sudo apt install podman crun passt
```

If you want to use Docker, the install command is 
```bash
sudo apt update; sudo apt install docker.io;
# configuration
sudo groupadd docker; sudo usermod -aG docker $USER; newgrp docker; sudo systemctl enable --now docker
```
</details>

---

```bash
# Podman command
podman run -dt \
  --runtime=/usr/bin/crun --network=pasta \
  --cap-add=NET_ADMIN,SYS_MODULE,SYS_ADMIN,NET_RAW \
  --sysctl net.ipv4.ip_forward=1 --sysctl net.ipv6.conf.all.forwarding=1 --sysctl net.ipv6.conf.all.proxy_ndp=1 -v /lib/modules:/lib/modules:ro \
  -p 500:500/udp -p 4500:4500/udp -e Y_FIREWALL_ENABLE=yes \
  -e Y_EAP_USERS="tux1:StrongPassword1 tux2:StrongPassword2" \
  --name myipsec docker.io/palw3ey/ye3ipsec
```
```bash
# Docker command
docker run -dt \
  --cap-add=NET_ADMIN --cap-add=SYS_MODULE --cap-add=SYS_ADMIN \
  --sysctl net.ipv4.ip_forward=1 --sysctl net.ipv6.conf.all.forwarding=1 --sysctl net.ipv6.conf.all.proxy_ndp=1 -v /lib/modules:/lib/modules:ro \
  -p 500:500/udp -p 4500:4500/udp -e Y_FIREWALL_ENABLE=yes \
  -e Y_EAP_USERS="tux1:StrongPassword1 tux2:StrongPassword2" \
  --name myipsec docker.io/palw3ey/ye3ipsec
```
```bash
# to auto-generate 10 random EAP users, add : -e Y_EAP_USERS_RANDOM=10
# to auto-generate 30 random RSA certificate users, add : -e Y_CERT_USERS_RANDOM=30
# to auto-generate 50 random PSK users, add : Y_PSK_USERS_RANDOM=50

# to see the logs and credentials : run this below command (replace docker by podman if you use podman)
docker logs myipsec

# to see Strongswan logs (press these 2 keys to exit logs viewing : Ctrl C)
docker exec -it myipsec swanctl --log
```

---
<details><summary>[optional] You can customize the network to match your home or business ip address assignment. Click</summary>
&nbsp;

```bash
# Podman command

# Using pasta
# adapt this line and include it to the container's option :
--network=pasta:--config-net,--map-gw,--address=10.3.192.254,--address=fd00::a03:c0fe -e Y_POOL_IPV4=10.2.193.0/24 -e Y_POOL_IPV6=fd00::a02:c100/120 -e Y_POOL_DNS4="1.1.1.1, 8.8.8.8" -e Y_POOL_DNS4="2606:4700:4700::1111, 2001:4860:4860::8888"

# If you don't want to use pasta then :
# adapt and run this to create a network 
podman network create --ipv6 --subnet=10.2.192.0/23 --subnet=fd00::a02:c000/119 mynet46

# remove --network=pasta in the container's option, and add/adapt this line :
-e Y_FIREWALL_NAT=no --network=mynet46 --ip 10.2.192.254 --ip6 fd00::a02:c0fe -e Y_POOL_IPV4=10.2.193.0/24 -e Y_POOL_IPV6=fd00::a02:c100/120 -e Y_POOL_DNS4="1.1.1.1, 8.8.8.8" -e Y_POOL_DNS4="2606:4700:4700::1111, 2001:4860:4860::8888"
```

For Docker, see how [to enable ipv6](https://github.com/palw3ey/ye3ipsec/blob/main/doc/howtos.md#enable-ipv6-in-docker)
```bash
# Docker command

# adapt and run this to create a network 
docker network create --ipv6 --subnet=10.2.192.0/23 --subnet=fd00::a02:c000/119 mynet46

# adapt this line and include it to the container's option :
--network=mynet46 --ip 10.2.192.254 --ip6 fd00::a02:c0fe -e Y_POOL_IPV4=10.2.193.0/24 -e Y_POOL_IPV6=fd00::a02:c100/120 -e Y_POOL_DNS4="1.1.1.1, 8.8.8.8" -e Y_POOL_DNS4="2606:4700:4700::1111, 2001:4860:4860::8888"
```
</details>

---

# Test

---
<details><summary>[tip] You can avoid step 1) and 2) if you have Let's Encrypt certificates. Click</summary>
&nbsp;

Just add these lines in podman/docker run options (replace `my.domain.com` by your real domain) :

```bash
-e Y_LOCAL_SELFCERT=no -e Y_SERVER_CERT_CN=my.domain.com \
-v /etc/letsencrypt/live/my.domain.com/chain.pem:/etc/swanctl/x509ca/chain.pem:ro \
-v /etc/letsencrypt/live/my.domain.com/cert.pem:/etc/swanctl/x509/cert.pem:ro \
-v /etc/letsencrypt/live/my.domain.com/privkey.pem:/etc/swanctl/private/privkey.pem:ro \
```
</details>

---

1) On the host, show the content of the ca certificate 
```bash
# Podman command :
podman exec -it myipsec cat /etc/swanctl/x509ca/caCert.pem
```

```bash
# Docker command :
docker exec -it myipsec cat /etc/swanctl/x509ca/caCert.pem
```

2) On Windows, open Notepad and paste the content, save the file as `caCert.crt`. Double clic on the crt file (or use certlm.msc) to import the certificate to : Local Computer > Trusted Root Certificate  

3) On Windows start menu type "add VPN connection", fill in the fields :
   - connection name : EAP Test
   - server name or address : Type the VPN server external ip address (or domain if using Let's Encrypt certificates)
   - VPN type : select "IKEv2"
   - Type of sign-in info : select "User name and password"
   - User name : type "tux1"
   - Password : type "StrongPassword1"
   - Save
   - Select "EAP Test" and Connect

4) [optional] To enable Split-Tunneling on Windows

```powershell
# Run powershell as administrator, and type
Set-VPNConnection -Name "EAP Test" -SplitTunneling $True
```


## Features
- Road warrior IKEv2 profile : RSA, PSK and EAP
- Road warrior IKEv1 profile : XAUTH RSA and XAUTH PSK
- Site to site IKEv2 profile : RSA and PSK
- IPv4 and IPv6
- Internal pool or external DHCP server
- Internal certificate authority, with certificate revocation option
- Possibility to use host Let's Encrypt certificate
- Possibility to authenticate with a radius server (AAA)
- Firewall option to Allow/Deny : interclient, lan, internet
- Support native VPN client : Windows, Mac, iPhone, Android

The 3 Road warrior IKEv2 profile (RSA, PSK, EAP) are activated by default.  
The credentials are randomly generated, if not set. 

The container will generate self signed certificate using external (public) ip address as CN, if not set.  

The container configurations and credentials can be displayed using the command : docker logs containerName  

The /etc/swanctl folder is persistent.  

Important, you need at least : `--cap-add NET_ADMIN` for strongswan to start.  

# [HOWTOs](https://github.com/palw3ey/ye3ipsec/blob/main/doc/howtos.md)

# [FAQ](https://github.com/palw3ey/ye3ipsec/blob/main/doc/faq.md)

# [GNS3](https://github.com/palw3ey/ye3ipsec/blob/main/doc/gns3.md)

# [Environment Variables](https://github.com/palw3ey/ye3ipsec/blob/main/doc/environment_variables.md)

# [Compatibility](https://github.com/palw3ey/ye3ipsec/blob/main/doc/compatibility.md)

# [Build](https://github.com/palw3ey/ye3ipsec/blob/main/doc/build.md)

# Documentation

[strongswan man page](https://docs.strongswan.org/)

# Version

| name | version |
| :- |:- |
|ye3ipsec | 1.0.7 |
|strongswan | 5.9.14 |
|alpine | 3.20.3 |

# [Changelog](https://github.com/palw3ey/ye3ipsec/blob/main/doc/changelog.md)

# [ToDo](https://github.com/palw3ey/ye3ipsec/blob/main/doc/todo.md)

# License

MIT  
author: palw3ey  
maintainer: palw3ey  
email: palw3ey@gmail.com  
website: https://github.com/palw3ey/ye3ipsec  
docker hub: https://hub.docker.com/r/palw3ey/ye3ipsec
