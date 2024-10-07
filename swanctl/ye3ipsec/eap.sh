cat <<EOL
connections {
	conn-eap : template-conn {
		
		local : template-local {
		}
		
		remote {
			auth = $Y_EAP_REMOTE_AUTH
			# uncomment this following lines if you want to attach a specific eap id to this connection
			# eap_id = $Y_EAP_REMOTE_EAP_ID
		}
		
		children {
			child-eap : template-child {
			}
		}
	}
}

secrets {
    eap-eap1 {
        id = $Y_EAP_USERNAME
        secret = $Y_EAP_PASSWORD
    }
}
EOL