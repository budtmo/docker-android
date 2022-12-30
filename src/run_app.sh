#!/bin/bash
curl -o src/get-pip.py https://bootstrap.pypa.io/pip/3.6/get-pip.py -o get-pip.py \
&& apt-get update \
&& apt-get install python3-apt \
&& apt-get install python3.6-distutils -y \
&& python3 src/get-pip.py \
&& pip install toml \
&& python3 -m src.app