
## These values will override container env variables, and used by entrypoint.sh on every restart. To activate and customize the configurations wanted, remove one or more # sign.

#export Y_LANGUAGE=fr_FR
#export Y_DEBUG=no
#export Y_IGNORE_CONFIG=no
#export Y_STRONGSWAN_VERSION=6.0.0
#export Y_EXTRA_PACKAGE="net-tools traceroute tcpdump ipcalc nano"
#export Y_URL_IP_CHECK=http://whatismyip.akamai.com
#export Y_URL_IP_CHECK_TIMEOUT=5
#export Y_PATCH=yes
#export Y_SHOW_CRED=yes
#export TZ=Europe/Paris
#export Y_DATE_FORMAT="%Y-%m-%dT%H:%M:%S%z"

## port
#export Y_PROTO_ESP=esp
#export Y_PROTO_AH=ah
#export Y_PORT_IKE=500
#export Y_PORT_NAT=4500

## certificate
#export Y_SERVER_CERT_CN=
#export Y_SERVER_CERT_DN="C=FR, ST=Ile-de-France, L=Paris, O=IPSec, OU=Example"
#export Y_SERVER_CERT_DAYS=3650

## connections preference
#export Y_PROPOSALS_PHASE1="aes256-sha256-ecp256, aes256gcm16-sha384-prfsha384-ecp384, aes256-sha256-modp2048, aes256-sha256-modp1024, aes256-sha1-modp1024, 3des-sha1-modp1024, des-sha1-modp1024"
#export Y_PROPOSALS_PHASE2="aes256-sha256, aes256gcm16-ecp384, aes256-sha1, 3des-sha1, des-sha1"
#export Y_REKEY_PHASE1=86400s
#export Y_REKEY_PHASE2=28800s
#export Y_DPD_DELAY=15s
#export Y_DPD_ACTION=restart
#export Y_LOCAL_SELFCERT=yes
#export Y_LOCAL_ID=
#export Y_LOCAL_SUBNET="0.0.0.0/0, ::/0"
#export Y_REMOTE_SUBNET=dynamic
#export Y_POOL_DHCP=no
#export Y_POOL_IPV6_ENABLE=yes
#export Y_POOL_IPV4=192.168.1.1/24
#export Y_POOL_IPV6=fd00::c0a8:101/120
#export Y_POOL_DNS4="1.1.1.1, 8.8.8.8"
#export Y_POOL_DNS6="2606:4700:4700::1111, 2001:4860:4860::8888"

## firewall
#export Y_FIREWALL_ENABLE=no
#export Y_FIREWALL_IPSEC_PORT=yes
#export Y_FIREWALL_NAT=yes
#export Y_FIREWALL_MANGLE=yes
#export Y_FIREWALL_REVOCATION=yes
#export Y_FIREWALL_REVOCATION_PORT=80,8080
#export Y_FIREWALL_INTERCLIENT=yes
#export Y_FIREWALL_LAN=yes
#export Y_FIREWALL_INTERNET=yes
#export Y_FIREWALL_COMMENT_PREFIX=ye3ipsec

## IKEv2 Remote Access with Virtual IP Adresses RSA
#export Y_CERT_ENABLE=yes
#export Y_CERT_DAYS=365
#export Y_CERT_REMOTE_ID=
#export Y_CERT_CN=
#export Y_CERT_PASSWORD=
#export Y_CERT_USERS=
#export Y_CERT_USERS_RANDOM=
#export Y_CERT_P12_EXTRA=yes

## IKEv2 Remote Access with Virtual IP Adresses EAP
#export Y_EAP_ENABLE=yes
#export Y_EAP_REMOTE_AUTH=eap-mschapv2
#export Y_EAP_REMOTE_EAP_ID=%any
#export Y_EAP_USERNAME=
#export Y_EAP_PASSWORD=
#export Y_EAP_USERS=
#export Y_EAP_USERS_RANDOM=

## IKEv2 Remote Access with Virtual IP Adresses PSK
#export Y_PSK_ENABLE=yes
#export Y_PSK_LOCAL_ID=
#export Y_PSK_REMOTE_ID=
#export Y_PSK_SECRET=
#export Y_PSK_USERS=
#export Y_PSK_USERS_RANDOM=

