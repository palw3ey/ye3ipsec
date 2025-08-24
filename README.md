# ye3ipsec

IPSec client and server based on Strongswan and Alpine. RA and S2S profile. GNS3 ready

This project offers a comprehensive set of features for creating IPSec VPN connections and is designed for both educational and practical applications, with default settings compatible with a wide range of devices such as Cisco IOS, Fortigate, built-in VPN clients (Windows, Android, iOS) and more.

# Simple usage

Create a remote access connection with EAP (mschapv2) authentication :

```bash
# Podman rootless command
podman run -dt \
  --runtime=/usr/bin/crun --network=pasta \
  --cap-add=NET_ADMIN,SYS_MODULE,SYS_ADMIN,NET_RAW \
  --sysctl net.ipv4.ip_forward=1 --sysctl net.ipv6.conf.all.forwarding=1 -v /lib/modules:/lib/modules:ro \
  -p 500:500/udp -p 4500:4500/udp -e Y_FIREWALL_ENABLE=yes \
  -e Y_EAP_USERS="tux1:StrongPassword1 tux2:StrongPassword2" \
  --name myipsec docker.io/palw3ey/ye3ipsec
```
```bash
# Docker command
docker run -dt \
  --cap-add=NET_ADMIN --cap-add=SYS_MODULE --cap-add=SYS_ADMIN \
  --sysctl net.ipv4.ip_forward=1 --sysctl net.ipv6.conf.all.forwarding=1 -v /lib/modules:/lib/modules:ro \
  -p 500:500/udp -p 4500:4500/udp -e Y_FIREWALL_ENABLE=yes \
  -e Y_EAP_USERS="tux1:StrongPassword1 tux2:StrongPassword2" \
  --name myipsec docker.io/palw3ey/ye3ipsec
```
```bash
# to auto-generate 10 random EAP users, add : -e Y_EAP_USERS_RANDOM=10
# to auto-generate 30 random RSA certificate users, add : -e Y_CERT_USERS_RANDOM=30
# to auto-generate 50 random PSK users, add : -e Y_PSK_USERS_RANDOM=50

# to see the logs and credentials : run this below command (replace docker by podman if you use podman)
docker logs myipsec

# to see Strongswan logs (press these 2 keys to exit logs viewing : Ctrl C)
docker exec -it myipsec swanctl --log
```

---
<details><summary>[optional] You can customize the network to match your home or business ip address assignment. Click</summary>
&nbsp;

```bash
# Podman rootless command

# Using pasta
# adapt this line and include it to the container's option :
--network=pasta:--config-net,--map-gw,--address=10.3.192.254,--address=fd00::a03:c0fe -e Y_POOL_IPV4=10.2.193.0/24 -e Y_POOL_IPV6=fd00::a02:c100/120 -e Y_POOL_DNS4="1.1.1.1, 8.8.8.8" -e Y_POOL_DNS6="2606:4700:4700::1111, 2001:4860:4860::8888"

# If you don't want to use pasta then :
# adapt and run this to create a network 
podman network create --ipv6 --subnet=10.2.192.0/23 --subnet=fd00::a02:c000/119 mynet46

# remove --network=pasta in the container's option, and add/adapt this line :
 -e Y_FIREWALL_NAT=no --network=mynet46 --ip 10.2.192.254 --ip6 fd00::a02:c0fe -e Y_POOL_IPV4=10.2.193.0/24 -e Y_POOL_IPV6=fd00::a02:c100/120 -e Y_POOL_DNS4="1.1.1.1, 8.8.8.8" -e Y_POOL_DNS6="2606:4700:4700::1111, 2001:4860:4860::8888"
```

For Docker, see how [to enable ipv6](https://github.com/palw3ey/ye3ipsec/blob/main/doc/howtos.md#-enable-ipv6-in-docker)
```bash
# Docker command

# adapt and run this to create a network 
docker network create --ipv6 --subnet=10.2.192.0/23 --subnet=fd00::a02:c000/119 mynet46

# adapt this line and include it to the container's option :
--network=mynet46 --ip 10.2.192.254 --ip6 fd00::a02:c0fe -e Y_POOL_IPV4=10.2.193.0/24 -e Y_POOL_IPV6=fd00::a02:c100/120 -e Y_POOL_DNS4="1.1.1.1, 8.8.8.8" -e Y_POOL_DNS6="2606:4700:4700::1111, 2001:4860:4860::8888"
```
</details>

---

# Test

---

[tip] You can avoid step 1) and 2) if you have Let's Encrypt certificates. See [HOWTOs](https://github.com/palw3ey/ye3ipsec/blob/main/doc/howtos.md#-use-the-host-lets-encrypt-certificate-to-identify-the-vpn-server-instead-of-the-certificate-generated-by-the-container) 

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
- Road warrior IKEv2 client profile : RSA (pkcs12 file), PSK and EAP
- Road warrior IKEv2 server profile : RSA, PSK and EAP
- Road warrior IKEv1 server profile : XAUTH RSA and XAUTH PSK
- Site to site IKEv2 server profile : RSA and PSK
- IPv4 and IPv6
- Internal pool or external DHCP server
- Internal certificate authority, with certificate revocation option
- Possibility to use host Let's Encrypt certificate
- Possibility to authenticate with a radius server (AAA)
- Firewall option to Allow/Deny : interclient, lan, internet
- Support native VPN client : Windows, Mac, iPhone, Android

The 3 Road warrior IKEv2 server profile (RSA, PSK, EAP) are activated by default.  
The credentials are randomly generated, if not set. 

The container will generate self signed certificate using external (public) ip address as CN, if not set.  

The container configurations and credentials can be displayed using the command : docker logs containerName  

The /etc/swanctl folder is persistent.  

Important, you need at least : `--cap-add NET_ADMIN` for strongswan to start.  

# [Prerequisite](https://github.com/palw3ey/ye3ipsec/blob/main/doc/prerequisite.md)

# [HOWTOs](https://github.com/palw3ey/ye3ipsec/blob/main/doc/howtos.md)

# [FAQ](https://github.com/palw3ey/ye3ipsec/blob/main/doc/faq.md)

# [GNS3](https://github.com/palw3ey/ye3ipsec/blob/main/doc/gns3.md)

# [Environment Variables](https://github.com/palw3ey/ye3ipsec/blob/main/doc/environment_variables.md)

# [Compatibility](https://github.com/palw3ey/ye3ipsec/blob/main/doc/compatibility.md)

# [Build](https://github.com/palw3ey/ye3ipsec/blob/main/doc/build.md)

# strongSwan Links
[strongSwan documentation](https://docs.strongswan.org/)

[swanctl.conf configuration](https://docs.strongswan.org/docs/latest/swanctl/swanctlConf.html)
 
[configuration examples](https://wiki.strongswan.org/projects/strongswan/wiki/ConfigurationExamples)

# Version

| name | version |
| :- |:- |
|ye3ipsec | 1.1.5 |
|strongswan | 6.0.2 |
|alpine | 3.22.1 |

# [Changelog](https://github.com/palw3ey/ye3ipsec/blob/main/doc/changelog.md)

# [ToDo](https://github.com/palw3ey/ye3ipsec/blob/main/doc/todo.md)

Feel free to contribute or share your ideas for new features, you can contact me here on github or by email. I speak French, you can write to me in other languages ​​I will find ways to translate.

# License

MIT  
author: palw3ey  
maintainer: palw3ey  
email: palw3ey@gmail.com  
website: https://github.com/palw3ey/ye3ipsec  
docker hub: https://hub.docker.com/r/palw3ey/ye3ipsec
