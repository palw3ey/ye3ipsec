cat <<EOL
connections {
	conn-cert : template-conn {
		
		local : template-local {
		}
		
		remote {
			auth = pubkey
			id = $Y_CERT_REMOTE_ID
		}
		
		children {
			child-cert : template-child {
			}
		}
	}
}
EOL