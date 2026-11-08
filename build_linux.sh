#!/bin/bash
g++ -std=c++17 -O2 -fstack-protector-all -D_FORTIFY_SOURCE=2 \
    -fPIE -pie -Wl,-z,relro,-z,now -Wall -Wextra \
    -o secure_gatekeeper Zero-Trust.cpp

# Harden binary
chmod 700 secure_gatekeeper
strip --strip-all secure_gatekeeper