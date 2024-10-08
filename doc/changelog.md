# Changelog

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
