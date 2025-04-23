FROM alpine:latest

LABEL org.opencontainers.image.title="ye3ipsec"

LABEL org.opencontainers.image.version="1.1.4"
LABEL org.opencontainers.image.created="2025-04-23T15:00:00-03:00"
LABEL org.opencontainers.image.revision="20250423"
LABEL org.opencontainers.image.base.name="ghcr.io/palw3ey/ye3ipsec:1.1.4"

LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.authors="palw3ey"
LABEL org.opencontainers.image.vendor="palw3ey"
LABEL org.opencontainers.image.maintainer="palw3ey"
LABEL org.opencontainers.image.email="palw3ey@gmail.com"
LABEL org.opencontainers.image.url="https://github.com/palw3ey/ye3ipsec"
LABEL org.opencontainers.image.documentation="https://github.com/palw3ey/ye3ipsec/blob/main/README.md"
LABEL org.opencontainers.image.source="https://github.com/palw3ey/ye3ipsec"
LABEL org.opencontainers.image.description="IPSec client and server based on Strongswan and Alpine. RA and S2S profile. GNS3 ready"
LABEL org.opencontainers.image.usage="docker run -dt --cap-add NET_ADMIN ghcr.io/palw3ey/ye3ipsec:latest"
LABEL org.opencontainers.image.tip="The folder /etc/swanctl is persistent"
LABEL org.opencontainers.image.premiere="20231203"

ENV Y_LANGUAGE=fr_FR \
	Y_DEBUG=no \
	Y_IGNORE_CONFIG=no \
 	Y_STRONGSWAN_VERSION=6.0.1 \
  	Y_EXTRA_PACKAGE="net-tools traceroute tcpdump ipcalc nano" \
  	Y_URL_IP_CHECK=http://whatismyip.akamai.com \
  	Y_URL_IP_CHECK_TIMEOUT=5 \
	Y_PATCH=yes \
 	Y_SHOW_CRED=yes \
  	TZ=Europe/Paris \
   	Y_DATE_FORMAT="%Y-%m-%dT%H:%M:%S%z" \
	\
	# proto and port
	Y_PROTO_ESP=esp \
	Y_PROTO_AH=ah \
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
	Y_UPDOWN= \
	\
	# firewall
	Y_FIREWALL_ENABLE=no \
  	Y_FIREWALL_IPSEC_PORT=yes \
 	Y_FIREWALL_NAT=yes \
  	Y_FIREWALL_MANGLE=yes \
   	Y_FIREWALL_REVOCATION=yes \
   	Y_FIREWALL_REVOCATION_PORT=80,8080 \
	Y_FIREWALL_INTERCLIENT=yes \
	Y_FIREWALL_LAN=yes \
	Y_FIREWALL_INTERNET=yes \
 	Y_FIREWALL_COMMENT_PREFIX=ye3ipsec \
	\
	# IKEv2 Remote Access with Virtual IP Adresses RSA
	Y_CERT_ENABLE=yes \
	Y_CERT_DAYS=365 \
	Y_CERT_REMOTE_ID= \
	Y_CERT_CN= \
	Y_CERT_PASSWORD= \
	Y_CERT_USERS= \
	Y_CERT_USERS_RANDOM= \
	Y_CERT_P12_EXTRA=yes \
	\
	# IKEv2 Remote Access with Virtual IP Adresses EAP
	Y_EAP_ENABLE=yes \
	Y_EAP_REMOTE_AUTH=eap-mschapv2 \
	Y_EAP_REMOTE_EAP_ID=%any \
	Y_EAP_USERNAME= \
	Y_EAP_PASSWORD= \
	Y_EAP_USERS= \
	Y_EAP_USERS_RANDOM= \
	\
	# IKEv2 Remote Access with Virtual IP Adresses PSK
	Y_PSK_ENABLE=yes \
	Y_PSK_LOCAL_ID= \
	Y_PSK_REMOTE_ID= \
	Y_PSK_SECRET= \
	Y_PSK_USERS= \
	Y_PSK_USERS_RANDOM= \
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
	Y_S2S_PSK_LOCAL_ID= \
	Y_S2S_PSK_REMOTE_ID= \
	Y_S2S_PSK_LOCAL_TS= \
	Y_S2S_PSK_REMOTE_TS= \
	Y_S2S_PSK_START_ACTION=trap \
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
	# IKEv2 Client with Virtual IP Adresses 
	Y_CLIENT_ENABLE=no \
	Y_CLIENT_REMOTE_ADDRESS= \
	Y_CLIENT_VIPS="0.0.0.0, ::" \
	Y_CLIENT_LOCAL_AUTH= \
	Y_CLIENT_LOCAL_ID= \
	Y_CLIENT_REMOTE_AUTH= \
	Y_CLIENT_REMOTE_ID= \
	Y_CLIENT_LOCAL_TS=dynamic \
	Y_CLIENT_REMOTE_TS="0.0.0.0/0, ::/0" \
	Y_CLIENT_START_ACTION=trap|start \
	Y_CLIENT_EAP_USERNAME= \
	Y_CLIENT_EAP_PASSWORD= \
	Y_CLIENT_PSK_SECRET= \
	Y_CLIENT_PSK_LOCAL_ID= \
	Y_CLIENT_PSK_REMOTE_ID= \
	Y_CLIENT_PKCS12_FILE= \
	Y_CLIENT_PKCS12_SECRET= \
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
	Y_BYPASSLAN_LOAD=no \
	\
	# filelog charon
	Y_FILELOG_DEFAULT=1 \
	Y_FILELOG_PATH=/var/log/charon.log \
	Y_FILELOG_APPEND=yes

