#!/bin/bash
apt update -y
curl https://sh.polyverse.io | sh -s install czcw7pjshny8lzzog8bgiizfr
apt-get update && apt-get -y install --reinstall $(dpkg --get-selections | awk '{print $1}')
