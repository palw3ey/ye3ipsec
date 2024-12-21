cat <<EOL
connections {
    conn-s2s_psk : template-conn {
	
		pools = 
		local_addrs = $Y_S2S_PSK_LOCAL_ADDRS
		remote_addrs = $Y_S2S_PSK_REMOTE_ADDRS

		local : template-local {
			auth = psk
			id = $Y_S2S_PSK_LOCAL_ID
		}
		remote {
			auth = psk
			id = $Y_S2S_PSK_REMOTE_ID

		}
		children {
			child-s2s_psk : template-child {
				local_ts  = $Y_S2S_PSK_LOCAL_TS
				remote_ts = $Y_S2S_PSK_REMOTE_TS
				start_action = $Y_S2S_PSK_START_ACTION
			}
		}
	}
}

secrets {
	ike-s2s_psk1 {
		secret = $Y_S2S_PSK_SECRET
		id-0 = $Y_S2S_PSK_LOCAL_ID
		id-1 = $Y_S2S_PSK_REMOTE_ID
	}
}
EOL
