# Changelog
## [1.1.4] - 2025-04-23
### Added
- new environment variable : Y_UPDOWN and Y_CLIENT_START_ACTION
## [1.1.3] - 2025-04-09
### Changed
- new version : just an apk update, for security (xz)
## [1.1.2] - 2025-03-16
### Changed
- new version : strongSwan 6.0.1
## [1.1.1] - 2025-03-03
### Changed
- new version : Alpine Linux 3.21.3
## [1.1.0] - 2024-12-17
### Added
- new package : openresolv ca-certificates tzdata
- start update-ca-certificates in entrypoint.sh 
- symbolic link of Let's Encrypt certificates, ISRG Root X1 and ISRG Root X2, to x509ca
- resolve plugin will use /usr/sbin/resolvconf
- new configuration file : client.conf, for easy setup as client with the help of new env variables. (eap, psk and pkcs12)
- new environment variables : TZ, Y_DATE_FORMAT, Y_SHOW_CRED (to show or hide credentials in docker logs), $Y_FILELOG_ (to log charon to file)
### Changed
- new version : strongSwan from 5.9.14 to 6.0.0, Alpine Linux from 3.20.3 to 3.21.0
### Fixed
- vg_interface_ip, to find the IP address of the default network interface 
## [1.0.8] - 2024-12-01
### Added
- new package : tini
### Changed
- use tini as entrypoint in Dockerfile
- source bypass_container_env.sh early inside entrypoint.sh
- if the env variable Y_SERVER_CERT_CN is not set, then will be set to the server certificate cn, if the certificate file exist
### Fixed
- fix an occurence of the variable vg_interface_ip (missing $)
## [1.0.7] - 2024-10-07
### Added
- new extra packages : net-tools traceroute tcpdump ipcalc nano
- new env variable : Y_EXTRA_PACKAGE, Y_URL_IP_CHECK, Y_URL_IP_CHECK_TIMEOUT, Y_FIREWALL_IPSEC_PORT, Y_FIREWALL_NAT, Y_FIREWALL_MANGLE, Y_FIREWALL_REVOCATION, Y_FIREWALL_REVOCATION_PORT, Y_FIREWALL_COMMENT_PREFIX
- Dockerfile now use org.opencontainers.image LABEL
### Changed
- rename STRONGSWAN_VERSION in Dockerfile to env variable Y_STRONGSWAN_VERSION
- the variable $vg_ip in entrypoint.sh : now curl timeout is set to 5 seconds to identify the external ip
- ameliorations in firewall.sh : use of chain, add revocation port, add f_firewall_delete_all function
- the prefix CRED_Y_ in logs now display multi users credentials in one line
- move bypass_container_env.sh to /etc/swanctl/ye3ipsec/, a symlink is created in /etc/profile.d/
## [1.0.6] - 2024-09-20
### Added
- upgrade to alpine 3.20.3
- upgrade to strongswan version 5.9.14
- support strongswan version 5.9.14 and 6.0.0beta6, thanks to Y_PATCH
- new env variable Y_PATCH, to apply fixes before and/or after strongswan build
### Changed
- new env variable Y_CERT_P12_EXTRA, to control if more p12 format (p12 legacy, p12 legacy no CA, p12 legacy pem) are created when client certificate are generated
## [1.0.5] - 2024-09-18
### Added
- functions and new env variable: Y_EAP_USERS_RANDOM, Y_CERT_USERS, Y_CERT_USERS_RANDOM, Y_PSK_USERS, Y_PSK_USERS_RANDOM, to add multiple user to Road Warrior profiles
- add pem version of p12 client certificate
- the log now show a command to display the CA certificate, and the PEM p12 client certificate
### Changed
- Rename filename bypass_docker_env.sh.dis to bypass_container_env.sh.dis
- Change in cert.sh, now it specify the certificate file to use
## [1.0.4] - 2024-09-12
### Changed
- Changed default configuration to also support native Android and iPhone VPN connection
## [1.0.3] - 2024-09-09
### Fixed
- add kmod to support ko.zst modules compression
### Changed 
- add STRONGSWAN_VERSION in Dockerfile to download a specific strongswan version
### Added
- add Dockerfile_master to build strongswan from github master
## [1.0.2] - 2024-02-14
### Fixed
- When Y_SERVER_CERT_CN is not set, entrypoint.sh will auto detect an IP address. But the IP address validation was using a bash syntax, that cause this error : "unknown operand". The fix now use a POSIX syntax.
### Added
- Improvement in the auto detect IP address for Y_SERVER_CERT_CN, if an external ip is not found then will get default route interface ip if exist, before going to the last choice : get first ip returned by the command $(hostname -i)
- A FAQ in README.md
### Changed 
- To reduce verbosity, in f_log function, show timestamp and container name only if Y_DEBUG is set to yes. 
## [1.0.1] - 2024-01-21
### Added
- new env variable : Y_EAP_USERS, to add multiple username and password to RA IKEv2 EAP profile
- A Changelog in README.md, using this syntax : [keepachangelog.com](https://keepachangelog.com/en/1.1.0/)
## [1.0.0] - 2023-12-03
### Added
- première : first release
