cat <<EOL
connections {
	conn-client : template-conn {
   
		remote_addrs = $Y_CLIENT_REMOTE_ADDRESS
		vips = $Y_CLIENT_VIPS

		local {
			auth = $Y_CLIENT_LOCAL_AUTH
			id = $Y_CLIENT_LOCAL_ID
		}
		
		remote {
			auth = $Y_CLIENT_REMOTE_AUTH
			id = $Y_CLIENT_REMOTE_ID
		}
		
		children {
			child-client : template-child {
				local_ts = $Y_CLIENT_LOCAL_TS
				remote_ts = $Y_CLIENT_REMOTE_TS
				start_action = $Y_CLIENT_START_ACTION
			}
		}
	}
}

secrets {
	eap-client1 {
		id = $Y_CLIENT_EAP_USERNAME
		secret = $Y_CLIENT_EAP_PASSWORD
	}
	
	ike-client1 {
		secret = $Y_CLIENT_PSK_SECRET
		id-0 = $Y_CLIENT_PSK_LOCAL_ID
		id-1 = $Y_CLIENT_PSK_REMOTE_ID
	}
	
	pkcs12-client1 {
      		file = $Y_CLIENT_PKCS12_FILE
      		secret = $Y_CLIENT_PKCS12_SECRET
   	}
}
EOL
