#!/bin/sh

# This sh script help you to manage the certificate server

# default language
vg_default_language="fr_FR"

# ============ [ internationalisation ] ============

# load default language
source /i18n/$vg_default_language.sh

# override with choosen language
if [[ $Y_LANGUAGE != $vg_default_language ]] && [[ -f /i18n/$Y_LANGUAGE.sh ]] ; then
	source /i18n/$Y_LANGUAGE.sh
fi

# ============ [ function ] ============

# initial setup : create certificate authority server
f_init() {

	# ============ [ backup ] ============
	
	# stop http, crl and ocsp service
	f_stop_http
	f_stop_crl
	f_stop_ocsp

	# backup
	if [ -f "/data/ssl/cacert.pem" ]; then
		timestamp=$(date +%Y%m%d%H%M%S)
		mkdir -p /data/backup/$timestamp
		cp -R /data/ssl/* /data/backup/$timestamp
		rm -R /data/ssl/*
	fi
	
	# ============ [ preparation ] ============
	
	# if env variable Y_IP doesn't exist, then set to external ip or default route interface ip or first hostname ip
		
	if [[ -z "$Y_IP" ]]; then

		# get external ip
		if [[ $Y_IP_CHECK_EXTERNAL == "yes" ]] ; then
			vl_ip_external=$(curl -m $Y_URL_IP_CHECK_TIMEOUT -s $Y_URL_IP_CHECK)
		else 
			vl_ip_external=""
		fi
		
		# get default interface ip
		vl_interface=$(route | awk '/^default/{print $NF}')
		vl_interface_ip=$(/sbin/ifconfig $vl_interface | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
	
		# choose
		if expr "$vl_ip_external" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
			Y_IP=$vl_ip_external
		elif [[ ! -z "vl_interface_ip" ]]; then
			Y_IP=$vl_interface_ip
		else
			Y_IP=$(hostname -i | cut -d ' ' -f1)
		fi
		echo "Y_IP : $Y_IP" 
	fi

	# create directories and files

	mkdir -p /data/ssl/private > /dev/null 2>&1
	mkdir /data/ssl/csr > /dev/null 2>&1
	mkdir /data/ssl/certs > /dev/null 2>&1
	mkdir /data/ssl/newcerts > /dev/null 2>&1
	mkdir /data/ssl/www > /dev/null 2>&1
	touch /data/ssl/index.txt
	sh -c "echo 10 > /data/ssl/serial"
	sh -c "echo 10 > /data/ssl/crlnumber"

	# configure cnf file

	cp /etc/ssl/openssl.cnf /data/ssl/openssl.cnf
	sed -i "s/.\/demoCA/\/data\/ssl/" /data/ssl/openssl.cnf
	sed -i "s/default_days[[:blank:]]*=[[:blank:]]*365/default_days = $Y_DAYS/" /data/ssl/openssl.cnf
	sed -i "s/# copy_extensions = copy/copy_extensions = copy/" /data/ssl/openssl.cnf
	sed -i "/^\[ usr_cert \]/a\extendedKeyUsage = $Y_EXTENDED_KEY_USAGE" /data/ssl/openssl.cnf
	sed -i "s/# keyUsage = nonRepudiation, digitalSignature, keyEncipherment/keyUsage = $Y_KEY_USAGE/" /data/ssl/openssl.cnf
	echo "[ v3_OCSP ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = OCSPSigning
" >> /data/ssl/openssl.cnf
	echo "[ usr_cert_with_revocation ]
extendedKeyUsage = $Y_EXTENDED_KEY_USAGE
basicConstraints=CA:FALSE
keyUsage = $Y_KEY_USAGE
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
crlDistributionPoints = URI:http://$Y_IP:$Y_HTTP_PORT
authorityInfoAccess = OCSP;URI:http://$Y_IP:$Y_OCSP_PORT
" >> /data/ssl/openssl.cnf
	

	# ============ [ CA ] ============

	# create ca key and cert

	if [[ -z "$Y_CN" ]]; then
		Y_CN=$Y_IP
	fi
	echo "Y_CN : $Y_CN" 

	openssl genrsa -aes256 -passout pass:$Y_CA_PASS -out /data/ssl/private/cakey.pem 2048 > /dev/null 2>&1

	openssl req -config /data/ssl/openssl.cnf -new -x509 -nodes -extensions v3_ca -subj "/CN=$Y_CN/C=$Y_COUNTRY_NAME/ST=$Y_STATE_OR_PROVINCE_NAME/L=$Y_LOCALITY_NAME/O=$Y_ORGANIZATION_NAME/OU=$Y_ORGANIZATIONAL_UNIT_NAME/emailAddress=$Y_EMAIL_ADDRESS" -days $Y_DAYS -key /data/ssl/private/cakey.pem -passin pass:$Y_CA_PASS -out /data/ssl/cacert.pem

	# ============ [ OCSP ] ============

	# create ocsp key and cert

	openssl req -config /data/ssl/openssl.cnf -subj "/CN=$Y_CN/C=$Y_COUNTRY_NAME/ST=$Y_STATE_OR_PROVINCE_NAME/L=$Y_LOCALITY_NAME/O=$Y_ORGANIZATION_NAME/OU=$Y_ORGANIZATIONAL_UNIT_NAME/emailAddress=$Y_EMAIL_ADDRESS" -addext "subjectAltName=DNS:$Y_DNS,IP:$Y_IP" -newkey rsa:2048 -nodes -keyout /data/ssl/private/server-keY_OCSP.pem -out /data/ssl/csr/server-req_ocsp.pem > /dev/null 2>&1

	openssl ca -config /data/ssl/openssl.cnf -extensions v3_OCSP -batch -notext -keyfile /data/ssl/private/cakey.pem -cert /data/ssl/cacert.pem -passin pass:$Y_CA_PASS -out /data/ssl/certs/server-cert_ocsp.pem -infiles /data/ssl/csr/server-req_ocsp.pem > /dev/null 2>&1

	cat /data/ssl/private/server-keY_OCSP.pem /data/ssl/certs/server-cert_ocsp.pem > example.com.pem

	# ============ [ https ] ============

	# create https server key and cert
	
	f_add server $Y_CN server yes "DNS.1:$Y_DNS,IP.1:$Y_IP"
	
	# ============ [ client ] ============

	# create a test client key and cert
	
	if [[ $Y_CREATE_TEST_CLIENT == "yes" ]]; then 
		f_add tux1 pc1.test.lan 1234 yes
	fi
	
	# ============ [ finalization ] ============

	# ping gateway
	ping -c 3 $(route -n | grep 'UG[ \t]' | awk '{print $2}') > /dev/null 2>&1

	# start http server
	if [[ $Y_HTTP == "yes" ]]; then f_start_http; fi
	
	# start crl update service
	if [[ $Y_CRL == "yes" ]]; then f_start_crl; fi
	
	# start ocsp service
	if [[ $Y_OCSP == "yes" ]]; then f_start_ocsp; fi
	
	echo "$i_finished"

}

# stop http service
f_stop_http() {
	/bin/kill `/bin/ps aux | /bin/grep "/usr/sbin/lighttpd -f /data/lighttpd.conf" | /bin/grep -v grep | /usr/bin/awk '{ print $1 }'` > /dev/null 2>&1
}

# start http service
f_start_http() {

	# create a custom configuration file
	cp /etc/lighttpd/lighttpd.conf /data/lighttpd.conf
	
	# correct to actual mime-types.conf
	sed -i "s|.*include \"mime-types.conf\".*|include \"/etc/lighttpd/mime-types.conf\"|" /data/lighttpd.conf
	
	# set document root
	if [[ $Y_HTTP_SHARE_CERT == "yes" ]]; then
		sed -i "s|.*server.document-root.*|server.document-root = \"$Y_HTTP_SHARE_FOLDER\"|" /data/lighttpd.conf
		ln -sfn /data/ssl/certs $Y_HTTP_SHARE_FOLDER/certs
	else
		sed -i "s|.*server.document-root.*|server.document-root = \"/var/www/localhost/htdocs\"|" /data/lighttpd.conf
	fi
	
	# enable directory listing
	sed -i "s|.*dir-listing.activate.*|dir-listing.activate = \"enable\"|" /data/lighttpd.conf
	
	# http : set port
	sed -i "s|.*server.port.*|server.port = \"$Y_HTTP_PORT\"|" /data/lighttpd.conf
	
	# https : activate module
	sed -i '/^server.modules = (/a\"mod_openssl",' /data/lighttpd.conf
	
	# https : if external pem files are provided then used them, otherwise use selfsigned
	if [[ -f "/data/fullchain.pem" && -f "/data/privkey.pem" ]]; then
		https_key=/data/privkey.pem
		https_cert=/data/fullchain.pem
	else
		https_key=/data/ssl/private/server-key.pem
		https_cert=/data/ssl/certs/server-cert.pem
	fi
	
	# https : set port and pem files
	echo '$SERVER["socket"] == ":'$Y_HTTP_PORT_SECURE'" {
	ssl.engine = "enable"
	ssl.privkey = "'$https_key'"
	ssl.pemfile = "'$https_cert'"
	}' >> /data/lighttpd.conf
	
	# start service
	/usr/sbin/lighttpd -f /data/lighttpd.conf > /dev/null 2>&1 &
	
}

# stop crl update service
f_stop_crl() {
	/bin/kill `/bin/ps aux | /bin/grep "crond -c /data/crontabs" | /bin/grep -v grep | /usr/bin/awk '{ print $1 }'` > /dev/null 2>&1
}

# start crl update service
f_start_crl() {

	# initial crl
	(/usr/bin/openssl ca -config /data/ssl/openssl.cnf -gencrl -keyfile /data/ssl/private/cakey.pem -cert /data/ssl/cacert.pem -passin pass:$Y_CA_PASS -out /data/ssl/crl.pem ; /usr/bin/openssl crl -inform PEM -in /data/ssl/crl.pem -outform DER -out /data/ssl/certs/crl ; ln -sfn /data/ssl/certs/crl /var/www/localhost/htdocs/crl ; ln -sfn /data/ssl/certs/crl $Y_HTTP_SHARE_FOLDER/crl ) > /dev/null 2>&1
	
	# create cron folder
	mkdir /data/crontabs > /dev/null 2>&1
	
	# create cron file
	echo "*/$Y_CRL_FREQUENCY * * * * (/usr/bin/openssl ca -config /data/ssl/openssl.cnf -gencrl -keyfile /data/ssl/private/cakey.pem -cert /data/ssl/cacert.pem -passin pass:$Y_CA_PASS -out /data/ssl/crl.pem ; /usr/bin/openssl crl -inform PEM -in /data/ssl/crl.pem -outform DER -out /data/ssl/certs/crl) > /dev/null 2>&1" > /data/crontabs/root
	
	# start service
	crond -c /data/crontabs > /dev/null 2>&1 & 
}


