#!/bin/bash

(export USER=$USER && export PASS=$PASS && docker-compose -f geny.yml up -d)
