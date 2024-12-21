#!/bin/sh

# https://github.com/strongswan/strongswan/commit/f5b1ca4ef60bc4fca91f0d1e852ef8447d23c99a

f_replace "xxd" "src/libcharon/network/pf_handler.c" "ye3ipsec_patch/before_build/all/pf_handler.c_search.txt" "ye3ipsec_patch/before_build/all/pf_handler.c_replacement.txt"
