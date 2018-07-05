#!/bin/bash
# Bash version should >= 4 to be able to run this script.

IMAGE="butomo1989/docker-android"

if [ -z "$1" ]; then
    read -p "Task (test|build|push|all) : " TASK
else
    TASK=$1
fi

if [ -z "$2" ]; then
    read -p "Android version (5.0.1|5.1.1|6.0|7.0|7.1.1|8.0|8.1|all): " ANDROID_VERSION
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
        [8.0]=26
        [8.1]=27
)

declare -A list_of_processors=(
        [arm]=armeabi-v7a
        [x86]=x86
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
        echo "Android version \"$ANDROID_VERSION\" is not found in the list or not supported! Support only version 5.0.1, 5.1.1, 6.0, 7.0, 7.1.1, 8.0, 8.1"
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
    # Prepare needed parameter to run tests
    test_android_version=7.1.1
    test_api_level=25
    test_processor=x86
    test_sys_img=x86_64
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

    # Build docker image(s)
    for p in "${processors[@]}"; do
        if [ "$p" == "x86" ]; then
            FILE_NAME=docker/Emulator_x86
        else
            FILE_NAME=docker/Emulator_arm
        fi

        for v in "${versions[@]}"; do
            # Find image type and default web browser
            if [ "$v" == "5.0.1" ] || [ "$v" == "5.1.1" ]; then
                IMG_TYPE=default
                BROWSER=browser
            elif [ "$v" == "6.0" ]; then
                # It is because there is no ARM EABI v7a System Image for 6.0
                IMG_TYPE=google_apis
                BROWSER=browser
            elif [[ "${list_of_levels[$v]}" -ge "24" && "$p" == "x86" ]]; then
                IMG_TYPE=google_apis_playstore
                BROWSER=chrome
            else
                IMG_TYPE=google_apis
                BROWSER=chrome
            fi
            echo "[BUILD] IMAGE TYPE: $IMG_TYPE"
            level=${list_of_levels[$v]}
            echo "[BUILD] API Level: $level"
            sys_img=${list_of_processors[$p]}
            echo "[BUILD] System Image: $sys_img"
            image_version="$IMAGE-$p-$v:$RELEASE"
            image_latest="$IMAGE-$p-$v:latest"
            if [[ "${list_of_levels[$v]}" -ge "24" && "$p" == "x86" ]]; then
                image_version="$IMAGE-$p-$v-playstore:$RELEASE"
                image_latest="$IMAGE-$p-$v-playstore:latest"
            fi
            if [[ "${list_of_levels[$v]}" -ge "26" && "$p" == "arm" ]]; then
                echo "System image $p for $v not supported"
                echo "Skip building!"
            else
                echo "[BUILD] Image name: $image_version and $image_latest"
                echo "[BUILD] Dockerfile: $FILE_NAME"
                docker build -t $image_version --build-arg ANDROID_VERSION=$v --build-arg API_LEVEL=$level \
                --build-arg PROCESSOR=$p --build-arg SYS_IMG=$sys_img --build-arg IMG_TYPE=$IMG_TYPE \
                --build-arg BROWSER=$BROWSER -f $FILE_NAME .
                docker tag $image_version $image_latest
            fi
        done
    done
}

function push() {
    # Push docker image(s)
    for p in "${processors[@]}"; do
        for v in "${versions[@]}"; do
            image_version="$IMAGE-$p-$v:$RELEASE"
            image_latest="$IMAGE-$p-$v:latest"
            if [[ "${list_of_levels[$v]}" -ge "24" && "$p" == "x86" ]]; then
                image_version="$IMAGE-$p-$v-playstore:$RELEASE"
                image_latest="$IMAGE-$p-$v-playstore:latest"
            fi
            if [[ "${list_of_levels[$v]}" -ge "26" && "$p" == "arm" ]]; then
                echo "docker image $image_version and $image_latest not existed"
                echo "Skip pushing!"
            else
                echo "[PUSH] Image name: $image_version and $image_latest"
                docker push $image_version
                docker push $image_latest
            fi
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
