FROM alpine:latest

MAINTAINER palw3ey <palw3ey@gmail.com>
LABEL name="ye3ipsec" version="1.0.0" author="palw3ey" maintainer="palw3ey" email="palw3ey@gmail.com" website="https://github.com/palw3ey/ye3ipsec" license="MIT" create="20231203" update="20240114" description="A docker IPSec server based on Strongswan and Alpine. RA and S2S profile. Below 70 Mb. GNS3 ready." usage="docker run -dt palw3ey/ye3ipsec" tip="The folder /etc/swanctl is persistent"

ENV Y_LANGUAGE=fr_FR \
	Y_DEBUG=no \
	Y_IGNORE_CONFIG=no \
	\
	# port
	Y_PORT_ESP=50 \
	Y_PORT_AH=51 \
	Y_PORT_IKE=500 \
	Y_PORT_NAT=4500 \
	\
	# certificate
	Y_SERVER_CERT_CN= \
	Y_SERVER_CERT_DN="C=FR, ST=Ile-de-France, L=Paris, O=IPSec, OU=Example" \
	Y_SERVER_CERT_DAYS=3650 \
	\
	# connections preference
	Y_PROPOSALS_PHASE1="aes256-sha256-ecp256, aes256gcm16-sha384-prfsha384-ecp384, aes256-sha256-modp2048, aes256-sha256-modp1024, aes256-sha1-modp1024, 3des-sha1-modp1024, des-sha1-modp1024" \
	Y_PROPOSALS_PHASE2="aes256-sha256, aes256gcm16-ecp384, aes256-sha1, 3des-sha1, des-sha1" \
	Y_REKEY_PHASE1=86400s \
	Y_REKEY_PHASE2=28800s \
	Y_DPD_DELAY=15s \
	Y_DPD_ACTION=restart \
	Y_LOCAL_SELFCERT=yes \
	Y_LOCAL_ID= \
	Y_LOCAL_SUBNET="0.0.0.0/0, ::/0" \
	Y_REMOTE_SUBNET=dynamic \
	Y_POOL_DHCP=no \
	Y_POOL_IPV6_ENABLE=yes \
	Y_POOL_IPV4=192.168.1.1/24 \
	Y_POOL_IPV6=fd00::c0a8:101/120 \
	Y_POOL_DNS4="1.1.1.1, 8.8.8.8" \
	Y_POOL_DNS6="2606:4700:4700::1111, 2001:4860:4860::8888" \
	\
	# firewall
	Y_FIREWALL_ENABLE=no \
	Y_FIREWALL_INTERCLIENT=yes \
	Y_FIREWALL_LAN=yes \
	Y_FIREWALL_INTERNET=yes \
	\
	# IKEv2 Remote Access with Virtual IP Adresses RSA
	Y_CERT_ENABLE=yes \
	Y_CERT_DAYS=365 \
	Y_CERT_REMOTE_ID= \
	Y_CERT_CN= \
	Y_CERT_PASSWORD= \
	\
	# IKEv2 Remote Access with Virtual IP Adresses EAP
	Y_EAP_ENABLE=yes \
	Y_EAP_REMOTE_AUTH=eap-mschapv2 \
	Y_EAP_REMOTE_EAP_ID=%any \
	Y_EAP_USERNAME= \
	Y_EAP_PASSWORD= \
	\
	# IKEv2 Remote Access with Virtual IP Adresses PSK
	Y_PSK_ENABLE=yes \
	Y_PSK_LOCAL_ID= \
	Y_PSK_REMOTE_ID= \
	Y_PSK_SECRET= \
	\
	# IKEv1 Remote Access with Virtual IP Adresses XAUTH PSK
	Y_XAUTH_PSK_ENABLE=no \
	Y_XAUTH_PSK_AGGRESSIVE=yes \
	Y_XAUTH_PSK_REMOTE_AUTH=xauth \
	Y_XAUTH_PSK_LOCAL_ID= \
	Y_XAUTH_PSK_REMOTE_ID= \
	Y_XAUTH_PSK_SECRET= \
	Y_XAUTH_PSK_USERNAME= \
	Y_XAUTH_PSK_PASSWORD= \
	\
	# IKEv1 Remote Access with Virtual IP Adresses XAUTH RSA
	Y_XAUTH_RSA_ENABLE=no \
	Y_XAUTH_RSA_AGGRESSIVE=no \
	Y_XAUTH_RSA_REMOTE_AUTH=xauth \
	Y_XAUTH_RSA_USERNAME= \
	Y_XAUTH_RSA_PASSWORD= \
	\
	# IKEv2 Site to Site PSK
	Y_S2S_PSK_ENABLE=no \
	Y_S2S_PSK_LOCAL_ADDRS= \
	Y_S2S_PSK_REMOTE_ADDRS= \
	Y_S2S_PSK_LOCAL_TS= \
	Y_S2S_PSK_REMOTE_TS= \
	Y_S2S_PSK_START_ACTION=trap \
	Y_S2S_PSK_LOCAL_ID= \
	Y_S2S_PSK_REMOTE_ID= \
	Y_S2S_PSK_SECRET= \
	\
	# IKEv2 Site to Site RSA
	Y_S2S_RSA_ENABLE=no \
	Y_S2S_RSA_LOCAL_ADDRS= \
	Y_S2S_RSA_REMOTE_ADDRS= \
	Y_S2S_RSA_LOCAL_CERTS= \
	Y_S2S_RSA_LOCAL_ID= \
	Y_S2S_RSA_REMOTE_CERTS= \
	Y_S2S_RSA_REMOTE_ID= \
	Y_S2S_RSA_LOCAL_TS= \
	Y_S2S_RSA_REMOTE_TS= \
	Y_S2S_RSA_START_ACTION=trap \
	\
	# revocation plugin
	Y_REVOCATION_LOAD=yes \
	Y_REVOCATION_ENABLE_CRL=yes \
	Y_REVOCATION_ENABLE_OCSP=yes \
	\
	# radius plugin
	Y_RADIUS_LOAD=no \
	Y_RADIUS_CLASS_GROUP=no \
	Y_RADIUS_ACCOUNTING=no \
	Y_RADIUS_ADDRESS=127.0.0.1 \
	Y_RADIUS_SECRET=testing123 \
	Y_RADIUS_AUTH_PORT=1812 \
	Y_RADIUS_ACCT_PORT=1813 \
	\
	# dae plugin
	Y_RADIUS_DAE_ENABLE=no \
	Y_RADIUS_DAE_LISTEN=0.0.0.0 \
	Y_RADIUS_DAE_PORT=3799 \
	Y_RADIUS_DAE_SECRET=testing123 \
	\
	# dhcp plugin
	Y_DHCP_FORCE_SERVER_ADDRESS=no \
	Y_DCHP_IDENTITY_LEASE=no \
	Y_DHCP_SERVER=255.255.255.255 \
	\
	# other plugin
	Y_FARP_LOAD=yes \
	Y_FORECAST_LOAD=yes \
	Y_BYPASSLAN_LOAD=no

