# ye3ipsec

A docker IPSec server based on Strongswan and Alpine. With remote access and site to site VPN profile. Below 70 Mb. GNS3 ready.

# Simple usage

```bash
docker run -dt --name myipsec palw3ey/ye3ipsec
```

# HOWTOs
- Show strongswan log
```bash
docker exec -it myradius sh --login -c "swanctl --log"
```


# GNS3

To run through GNS3, download and import the appliance : [ye3ipsec.gns3a](https://raw.githubusercontent.com/palw3ey/ye3ipsec/master/ye3ipsec.gns3a)

# Environment Variables

These are the env variables and their default values.  

| variables | format | default | description |
| :- |:- |:- |:- |
|Y_LANGUAGE | text | fr_FR | Language. The list is in the folder /i18n |
|Y_DEBUG | yes/no | no | yes, to show charon messages |
|Y_IGNORE_CONFIG | yes/no | no | yes, to not apply file changes in the /etc/swanctl folder. A good option if you use a custom /etc/swanctl folder mounted from outside |

# Build

To customize and create your own images.

```bash
git clone https://github.com/palw3ey/ye3ipsec.git
cd ye3ipsec
# Make all your modifications, then :
docker build --no-cache --network=host -t ye3ipsec .
docker run -dt --name my_customized_ipsec ye3ipsec
```

# Documentation

[strongswan man page](https://docs.strongswan.org/)

# Version

| name | version |
| :- |:- |
|ye3ipsec | 1.0.0 |
|strongswan | 5.9.13 |
|alpine | 3.18.4 |

# ToDo

- need to document env variables
- add more translation files in i18n folder. Contribute ! Send me your translations by mail ;)

Don't hesitate to send me your contributions, issues, improvements on github or by mail.

# License

MIT  
author: palw3ey  
maintainer: palw3ey  
email: palw3ey@gmail.com  
website: https://github.com/palw3ey/ye3ipsec  
docker hub: https://hub.docker.com/r/palw3ey/ye3ipsec
