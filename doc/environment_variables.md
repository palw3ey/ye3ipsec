# Environment Variables
These are the env variables and their default values.  

| variables | format | default | description |
| :- |:- |:- |:- |
|Y_LANGUAGE | text | fr_FR | Language. The list is in the folder /i18n |
|Y_DEBUG | yes/no | no | yes, to show charon messages |
|Y_IGNORE_CONFIG | yes/no | no | yes, to not apply file changes in the /etc/swanctl folder. A good option if you use a custom /etc/swanctl folder mounted from outside |
|Y_STRONGSWAN_VERSION | text | 5.9.14 | strongswan's version to download when building image |
|Y_EXTRA_PACKAGE | text | "net-tools traceroute tcpdump ipcalc nano" | additional package to install in the image |
|Y_URL_IP_CHECK | url | http://whatismyip.akamai.com | Url that curl will use to retrieve the public IP |
|Y_URL_IP_CHECK_TIMEOUT | integer | 5 | this is the -m option in curl : Maximum time allowed, in second |
|Y_PATCH | yes/no | yes | yes, to apply fixes before and/or after strongswan build |
|Y_PROTO_ESP | text | esp | esp protocol |
|Y_PROTO_AH | text | ah | ah protocol |
|Y_PORT_IKE | port number | 500 | ike port |
|Y_PORT_NAT | port number | 4500 | nat-t port |
|Y_SERVER_CERT_CN | IP address or domain name | *if not set, then will be set to the server certificate cn, if this certificate file exist, or will attempt to detect and use the public ip address otherwise the first local ip address* | CN value to use for the server certificate  |
|Y_SERVER_CERT_DN | text | "C=FR, ST=Ile-de-France, L=Paris, O=IPSec, OU=Example" | DN value to add to the server certificate |
|Y_SERVER_CERT_DAYS | integer | 3650 | number of days before expiration, for CA and Server certificate |
|Y_PROPOSALS_PHASE1 | cipher suite | "aes256-sha256-ecp256, aes256gcm16-sha384-prfsha384-ecp384, aes256-sha256-modp2048, aes256-sha256-modp1024, aes256-sha1-modp1024, 3des-sha1-modp1024, des-sha1-modp1024" | cipher suites to use for phase 1. Note that by default some weak cipher are present in the list, you should narrow the list to strong ones. If supported by the client |
|Y_PROPOSALS_PHASE2 | cipher suite | "aes256-sha256, aes256gcm16-ecp384, aes256-sha1, 3des-sha1, des-sha1" | cipher suites to use for phase 2. Note that by default some weak cipher are present in the list, you should narrow the list to strong ones. If supported by the client |
|Y_REKEY_PHASE1 | text | 86400s | rekey time for phase 1 |
|Y_REKEY_PHASE2 | text | 28800s | rekey time for phase 2 |
|Y_DPD_DELAY | text | 15s | delay for dead peer detection  |
|Y_DPD_ACTION | text | restart | action to take on dead peer detection timeout |
|Y_LOCAL_SELFCERT | yes/no | yes | yes, to use self-signed certificates to identify the VPN server. If set to no, you need to provide 3 files... the CA : /etc/swanctl/x509ca/chain.pem  the certificate : /etc/swanctl/x509/cert.pem  the private key : /etc/swanctl/private/privkey.pem  The same files provided by Let's Encrypt. |
|Y_LOCAL_ID | text | *if not set, will be equal to Y_SERVER_CERT_CN* | IKE identity for the VPN server |
|Y_LOCAL_SUBNET | text | "0.0.0.0/0, ::/0" | local traffic selectors |
|Y_REMOTE_SUBNET | text | dynamic | remote traffic selectors |
|Y_POOL_DHCP | yes/no | no | yes, to set the pool to dhcp and give clients an ip address from an external dhcp server. You need to specify the dhcp server. see Y_DHCP_SERVER |
|Y_POOL_IPV6_ENABLE | yes/no | yes | yes, to give clients IPv6 address |
|Y_POOL_IPV4 | IP Address, and mask | 192.168.1.1/24 | IPv4 address pool for the clients |
|Y_POOL_IPV6 | IPv6 Address, and mask | fd00::c0a8:101/120 | IPv6 address pool for the clients |
|Y_POOL_DNS4 | IP Address | "1.1.1.1, 8.8.8.8" | IPv4 DNS for the clients, primary and secondary, default are Cloudflare and Google |
|Y_POOL_DNS6 | IPv6 Address | "2606:4700:4700::1111, 2001:4860:4860::8888" | IPv6 DNS for the clients, primary and secondary, default are Cloudflare and Google |
|Y_FIREWALL_ENABLE | yes/no | no | yes, to enable the firewall rules |
|Y_FIREWALL_IPSEC_PORT | yes/no | yes | yes, to add ipsec port and protocol |
|Y_FIREWALL_NAT | yes/no | yes | yes, to add NAT rule |
|Y_FIREWALL_MANGLE | yes/no | yes | yes, to add Mangle rule |
|Y_FIREWALL_REVOCATION | yes/no | yes | yes, to add revocation rule |
|Y_FIREWALL_REVOCATION_PORT | port number | "80,8080" | port number for crl and ocsp |
|Y_FIREWALL_INTERCLIENT | yes/no | yes | yes, to allow clients to talk to each other |
|Y_FIREWALL_LAN | yes/no | yes | yes, to allow client to communicate to lan address : 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, fc00::/7 |
|Y_FIREWALL_INTERNET | yes/no | yes | yes, to allow client to communicate with internet |
|Y_FIREWALL_COMMENT_PREFIX | text | ye3ipsec | comment prefix added to firewall rules |
|Y_CERT_ENABLE | yes/no | yes | yes, to activate the RA (remote access) IKEv2 Certificate profile |
|Y_CERT_DAYS | integer | 365 | RA IKEv2 Certificate profile : How long to certify for |
|Y_CERT_REMOTE_ID | text |  | RA IKEv2 Certificate profile : remote identity |
|Y_CERT_CN | text | *(randomly generated, if not set)* | RA IKEv2 Certificate profile : CN of the client certificate |
|Y_CERT_PASSWORD | password | *(randomly generated, if not set)* | RA IKEv2 Certificate profile : password of the client p12 certificate file (/etc/swanctl/pkcs12/clientCert.p12)|
|Y_CERT_USERS | text| | RA IKEv2 Certificate profile : list of remote users to create (certificate_id:certificate_p12_password) separated by a blank space. eg: "emily:123789 elisabeth:987456" |
|Y_CERT_USERS_RANDOM | integer | | RA IKEv2 Certificate profile : number of remote users to randomly create |
|Y_CERT_P12_EXTRA | yes/no | yes | RA IKEv2 Certificate profile : yes, to add more p12 format (p12 legacy, p12 legacy no CA, p12 legacy pem) |
|Y_EAP_ENABLE | yes/no | yes | yes, to activate the RA (remote access) IKEv2 EAP profile |
|Y_EAP_REMOTE_AUTH | text | eap-mschapv2 | RA IKEv2 EAP profile : remote authentication method |
|Y_EAP_REMOTE_EAP_ID | text | %any | RA IKEv2 EAP profile : remote eap identity |
|Y_EAP_USERNAME | text | *(randomly generated, if not set)* | RA IKEv2 EAP profile : remote username  |
|Y_EAP_PASSWORD | password | *(randomly generated, if not set)* | RA IKEv2 EAP profile : remote password|
|Y_EAP_USERS | text| | RA IKEv2 EAP profile : list of remote users to create (username:password) separated by a blank space. eg: "emily:123789 elisabeth:987456" |
|Y_EAP_USERS_RANDOM | integer | | RA IKEv2 EAP profile : number of remote users to randomly create |
|Y_PSK_ENABLE | yes/no | yes | yes, to activate the RA (remote access) IKEv2 PSK profile |
|Y_PSK_LOCAL_ID | text | *(randomly generated, if not set)* | RA IKEv2 PSK profile : local identity |
|Y_PSK_REMOTE_ID | text | *(randomly generated, if not set)* | RA IKEv2 PSK profile : remote identity |
|Y_PSK_SECRET | password | *(randomly generated, if not set)* | RA IKEv2 PSK profile : shared secret |
|Y_PSK_USERS | text| | RA IKEv2 PSK profile : list of remote users to create (shared_secret:local_id:remote_id) separated by a blank space. eg: "123789:emily:emily 987456:elisabeth:elisabeth" |
|Y_PSK_USERS_RANDOM | integer | | RA IKEv2 PSK profile : number of remote users to randomly create |
|Y_XAUTH_PSK_ENABLE | yes/no | no | yes, to activate the RA (remote access) IKEv1 XAUTH PSK profile |
|Y_XAUTH_PSK_AGGRESSIVE | yes/no | yes | RA IKEv1 XAUTH PSK profile : yes, to enable aggressive mode. (use no, for main mode) |
|Y_XAUTH_PSK_REMOTE_AUTH | text | xauth | RA IKEv1 XAUTH PSK profile : remote authentication method |
|Y_XAUTH_PSK_LOCAL_ID | text | *(randomly generated, if not set)* | RA IKEv1 XAUTH PSK profile : local identity |
|Y_XAUTH_PSK_REMOTE_ID | text | *(randomly generated, if not set)* | RA IKEv1 XAUTH PSK profile : remote identity |
|Y_XAUTH_PSK_SECRET | password | *(randomly generated, if not set)* | RA IKEv1 XAUTH PSK profile : shared secret |
|Y_XAUTH_PSK_USERNAME | text | *(randomly generated, if not set)* | RA IKEv1 XAUTH PSK profile : remote username |
|Y_XAUTH_PSK_PASSWORD | password | *(randomly generated, if not set)* | RA IKEv1 XAUTH PSK profile : remote password |
|Y_XAUTH_RSA_ENABLE | yes/no | no | yes, to activate the RA (remote access) IKEv1 XAUTH RSA profile. The client p12 certificate is the same generated by Y_CERT_DAYS, Y_CERT_CN and Y_CERT_PASSWORD : /etc/swanctl/pkcs12/clientCert.p12 |
|Y_XAUTH_RSA_AGGRESSIVE | yes/no | no | RA IKEv1 XAUTH RSA profile : yes, to enable aggressive mode. (use no, for main mode) |
|Y_XAUTH_RSA_REMOTE_AUTH | text | xauth | RA IKEv1 XAUTH RSA profile : remote authentication method |
|Y_XAUTH_RSA_USERNAME | text | *(randomly generated, if not set)* | RA IKEv1 XAUTH RSA profile : remote username |
|Y_XAUTH_RSA_PASSWORD | password | *(randomly generated, if not set)* | RA IKEv1 XAUTH RSA profile : remote password |
|Y_S2S_PSK_ENABLE | yes/no | no | yes, to activate the S2S (site to site) IKEv2 PSK profile |
|Y_S2S_PSK_LOCAL_ADDRS | IP address or domain |  | S2S IKEv2 PSK profile : local address |
|Y_S2S_PSK_REMOTE_ADDRS | IP address or domain |  | S2S IKEv2 PSK profile : remote address |
|Y_S2S_PSK_LOCAL_TS | IP Address, and mask |  | S2S IKEv2 PSK profile : local traffic selectors |
|Y_S2S_PSK_REMOTE_TS | IP Address, and mask |  | S2S IKEv2 PSK profile : remote traffic selectors |
|Y_S2S_PSK_START_ACTION | text | trap | S2S IKEv2 PSK profile : start action |
|Y_S2S_PSK_LOCAL_ID | text | *(randomly generated, if not set)* | S2S IKEv2 PSK profile : local identity |
|Y_S2S_PSK_REMOTE_ID | text | *(randomly generated, if not set)* | S2S IKEv2 PSK profile : remote identity |
|Y_S2S_PSK_SECRET | password | *(randomly generated, if not set)* | S2S IKEv2 PSK profile : shared secret |
|Y_S2S_RSA_ENABLE | yes/no | no | yes, to activate the S2S (site to site) IKEv2 RSA profile |
|Y_S2S_RSA_LOCAL_ADDRS | IP address or domain |  | S2S IKEv2 RSA profile : local address |
|Y_S2S_RSA_REMOTE_ADDRS | IP address or domain |  | S2S IKEv2 RSA profile : remote address |
|Y_S2S_RSA_LOCAL_CERTS | file path |  | S2S IKEv2 RSA profile : local certificate. Y_S2S_RSA_LOCAL_ID must be set, otherwise will be ignored and will use the server selfsigned certifate by default. |
|Y_S2S_RSA_LOCAL_ID | text |  | S2S IKEv2 RSA profile : local identity. Y_S2S_RSA_LOCAL_CERTS must be set, otherwise will be ignored and will use the server selfsigned id by default. |
|Y_S2S_RSA_REMOTE_CERTS | file path |  | S2S IKEv2 RSA profile : remote certificate |
|Y_S2S_RSA_REMOTE_ID | text |  | S2S IKEv2 RSA profile : remote identity |
|Y_S2S_RSA_LOCAL_TS | IP address, with mask |  | S2S IKEv2 RSA profile : local traffic selectors |
|Y_S2S_RSA_REMOTE_TS | IP address, with mask |  | S2S IKEv2 RSA profile : remote traffic selectors |
|Y_S2S_RSA_START_ACTION | text | trap | S2S IKEv2 RSA profile : start action |
|Y_REVOCATION_LOAD | yes/no | yes | yes, to activate revocation plugin |
|Y_REVOCATION_ENABLE_CRL | yes/no | yes | REVOCATION : yes, to enable crl |
|Y_REVOCATION_ENABLE_OCSP | yes/no | yes | REVOCATION : yes, to enable ocsp |
|Y_RADIUS_LOAD | yes/no | no | yes, to activate radius plugin |
|Y_RADIUS_CLASS_GROUP | yes/no | no | RADIUS : yes, to enable class group |
|Y_RADIUS_ACCOUNTING | yes/no | no | RADIUS : yes, to enable radius accounting |
|Y_RADIUS_ADDRESS | IP address | 127.0.0.1 | RADIUS : IP address of the radius server |
|Y_RADIUS_SECRET | text | testing123 | RADIUS : secret password to connect to the radius server |
|Y_RADIUS_AUTH_PORT | port number | 1812 | RADIUS : authentication port |
|Y_RADIUS_ACCT_PORT | port number | 1813 | RADIUS : accounting port |
|Y_RADIUS_DAE_ENABLE | yes/no | no | RADIUS : yes, to enable dae (Dynamic Authorization Extensions). If you need coa (Change-of-Authorization) |
|Y_RADIUS_DAE_LISTEN | IP address | 0.0.0.0 | DAE : IP address to listen for requests |
|Y_RADIUS_DAE_PORT | port number | 3799 | DAE : Port to listen for requests |
|Y_RADIUS_DAE_SECRET | password | testing123 | DAE : shared secret |
|Y_DHCP_FORCE_SERVER_ADDRESS | yes/no | no | DHCP : yes, to enable force server address |
|Y_DCHP_IDENTITY_LEASE | yes/no | no | DHCP : yes, to enable identity lease |
|Y_DHCP_SERVER | IP address | 255.255.255.255 | DHCP : IP address of the dhcp server |
|Y_FARP_LOAD | yes/no | yes | yes, to activate farp plugin |
|Y_FORECAST_LOAD | yes/no | yes | yes, to activate forecast plugin |
|Y_BYPASSLAN_LOAD | yes/no | no | yes, to activate bypasslan plugin |