ADD entrypoint.sh /
ADD i18n/ /i18n/
ADD bypass_docker_env.sh.dis /etc/profile.d/

RUN \
	# install packages
	apk --update --no-cache add build-base gmp-dev openssl openssl-dev linux-pam-dev ip6tables iptables-dev curl curl-dev &&  \
	\
	# build strongswan
	mkdir /usr/local/src && cd /usr/local/src && \
	wget https://download.strongswan.org/strongswan.tar.bz2 && tar xjvf "strongswan.tar.bz2" &&  cd strongswan*/ &&  \
	./configure --prefix= --enable-eap-identity --enable-eap-dynamic --enable-eap-mschapv2 --enable-md4 --enable-eap-md5 --enable-eap-tls --enable-eap-ttls --enable-eap-tnc --enable-eap-gtc --enable-xauth-eap --enable-xauth-noauth --enable-xauth-pam --enable-eap-peap --enable-eap-sim --enable-eap-radius --enable-openssl --enable-vici --enable-swanctl --enable-charon --enable-stroke --enable-dhcp --enable-forecast --enable-farp --enable-bypass-lan --enable-curl && \
	NB_CORES=$(grep -c '^processor' /proc/cpuinfo) && make -j$((NB_CORES+1)) -l${NB_CORES} &&  make install && \
	\
	# clean
	apk del build-base && rm -rf /tmp/* && rm -rf /var/cache/apk/* && rm -rf /usr/local/src/ &&  \
	\
	# entrypoint executable
	chmod +x /entrypoint.sh

ADD swanctl/ /etc/swanctl/

EXPOSE $Y_PORT_ESP/udp $Y_PORT_AH/udp $Y_PORT_IKE/udp $Y_PORT_NAT/udp

VOLUME "/etc/swanctl"

ENTRYPOINT sh --login -c "/entrypoint.sh"