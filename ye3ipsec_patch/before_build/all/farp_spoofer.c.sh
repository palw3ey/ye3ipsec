#!/bin/sh

# https://github.com/strongswan/strongswan/commit/540881627fe8083207f9a2cfd01b931164c7ef4e

f_replace "xxd" "src/libcharon/plugins/farp/farp_spoofer.c" "ye3ipsec_patch/before_build/all/farp_spoofer.c_search.txt" "ye3ipsec_patch/before_build/all/farp_spoofer.c_replacement.txt"
