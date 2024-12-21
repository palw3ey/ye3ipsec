cat <<EOL
connections {
    conn-xauth_rsa : template-conn {
	
		aggressive = $Y_XAUTH_RSA_AGGRESSIVE
		version = 1

		local-rsa : template-local {
		}
		remote-rsa {
			auth = pubkey
			# uncomment these 2 following lines if you want to attach a specific certificate to this connection
			# certs = clientCert.pem
			# id = "$Y_CERT_REMOTE_ID"
		}
		remote-xauth {
			auth = $Y_XAUTH_RSA_REMOTE_AUTH
		}
		children {
			child-xauth_rsa : template-child {
			}
		}
	}
}

secrets {
	xauth-xauth_rsa1 {
		id = $Y_XAUTH_RSA_USERNAME
		secret = $Y_XAUTH_RSA_PASSWORD
	}
}
EOL
