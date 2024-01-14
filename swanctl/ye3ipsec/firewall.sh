function f_firewall () {
	
	if [[ $1 == "iptables" ]]; then
		vl_private="10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
	else
		vl_private="fc00::/7"
	fi
	
	if [[ $Y_FIREWALL_INTERCLIENT == "yes" ]]; then
		vl_interclient="ACCEPT"
	else
		vl_interclient="DROP"
	fi
	
	if [[ $Y_FIREWALL_LAN == "yes" ]]; then
		vl_lan="ACCEPT"
	else
		vl_lan="DROP"
	fi
	
	if [[ $Y_FIREWALL_INTERNET == "yes" ]]; then
		vl_internet="ACCEPT"
	else
		vl_internet="DROP"
	fi
	
	# localhost
	# $1 -$4 INPUT -i lo -j ACCEPT -m comment --comment "ye3ipsec_localhost"
	# $1 -$4 OUTPUT -o lo -j ACCEPT -m comment --comment "ye3ipsec_localhost"
	
	# default
	# $1 -P OUTPUT ACCEPT
	# $1 -P INPUT DROP
	# $1 -P FORWARD DROP
	
	# Allowing established
	# $1 -$4 INPUT -p all -m state --state ESTABLISHED -j ACCEPT -m comment --comment "ye3ipsec_established"
	# $1 -$4 OUTPUT -p all -m state --state ESTABLISHED -j ACCEPT -m comment --comment "ye3ipsec_established"
	
	# Act as a gateway, Masquerade local subnet
	$1 -t nat -$4 POSTROUTING -s $2 -o $3 -m policy --pol ipsec --dir out -j ACCEPT -m comment --comment "ye3ipsec_gateway"
	$1 -t nat -$4 POSTROUTING -s $2 -o $3 -j MASQUERADE -m comment --comment "ye3ipsec_gateway"

	# Prevent IP packet fragmentation
	$1 -t mangle -$4 FORWARD --match policy --pol ipsec --dir in -s $2 -o $3 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360 -m comment --comment "ye3ipsec_fragmentation"
	
	# UDP connections : ESP, AH, IKE, NAT-T
	$1 -$4 INPUT -p udp -m multiport --dports 50,51,500,4500 -j ACCEPT -m comment --comment "ye3ipsec_ipsec"
	$1 -$4 OUTPUT -p udp -m multiport --sports 50,51,500,4500 -j ACCEPT -m comment --comment "ye3ipsec_ipsec"
	
	# forward block : most specific on top, and the less specific is following
	
	# Forward ESP : Inter client communication
	$1 -$4 FORWARD --match policy --pol ipsec --dir in --proto esp -s $2 -d $2 -j $vl_interclient -m comment --comment "ye3ipsec_esp_interclient"
	$1 -$4 FORWARD --match policy --pol ipsec --dir out --proto esp -d $2 -s $2 -j $vl_interclient -m comment --comment "ye3ipsec_esp_interclient"

	# Forward ESP : Private IPv4 addresses
	$1 -$4 FORWARD --match policy --pol ipsec --dir in --proto esp -s $2 -d $vl_private -j $vl_lan -m comment --comment "ye3ipsec_esp_lan"
	$1 -$4 FORWARD --match policy --pol ipsec --dir out --proto esp -d $2 -s $vl_private -j $vl_lan -m comment --comment "ye3ipsec_esp_lan"

	# Forward ESP : Other addresses, internet
	$1 -$4 FORWARD --match policy --pol ipsec --dir in --proto esp -s $2 -j $vl_internet -m comment --comment "ye3ipsec_esp_internet"
	$1 -$4 FORWARD --match policy --pol ipsec --dir out --proto esp -d $2 -j $vl_internet -m comment --comment "ye3ipsec_esp_internet"
	
}