# stop ocsp server
f_stop_ocsp() {
	/bin/kill `/bin/ps aux | /bin/grep "/usr/bin/openssl ocsp -resp_text -ignore_err -nmin 1 -port $Y_OCSP_PORT -index /data/ssl/index.txt -CA /data/ssl/cacert.pem -rkey /data/ssl/private/server-keY_OCSP.pem -rsigner /data/ssl/certs/server-cert_ocsp.pem -out /data/ssl/log.txt" | /bin/grep -v grep | /usr/bin/awk '{ print $1 }'` > /dev/null 2>&1
}

# start ocsp server
f_start_ocsp() {
	/usr/bin/openssl ocsp -resp_text -ignore_err -nmin 1 -port $Y_OCSP_PORT -index /data/ssl/index.txt -CA /data/ssl/cacert.pem -rkey /data/ssl/private/server-keY_OCSP.pem -rsigner /data/ssl/certs/server-cert_ocsp.pem -out /data/ssl/log.txt > /dev/null 2>&1 &
}

# add a certificate
f_add() {
	
	prefix=$1
	cn=$2
	password=$3
	
	# extension
	if [[ "$4" == "no" ]]; then
		usr_cert='usr_cert'
	else
		usr_cert='usr_cert_with_revocation'
	fi
	
	# san
	if [[ ! -z "$5" ]]; then
		san='-addext subjectAltName='$5
	else
		san=''
	fi
	
	# create client key and cert
	
	openssl req -config /data/ssl/openssl.cnf -newkey rsa:2048 -nodes -subj "/CN=$cn" $san -keyout /data/ssl/private/$prefix-key.pem -out /data/ssl/csr/$prefix-req.pem > /dev/null 2>&1

	openssl ca -config /data/ssl/openssl.cnf -policy policy_anything -extensions $usr_cert -batch -notext -keyfile /data/ssl/private/cakey.pem -cert /data/ssl/cacert.pem -passin pass:$Y_CA_PASS -out /data/ssl/certs/$prefix-cert.pem -infiles /data/ssl/csr/$prefix-req.pem > /dev/null 2>&1
	
	# export
	
	f_export $prefix $password
	
}

