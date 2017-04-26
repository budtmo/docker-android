#!/bin/bash
# Bash version should >= 4 to be able to run this script.

IMAGE="butomo1989/docker-android"
LATEST_BUILD_TOOL=25.0.2

if [ -z "$1" ]; then
    read -p "Task (test|build|push|all) : " TASK
else
    TASK=$1
fi

if [ -z "$2" ]; then
    read -p "Android version (5.0.1|5.1.1|6.0|7.0|7.1.1|all): " ANDROID_VERSION
else
    ANDROID_VERSION=$2
fi

if [ -z "$3" ]; then
    read -p "Processor type (x86|arm|all): " PROCESSOR
else
    PROCESSOR=$3
fi

if [ -z "$4" ]; then
    read -p "Release version: " RELEASE
else
    RELEASE=$4
fi

declare -A list_of_levels=(
        [5.0.1]=21
        [5.1.1]=22
        [6.0]=23
        [7.0]=24
        [7.1.1]=25
)

declare -A list_of_processors=(
        [arm]=armeabi-v7a
        [x86]=x86_64
)

function get_android_versions() {
    versions=()

    if [ "$ANDROID_VERSION" == "all" ]; then
        for key in "${!list_of_levels[@]}"; do
            versions+=($key)
        done
    else
        for key in "${!list_of_levels[@]}"; do
            if [[ $key == *"$ANDROID_VERSION"* ]]; then
                versions+=($key)
            fi
        done
    fi

    # If version cannot be found in the list
    if [ -z "$versions" ]; then
        echo "Android version \"$ANDROID_VERSION\" is not found in the list or not supported! Support only version 5.0.1, 5.1.1, 6.0, 7.0, 7.1.1"
        exit 1
    fi

    echo "Android versions: ${versions[@]}"
}

function get_processors() {
    processors=()

    if [ "$PROCESSOR" == "all" ]; then
        for key in "${!list_of_processors[@]}"; do
            processors+=($key)
        done
    else
        for key in "${!list_of_processors[@]}"; do
            if [[ $key == *"$PROCESSOR"* ]]; then
                processors+=($key)
            fi
        done
    fi

    # If version cannot be found in the list
    if [ -z "$processors" ]; then
        echo "Invalid processor \"$PROCESSOR\"! Valid options: x86, arm"
        exit 1
    fi

    echo "Processors: ${processors[@]}"
}

get_android_versions
get_processors

function test() {
    (export ANDROID_HOME=/root && export ANDROID_VERSION=5.0.1 && export API_LEVEL=21 \
    && export PROCESSOR=x86 && export SYS_IMG=x86_64 && export IMG_TYPE=google_apis && nosetests -v)
}

function build() {
    # Remove pyc files
    find . -name "*.pyc" -exec rm -f {} \;

    # Build docker image(s)
    for p in "${processors[@]}"; do
        for v in "${versions[@]}"; do
            # Find image type
            if [ "$v" == "5.0.1" ] || [ "$v" == "5.1.1" ]; then
                IMG_TYPE=android
            else
                IMG_TYPE=google_apis
            fi
            echo "[BUILD] IMAGE TYPE: $IMG_TYPE"
            level=${list_of_levels[$v]}
            echo "[BUILD] API Level: $level"
            sys_img=${list_of_processors[$p]}
            echo "[BUILD] System Image: $sys_img"
            image_version="$IMAGE-$p-$v:$RELEASE"
            image_latest="$IMAGE-$p-$v:latest"
            echo "[BUILD] Image name: $image_version and $image_latest"
            docker build -t $image_version --build-arg ANDROID_VERSION=$v --build-arg BUILD_TOOL=$LATEST_BUILD_TOOL \
            --build-arg API_LEVEL=$level --build-arg PROCESSOR=$p --build-arg SYS_IMG=$sys_img \
            --build-arg IMG_TYPE=$IMG_TYPE .
            docker build -t $image_latest --build-arg ANDROID_VERSION=$v --build-arg BUILD_TOOL=$LATEST_BUILD_TOOL \
            --build-arg API_LEVEL=$level --build-arg PROCESSOR=$p --build-arg SYS_IMG=$sys_img \
            --build-arg IMG_TYPE=$IMG_TYPE .
        done
    done
}

function push() {
    # Push docker image(s)
    for p in "${processors[@]}"; do
        for v in "${versions[@]}"; do
            image_version="$IMAGE-$p-$v:$RELEASE"
            image_latest="$IMAGE-$p-$v:latest"
            echo "[PUSH] Image name: $image_version and $image_latest"
            docker push $image_version
            docker push $image_latest
        done
    done
}

case $TASK in
    test)
        test
    ;;
    build)
        build
    ;;
    push)
        push
    ;;
    all)
        test
        build
        push
    ;;
    *)
        echo "Invalid environment! Valid options: test, build, push, all"
    ;;
esac
