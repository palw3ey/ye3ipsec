cat <<EOL
connections {
	conn-eap : template-conn {
		
		local : template-local {
		}
		
		remote {
			auth = $Y_EAP_REMOTE_AUTH
			eap_id = $Y_EAP_REMOTE_EAP_ID
		}
		
		children {
			child-eap : template-child {
			}
		}
	}
}
EOL