# export to p12
f_export() {

	prefix=$1
	password=$2
	
	# export to p12

	openssl pkcs12 -in /data/ssl/certs/$prefix-cert.pem -inkey /data/ssl/private/$prefix-key.pem -certfile /data/ssl/cacert.pem -export -out /data/ssl/certs/$prefix-cert.p12 -passout pass:$password 
	chmod 644 /data/ssl/certs/$prefix-cert.p12

	# export to p12 legacy

	openssl pkcs12 -legacy -in /data/ssl/certs/$prefix-cert.pem -inkey /data/ssl/private/$prefix-key.pem -certfile /data/ssl/cacert.pem -export -out /data/ssl/certs/$prefix-cert-legacy.p12 -passout pass:$password
	chmod 644 /data/ssl/certs/$prefix-cert-legacy.p12
	
	# export p12 legacy to pem

	openssl base64 -in /data/ssl/certs/$prefix-cert-legacy.p12 -out /data/ssl/certs/$prefix-cert-legacy.pem
	
}

# show crl
f_crl() {
	openssl crl -inform DER -text -noout -in /data/ssl/certs/crl
}

# test certificate against OCSP server
f_test() {
	prefix=$1
	openssl ocsp -CAfile /data/ssl/cacert.pem -issuer /data/ssl/cacert.pem -cert /data/ssl/certs/$prefix-cert.pem -url 127.0.0.1:$Y_OCSP_PORT -resp_text 
}

