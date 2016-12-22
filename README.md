Docker-Android-Appium
=====================

[![Build Status](https://travis-ci.org/butomo1989/docker-appium.svg?branch=master)](https://travis-ci.org/butomo1989/docker-appium)
[![codecov](https://codecov.io/gh/butomo1989/docker-appium/branch/master/graph/badge.svg)](https://codecov.io/gh/butomo1989/docker-appium)

Android emulator and Appium server in docker solution.

Requirements
------------

Docker is installed in your system.

Quick Start
-----------

1. Run docker-appium with command:

    ```bash
    docker run -d -p 4723:4723 -v <apk_path_that_will_be_tested>:/target_apk -e ANDROID_VERSION=<target_android_version> --name appium-container butomo1989/docker-appium
    ```

    ***Note: There is an example apk in folder example.***

    An Example:

    ```bash
    docker run -d -p 4723:4723 -v $PWD/example/sample_apk:/target_apk -e ANDROID_VERSION=4.2.2 --name appium-container butomo1989/docker-appium
    ```

2. See the docker logs with command:

    ```bash
    docker logs appium-container -f
    ```

3. Wait until you see this following example messages in logs that showing that appium server is ready to use:

    ```bash
    INFO:android_appium:Android emulator is created
    INFO:android_appium:android emulator name: emulator_4.2.2
    [Appium] Welcome to Appium v1.6.3
    [Appium] Appium REST http interface listener started on 0.0.0.0:4723
    ```

4. Run your UI tests by using docker-appium.

    ***Note: There is an example UITests in folder example.***
