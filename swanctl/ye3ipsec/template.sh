cat <<EOL

template-conn {
	version = 2
	send_cert = always
	proposals = $Y_PROPOSALS_PHASE1
	encap = yes
	pools = $vg_pool
	rekey_time = $Y_REKEY_PHASE1
	dpd_delay = $Y_DPD_DELAY
	
}

template-local {
	auth = pubkey
	certs = $vg_local_cert
	id = $Y_LOCAL_ID
}
		
template-child {
	local_ts = $Y_LOCAL_SUBNET
	remote_ts = $Y_REMOTE_SUBNET
	esp_proposals = $Y_PROPOSALS_PHASE2
	rekey_time = $Y_REKEY_PHASE2
	dpd_action = $Y_DPD_ACTION
	updown = $Y_UPDOWN
}

pools {
	pool-ipv4-1 {
		addrs = $Y_POOL_IPV4
		dns = $Y_POOL_DNS4
	}
	pool-ipv6-1 {
		addrs = $Y_POOL_IPV6
		dns = $Y_POOL_DNS6
	}
}
EOL