## IKEv1 Remote Access with Virtual IP Adresses XAUTH PSK
#export Y_XAUTH_PSK_ENABLE=no
#export Y_XAUTH_PSK_AGGRESSIVE=yes
#export Y_XAUTH_PSK_REMOTE_AUTH=xauth
#export Y_XAUTH_PSK_LOCAL_ID=
#export Y_XAUTH_PSK_REMOTE_ID=
#export Y_XAUTH_PSK_SECRET=
#export Y_XAUTH_PSK_USERNAME=
#export Y_XAUTH_PSK_PASSWORD=

## IKEv1 Remote Access with Virtual IP Adresses XAUTH RSA
#export Y_XAUTH_RSA_ENABLE=no
#export Y_XAUTH_RSA_AGGRESSIVE=no
#export Y_XAUTH_RSA_REMOTE_AUTH=xauth
#export Y_XAUTH_RSA_USERNAME=
#export Y_XAUTH_RSA_PASSWORD=

## IKEv2 Site to Site PSK
#export Y_S2S_PSK_ENABLE=no
#export Y_S2S_PSK_LOCAL_ADDRS=
#export Y_S2S_PSK_REMOTE_ADDRS=
#export Y_S2S_PSK_LOCAL_TS=
#export Y_S2S_PSK_REMOTE_TS=
#export Y_S2S_PSK_START_ACTION=trap
#export Y_S2S_PSK_LOCAL_ID=
#export Y_S2S_PSK_REMOTE_ID=
#export Y_S2S_PSK_SECRET=

## IKEv2 Site to Site RSA
#export Y_S2S_RSA_ENABLE=no
#export Y_S2S_RSA_LOCAL_ADDRS=
#export Y_S2S_RSA_REMOTE_ADDRS=
#export Y_S2S_RSA_LOCAL_CERTS=
#export Y_S2S_RSA_LOCAL_ID=
#export Y_S2S_RSA_REMOTE_CERTS=
#export Y_S2S_RSA_REMOTE_ID=
#export Y_S2S_RSA_LOCAL_TS=
#export Y_S2S_RSA_REMOTE_TS=
#export Y_S2S_RSA_START_ACTION=trap

## IKEv2 Client with Virtual IP Adresses 
#export Y_CLIENT_ENABLE=no
#export Y_CLIENT_REMOTE_ADDRESS=
#export Y_CLIENT_VIPS="0.0.0.0, ::"
#export Y_CLIENT_LOCAL_AUTH=
#export Y_CLIENT_LOCAL_ID=
#export Y_CLIENT_REMOTE_AUTH=
#export Y_CLIENT_REMOTE_ID=
#export Y_CLIENT_LOCAL_TS=dynamic
#export Y_CLIENT_REMOTE_TS="0.0.0.0/0, ::/0"
#export Y_CLIENT_EAP_USERNAME=
#export Y_CLIENT_EAP_PASSWORD=
#export Y_CLIENT_PSK_SECRET=
#export Y_CLIENT_PSK_LOCAL_ID=
#export Y_CLIENT_PSK_REMOTE_ID=
#export Y_CLIENT_PKCS12_FILE=
#export Y_CLIENT_PKCS12_SECRET=

## revocation plugin
#export Y_REVOCATION_LOAD=yes
#export Y_REVOCATION_ENABLE_CRL=yes
#export Y_REVOCATION_ENABLE_OCSP=yes

## radius plugin
#export Y_RADIUS_LOAD=no
#export Y_RADIUS_CLASS_GROUP=no
#export Y_RADIUS_ACCOUNTING=no
#export Y_RADIUS_ADDRESS=127.0.0.1
#export Y_RADIUS_SECRET=testing123
#export Y_RADIUS_AUTH_PORT=1812
#export Y_RADIUS_ACCT_PORT=1813

## dae plugin
#export Y_RADIUS_DAE_ENABLE=no
#export Y_RADIUS_DAE_LISTEN=0.0.0.0
#export Y_RADIUS_DAE_PORT=3799
#export Y_RADIUS_DAE_SECRET=testing123

## dhcp plugin
#export Y_DHCP_FORCE_SERVER_ADDRESS=no
#export Y_DCHP_IDENTITY_LEASE=no
#export Y_DHCP_SERVER=255.255.255.255

## other plugin
#export Y_FARP_LOAD=yes
#export Y_FORECAST_LOAD=yes
#export Y_BYPASSLAN_LOAD=no

## filelog charon
#export Y_FILELOG_DEFAULT=1
#export Y_FILELOG_PATH=/var/log/charon.log
#export Y_FILELOG_APPEND=yes