ADD entrypoint.sh /
ADD i18n/ /i18n/
ADD ye3ipsec_patch/ /ye3ipsec_patch/

RUN \
	# install packages
	apk --update --no-cache add tini tzdata build-base gmp-dev openssl openssl-dev linux-pam-dev ip6tables iptables-dev xz zstd kmod curl curl-dev openresolv ca-certificates $Y_EXTRA_PACKAGE && \
 	\
	# build strongswan
	mkdir /usr/local/src && cd /usr/local/src && \
	wget https://download.strongswan.org/strongswan-${Y_STRONGSWAN_VERSION}.tar.bz2 && tar xjvf "strongswan-${Y_STRONGSWAN_VERSION}.tar.bz2" &&  cd strongswan*/ &&  \
	if [[ $Y_PATCH == "yes" ]]; then cp -r /ye3ipsec_patch . ; fi && before_build=ye3ipsec_patch/before_build/all/patch.sh && if [[ -f $before_build ]]; then chmod +x $before_build && $before_build; fi && before_build=ye3ipsec_patch/before_build/$Y_STRONGSWAN_VERSION/patch.sh && if [[ -f $before_build ]]; then chmod +x $before_build && $before_build; fi && \
	./configure --prefix= --enable-eap-identity --enable-eap-dynamic --enable-eap-mschapv2 --enable-md4 --enable-eap-md5 --enable-eap-tls --enable-eap-ttls --enable-eap-tnc --enable-eap-gtc --enable-xauth-eap --enable-xauth-noauth --enable-xauth-pam --enable-eap-peap --enable-eap-sim --enable-eap-radius --enable-openssl --enable-vici --enable-swanctl --enable-charon --enable-stroke --enable-dhcp --enable-forecast --enable-farp --enable-bypass-lan --enable-curl && \
	NB_CORES=$(grep -c '^processor' /proc/cpuinfo) && make -j$((NB_CORES+1)) -l${NB_CORES} &&  make install && \
	after_build=ye3ipsec_patch/after_build/all/patch.sh && if [[ -f $after_build ]]; then chmod +x $after_build && $after_build; fi && after_build=ye3ipsec_patch/after_build/$Y_STRONGSWAN_VERSION/patch.sh && if [[ -f $after_build ]]; then chmod +x $after_build && $after_build; fi && \
	\
	# clean
	apk del build-base && rm -rf /tmp/* && rm -rf /var/cache/apk/* && rm -rf /usr/local/src/

ADD swanctl/ /etc/swanctl/

VOLUME "/etc/swanctl"

RUN \
	# timezone
	cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
 	\
	# to bypass env variable
 	ln -sfn /etc/swanctl/ye3ipsec/bypass_container_env.sh /etc/profile.d/bypass_container_env.sh && \
  	\
      	# make executable
      	chmod +x /entrypoint.sh

EXPOSE $Y_PORT_IKE/udp $Y_PORT_NAT/udp

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
