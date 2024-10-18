#!/bin/sh

# Entrypoint for container

# ============ [ global variable ] ============

# default language
vg_default_language="fr_FR"

# ============ [ function ] ============

# echo information for docker logs
function f_log(){
  echo -e " : $@"
}

# ============ [ internationalisation ] ============

# load default language
source /i18n/$vg_default_language.sh

# override with choosen language
if [[ $Y_LANGUAGE != $vg_default_language ]] && [[ -f /i18n/$Y_LANGUAGE.sh ]] ; then
	source /i18n/$Y_LANGUAGE.sh
fi

# ============ [ config ] ============

f_log "$i_update_timezone"
/yee.sh --action=timezone --tz=$TZ

# check ca file presence
if [ -f "/data/ssl/cacert.pem" ]; then

	if [[ $Y_HTTP == "yes" ]]; then /yee.sh --action=restart_http; fi
	
	if [[ $Y_CRL == "yes" ]]; then /yee.sh --action=restart_crl; fi
	
	if [[ $Y_OCSP == "yes" ]]; then /yee.sh --action=restart_ocsp; fi
	
else
	
	f_log "$i_run_initial_setup"
	/yee.sh --action=init

fi

# create/update symbolic link for bypass_container_env.sh
 
ln -sfn /data/bypass_container_env.sh /etc/profile.d/bypass_container_env.sh

f_log ":: $i_ready ::"

# keep the server running
tail -f /dev/null
