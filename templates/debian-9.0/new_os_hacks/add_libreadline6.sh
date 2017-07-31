#!/bin/bash

# Install libreadline6 so jessie agents can work on stretch
cd /tmp
curl -O http://http.us.debian.org/debian/pool/main/r/readline6/libreadline6_6.3-8+b3_$(dpkg --print-architecture).deb
dpkg -i libreadline6_6.3-8+b3_$(dpkg --print-architecture).deb
rm libreadline6_6.3-8+b3_$(dpkg --print-architecture).deb
