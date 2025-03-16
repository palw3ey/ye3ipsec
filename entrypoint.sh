#!/bin/sh

# Entrypoint for the container

# change timezone
cp /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone

# ============ [ global variable ] ============

# date
vg_date=$(date "+$Y_DATE_FORMAT")

# base directory, without ending slash
vg_dir_swanctl="/etc/swanctl"

# to load other env var
if [[ -f $vg_dir_swanctl/ye3ipsec/bypass_container_env.sh ]] ; then

	# create/update symbolic link for bypass_container_env.sh
	ln -sfn $vg_dir_swanctl/ye3ipsec/bypass_container_env.sh /etc/profile.d/bypass_container_env.sh
	
	# source
	source /etc/profile.d/bypass_container_env.sh > /dev/null 2>&1		
fi

# default language
vg_default_language="fr_FR"

# script name
vg_name=ye3ipsec

# get default interface
vg_interface=$(route | awk '/^default/{print $NF}')
vg_interface_ip=$(ip addr show dev $vg_interface | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

# get external ip
vg_ip=$(curl -m $Y_URL_IP_CHECK_TIMEOUT -s $Y_URL_IP_CHECK)

# credential directory, without ending slash
vg_dir_credential=$vg_dir_swanctl/ye3ipsec/credential
if [[ ! -d $vg_dir_credential ]]; then
    mkdir $vg_dir_credential
fi

# id and password parameters
vg_users_separator=":"
vg_username_char="a-z"
vg_username_length=12
vg_password_char="A-Za-z0-9"
vg_password_length=32

# ca certificate
vg_file_ca_key=$vg_dir_swanctl/private/caKey.pem
vg_file_ca_cert=$vg_dir_swanctl/x509ca/caCert.pem

# server certificate
vg_file_server_key=$vg_dir_swanctl/private/serverKey.pem
vg_file_server_cert=$vg_dir_swanctl/x509/serverCert.pem

# default client certificate
vg_file_client_key=$vg_dir_swanctl/private/clientKey.pem
vg_file_client_cert=$vg_dir_swanctl/x509/clientCert.pem
vg_file_client_p12=$vg_dir_swanctl/pkcs12/clientCert

# external certificate, lets encrypt for example
vg_file_external_key=$vg_dir_swanctl/private/privkey.pem
vg_file_external_cert=$vg_dir_swanctl/x509/cert.pem

# firewall function
vg_file_firewall=$vg_dir_swanctl/ye3ipsec/firewall.sh

# ============ [ function ] ============

# echo information for logs
function f_log(){

	# extra info in logs, if debug on
	vl_log=""
	if [[ $Y_DEBUG == "yes" ]]; then
		vl_log="$(date '+%Y-%m-%d %H:%M:%S') $(hostname) $vg_name:"
	fi

	echo -e "$vl_log $@"
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
	
	# if env credentials not exist : generate and make persistent to survive a container restart
	
	if [[ -z $vl_cred_value ]] ; then
		
		# verify if already exist
		if [[ -f $vg_dir_credential/$vl_cred_var ]] && [[ $vl_persistent == "yes" ]] ; then
			vl_result=$(cat $vg_dir_credential/$vl_cred_var)
		else
			# generate
			if [[ $2 == "username" ]]; then
				vl_char=$vg_username_char
				vl_size=$vg_username_length
			else
				vl_char=$vg_password_char
				vl_size=$vg_password_length
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

# show client credential in log
function f_show_cred(){

	vl_cred_var=$1
	vl_cred_value=$(eval "echo \$$vl_cred_var")

	if [[ ! -z "$vl_cred_value" ]]; then
		f_log "    CRED_$vl_cred_var : $vl_cred_value"
	fi
}

# create random client certificate
function f_certificate(){

	vl_cn=$1
	vl_password=$2
	
	if [[ $3 == "default" ]]; then
		vl_file=""
	else
		vl_file=$3
	fi
	
	# client certificate
	vl_file_client_key="$vg_dir_swanctl/private/clientKey${vl_file}.pem"
	vl_file_client_cert="$vg_dir_swanctl/x509/clientCert${vl_file}.pem"
	vl_file_client_p12="$vg_dir_swanctl/pkcs12/clientCert${vl_file}"
	
	pki --gen --outform pem > $vl_file_client_key
	pki --issue --outform pem --type priv --lifetime $Y_CERT_DAYS --in $vl_file_client_key --cacert $vg_file_ca_cert --cakey $vg_file_ca_key --dn "CN=$vl_cn" --san $vl_cn --flag clientAuth > $vl_file_client_cert
	
	# export to p12
	openssl pkcs12 -in $vl_file_client_cert -inkey $vl_file_client_key -certfile $vg_file_ca_cert -export -out $vl_file_client_p12.p12 -passout pass:$vl_password
	
	# export to p12 pem
	openssl base64 -in $vl_file_client_p12.p12 -out $vl_file_client_p12.pem.p12
	
	if [[ $Y_CERT_P12_EXTRA == "yes" ]]; then
	
		# export to p12 legacy
		openssl pkcs12 -legacy -in $vl_file_client_cert -inkey $vl_file_client_key -certfile $vg_file_ca_cert -export -out $vl_file_client_p12.legacy.p12 -passout pass:$vl_password
		
		# export to p12 legacy no ca
		openssl pkcs12 -legacy -in $vl_file_client_cert -inkey $vl_file_client_key -export -out $vl_file_client_p12.legacy.noca.p12 -passout pass:$vl_password

		# export to p12 legacy pem
		openssl base64 -in $vl_file_client_p12.legacy.p12 -out $vl_file_client_p12.legacy.pem.p12
	
	fi
}	

# get and create EAP username and password from Y_EAP_USERS
function f_eap_users(){

	if [[ ! -f $vg_dir_swanctl/conf.d/eap_users.conf ]] ; then
	
		vl_users=$1
		vl_iteration=1
		
		echo "secrets {"  > $vg_dir_swanctl/conf.d/eap_users.conf
		
		for vl_user in $vl_users; do
			vl_iteration=$((vl_iteration+1))
			if [[ $vl_user == "$vg_users_separator"* ]]; then
				vl_id=$(f_credential vl_id username no)
			else
				vl_id=$(echo $vl_user | sed "s/$vg_users_separator.*//")
			fi

			if [[ $vl_user == *"$vg_users_separator" ]] || [[ ! $vl_user =~ "$vg_users_separator" ]]; then
				vl_secret=$(f_credential vl_secret password no)
			else
				vl_secret=$(echo $vl_user | sed "s/[^$vg_users_separator]*$vg_users_separator//")
			fi

			echo -e "  eap-eap$vl_iteration { \n    id = $vl_id \n    secret = $vl_secret \n  }" >> $vg_dir_swanctl/conf.d/eap_users.conf
			
			vl_id=
			vl_secret=
			
		done
		
		echo "}" >> $vg_dir_swanctl/conf.d/eap_users.conf
		
	fi
}

# create x number of random EAP username and secrets
function f_eap_users_random(){

	if [[ ! -f $vg_dir_swanctl/conf.d/eap_users_random.conf ]] ; then
	
		vl_iteration=$1
		i=1
		
		echo "secrets {"  > $vg_dir_swanctl/conf.d/eap_users_random.conf
		
		while [[ $i -le $vl_iteration ]]
		do
			vl_id=$(f_credential vl_id username no)
			vl_secret=$(f_credential vl_secret password no)
			
			echo -e "  eap-eaprandom$i { \n    id = $vl_id \n    secret = $vl_secret \n  }" >> $vg_dir_swanctl/conf.d/eap_users_random.conf
			
			vl_id=
			vl_secret=
			
			i=$((i+1))
		done
		
		echo "}" >> $vg_dir_swanctl/conf.d/eap_users_random.conf
	
	fi
}

# get and create PSK and ids from Y_PSK_USERS
function f_psk_users(){

	if [[ ! -f $vg_dir_swanctl/conf.d/psk_users.conf ]] ; then
	
		vl_users=$1
		vl_iteration=1
		
		echo "secrets {"  > $vg_dir_swanctl/conf.d/psk_users.conf
		
		for vl_user in $vl_users; do
			vl_iteration=$((vl_iteration+1))
			
			if [[ $vl_user == "$vg_users_separator"* ]]; then
				vl_secret=$(f_credential vl_secret password no)
			else
				vl_secret=$(echo $vl_user | sed "s/$vg_users_separator.*//")
			fi

			vl_user_id=$(echo $vl_user | sed "s/[^$vg_users_separator]*$vg_users_separator//")
			if [[ $vl_user_id == "$vg_users_separator"* ]] || [[ -z $vl_user_id ]] || [[ ! $vl_user =~ "$vg_users_separator" ]]; then
				vl_id0=$(f_credential vl_id0 username no)
			else
				vl_id0=$(echo $vl_user_id | sed "s/$vg_users_separator.*//")
			fi
			if [[ $vl_user_id == *"$vg_users_separator" ]] || [[ ! $vl_user_id =~ "$vg_users_separator" ]]; then
				vl_id1=$(f_credential vl_id1 username no)
			else
				vl_id1=$(echo $vl_user_id | sed "s/[^$vg_users_separator]*$vg_users_separator//")
			fi

			echo -e "  ike-psk$vl_iteration { \n    secret = $vl_secret \n    id-0 = $vl_id0 \n    id-1 = $vl_id1 \n  }" >> $vg_dir_swanctl/conf.d/psk_users.conf
			
			vl_secret=
			vl_id0=
			vl_id1=
			
		done
		
		echo "}" >> $vg_dir_swanctl/conf.d/psk_users.conf
		
	fi
}

# create x number of random psk id and secrets
function f_psk_users_random(){

	if [[ ! -f $vg_dir_swanctl/conf.d/psk_users_random.conf ]] ; then
	
		vl_iteration=$1
		i=1
		
		echo "secrets {"  > $vg_dir_swanctl/conf.d/psk_users_random.conf
		
		while [[ $i -le $vl_iteration ]]
		do
			vl_id0=$(f_credential vl_id0 username no)
			vl_id1=$(f_credential vl_id1 username no)
			vl_secret=$(f_credential vl_secret password no)
			
			echo -e "  ike-pskrandom$i { \n    secret = $vl_secret \n    id-0 = $vl_id0 \n    id-1 = $vl_id1 \n  }" >> $vg_dir_swanctl/conf.d/psk_users_random.conf
			
			vl_secret=
			vl_id0=
			vl_id1=
			
			i=$((i+1))
		done
		
		echo "}" >> $vg_dir_swanctl/conf.d/psk_users_random.conf
	
	fi
}

# get and create certificates and password from Y_CERT_USERS
function f_cert_users(){

	if [[ ! -f $vg_dir_swanctl/conf.d/cert_users.txt ]] ; then
	
		vl_users=$1
		vl_iteration=1
		
		for vl_user in $vl_users; do
			vl_iteration=$((vl_iteration+1))
			if [[ $vl_user == "$vg_users_separator"* ]]; then
				vl_id=$(f_credential vl_id username no)
			else
				vl_id=$(echo $vl_user | sed "s/$vg_users_separator.*//")
			fi

			if [[ $vl_user == *"$vg_users_separator" ]] || [[ ! $vl_user =~ "$vg_users_separator" ]]; then
				vl_secret=$(f_credential vl_secret password no)
			else
				vl_secret=$(echo $vl_user | sed "s/[^$vg_users_separator]*$vg_users_separator//")
			fi

			f_certificate $vl_id $vl_secret "_$vl_id"
			
			echo -e "# cat \"/etc/swanctl/pkcs12/clientCert_${vl_id}.pem.p12\" password: $vl_secret \n" >> $vg_dir_swanctl/conf.d/cert_users.txt
			
			vl_id=
			vl_secret=
			
		done
		
	fi
}

# create x number of random certificate connections
function f_cert_users_random(){

	if [[ ! -f $vg_dir_swanctl/conf.d/cert_users_random.txt ]] ; then
	
		vl_iteration=$1
		i=1
		
		while [[ $i -le $vl_iteration ]]
		do
			vl_id=$(f_credential vl_id username no)
			vl_secret=$(f_credential vl_secret password no)
			
			f_certificate $vl_id $vl_secret "_$vl_id"
			
			echo -e "# cat \"/etc/swanctl/pkcs12/clientCert_${vl_id}.pem.p12\" password: $vl_secret \n" >> $vg_dir_swanctl/conf.d/cert_users_random.txt
			
			vl_id=
			vl_secret=
			
			i=$((i+1))
		done
	
	fi
}

function f_certificate_cn() {
    echo "$(openssl x509 -in $1 -noout -subject | sed -n 's/.*subject[[:space:]]*=[[:space:]]*CN[[:space:]]*=\([[:space:]]*\)\(.*\)/\2/p')"
}

# create firewall rules
if [[ -f $vg_file_firewall ]] ; then
	source $vg_file_firewall
fi

# to do before container exit
function f_pre_exit(){
	f_log "$i_exiting_in_progress"
	if [[ $Y_IGNORE_CONFIG == "no" ]] && [[ $Y_FIREWALL_ENABLE == "yes" ]]; then
		f_log "$i_remove : $i_ipv4_firewall_rules"
		f_firewall_delete_all iptables &> /dev/null
		f_log "$i_remove : $i_ipv6_firewall_rules"
		f_firewall_delete_all ip6tables &> /dev/null
	fi
 	kill -TERM "$child" 2>/dev/null
}

# ============ [ timestamp ] ============

echo $vg_date

# ============ [ internationalisation ] ============

# load default language
source /i18n/$vg_default_language.sh

# override with choosen language
if [[ $Y_LANGUAGE != $vg_default_language ]] && [[ -f /i18n/$Y_LANGUAGE.sh ]] ; then
	source /i18n/$Y_LANGUAGE.sh
fi

f_log "i18n : $Y_LANGUAGE"

# ============ [ unnecessary config ] ============

if [[ $Y_IGNORE_CONFIG == "no" ]]; then

	f_log "$i_apply_configuration"

	# filelog symlink
	ln -sfn $Y_FILELOG_PATH /var/log/charon.log > /dev/null 2>&1

	# update ca certificates
	update-ca-certificates > /dev/null 2>&1
	
	# add some ca certificates to x509ca folder
	ln -sfn /etc/ssl/certs/ca-cert-ISRG_Root_X1.pem /etc/swanctl/x509ca/ca-cert-ISRG_Root_X1.pem > /dev/null 2>&1
	ln -sfn /etc/ssl/certs/ca-cert-ISRG_Root_X2.pem /etc/swanctl/x509ca/ca-cert-ISRG_Root_X2.pem > /dev/null 2>&1
	
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

	# if env variable Y_SERVER_CERT_CN doesn't exist, then set to certificate cn, or external ip or default route interface ip or first hostname ip
	
	if [[ -z "$Y_SERVER_CERT_CN" ]]; then

		if [ $Y_LOCAL_SELFCERT == "no" ] && [ -f "$vg_file_external_key" ] && [ -f "$vg_file_external_cert" ]; then
			Y_SERVER_CERT_CN="$(f_certificate_cn $vg_file_external_cert)"
 		elif [[ -f "$vg_file_server_cert" ]] ; then
 			Y_SERVER_CERT_CN="$(f_certificate_cn $vg_file_server_cert)"
		elif expr "$vg_ip" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
			Y_SERVER_CERT_CN="$vg_ip"
		elif [[ ! -z "$vg_interface_ip" ]]; then
			Y_SERVER_CERT_CN="$vg_interface_ip"
		else
			Y_SERVER_CERT_CN="$(hostname -i | cut -d ' ' -f1)"
		fi
	fi
 
	f_log "Y_SERVER_CERT_CN = $Y_SERVER_CERT_CN"
	
	# create ca certificate

	if [ ! -f "$vg_file_ca_key" ] || [ ! -f "$vg_file_ca_cert" ] ; then
	
		f_log "$i_create_ca_certificate"
		
		pki --gen --outform pem > $vg_file_ca_key
		pki --self --lifetime $Y_SERVER_CERT_DAYS --in $vg_file_ca_key --dn "$Y_SERVER_CERT_DN, CN=$Y_SERVER_CERT_CN" --ca --outform pem > $vg_file_ca_cert
	fi
	
	f_log 'caCert : cat /etc/swanctl/x509ca/caCert.pem'

 	# create server certificate
   
	if [ ! -f "$vg_file_server_key" ] || [ ! -f "$vg_file_server_cert" ] ; then
	
		f_log "$i_create_server_certificate"
		
		pki --gen --outform pem > $vg_file_server_key
		pki --issue --outform pem --type priv --lifetime $Y_SERVER_CERT_DAYS --in $vg_file_server_key --cacert $vg_file_ca_cert --cakey $vg_file_ca_key --dn "CN=$Y_SERVER_CERT_CN" --san "$Y_SERVER_CERT_CN" --flag clientAuth --flag serverAuth --flag ikeIntermediate > $vg_file_server_cert

 	fi
	
	# create client certificate
   
	if [ ! -f "$vg_file_client_cert" ] || [ ! -f "$vg_file_client_key" ] ; then
	
		f_log "$i_create_client_certificate"
		
		f_certificate "$Y_CERT_CN" "$Y_CERT_PASSWORD" "default"

	fi

	# activate firewall and generate template
	
	if [ $Y_CERT_ENABLE == "yes" ] || [ $Y_EAP_ENABLE == "yes" ] || [ $Y_PSK_ENABLE == "yes" ] || [ $Y_XAUTH_PSK_ENABLE == "yes" ] || [ $Y_XAUTH_RSA_ENABLE == "yes" ] || [ $Y_S2S_PSK_ENABLE == "yes" ] || [ $Y_S2S_RSA_ENABLE == "yes" ] ; then

		if [[ $Y_FIREWALL_ENABLE == "yes" ]]; then
			f_log "$i_enable : $i_firewall"
			f_firewall_delete_all iptables &> /dev/null
    			f_firewall_delete_all ip6tables &> /dev/null
			f_firewall iptables $Y_POOL_IPV4 $vg_interface
			f_firewall ip6tables $Y_POOL_IPV6 $vg_interface
		fi
		
		if [[ -z "$Y_LOCAL_ID" ]]; then
			Y_LOCAL_ID="$Y_SERVER_CERT_CN"
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
		source $vg_dir_swanctl/ye3ipsec/cert.sh > $vg_dir_swanctl/conf.d/cert.conf
		if [[ ! -z "$Y_CERT_USERS" ]]; then
			f_cert_users "$Y_CERT_USERS"
		fi
		if [[ ! -z "$Y_CERT_USERS_RANDOM" ]]; then
			f_cert_users_random "$Y_CERT_USERS_RANDOM"
		fi
  		if [[ $Y_SHOW_CRED == "yes" ]]; then
			f_show_cred Y_SERVER_CERT_CN
			f_show_cred Y_CERT_CN
			f_show_cred Y_CERT_PASSWORD
			f_log '    CRED_Y_CERT_ : cat "/etc/swanctl/pkcs12/clientCert.pem.p12"'
			if [[ -f $vg_dir_swanctl/conf.d/cert_users.txt ]]; then
				f_log "    CRED_Y_CERT_USERS : $(cat $vg_dir_swanctl/conf.d/cert_users.txt | grep '# cat ' | tr '\n' ' ' | tr -s ' ')"
			fi
			if [[ -f $vg_dir_swanctl/conf.d/cert_users_random.txt ]]; then
				f_log "    CRED_Y_CERT_USERS_RANDOM : $(cat $vg_dir_swanctl/conf.d/cert_users_random.txt | grep '# cat ' | tr '\n' ' ' | tr -s ' ')"
			fi
   		fi
	else
		mv -f $vg_dir_swanctl/conf.d/cert.conf $vg_dir_swanctl/conf.d/cert-$vg_date.dis 2>/dev/null
		mv -f $vg_dir_swanctl/conf.d/cert_users.txt $vg_dir_swanctl/conf.d/cert_users-$vg_date.dis 2>/dev/null
		mv -f $vg_dir_swanctl/conf.d/cert_users_random.txt $vg_dir_swanctl/conf.d/cert_users_random-$vg_date.dis 2>/dev/null
	fi

	if [[ $Y_EAP_ENABLE == "yes" ]]; then
		f_log "$i_enable : $i_eap"
		source $vg_dir_swanctl/ye3ipsec/eap.sh > $vg_dir_swanctl/conf.d/eap.conf
		if [[ ! -z "$Y_EAP_USERS" ]]; then
			f_eap_users "$Y_EAP_USERS"
		fi
		if [[ ! -z "$Y_EAP_USERS_RANDOM" ]]; then
			f_eap_users_random "$Y_EAP_USERS_RANDOM"
		fi
  		if [[ $Y_SHOW_CRED == "yes" ]]; then
			f_show_cred Y_EAP_USERNAME
			f_show_cred Y_EAP_PASSWORD
			if [[ -f $vg_dir_swanctl/conf.d/eap_users.conf ]]; then
				f_log "    CRED_Y_EAP_USERS : $(cat $vg_dir_swanctl/conf.d/eap_users.conf | tr '\n' ' ' | tr -s ' ')"
			fi
			if [[ -f $vg_dir_swanctl/conf.d/eap_users_random.conf ]]; then
				f_log "    CRED_Y_EAP_USERS_RANDOM : $(cat $vg_dir_swanctl/conf.d/eap_users_random.conf | tr '\n' ' ' | tr -s ' ')"
			fi
   		fi
	else
		mv -f $vg_dir_swanctl/conf.d/eap.conf $vg_dir_swanctl/conf.d/eap-$vg_date.dis 2>/dev/null
		mv -f $vg_dir_swanctl/conf.d/eap_users.conf $vg_dir_swanctl/conf.d/eap_users-$vg_date.dis 2>/dev/null
		mv -f $vg_dir_swanctl/conf.d/eap_users_random.conf $vg_dir_swanctl/conf.d/eap_users_random-$vg_date.dis 2>/dev/null
	fi

	if [[ $Y_PSK_ENABLE == "yes" ]]; then
		f_log "$i_enable : $i_psk"
		source $vg_dir_swanctl/ye3ipsec/psk.sh > $vg_dir_swanctl/conf.d/psk.conf
		if [[ ! -z "$Y_PSK_USERS" ]]; then
			f_psk_users "$Y_PSK_USERS"
		fi
		if [[ ! -z "$Y_PSK_USERS_RANDOM" ]]; then
			f_psk_users_random "$Y_PSK_USERS_RANDOM"
		fi
  		if [[ $Y_SHOW_CRED == "yes" ]]; then
			f_show_cred Y_PSK_SECRET
			f_show_cred Y_PSK_LOCAL_ID
			f_show_cred Y_PSK_REMOTE_ID
			if [[ -f $vg_dir_swanctl/conf.d/psk_users.conf ]]; then
				f_log "    CRED_Y_PSK_USERS : $(cat $vg_dir_swanctl/conf.d/psk_users.conf | tr '\n' ' ' | tr -s ' ')"
			fi
			if [[ -f $vg_dir_swanctl/conf.d/psk_users_random.conf ]]; then
				f_log "    CRED_Y_PSK_USERS_RANDOM : $(cat $vg_dir_swanctl/conf.d/psk_users_random.conf | tr '\n' ' ' | tr -s ' ')"
			fi
   		fi
	else
		mv -f $vg_dir_swanctl/conf.d/psk.conf $vg_dir_swanctl/conf.d/psk-$vg_date.dis 2>/dev/null
		mv -f $vg_dir_swanctl/conf.d/psk_users.conf $vg_dir_swanctl/conf.d/psk_users-$vg_date.dis 2>/dev/null
		mv -f $vg_dir_swanctl/conf.d/psk_users_random.conf $vg_dir_swanctl/conf.d/psk_users_random-$vg_date.dis 2>/dev/null
	fi
	
	if [[ $Y_XAUTH_PSK_ENABLE == "yes" ]]; then
		f_log "$i_enable : xauth psk"
		source $vg_dir_swanctl/ye3ipsec/xauth_psk.sh > $vg_dir_swanctl/conf.d/xauth_psk.conf
  		if [[ $Y_SHOW_CRED == "yes" ]]; then
			f_show_cred Y_XAUTH_PSK_LOCAL_ID
			f_show_cred Y_XAUTH_PSK_REMOTE_ID
			f_show_cred Y_XAUTH_PSK_SECRET
			f_show_cred Y_XAUTH_PSK_USERNAME
			f_show_cred Y_XAUTH_PSK_PASSWORD
   		fi
	else
		mv -f $vg_dir_swanctl/conf.d/xauth_psk.conf $vg_dir_swanctl/conf.d/xauth_psk-$vg_date.dis 2>/dev/null
	fi
	
	if [[ $Y_XAUTH_RSA_ENABLE == "yes" ]]; then
		f_log "$i_enable : xauth rsa"
		source $vg_dir_swanctl/ye3ipsec/xauth_rsa.sh > $vg_dir_swanctl/conf.d/xauth_rsa.conf
	  	if [[ $Y_SHOW_CRED == "yes" ]]; then
			f_show_cred Y_SERVER_CERT_CN
			f_show_cred Y_CERT_CN
			f_show_cred Y_CERT_PASSWORD
			f_show_cred Y_XAUTH_RSA_USERNAME
			f_show_cred Y_XAUTH_RSA_PASSWORD
   		fi
	else
		mv -f $vg_dir_swanctl/conf.d/xauth_rsa.conf $vg_dir_swanctl/conf.d/xauth_rsa-$vg_date.dis 2>/dev/null
	fi
	
	if [[ $Y_S2S_PSK_ENABLE == "yes" ]]; then
		f_log "$i_enable : s2s psk"
		source $vg_dir_swanctl/ye3ipsec/s2s_psk.sh > $vg_dir_swanctl/conf.d/s2s_psk.conf
  		if [[ $Y_SHOW_CRED == "yes" ]]; then
			f_show_cred Y_S2S_PSK_LOCAL_ID
			f_show_cred Y_S2S_PSK_REMOTE_ID
			f_show_cred Y_S2S_PSK_SECRET
		fi
	else
		mv -f $vg_dir_swanctl/conf.d/s2s_psk.conf $vg_dir_swanctl/conf.d/s2s_psk-$vg_date.dis 2>/dev/null
	fi
	
	if [[ $Y_S2S_RSA_ENABLE == "yes" ]]; then
		f_log "$i_enable : s2s rsa"
		# if local certificate and id are not set, then use selfsigned
		if [[ -z $Y_S2S_RSA_LOCAL_CERTS ]] && [[ -z $Y_S2S_RSA_LOCAL_ID ]] ; then
			Y_S2S_RSA_LOCAL_CERTS=serverCert.pem
			Y_S2S_RSA_LOCAL_ID="$Y_SERVER_CERT_CN"
		fi
		source $vg_dir_swanctl/ye3ipsec/s2s_rsa.sh > $vg_dir_swanctl/conf.d/s2s_rsa.conf
  		if [[ $Y_SHOW_CRED == "yes" ]]; then
			f_show_cred Y_S2S_RSA_LOCAL_ID
			f_show_cred Y_S2S_RSA_LOCAL_CERTS
			f_show_cred Y_S2S_RSA_REMOTE_ID
			f_show_cred Y_S2S_RSA_REMOTE_CERTS
   		fi
	else
		mv -f $vg_dir_swanctl/conf.d/s2s_rsa.conf $vg_dir_swanctl/conf.d/s2s_rsa-$vg_date.dis 2>/dev/null
	fi

 	if [[ $Y_CLIENT_ENABLE == "yes" ]]; then
		f_log "$i_enable : client"
		source $vg_dir_swanctl/ye3ipsec/client.sh > $vg_dir_swanctl/conf.d/client.conf
 		if [[ $Y_SHOW_CRED == "yes" ]]; then
			f_show_cred Y_CLIENT_REMOTE_ADDRESS
			f_show_cred Y_CLIENT_LOCAL_AUTH
			f_show_cred Y_CLIENT_LOCAL_ID
			f_show_cred Y_CLIENT_REMOTE_AUTH
			f_show_cred Y_CLIENT_REMOTE_ID
	    		f_show_cred Y_CLIENT_EAP_USERNAME
	    		f_show_cred Y_CLIENT_EAP_PASSWORD
	    		f_show_cred Y_CLIENT_PSK_SECRET
	    		f_show_cred Y_CLIENT_PSK_LOCAL_ID
	    		f_show_cred Y_CLIENT_PSK_REMOTE_ID
	    		f_show_cred Y_CLIENT_PKCS12_FILE
	    		f_show_cred Y_CLIENT_PKCS12_SECRET
      		fi
	else
		mv -f $vg_dir_swanctl/conf.d/client.conf $vg_dir_swanctl/conf.d/client-$vg_date.dis 2>/dev/null
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
 	child=$! 
else
	/libexec/ipsec/charon > /dev/null 2>&1 &
 	child=$! 
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
trap f_pre_exit SIGINT SIGQUIT SIGTERM

# keep the server running,
if [[ $Y_DEBUG == "yes" ]]; then
	# by using tail
	tail -f /dev/null
else
	# by waiting child process 
	wait "$child"
fi

# before final exit
f_pre_exit

f_log ":: $i_finished ::"
