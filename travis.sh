#!/bin/bash
# Bash version should >= 4 to be able to run this script.

if [ -z "$TRAVIS_TAG" ]; then
    echo "UNIT TEST ONLY"
    bash release.sh test all all 0.1
else
    if [ ! -z "$ANDROID_VERSION" ]; then
      echo "Log in to docker hub"
      docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
      echo "[Version: $ANDROID_VERSION] RUN UNIT TEST, BUILD DOCKER IMAGES AND PUSH THOSE TO DOCKER HUB"
      bash release.sh all $ANDROID_VERSION all $TRAVIS_TAG
    elif [ ! -z "$REAL_DEVICE" ]; then
      echo "[SUPPORT FOR REAL DEVICE: BUILD DOCKER IMAGES AND PUSH THOSE TO DOCKER HUB ]"
      bash release_real.sh all $TRAVIS_TAG
    fi
    echo "Log out of docker hub"
    docker logout
fi
