#!/bin/bash

# Run the install scripts in the background
/entrypoints/add-polyverse.sh &
# entrypoints in docker-compose overwrite CMDs in dockerfiles.
# https://github.com/docker/compose/issues/3140
/root/wireless_autoconnect.sh && /root/entry_point.sh