FROM alpine:latest

LABEL org.opencontainers.image.title="ye3cert"
LABEL org.opencontainers.image.version="1.0.2"
LABEL org.opencontainers.image.created="2024-10-17T15:00:00-03:00"
LABEL org.opencontainers.image.revision="20241017"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.authors="palw3ey"
LABEL org.opencontainers.image.vendor="palw3ey"
LABEL org.opencontainers.image.maintainer="palw3ey"
LABEL org.opencontainers.image.email="palw3ey@gmail.com"
LABEL org.opencontainers.image.url="https://github.com/palw3ey/ye3cert"
LABEL org.opencontainers.image.documentation="https://github.com/palw3ey/ye3cert/blob/main/README.md"
LABEL org.opencontainers.image.source="https://github.com/palw3ey/ye3cert"
LABEL org.opencontainers.image.base.name="ghcr.io/palw3ey/ye3cert:1.0.2"
LABEL org.opencontainers.image.description="A docker CA server based on Openssl and Alpine. Below 20 Mb. With CRL, OCSP and HTTP. GNS3 ready."
LABEL org.opencontainers.image.usage="docker run -dt -e Y_HTTP_SHARE_CERT=yes -p 8443:443 ghcr.io/palw3ey/ye3cert:latest"
LABEL org.opencontainers.image.tip="The folder /data is persistent"
LABEL org.opencontainers.image.premiere="20231203"

MAINTAINER palw3ey <palw3ey@gmail.com>

ENV TZ=Europe/Paris \
	Y_LANGUAGE=fr_FR \
	Y_IP="" \
	Y_IP_CHECK_EXTERNAL=yes \
	Y_URL_IP_CHECK=http://whatismyip.akamai.com \
  	Y_URL_IP_CHECK_TIMEOUT=5 \
	\
	# http
	Y_HTTP=yes \
	Y_HTTP_SHARE_CERT=no \
	Y_HTTP_SHARE_FOLDER=/data/ssl/www \
	Y_HTTP_PORT=80 \
	Y_HTTP_PORT_SECURE=443 \
	\
	# crl, frenquency is in seconde
	Y_CRL=yes \
	Y_CRL_FREQUENCY=15 \
	\
	# ocsp
	Y_OCSP=yes \
	Y_OCSP_PORT=8080 \
	\
	# default certificate
	Y_DAYS=3650 \
	Y_DNS=ye3cert.test.lan \
	Y_CN= \
	Y_ORGANIZATION_NAME=Test \
	Y_EMAIL_ADDRESS=webmaster@test.lan \
	Y_COUNTRY_NAME=FR \
	Y_STATE_OR_PROVINCE_NAME=Ile-de-France \
	Y_LOCALITY_NAME=Paris \
	Y_ORGANIZATIONAL_UNIT_NAME=Web \
	Y_KEY_USAGE="nonRepudiation, digitalSignature, keyEncipherment" \
	Y_EXTENDED_KEY_USAGE="serverAuth, clientAuth" \
	Y_CA_PASS=ca \
	Y_CREATE_TEST_CLIENT=yes

ADD entrypoint.sh yee.sh /
ADD i18n/ /i18n/

RUN apk add --update --no-cache openssl tzdata lighttpd curl ; \
	cp /usr/share/zoneinfo/$TZ /etc/localtime ; \
	echo $TZ > /etc/timezone ; \
	mkdir -p /data/ssl/certs ; \
	chmod +x /entrypoint.sh ; \
	chmod +x /yee.sh ; \
	ln -sfn /yee.sh /usr/sbin/yee

ADD bypass_container_env.sh /data/

EXPOSE $Y_HTTP_PORT/tcp $Y_HTTP_PORT_SECURE/tcp $Y_OCSP_PORT/tcp

VOLUME "/data"

ENTRYPOINT sh --login -c  "/entrypoint.sh"
