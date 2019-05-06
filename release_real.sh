#!/bin/bash

if [ -z "$1" ]; then
    read -p "Task (build|push|all) : " TASK
else
    TASK=$1
fi

if [ -z "$2" ]; then
    read -p "Release version: " RELEASE
else
    RELEASE=$2
fi

IMAGE="budtmo/docker-android"
FILE_NAME=docker/Real_device

image_version="$IMAGE-real-device:$RELEASE"
image_latest="$IMAGE-real-device:latest"

function build() {
  echo "[BUILD] Image name: $image_version and $image_latest"
  echo "[BUILD] Dockerfile: $FILE_NAME"
  docker build -t $image_version --build-arg TOKEN=$TOKEN --build-arg APP_RELEASE_VERSION=$RELEASE -f $FILE_NAME .
  docker tag $image_version $image_latest
}

function push() {
  echo "[PUSH] Image name: $image_version and $image_latest"
  docker push $image_version
  docker push $image_latest
}

case $TASK in
    build)
        build
    ;;
    push)
        push
    ;;
    all)
        build
        push
    ;;
    *)
        echo "Invalid environment! Valid options: test, build, push, all"
    ;;
esac