# revoke a certificate
f_revoke() {
	prefix=$1
	openssl ca -config /data/ssl/openssl.cnf -keyfile /data/ssl/private/cakey.pem -cert /data/ssl/cacert.pem -passin pass:$Y_CA_PASS -revoke /data/ssl/certs/$prefix-cert.pem
}

# display ca
f_ca() {
	cat /data/ssl/cacert.pem
}

# display pem certificate 
f_pem() {
	prefix=$1
	cat /data/ssl/certs/$prefix-cert.pem
}

# display p12 legacy certificate in pem
f_p12() {
	prefix=$1
	cat /data/ssl/certs/$prefix-cert-legacy.pem
}

# get certificate info
f_info() {
	prefix=$1
	openssl x509 -text -noout -in /data/ssl/certs/$prefix-cert.pem
}

# get certificate sha1 fingerprint
f_sha1() {
	prefix=$1
	openssl x509 -fingerprint -noout -sha1 -in /data/ssl/certs/$prefix-cert.pem | cut -d "=" -f2 | sed 's/://g'
}

# change timezone
f_timezone(){
	timezone=$1
	cp /usr/share/zoneinfo/$timezone /etc/localtime
	echo $timezone > /etc/timezone
	export TZ=$timezone
	date
}

# shutdown the server
f_shutdown(){
	/bin/kill `/bin/ps aux | /bin/grep "tail -f /dev/null" | /bin/grep -v grep | /usr/bin/awk '{ print $1 }'`
}

f_arg() {
	echo -e "$(hostname -i)\n$i_HELP"
}

while [ $# -gt 0 ]; do
	case "$1" in
		--action=*|-a=*)
			action="${1#*=}"
			;;
		--prefix=*|-p=*)
			prefix="${1#*=}"
			;;
		--cn=*|-c=*)
			cn="${1#*=}"
			;;
		--password=*|-pw=*)
			password="${1#*=}"
			;;
		--san=*|-s=*)
			san="${1#*=}"
			;;
		--revo=*|-r=*)
			revo="${1#*=}"
			;;
		--tz=*|-t=*)
			tz="${1#*=}"
			;;
		"?")
			f_arg
			exit 0
			;;
		*)
			echo -e "\n$i_error: $i_missing_or_invalid_argument"
			f_arg
			exit 1
	esac
	shift
done


case "$action" in
	"init")
		f_init
	;;
	"add")
		if [[ ! -z "$prefix" && ! -z "$cn" && ! -z "$password" ]]; then
			f_add $prefix $cn $password $revo $san
		else 
			f_arg
		fi
	;;
	"crl")
		f_crl
	;;
	"test"|"revoke"|"pem"|"p12"|"info"|"sha1")
		if [[ ! -z "$prefix" ]]; then
			f_$action $prefix
		else 
			f_arg
		fi
	;;
	"ca")
		f_ca
	;;
	"stop_http")
		f_stop_http
	;;
	"stop_crl")
		f_stop_crl
	;;
	"stop_ocsp")
		f_stop_ocsp
	;;
	"restart_http")
		f_stop_http
		f_start_http
	;;
	"restart_crl")
		f_stop_crl
		f_start_crl
	;;
	"restart_ocsp")
		f_stop_ocsp
		f_start_ocsp
	;;
	"timezone")
		if [[ ! -z "$tz" ]]; then
			f_timezone $tz
		else 
			f_arg
		fi
	;;
	"shutdown")
		f_shutdown
	;;
	*)
		echo -e "\n$i_error: $i_missing_or_invalid_argument"
		f_arg
		exit 1
	;;
esac
