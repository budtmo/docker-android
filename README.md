Docker-Android-Appium
=====================

[![Build Status](https://travis-ci.org/butomo1989/docker-appium.svg?branch=master)](https://travis-ci.org/butomo1989/docker-appium)
[![codecov](https://codecov.io/gh/butomo1989/docker-appium/branch/master/graph/badge.svg)](https://codecov.io/gh/butomo1989/docker-appium)

Android emulator and Appium server in docker solution with noVNC supported.

Requirements
------------

Docker is installed in your system.

Features
--------

1. Android emulator
2. noVNC
3. Appium server
4. Able to connect to selenium grid
5. Browser application for mobile website testing
	- Chrome version 55 (for x86 and armeabi)
	- Firefox version 51 (for x86 and armeabi)

Quick Start
-----------

1. Enable **Virtualization** under **System Setup** in **BIOS**. (It is only for Ubuntu OS. If you use different OS, you can skip this step).

2. Run docker-appium with command:

    ```bash
    docker run -d -p 6080:6080 -p 4723:4723 -v <path_of_apk_that_want_to_be_tested>:/target_apk -e ANDROID_VERSION=<target_android_version> -e EMULATOR_TYPE=<emulator_type> -e CONNECT_TO_GRID=<True/False> --name appium-container butomo1989/docker-appium
    ```

    An Example:

    ```bash
    docker run -d -p 6080:6080 -p 4723:4723 -v $PWD/example/sample_apk:/target_apk -e ANDROID_VERSION=4.2.2 -e EMULATOR_TYPE=armeabi -e CONNECT_TO_GRID=False --name appium-container butomo1989/docker-appium
    ```
	**Optional arguments for CONNECT\_TO\_GRID=True**

		-e APPIUM_HOST="<host_ip_address>": if appium is running under different host. default value: 127.0.0.1
		-e APPIUM_PORT=<port_number>: if appium is running under different port. default port: 4723
		-e SELENIUM_HOST="<host_ip_address>": if selenium hub is running under different host. default value: 172.17.0.1
		-e SELENIUM_PORT=<port_number>: if selenium hub is running under different port. default port: 4444

	**Note: use flag *--privileged* and *EMULATOR_TYPE=x86* for ubuntu OS to make emulator faster**

2. Verify the ip address of docker-machine.

   - For OSX, you can find out by using following command:

	   ```bash
	   docker-machine ip default
	   ```

   - For different OS, localhost should work.

3. Open ***http://docker-machine-ip-address:6080/vnc.html*** from web browser and connect to it without password.

   ![][noVNC]

4. Wait until the installation of selected android version packages is done and appium is ready to use by waiting following message shown in Terminal:

   ![][Appium is ready]

   *The name of created emulator can be seen in that terminal. In screenshot above, the emulator name is* ***emulator_4.2.2***.

5. Run your UI tests by using docker-appium and Android emulator will be started automatically by following desire capability:

   ```
   desired_caps = {
   		'avd': 'emulator_4.2.2'
   }
   ```

***Note: In folder "example" there is an example of Appium-UITest that is written in python.***

[noVNC]: <images/noVNC.png> "login with noVNC to see what happen inside container"
[Appium is ready]: <images/appium.png> "appium is ready"
