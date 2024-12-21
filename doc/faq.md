# FAQ
- How can i run strongswan without the configurations files provided by ye3ipsec ?
---
```bash
docker run -dt --cap-add NET_ADMIN -e Y_IGNORE_CONFIG=yes --name myipsec palw3ey/ye3ipsec
```
`Y_IGNORE_CONFIG=yes`, This way you only have strongswan without any custom configurations. You can find examples on the strongswan website on how to create connections.  

If you are not comfortable, use `Y_IGNORE_CONFIG=no`, then use the environment variables which will automatically configure Strongswan with ready-made connection profiles. This is the purpose of the ye3ipsec container.

---
- With docker environment variables I can only create 1 site to site PSK profile, how do I add another site to site connection ?
---
You are not restricted to only using docker environment variables to customize the server, you can add new connections as you wish by simply adding a .conf file in this folder: `/etc/swanctl/conf.d/`

In the example of a PSK site-to-site connection where:  

site X:
```
Server IP address: X.X.X.X
Lan IP address: 10.1.0.0/16,fd00::a01:101/112
```

site Y:

```
Server IP address: Y.Y.Y.Y
Lan IP address: 10.2.0.0/16,fd00::a02:101/112
```

Connect to the site X server, and create the file `/etc/swanctl/conf.d/s2s_psk_siteY.conf` :
```bash
cat > /etc/swanctl/conf.d/s2s_psk_siteY.conf <<EOL
connections {
	conn-s2s_psk_siteY {
		version = 2
		send_cert = ifasked
		encap = yes
		rekey_time = 86400s
		dpd_delay = 15s
		proposals = aes256-sha256-ecp256
		remote_addrs = Y.Y.Y.Y

		local {
			auth = psk
			certs = serverCert.pem
			id = X.X.X.X
		}
		
		remote {
			auth = psk
			id = Y.Y.Y.Y
		}
		
		children {
			child-s2s_psk_siteY {
				local_ts  = 0.0.0.0/0,::/0
				remote_ts = 10.2.0.0/16,fd00::a02:101/112
				start_action = trap
				esp_proposals = aes256-sha256
				rekey_time = 28800s
				dpd_action = restart
			}
		}
		
	}
}

secrets {
	ike-s2s_psk_siteY {
		secret = StrongSecret
		id-0 = X.X.X.X
		id-1 = Y.Y.Y.Y
	}
}
EOL
```
reload strongswan to apply
```bash
swanctl --load-all --noprompt
```


Connect to the site Y server, and create the file `/etc/swanctl/conf.d/s2s_psk_siteX.conf` :
```bash
cat > /etc/swanctl/conf.d/s2s_psk_siteX.conf <<EOL
connections {
	conn-s2s_psk_siteX {
	
		version = 2
		send_cert = ifasked
		encap = yes
		rekey_time = 86400s
		dpd_delay = 15s
		proposals = aes256-sha256-ecp256
		remote_addrs = X.X.X.X

		local {
			auth = psk
			certs = serverCert.pem
			id = Y.Y.Y.Y
		}
		
		remote {
			auth = psk
			id = X.X.X.X
		}
		
		children {
			child-s2s_psk_siteX {
				local_ts  = 0.0.0.0/0,::/0
				remote_ts = 10.1.0.0/16,fd00::a01:101/112
				start_action = trap
				esp_proposals = aes256-sha256
				rekey_time = 28800s
				dpd_action = restart
			}
		}
		
	}
}

secrets {
	ike-s2s_psk_siteX {
		secret = StrongSecret
		id-0 = Y.Y.Y.Y
		id-1 = X.X.X.X
	}
}
EOL
```
reload strongswan to apply
```bash
swanctl --load-all --noprompt
```

You can now ping server Y Lan from server X, this will automatically bring up the connection.  
Or you can do it manually using this command from server X :
```
sudo swanctl --initiate --ike conn-s2s_psk_siteY
```

---
- How do i update my running container to the latest ye3ipsec image without losing my container data ?
---  
The folder /etc/swanctl is persistent, and won't be deleted by a `docker rm`. You can find its path on the host using this command :
```bash
docker inspect -f '{{ json .Mounts }}' myipsec | jq
```
Now you can stop and delete the container. Update the image.
```bash
# Stop and delete the container
docker stop myipsec && docker rm myipsec

# Update the image
docker pull palw3ey/ye3ipsec
```

You have 2 methods to mount the folder to your new container : use bind or volume.  

Bind method :
```bash
# Run the container, adding this option
-v YOUR_HOST_OLD_SWANCTL_FOLDER_PATH:/etc/swanctl
```

Volume method, i recommend this method :
```bash
# Create a volume named myipsec_volume
docker volume create myipsec_volume

# get its path
docker volume inspect myipsec_volume -f '{{ .Mountpoint }}'

# copy your host old /etc/swanctl content to myipsec_volume
sudo cp -a /var/lib/docker/volumes/XXXXXXXXXXXXXXXX/_data/. /var/lib/docker/volumes/myipsec_volume/_data/

# finally start your container, adding this option
--mount source=myipsec_volume,target=/etc/swanctl
```
