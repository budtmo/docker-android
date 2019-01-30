#!/bin/bash

IMAGE_NAME="budtmo/docker-android"

if [ -z "$1" ]; then
    read -p "Type : " TYPE
else
    TYPE=$1
fi

if [ -z "$2" ]; then
    read -p "Version : " VERSION
else
    VERSION=$2
fi

declare -a versions=("7.1.1" "7.0" "6.0" "5.1.1" "5.0.1")

## now loop through the above array
for v in "${versions[@]}"
do
	IMAGE="$IMAGE_NAME-$TYPE-$v"
	IMAGE_OLD="$IMAGE:$VERSION"
	IMAGE_LATEST="$IMAGE:latest"
	echo "Revert image \"$IMAGE_LATEST\" to version \"$IMAGE_OLD\""
	docker pull $IMAGE_OLD
	docker tag $IMAGE_OLD $IMAGE_LATEST
	docker push $IMAGE_LATEST
done
