#!/bin/bash
# Bash version should >= 4 to be able to run this script.

IMAGE="butomo1989/docker-android"

if [ -z "$1" ]; then
    read -p "Environment (test|build|push|all) : " TASK
else
    TASK=$1
fi

if [ -z "$2" ]; then
    read -p "Android version: " GIVEN_VERSION
else
    GIVEN_VERSION=$2
fi

if [ -z "$3" ]; then
    read -p "Processor type (x86|arm): " PROCESSOR
else
    PROCESSOR=$3
fi

function build_tool() {
    declare -A build_tools=(
        [5.0.1]=21.1.2
        [5.1.1]=22.0.1
        [6.0]=23.0.3
        [7.0]=24.0.3
        [7.1.1]=25.0.2
    )

    # TODO: Need to be sorted
    for key in "${!build_tools[@]}"; do
        if [[ $key == *"$GIVEN_VERSION"* ]]; then
            version=$key
        fi
    done

    # If version cannot be found in the list
    if [ -z "$version" ]; then
        echo "Version is not found in the list or not supported! Support only version 5.0.1, 5.1.1, 6.0, 7.0, 7.1.1"
        exit 1
    fi

    echo "Android version: $version"
    build_tools=${build_tools[$version]}
    echo "Build tool: $build_tools"
}

function api_level() {
    declare -A levels=(
        [5.0.1]=21
        [5.1.1]=22
        [6.0]=23
        [7.0]=24
        [7.1.1]=25
    )

    level=${levels[$version]}
    echo "Api level: $level"
}

function system_image() {
    case $PROCESSOR in
        x86)
            sys_img=x86_64
        ;;
        arm)
            sys_img=armeabi-v7a
        ;;
        *)
            echo "Invalid processor! Valid options: x86, arm"
            exit 1
        ;;
    esac
    echo "Processor: $PROCESSOR"
    echo "System Image: $sys_img"
}

function init() {
    build_tool
    api_level
    system_image
}

init
IMAGE_NAME="$IMAGE-$PROCESSOR-$version"
echo "Image tag: $TAG"

function test() {
    (export ANDROID_HOME=/root && export ANDROID_VERSION=$version && export API_LEVEL=$level \
    && export PROCESSOR=$PROCESSOR && export SYS_IMG=$sys_img && nosetests -v)
}

function build() {
    # Remove pyc files
    find . -name "*.pyc" -exec rm -f {} \;

    docker build -t $IMAGE_NAME --build-arg ANDROID_VERSION=$version --build-arg BUILD_TOOL=$$build_tools \
        --build-arg API_LEVEL=$level --build-arg PROCESSOR=$PROCESSOR --build-arg SYS_IMG=$sys_img .
}

function push() {
    docker push $IMAGE_NAME
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
