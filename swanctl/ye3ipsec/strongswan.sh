cat <<EOL
charon {

	load_modular = yes

	# ip route list table 220
	install_routes = yes
	
	# for IKEv1 xauth  :
	i_dont_care_about_security_and_use_aggressive_mode_psk=$vg_aggressive

	 filelog {
	    	charon {
			path = $Y_FILELOG_PATH
			time_format = $Y_DATE_FORMAT
			ike_name = yes
			append = $Y_FILELOG_APPEND
			default = $Y_FILELOG_DEFAULT
			flush_line = yes
	   	}
	}

	plugins {
	
		include strongswan.d/charon/*.conf

		resolve {
			# file = /etc/resolv.conf
		    	load = yes
		    	resolvconf {
				# iface = lo.ipsec
		        	path = /usr/sbin/resolvconf
		    	}
		}

		revocation {
			load = $Y_REVOCATION_LOAD
			enable_crl = $Y_REVOCATION_ENABLE_CRL
			enable_ocsp = $Y_REVOCATION_ENABLE_OCSP
		}
	
		eap-radius {
			load = $Y_RADIUS_LOAD
			class_group = $Y_RADIUS_CLASS_GROUP
			accounting = $Y_RADIUS_ACCOUNTING
			servers {
				server-a {
					address = $Y_RADIUS_ADDRESS
					secret = $Y_RADIUS_SECRET
					auth_port = $Y_RADIUS_AUTH_PORT
					acct_port = $Y_RADIUS_ACCT_PORT
				}
			}
			dae {
				enable = $Y_RADIUS_DAE_ENABLE
				listen = $Y_RADIUS_DAE_LISTEN
				port = $Y_RADIUS_DAE_PORT
				secret = $Y_RADIUS_DAE_SECRET
			}
		}
		
		dhcp {
			force_server_address = $Y_DHCP_FORCE_SERVER_ADDRESS
			identity_lease = $Y_DCHP_IDENTITY_LEASE
			server = $Y_DHCP_SERVER
		}
		farp {
			load = $Y_FARP_LOAD
        }
		forecast {
			load = $Y_FORECAST_LOAD
        }
		bypass-lan{
			load = $Y_BYPASSLAN_LOAD
		}
	}
}

include strongswan.d/*.conf
EOL
