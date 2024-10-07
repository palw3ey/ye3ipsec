cat <<EOL
connections {
	conn-cert : template-conn {
		
		local : template-local {
		}
		
		remote {
			auth = pubkey
			# uncomment these 2 following lines if you want to attach a specific certificate to this connection
			# certs = clientCert.pem
			# id = "$Y_CERT_REMOTE_ID"
		}
		
		children {
			child-cert : template-child {
			}
		}
	}
}
EOL