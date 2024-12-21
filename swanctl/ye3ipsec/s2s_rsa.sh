cat <<EOL
connections {
    conn-s2s_rsa : template-conn {
	
		pools = 
		local_addrs  = $Y_S2S_RSA_LOCAL_ADDRS
		remote_addrs = $Y_S2S_RSA_REMOTE_ADDRS

		local : template-local {
			certs = $Y_S2S_RSA_LOCAL_CERTS
			id = $Y_S2S_RSA_LOCAL_ID
		}
		remote {
			auth = pubkey
			certs = $Y_S2S_RSA_REMOTE_CERTS
			id = $Y_S2S_RSA_REMOTE_ID
		}
		children {
			child-s2s_rsa : template-child {
				local_ts = $Y_S2S_RSA_LOCAL_TS
				remote_ts = $Y_S2S_RSA_REMOTE_TS
				start_action = $Y_S2S_RSA_START_ACTION
			}
		}
	}
}
EOL
