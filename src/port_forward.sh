#!/bin/bash

ip=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
socat tcp-listen:5554,bind=$ip,fork tcp:127.0.0.1:5554 &
socat tcp-listen:5555,bind=$ip,fork tcp:127.0.0.1:5555
