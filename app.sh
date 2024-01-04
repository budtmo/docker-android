#!/bin/bash

function is_str_in_list(){
    local given_str=${1}
    local list_str=${@:2}

    if [[ ! " ${list_str[*]} " =~ " ${given_str} " ]]; then
        echo "${given_str} is not supported!"
        exit 1
    fi
}

tasks=("test" "build" "push")
if [ -z "${1}" ]; then
    read -p "Task ($(echo "${tasks[@]}" | tr ' ' '|')) : " t
else
    t=${1}
fi
is_str_in_list ${t} ${tasks[@]}

projects=("base" "emulator" "genymotion" "pro-emulator" "pro-emulator_headless")
if [ -z "${2}" ]; then
    read -p "Project ($(echo "${projects[@]}" | tr ' ' '|')) : " p
else
    p=${2}
fi
is_str_in_list ${p} ${projects[@]}

if [ -z "${3}" ]; then
    read -p "Release Version (v2.0.0-p0|v2.0.0-p1|etc) : " r_v
else
    r_v=${3}
fi

FOLDER_PATH=""
IMAGE_NAME=""
TAG_NAME=""

if [[ "${p}" == "pro"* ]]; then
    IFS='-' read -ra arr <<<"${p}"
    FOLDER_PATH+="docker/${arr[0]}/${arr[1]}"
    IMAGE_NAME+="budtmo2/docker-android-${arr[0]}"
    TAG_NAME+="${arr[1]}"
else
    FOLDER_PATH+="docker/${p}"
    IMAGE_NAME+="budtmo/docker-android"
    TAG_NAME+="${p}"
fi

if [[ "${p}" == *"emulator"* ]]; then
    supported_android_version=("9.0" "10.0" "11.0" "12.0" "13.0" "14.0")
    declare -A api_levels=(
        ["9.0"]=28
        ["10.0"]=29
        ["11.0"]=30
        ["12.0"]=32
        ["13.0"]=33
        ["14.0"]=34
    )

    # To get the last index
    keys=("${!api_levels[@]}")
    sorted_keys=($(printf '%s\n' "${keys[@]}" | sort)) 
    last_key=${keys[-2]} # because 9.0 will be last

    if [ -z "${4}" ]; then
        read -p "Android Version ($(echo "${supported_android_version[@]}" \
            | tr ' ' '|')) : " a_v
    else
        a_v=${4}
    fi
    is_str_in_list ${a_v} ${supported_android_version[@]}
    a_l=${api_levels[${a_v}]}
    TAG_NAME+="_${a_v}"
fi

IMAGE_NAME_LATEST="${IMAGE_NAME}:${TAG_NAME}"
TAG_NAME+="_${r_v}"
IMAGE_NAME_SPECIFIC_RELEASE=${IMAGE_NAME}:${TAG_NAME}
echo "${IMAGE_NAME_SPECIFIC_RELEASE} or ${IMAGE_NAME_LATEST} "

function build() {
    # autopep8 --recursive --exclude=.git,__pycache__,venv --max-line-length=120 --in-place .
    cmd="docker build -t ${IMAGE_NAME_SPECIFIC_RELEASE} --build-arg DOCKER_ANDROID_VERSION=${r_v} "
    if [ -n "${a_v}" ]; then
        cmd+="--build-arg EMULATOR_ANDROID_VERSION=${a_v} --build-arg EMULATOR_API_LEVEL=${a_l} "
    fi

    cmd+="-f ${FOLDER_PATH} ."
    ${cmd}
    docker tag ${IMAGE_NAME_SPECIFIC_RELEASE} ${IMAGE_NAME_LATEST}

    if [ -n "${a_v}" ] && [ "${a_v}" = "${last_key}" ]; then
        echo "${a_v} is the last version in the list, will use it as default image tag"
        docker tag ${IMAGE_NAME_SPECIFIC_RELEASE} ${IMAGE_NAME}:latest
    fi
}

function test() {
    cli_path="/home/androidusr/docker-android/cli"
    results_path="test-results"
    tmp_folder="tmp"

    mkdir -p tmp
    build
    docker run -it --rm --name test --entrypoint /bin/bash \
    -v $PWD/${tmp_folder}:${cli_path}/${tmp_folder} ${IMAGE_NAME_SPECIFIC_RELEASE} \
    -c "cd ${cli_path} && sudo rm -rf ${tmp_folder}/* && \
    nosetests -v && sudo mv .coverage ${tmp_folder} && \
    sudo cp -r ${results_path}/* ${tmp_folder} && sudo chown -R 1300:1301 ${tmp_folder} &&
    sudo chmod a+x -R ${tmp_folder}"
}

function push() {
    build
    docker push ${IMAGE_NAME_SPECIFIC_RELEASE}
    docker push ${IMAGE_NAME_LATEST}
    if [ -n "${a_v}" ] && [ "${a_v}" = "${last_key}" ]; then
        docker push ${IMAGE_NAME}:latest
    fi
}

${t}
