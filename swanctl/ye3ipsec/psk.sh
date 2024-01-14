cat <<EOL
connections {
	conn-psk : template-conn {
		
		local : template-local {
			auth = psk
			id = $Y_PSK_LOCAL_ID
		}
		
		remote {
			auth = psk
		}
		
		children {
			child-psk : template-child {
			}
		}
	}
}
EOL