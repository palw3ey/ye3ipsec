#!/bin/sh

source ye3ipsec_patch/functions.sh

# Fix build with musl C library : https://github.com/strongswan/strongswan/issues/2195
source ye3ipsec_patch/before_build/all/pf_handler.c.sh
source ye3ipsec_patch/before_build/all/farp_spoofer.c.sh
