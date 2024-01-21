#!/bin/sh

# LABEL name="ye3ipsec" version="1.0.1" author="palw3ey" maintainer="palw3ey" email="palw3ey@gmail.com" website="https://github.com/palw3ey/ye3ipsec" license="MIT" create="20231203" update="20240121"

# Entrypoint for docker

# ============ [ global variable ] ============

# script name
vg_name=ye3ipsec

# get default interface
vg_interface=$(route | awk '/^default/{print $NF}')

# get external ip
vg_ip=$(curl -s http://whatismyip.akamai.com/)

# base directory, without ending slash
vg_dir_swanctl="/etc/swanctl"

# credential directory, without ending slash
vg_dir_credential=$vg_dir_swanctl/ye3ipsec/credential
if [[ ! -d $vg_dir_credential ]]; then
    mkdir $vg_dir_credential
fi

# ca certificate
vg_file_ca_key=$vg_dir_swanctl/private/caKey.pem
vg_file_ca_cert=$vg_dir_swanctl/x509ca/caCert.pem

# server certificate
vg_file_server_key=$vg_dir_swanctl/private/serverKey.pem
vg_file_server_cert=$vg_dir_swanctl/x509/serverCert.pem

# client certificate
vg_file_client_key=$vg_dir_swanctl/private/clientKey.pem
vg_file_client_cert=$vg_dir_swanctl/x509/clientCert.pem
vg_file_client_p12=$vg_dir_swanctl/pkcs12/clientCert

# external certificate, lets encrypt for example
vg_file_external_key=$vg_dir_swanctl/private/privkey.pem
vg_file_external_cert=$vg_dir_swanctl/x509/cert.pem

# firewall function
vg_file_firewall=$vg_dir_swanctl/ye3ipsec/firewall.sh

# ============ [ function ] ============

# echo information for docker logs
function f_log(){
	echo -e "$(date '+%Y-%m-%d %H:%M:%S') $(hostname) $vg_name: $@"
}

# create random credential
function f_credential(){
	
	vl_cred_var=$1
	vl_cred_value=$(eval "echo \$$vl_cred_var")
	
	if [[ -z $3 ]]; then
		vl_persistent="yes"
	else
		vl_persistent=$3
	fi
	
	# if env credentials not exist : generate and make persistent to survive a docker restart
	
	if [[ -z $vl_cred_value ]] ; then
		
		# verify if already exist
		if [[ -f $vg_dir_credential/$vl_cred_var ]] && [[ $vl_persistent == "yes" ]] ; then
			vl_result=$(cat $vg_dir_credential/$vl_cred_var)
		else
			# generate
			if [[ $2 == "username" ]]; then
				vl_char="a-z"
				vl_size=12
			else
				vl_char="A-Za-z0-9"
				vl_size=32
			fi
			vl_result=$(tr -dc $vl_char </dev/urandom | head -c $vl_size; echo)
			# make persistent
			if [[ $vl_persistent == "yes" ]]; then
				echo $vl_result > $vg_dir_credential/$vl_cred_var
			fi
		fi
		echo $vl_result
	else
		echo $vl_cred_value
	fi
	
}

# get EAP username and password from Y_EAP_USERS
function f_eap_users(){

	vl_users=$1
	vl_iteration=1
	
	echo "secrets {"  > $vg_dir_swanctl/conf.d/users.conf
	
	for vl_user in $vl_users; do
		vl_iteration=$((vl_iteration+1))
		if [[ $vl_user == ":"* ]]; then
			vl_id=$(f_credential vl_id username no)
		else
			vl_id=$(echo $vl_user | sed 's/:.*//')
		fi

		if [[ $vl_user == *":" ]] || [[ ! $vl_user =~ ":" ]]; then
			vl_secret=$(f_credential vl_secret password no)
		else
			vl_secret=$(echo $vl_user | sed 's/[^:]*://')
		fi

		echo -e "  eap-eap$vl_iteration { \n    id = $vl_id \n    secret = $vl_secret \n  }" >> $vg_dir_swanctl/conf.d/users.conf
		
		vl_id=
		vl_secret=
		
	done
	
	echo "}" >> $vg_dir_swanctl/conf.d/users.conf
}

# create firewall rules
if [[ -f $vg_file_firewall ]] ; then
	source $vg_file_firewall
fi

# to do before container exit
function f_pre_exit(){
	f_log "$i_exiting_in_progress"
	if [[ $Y_FIREWALL_ENABLE == "yes" ]]; then
		if iptables -nvL | grep -q "ye3ipsec" ; then
			f_log "$i_remove : $i_ipv4_firewall_rules"
			f_firewall iptables $Y_POOL_IPV4 $vg_interface D
		fi
		if ip6tables -nvL | grep -q "ye3ipsec" ; then
			f_log "$i_remove : $i_ipv6_firewall_rules"
			f_firewall ip6tables $Y_POOL_IPV6 $vg_interface D
		fi
	fi
}

# ============ [ internationalisation ] ============

# load default language
source /i18n/fr_FR.sh

# override with choosen language
if [[ $Y_LANGUAGE != "fr_FR" ]] && [[ -f /i18n/$Y_LANGUAGE.sh ]] ; then
	source /i18n/$Y_LANGUAGE.sh
fi

f_log "i18n : $Y_LANGUAGE"

# ============ [ unnecessary config ] ============

if [[ $Y_IGNORE_CONFIG == "no" ]]; then

	f_log "$i_apply_configuration"
	
	# generate strongswan.conf and symbolic link to /etc/strongswan.conf
	
	if [[ $Y_XAUTH_PSK_ENABLE == "yes" ]] || [[ $Y_XAUTH_RSA_ENABLE == "yes" ]] ; then
		vg_aggressive=yes
	else 
		vg_aggressive=no
	fi
	
	source $vg_dir_swanctl/ye3ipsec/strongswan.sh > $vg_dir_swanctl/ye3ipsec/strongswan.conf
	ln -sfn $vg_dir_swanctl/ye3ipsec/strongswan.conf /etc/strongswan.conf
	
	# credentials 
	
	# cert
	Y_CERT_CN=$(f_credential Y_CERT_CN username)
	Y_CERT_PASSWORD=$(f_credential Y_CERT_PASSWORD password)
	# eap
	Y_EAP_USERNAME=$(f_credential Y_EAP_USERNAME username)
	Y_EAP_PASSWORD=$(f_credential Y_EAP_PASSWORD password)
	# psk
	Y_PSK_LOCAL_ID=$(f_credential Y_PSK_LOCAL_ID username)
	Y_PSK_REMOTE_ID=$(f_credential Y_PSK_REMOTE_ID username)
	Y_PSK_SECRET=$(f_credential Y_PSK_SECRET password)
	# xauth psk
	Y_XAUTH_PSK_LOCAL_ID=$(f_credential Y_XAUTH_PSK_LOCAL_ID username)
	Y_XAUTH_PSK_REMOTE_ID=$(f_credential Y_XAUTH_PSK_REMOTE_ID username)
	Y_XAUTH_PSK_SECRET=$(f_credential Y_XAUTH_PSK_SECRET password)
	Y_XAUTH_PSK_USERNAME=$(f_credential Y_XAUTH_PSK_USERNAME username)
	Y_XAUTH_PSK_PASSWORD=$(f_credential Y_XAUTH_PSK_PASSWORD password)
	# xauth rsa
	Y_XAUTH_RSA_USERNAME=$(f_credential Y_XAUTH_RSA_USERNAME username)
	Y_XAUTH_RSA_PASSWORD=$(f_credential Y_XAUTH_RSA_PASSWORD password)
	# s2s psk
	Y_S2S_PSK_LOCAL_ID=$(f_credential Y_S2S_PSK_LOCAL_ID username)
	Y_S2S_PSK_REMOTE_ID=$(f_credential Y_S2S_PSK_REMOTE_ID username)
	Y_S2S_PSK_SECRET=$(f_credential Y_S2S_PSK_SECRET password)

	# if env variable Y_SERVER_CERT_CN doesn't exist, then set to external ip or first hostname ip
	
	if [[ -z "$Y_SERVER_CERT_CN" ]]; then
		if [[ $vg_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
			Y_SERVER_CERT_CN=$vg_ip
		else
			Y_SERVER_CERT_CN=$(hostname -i | cut -d ' ' -f1)
		fi
	fi
	f_log "Y_SERVER_CERT_CN = $Y_SERVER_CERT_CN"
	
	# create ca certificate

	if [ ! -f "$vg_file_ca_key" ] || [ ! -f "$vg_file_ca_cert" ] ; then
	
		f_log "$i_create_ca_certificate"
		
		pki --gen --outform pem > $vg_file_ca_key
		pki --self --lifetime $Y_SERVER_CERT_DAYS --in $vg_file_ca_key --dn "$Y_SERVER_CERT_DN, CN=$Y_SERVER_CERT_CN" --ca --outform pem > $vg_file_ca_cert
	fi
	
	# create server certificate
	
	if [ ! -f "$vg_file_server_key" ] || [ ! -f "$vg_file_server_cert" ] ; then
	
		f_log "$i_create_server_certificate"
		
		pki --gen --outform pem > $vg_file_server_key
		pki --issue --outform pem --type priv --lifetime $Y_SERVER_CERT_DAYS --in $vg_file_server_key --cacert $vg_file_ca_cert --cakey $vg_file_ca_key --dn "CN=$Y_SERVER_CERT_CN" --san "$Y_SERVER_CERT_CN" --flag clientAuth --flag serverAuth --flag ikeIntermediate 	> $vg_file_server_cert
	fi
	
	# create client certificate
	
	if [ ! -f "$vg_file_client_cert" ] ; then
	
		f_log "$i_create_client_certificate"
		
		pki --gen --outform pem > $vg_file_client_key
		pki --issue --outform pem --type priv --lifetime $Y_CERT_DAYS --in $vg_file_client_key --cacert $vg_file_ca_cert --cakey $vg_file_ca_key --dn "CN=$Y_CERT_CN" --san $Y_CERT_CN --flag clientAuth > $vg_file_client_cert
		
		# export to p12
		openssl pkcs12 -in $vg_file_client_cert -inkey $vg_file_client_key -certfile $vg_file_ca_cert -export -out $vg_file_client_p12.p12 -passout pass:$Y_CERT_PASSWORD
		
		# export to p12 legacy
		openssl pkcs12 -legacy -in $vg_file_client_cert -inkey $vg_file_client_key -certfile $vg_file_ca_cert -export -out $vg_file_client_p12.legacy.p12 -passout pass:$Y_CERT_PASSWORD
		
		# export to p12 legacy no ca
		openssl pkcs12 -legacy -in $vg_file_client_cert -inkey $vg_file_client_key -export -out $vg_file_client_p12.legacy.noca.p12 -passout pass:$Y_CERT_PASSWORD

		# export to p12 legacy pem
		openssl base64 -in $vg_file_client_p12.legacy.p12 -out $vg_file_client_p12.legacy.pem.p12

	fi

	# activate firewall and generate template
	
	if [ $Y_CERT_ENABLE == "yes" ] || [ $Y_EAP_ENABLE == "yes" ] || [ $Y_PSK_ENABLE == "yes" ] || [ $Y_XAUTH_PSK_ENABLE == "yes" ] || [ $Y_XAUTH_RSA_ENABLE == "yes" ] || [ $Y_S2S_PSK_ENABLE == "yes" ] || [ $Y_S2S_RSA_ENABLE == "yes" ] ; then

		if [[ $Y_FIREWALL_ENABLE == "yes" ]]; then
			f_log "$i_enable : $i_firewall"
			f_firewall iptables $Y_POOL_IPV4 $vg_interface A
			f_firewall ip6tables $Y_POOL_IPV6 $vg_interface A
		fi
		
		if [[ -z "$Y_LOCAL_ID" ]]; then
			Y_LOCAL_ID=$Y_SERVER_CERT_CN
		fi
		f_log "Y_LOCAL_ID = $Y_LOCAL_ID"
		
		if [ $Y_LOCAL_SELFCERT == "no" ] && [ -f "$vg_file_external_key" ] && [ -f "$vg_file_external_cert" ]; then
			f_log "$i_use : cert.pem"
			vg_local_cert=cert.pem
		else
			f_log "$i_use : $i_self_cert"
			vg_local_cert=serverCert.pem
		fi
		
		if [[ $Y_POOL_DHCP == "yes" ]]; then
			f_log "$i_use : $i_dhcp_pool"
			vg_pool=dhcp
		else
			f_log "$i_use : $i_internal_pool"
			if [[ $Y_POOL_IPV6_ENABLE == "yes" ]]; then
				f_log "$i_with_ipv6"
				vg_pool=pool-ipv4-1,pool-ipv6-1
			else
				vg_pool=pool-ipv4-1
			fi
		fi
		
		source $vg_dir_swanctl/ye3ipsec/template.sh > $vg_dir_swanctl/conf.d/template.conf
		
	else
		rm $vg_dir_swanctl/conf.d/template.conf 2>/dev/null
	fi
	
	# generate connections conf files
	
	if [[ $Y_CERT_ENABLE == "yes" ]]; then
		f_log "$i_enable : $i_certificate"
		f_log "    CRED_Y_SERVER_CERT_CN : $Y_SERVER_CERT_CN"
		f_log "    CRED_Y_CERT_CN : $Y_CERT_CN"
		f_log "    CRED_Y_CERT_PASSWORD : $Y_CERT_PASSWORD"
		source $vg_dir_swanctl/ye3ipsec/cert.sh > $vg_dir_swanctl/conf.d/cert.conf
	else
		rm $vg_dir_swanctl/conf.d/cert.conf 2>/dev/null
	fi

	if [[ $Y_EAP_ENABLE == "yes" ]]; then
		f_log "$i_enable : $i_eap"
		f_log "    CRED_Y_EAP_USERNAME : $Y_EAP_USERNAME"
		f_log "    CRED_Y_EAP_PASSWORD : $Y_EAP_PASSWORD"
		if [[ ! -z "$Y_EAP_USERS" ]]; then
			f_eap_users "$Y_EAP_USERS"
		fi
		if [[ -f $vg_dir_swanctl/conf.d/users.conf ]]; then
			f_log "    CRED_Y_EAP_USERS : "
			echo "$(cat $vg_dir_swanctl/conf.d/users.conf)"
		fi
		source $vg_dir_swanctl/ye3ipsec/eap.sh > $vg_dir_swanctl/conf.d/eap.conf
	else
		rm $vg_dir_swanctl/conf.d/eap.conf 2>/dev/null
	fi

	if [[ $Y_PSK_ENABLE == "yes" ]]; then
		f_log "$i_enable : $i_psk"
		f_log "    CRED_Y_PSK_LOCAL_ID : $Y_PSK_LOCAL_ID"
		f_log "    CRED_Y_PSK_REMOTE_ID : $Y_PSK_REMOTE_ID"
		f_log "    CRED_Y_PSK_SECRET : $Y_PSK_SECRET"
		source $vg_dir_swanctl/ye3ipsec/psk.sh > $vg_dir_swanctl/conf.d/psk.conf
	else
		rm $vg_dir_swanctl/conf.d/psk.conf 2>/dev/null
	fi
	
	if [[ $Y_XAUTH_PSK_ENABLE == "yes" ]]; then
		f_log "$i_enable : xauth psk"
		f_log "    CRED_Y_XAUTH_PSK_LOCAL_ID : $Y_XAUTH_PSK_LOCAL_ID"
		f_log "    CRED_Y_XAUTH_PSK_REMOTE_ID : $Y_XAUTH_PSK_REMOTE_ID"
		f_log "    CRED_Y_XAUTH_PSK_SECRET : $Y_XAUTH_PSK_SECRET"
		f_log "    CRED_Y_XAUTH_PSK_USERNAME : $Y_XAUTH_PSK_USERNAME"
		f_log "    CRED_Y_XAUTH_PSK_PASSWORD : $Y_XAUTH_PSK_PASSWORD"
		source $vg_dir_swanctl/ye3ipsec/xauth_psk.sh > $vg_dir_swanctl/conf.d/xauth_psk.conf
	else
		rm $vg_dir_swanctl/conf.d/xauth_psk.conf 2>/dev/null
	fi
	
	if [[ $Y_XAUTH_RSA_ENABLE == "yes" ]]; then
		f_log "$i_enable : xauth rsa"
		f_log "    CRED_Y_SERVER_CERT_CN : $Y_SERVER_CERT_CN"
		f_log "    CRED_Y_CERT_CN : $Y_CERT_CN"
		f_log "    CRED_Y_CERT_PASSWORD : $Y_CERT_PASSWORD"
		f_log "    CRED_Y_XAUTH_RSA_USERNAME : $Y_XAUTH_RSA_USERNAME"
		f_log "    CRED_Y_XAUTH_RSA_PASSWORD : $Y_XAUTH_RSA_PASSWORD"
		source $vg_dir_swanctl/ye3ipsec/xauth_rsa.sh > $vg_dir_swanctl/conf.d/xauth_rsa.conf
	else
		rm $vg_dir_swanctl/conf.d/xauth_rsa.conf 2>/dev/null
	fi
	
	if [[ $Y_S2S_PSK_ENABLE == "yes" ]]; then
		f_log "$i_enable : s2s psk"
		f_log "    CRED_Y_S2S_PSK_LOCAL_ID : $Y_S2S_PSK_LOCAL_ID"
		f_log "    CRED_Y_S2S_PSK_REMOTE_ID : $Y_S2S_PSK_REMOTE_ID"
		f_log "    CRED_Y_S2S_PSK_SECRET : $Y_S2S_PSK_SECRET"
		source $vg_dir_swanctl/ye3ipsec/s2s_psk.sh > $vg_dir_swanctl/conf.d/s2s_psk.conf
	else
		rm $vg_dir_swanctl/conf.d/s2s_psk.conf 2>/dev/null
	fi
	
	if [[ $Y_S2S_RSA_ENABLE == "yes" ]]; then
		f_log "$i_enable : s2s rsa"
		# if local certificate and id are not set, then use selfsigned
		if [[ -z $Y_S2S_RSA_LOCAL_CERTS ]] && [[ -z $Y_S2S_RSA_LOCAL_ID ]] ; then
			Y_S2S_RSA_LOCAL_CERTS=serverCert.pem
			Y_S2S_RSA_LOCAL_ID=$Y_SERVER_CERT_CN
		fi
		f_log "    CRED_Y_S2S_RSA_LOCAL_ID : $Y_S2S_RSA_LOCAL_ID"
		f_log "    CRED_Y_S2S_RSA_LOCAL_CERTS : $Y_S2S_RSA_LOCAL_CERTS"
		f_log "    CRED_Y_S2S_RSA_REMOTE_ID : $Y_S2S_RSA_REMOTE_ID"
		f_log "    CRED_Y_S2S_RSA_REMOTE_CERTS : $Y_S2S_RSA_REMOTE_CERTS"
		source $vg_dir_swanctl/ye3ipsec/s2s_rsa.sh > $vg_dir_swanctl/conf.d/s2s_rsa.conf
	else
		rm $vg_dir_swanctl/conf.d/s2s_rsa.conf 2>/dev/null
	fi
	
else

	f_log "$i_ignore_configuration"
	
fi

# ============ [ start service ] ============

f_log "$i_start : charon"
rm /var/run/charon.vici 2>/dev/null
if [[ $Y_DEBUG == "yes" ]]; then
	f_log "$i_with_debug_option"
	/libexec/ipsec/charon &
else
	/libexec/ipsec/charon > /dev/null 2>&1 &
fi

f_log "$i_waiting_for_vici"
while [ ! $(ls /var/run/charon.vici 2>/dev/null) ]; do sleep 1; done

f_log "$i_start : swanctl"
if [[ $Y_DEBUG == "yes" ]]; then
	f_log " $i_with_debug_option"
	/sbin/swanctl --load-all --noprompt
	/sbin/swanctl --log &
else
	/sbin/swanctl --load-all --noprompt > /dev/null 2>&1
fi

f_log ":: $i_ready ::"

# catch SIGTERM
trap f_pre_exit SIGTERM

# keep the server running,
if [[ $Y_DEBUG == "yes" ]]; then
	# by using tail
	tail -f /dev/null
else
	# by waiting child process 
	wait $!
fi

# before final exit
f_pre_exit

f_log ":: $i_finished ::"