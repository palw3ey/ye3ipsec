# GNS3

To run through GNS3, download and import the appliance : [ye3ipsec.gns3a](https://raw.githubusercontent.com/palw3ey/ye3ipsec/master/ye3ipsec.gns3a)

## How to connect the docker container in the GNS3 topology ?
Drag and drop the device in the topology. Right click on the device and select "Edit config".  
If you want a static configuration, uncomment the lines just below `# Static config for eth0` or otherwise `# DHCP config for eth0` for a dhcp configuration. Click "Save".  
Add a link to connect the device to a switch or router. Finally, right click on the device, select "Start".  
To see the output, right click "Console".  
To type commands, right click "Auxiliary console".  

## Test

Example of environment variables for PSK connections. Just copy/paste and adapt to your needs, from the below examples.  
 
Where to paste ? In GNS3 Right click on your device > Configure > General settings > Environment variables

### routerA
```plaintext
enable
configure terminal

hostname routerA

! wan
interface g0/0
ip address 10.0.1.1 255.255.0.0
ip nat outside
no shutdown
exit

! lan
interface g0/1
ip address 192.168.1.1 255.255.255.0
ip nat inside
no shutdown
exit

! nat
ip nat pool MYPOOL 10.0.1.1 10.0.1.1 netmask 255.255.255.0
access-list 1 permit 192.168.1.0 0.0.0.255
ip nat inside source list 1 pool MYPOOL overload

! port forward
ip nat inside source static udp 192.168.1.2 500 10.0.1.1 500
ip nat inside source static udp 192.168.1.2 4500 10.0.1.1 4500
do show ip nat translations

do copy running-config startup-config
```

### routerB
```plaintext
enable
configure terminal

hostname routerB

! wan
interface g0/0
ip address 10.0.2.1 255.255.0.0
ip nat outside
no shutdown
exit

! lan
interface g0/1
ip address 192.168.2.1 255.255.255.0
ip nat inside
no shutdown
exit

! nat
ip nat pool MYPOOL 10.0.2.1 10.0.2.1 netmask 255.255.255.0
access-list 1 permit 192.168.2.0 0.0.0.255
ip nat inside source list 1 pool MYPOOL overload

! port forward
ip nat inside source static udp 192.168.2.2 500 10.0.2.1 500
ip nat inside source static udp 192.168.2.2 4500 10.0.2.1 4500
do show ip nat translations

do copy running-config startup-config
```

### Device A :
External IP (wan) : 10.0.1.1  
Internal IP (lan) : 192.168.1.2  
Lan network : 192.168.1.0/24  

### Device B :
External IP (wan) : 10.0.2.1  
Internal IP (lan) : 192.168.2.2  
Lan network : 192.168.2.0/24  

## Site to site
- Device A :
```bash
Y_S2S_PSK_ENABLE=yes
Y_S2S_PSK_REMOTE_ADDRS=10.0.2.1
Y_S2S_PSK_LOCAL_ID=192.168.1.2
Y_S2S_PSK_REMOTE_ID=192.168.2.2
Y_S2S_PSK_SECRET=StrongSecret
Y_S2S_PSK_LOCAL_TS=192.168.1.0/24
Y_S2S_PSK_REMOTE_TS=192.168.2.0/24
```
- Device B :
```bash
Y_S2S_PSK_ENABLE=yes
Y_S2S_PSK_REMOTE_ADDRS=10.0.1.1
Y_S2S_PSK_LOCAL_ID=192.168.2.2
Y_S2S_PSK_REMOTE_ID=192.168.1.2
Y_S2S_PSK_SECRET=StrongSecret
Y_S2S_PSK_LOCAL_TS=192.168.2.0/24
Y_S2S_PSK_REMOTE_TS=192.168.1.0/24
```

## Client server
- Device A, as server :
```bash
Y_PSK_ENABLE=yes
Y_PSK_LOCAL_ID=192.168.1.2
Y_PSK_REMOTE_ID=192.168.2.2
Y_PSK_SECRET=StrongSecret
```
- Device B, as client :
```bash
Y_CLIENT_ENABLE=yes
Y_CLIENT_REMOTE_ADDRESS=10.0.1.2
Y_CLIENT_REMOTE_ID=192.168.1.2
Y_CLIENT_LOCAL_ID=192.168.2.2
Y_CLIENT_REMOTE_AUTH=psk
Y_CLIENT_LOCAL_AUTH=psk
Y_CLIENT_PSK_SECRET=StrongSecret
Y_CLIENT_PSK_LOCAL_ID=192.168.2.2
```
