
function f_firewall_delete_all () {

  	$1 -t nat -D POSTROUTING -j chain-ye3ipsec-nat
 	$1 -t mangle -D FORWARD -j chain-ye3ipsec-mangle
	$1 -D FORWARD -j chain-ye3ipsec-forward
	$1 -D OUTPUT -j chain-ye3ipsec-output
	$1 -D INPUT -j chain-ye3ipsec-input
   
 	$1 -t nat --flush chain-ye3ipsec-nat
 	$1 -t mangle --flush chain-ye3ipsec-mangle
 	$1 --flush chain-ye3ipsec-forward
 	$1 --flush chain-ye3ipsec-output
 	$1 --flush chain-ye3ipsec-input
 
	$1 -t nat --delete-chain chain-ye3ipsec-nat
	$1 -t mangle --delete-chain chain-ye3ipsec-mangle
	$1 --delete-chain chain-ye3ipsec-forward
	$1 --delete-chain chain-ye3ipsec-output
	$1 --delete-chain chain-ye3ipsec-input
 
}

function f_firewall () {

	# create chain
 	$1 -t nat -N chain-ye3ipsec-nat
 	$1 -t mangle -N chain-ye3ipsec-mangle
 	$1 -N chain-ye3ipsec-forward
 	$1 -N chain-ye3ipsec-output
 	$1 -N chain-ye3ipsec-input
  
	# IPSec connections : ESP, AH, IKE, NAT-T
	if [[ $Y_FIREWALL_IPSEC_PORT == "yes" ]]; then
		$1 -A chain-ye3ipsec-input -p udp -m multiport --dports $Y_PORT_IKE,$Y_PORT_NAT -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_ipsec_port"
		$1 -A chain-ye3ipsec-output -p udp -m multiport --sports $Y_PORT_IKE,$Y_PORT_NAT -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_ipsec_port"
		
		$1 -A chain-ye3ipsec-input -p $Y_PROTO_ESP -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_ipsec_port"
		$1 -A chain-ye3ipsec-output -p $Y_PROTO_ESP -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_ipsec_port"
			
		if [[ $1 == "iptables" ]]; then
			$1 -A chain-ye3ipsec-input -p $Y_PROTO_AH -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_ipsec_port"
			$1 -A chain-ye3ipsec-output -p $Y_PROTO_AH -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_ipsec_port"
		else
			$1 -A chain-ye3ipsec-input -m $Y_PROTO_AH -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_ipsec_port"
			$1 -A chain-ye3ipsec-output -m $Y_PROTO_AH -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_ipsec_port"
		fi
	fi
	
	# Act as a gateway, Masquerade local subnet
	if [[ $Y_FIREWALL_NAT == "yes" ]]; then
		$1 -t nat -A chain-ye3ipsec-nat -s $2 -o $3 -m policy --pol ipsec --dir out -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_nat"
		$1 -t nat -A chain-ye3ipsec-nat -s $2 -o $3 -j MASQUERADE -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_nat"
	fi

	# Prevent IP packet fragmentation
	if [[ $Y_FIREWALL_MANGLE == "yes" ]]; then
		$1 -t mangle -A chain-ye3ipsec-mangle --match policy --pol ipsec --dir in -s $2 -o $3 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360 -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_mangle"
	fi
	
	# Allow server to reach remote dns, crl and ocsp
	if [[ $Y_FIREWALL_REVOCATION == "yes" ]]; then
		$1 -A chain-ye3ipsec-output -p tcp -m multiport --dports $Y_FIREWALL_REVOCATION_PORT -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_revocation"
		$1 -A chain-ye3ipsec-output -p udp --dport 53 -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_revocation"
		$1 -A chain-ye3ipsec-output -p tcp --dport 53 -j ACCEPT -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_revocation"
	fi
	
	# local variables
	
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
	
	# forward block : most specific on top, and the less specific is following
	
	# Forward ESP : Inter client communication
	$1 -A chain-ye3ipsec-forward --match policy --pol ipsec --dir in --proto esp -s $2 -d $2 -j $vl_interclient -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_esp_interclient"
	$1 -A chain-ye3ipsec-forward --match policy --pol ipsec --dir out --proto esp -d $2 -s $2 -j $vl_interclient -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_esp_interclient"

	# Forward ESP : Private IPv4 addresses
	$1 -A chain-ye3ipsec-forward --match policy --pol ipsec --dir in --proto esp -s $2 -d $vl_private -j $vl_lan -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_esp_lan"
	$1 -A chain-ye3ipsec-forward --match policy --pol ipsec --dir out --proto esp -d $2 -s $vl_private -j $vl_lan -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_esp_lan"

	# Forward ESP : Other addresses, internet
	$1 -A chain-ye3ipsec-forward --match policy --pol ipsec --dir in --proto esp -s $2 -j $vl_internet -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_esp_internet"
	$1 -A chain-ye3ipsec-forward --match policy --pol ipsec --dir out --proto esp -d $2 -j $vl_internet -m comment --comment "${Y_FIREWALL_COMMENT_PREFIX}_esp_internet"

 	# chain
  	$1 -I INPUT 1 -j chain-ye3ipsec-input
	$1 -I OUTPUT 1 -j chain-ye3ipsec-output
	$1 -I FORWARD 1 -j chain-ye3ipsec-forward
 	$1 -t mangle -I FORWARD 1 -j chain-ye3ipsec-mangle
  	$1 -t nat -I POSTROUTING 1 -j chain-ye3ipsec-nat
	
}
