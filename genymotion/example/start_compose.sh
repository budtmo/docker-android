#!/bin/bash

(export USER=$USER && export PASS=$PASS && export LICENSE=$LICENSE && docker-compose -f geny.yml up -d)
