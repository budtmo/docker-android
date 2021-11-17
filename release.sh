#!/bin/bash
# Bash version should >= 4 to be able to run this script.

IMAGE="${DOCKER_ORG:-budtmo}/docker-android"

if [ -z "$1" ]; then
    read -p "Task (test|build|push|all) : " TASK
else
    TASK=$1
fi

if [ -z "$2" ]; then
    read -p "Android version (6.0|7.0|7.1.1|8.0|8.1|9.0|10.0|11.0|12.0|all): " ANDROID_VERSION
else
    ANDROID_VERSION=$2
fi

if [ -z "$3" ]; then
    read -p "Release version: " RELEASE
else
    RELEASE=$3
fi

declare -A list_of_levels=(
        [6.0]=23
        [7.0]=24
        [7.1.1]=25
        [8.0]=26
        [8.1]=27
        [9.0]=28
        [10.0]=29
        [11.0]=30
        [12.0]=31
)

# The version of the Chrome browser installed on the Android emulator needs to be known beforehand
# in order to chose the proper version of chromedriver (see http://chromedriver.chromium.org/downloads)
declare -A chromedriver_versions=(
        [6.0]="2.18"
        [7.0]="2.23"
        [7.1.1]="2.28"
        [8.0]="2.31"
        [8.1]="2.33"
        [9.0]="2.40"
        [10.0]="74.0.3729.6"
        [11.0]="83.0.4103.39"
        [12.0]="93.0.4577.15"
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
        echo "Android version \"$ANDROID_VERSION\" is not found in the list or not supported! Support only version 6.0, 7.0, 7.1.1, 8.0, 8.1, 9.0, 10.0, 11.0, 12.0"
        exit 1
    fi

    echo "Android versions: ${versions[@]}"
}

get_android_versions
processor=x86

function test() {
    # Prepare needed parameter to run tests
    test_android_version=7.1.1
    test_api_level=25
    test_processor=x86
    test_sys_img=$test_processor
    test_img_type=google_apis
    test_browser=chrome
    test_image=test_img
    test_container=test_con

    # Run e2e tests
    # E2E tests must be run only for linux OS / x86 image to reduce duration of test execution
    if [ "$(uname -s)" == 'Linux' ] && [ "$E2E" = true ]; then
        echo "----BUILD TEST IMAGE----"
        docker build -t $test_image --build-arg ANDROID_VERSION=$test_android_version \
        --build-arg API_LEVEL=$test_api_level --build-arg PROCESSOR=$test_processor --build-arg SYS_IMG=$test_sys_img \
        --build-arg IMG_TYPE=$test_img_type --build-arg BROWSER=$test_browser -f docker/Emulator_x86 .

        echo "----REMOVE OLD TEST CONTAINER----"
        docker kill $test_container && docker rm $test_container

        echo "----PREPARE CONTAINER----"
        docker run --privileged -d -p 4723:4723 -p 6080:6080 -e APPIUM=True -e DEVICE="Samsung Galaxy S6" --name $test_container $test_image
        docker cp example/sample_apk $test_container:/root/tmp
        attempt=0
        while [ ${attempt} -le 10 ]; do
            attempt=$(($attempt + 1))
            output=$(docker ps | grep healthy | grep test_con | wc -l)
            if [[ "$output" == 1 ]]; then
                echo "Emulator is ready."
                break
            else
                echo "Waiting 10 seconds for emulator to be ready (attempt: $attempt)"
                sleep 10
            fi

            if [[ $attempt == 10 ]]; then
                echo "Failed!"
                exit 1
            fi
        done

        echo "----RUN E2E TESTS----"
        nosetests src/tests/e2e -v

        echo "----REMOVE TEST CONTAINER----"
        docker kill $test_container && docker rm $test_container
    fi

    # Run unit tests (After e2e test to get coverage result)
    echo "----UNIT TESTS----"
    (export ANDROID_HOME=/root && export ANDROID_VERSION=$test_android_version && export API_LEVEL=$test_api_level \
    && export PROCESSOR=$test_processor && export SYS_IMG=$test_sys_img && export IMG_TYPE=$test_img_type \
    && nosetests src/tests/unit -v)
}

function build() {
    # Remove pyc files
    find . -name "*.pyc" -exec rm -f {} \;

    # Build docker image
    FILE_NAME=docker/Emulator_x86

    for v in "${versions[@]}"; do
        level=${list_of_levels[$v]}

        # Find image type and default web browser
        if [ "$v" == "6.0" ]; then
            # It is because there is no ARM EABI v7a System Image for 6.0
            IMG_TYPE=google_apis
            BROWSER=browser
        elif [ "$v" == "" ]; then
            IMG_TYPE=google_apis
            BROWSER=chrome
        else
            #adb root cannot be run in IMG_TYPE=google_apis_playstore
            IMG_TYPE=google_apis
            BROWSER=chrome
            # Android 9 & Android 11 had build issues that requires 64-bit
            # Android 12+ Google dropped 32-bit support
            if [ "$v" == "9.0" ] || [ $level -ge 30 ]; then
                processor=x86_64
            fi
        fi
        echo "[BUILD] IMAGE TYPE: $IMG_TYPE"
        echo "[BUILD] API Level: $level"
        sys_img=$processor
        echo "[BUILD] System Image: $sys_img"
        chrome_driver="${chromedriver_versions[$v]}"
        echo "[BUILD] chromedriver version: $chrome_driver"
        image_version="$IMAGE-x86-$v:$RELEASE"
        image_latest="$IMAGE-x86-$v:latest"
        echo "[BUILD] Image name: $image_version and $image_latest"
        echo "[BUILD] Dockerfile: $FILE_NAME"
        docker build -t $image_version --build-arg TOKEN=$TOKEN --build-arg ANDROID_VERSION=$v --build-arg API_LEVEL=$level \
        --build-arg PROCESSOR=$processor --build-arg SYS_IMG=$sys_img --build-arg IMG_TYPE=$IMG_TYPE \
        --build-arg BROWSER=$BROWSER --build-arg CHROME_DRIVER=$chrome_driver \
        --build-arg APP_RELEASE_VERSION=$RELEASE -f $FILE_NAME .
        docker tag $image_version $image_latest
    done
}

function push() {
    # Push docker image(s)
    for v in "${versions[@]}"; do
        image_version="$IMAGE-x86-$v:$RELEASE"
        image_latest="$IMAGE-x86-$v:latest"
        echo "[PUSH] Image name: $image_version and $image_latest"
        docker push $image_version
        docker push $image_latest
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
