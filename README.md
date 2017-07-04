Docker-Android
==============

[![Join the chat at https://gitter.im/butomo1989/docker-android](https://badges.gitter.im/butomo1989/docker-android.svg)](https://gitter.im/butomo1989/docker-android?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/butomo1989/docker-android.svg?branch=master)](https://travis-ci.org/butomo1989/docker-android)
[![codecov](https://codecov.io/gh/butomo1989/docker-android/branch/master/graph/badge.svg)](https://codecov.io/gh/butomo1989/docker-android)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/3f000ffb97db45a59161814e1434c429)](https://www.codacy.com/app/butomo1989/docker-appium?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=butomo1989/docker-appium&amp;utm_campaign=Badge_Grade)

Docker-Android is a docker image built to be used for everything related to mobile website testing and Android project.

Samsung Device               |  Google Device
:---------------------------:|:---------------------------:
![][docker android samsung]  |  ![][docker android nexus]

Purpose
-------

1. Run UI tests for mobile websites with [appium]
2. Build Android project and run unit tests with the latest build-tools
3. Run UI tests for Android applications with different frameworks ([appium], [espresso], [robotium], etc.)
4. Run monkey / stress tests
5. SMS testing

Advantages compare with other docker-android projects
-----------------------------------------------------

1. noVNC to see what happen inside docker container
2. Emulator for different devices / skins, such as Samsung Galaxy S6, LG Nexus 4, HTC Nexus One and more.
3. Ability to connect to Selenium Grid
4. Ability to control emulator from outside container by using adb connect
5. Open source with more features coming (monkey test, support real devices with screen mirroring and video recording)

List of Docker images
---------------------

|Supported OS   |Android version   |API level   |Image Type   |Image name   |Image status   |Interactive Web Interface   |
|:---|:---|:---|:---|:---|:---|:---:|
|Linux|5.0.1|21|Google Api x86|butomo1989/docker-android-x86-5.0.1|[![](https://images.microbadger.com/badges/image/butomo1989/docker-android-x86-5.0.1.svg)](https://microbadger.com/images/butomo1989/docker-android-x86-5.0.1 "Get your own image badge on microbadger.com")|Yes|
|Linux|5.1.1|22|Google Api x86|butomo1989/docker-android-x86-5.1.1|[![](https://images.microbadger.com/badges/image/butomo1989/docker-android-x86-5.1.1.svg)](https://microbadger.com/images/butomo1989/docker-android-x86-5.1.1 "Get your own image badge on microbadger.com")|Yes|
|Linux|6.0|23|Google Api x86|butomo1989/docker-android-x86-6.0|[![](https://images.microbadger.com/badges/image/butomo1989/docker-android-x86-6.0.svg)](https://microbadger.com/images/butomo1989/docker-android-x86-6.0 "Get your own image badge on microbadger.com")|Yes|
|Linux|6.0|23|Atom x86|alanbueno8/docker-android-atom-x86-6.0|[![](https://images.microbadger.com/badges/image/alanbueno8/docker-android-atom-x86-6.0.svg)](https://microbadger.com/images/alanbueno8/docker-android-atom-x86-6.0 "Get your own image badge on microbadger.com")|Yes|
|Linux|6.0|23|Atom x86|alanbueno8/docker-android-atom-x86-6.0_non-interactive|[![](https://images.microbadger.com/badges/image/alanbueno8/docker-android-atom-x86-6.0_non-interactive.svg)](https://microbadger.com/images/alanbueno8/docker-android-atom-x86-6.0_non-interactive "Get your own image badge on microbadger.com")|No|
|Linux|6.0|23|Atom x64|alanbueno8/docker-android-atom-x86_64-6.0|[![](https://images.microbadger.com/badges/image/alanbueno8/docker-android-atom-x86_64-6.0.svg)](https://microbadger.com/images/alanbueno8/docker-android-atom-x86_64-6.0 "Get your own image badge on microbadger.com")|Yes|
|Linux|6.0|23|Atom x64|alanbueno8/docker-android-atom-x86_64-6.0_non-interactive|[![](https://images.microbadger.com/badges/image/alanbueno8/docker-android-atom-x86_64-6.0_non-interactive.svg)](https://microbadger.com/images/alanbueno8/docker-android-atom-x86_64-6.0_non-interactive "Get your own image badge on microbadger.com")|No|
|Linux|7.0|24|Google Api x86|butomo1989/docker-android-x86-7.0|[![](https://images.microbadger.com/badges/image/butomo1989/docker-android-x86-7.0.svg)](https://microbadger.com/images/butomo1989/docker-android-x86-7.0 "Get your own image badge on microbadger.com")|Yes|
|Linux|7.1.1|25|Google Api x86|butomo1989/docker-android-x86-7.1.1|[![](https://images.microbadger.com/badges/image/butomo1989/docker-android-x86-7.1.1.svg)](https://microbadger.com/images/butomo1989/docker-android-x86-7.1.1 "Get your own image badge on microbadger.com")|Yes|
|OSX / Windows|5.0.1|21|Arm|butomo1989/docker-android-arm-5.0.1|[![](https://images.microbadger.com/badges/image/butomo1989/docker-android-arm-5.0.1.svg)](https://microbadger.com/images/butomo1989/docker-android-arm-5.0.1 "Get your own image badge on microbadger.com")|Yes|
|OSX / Windows|5.1.1|22|Arm|butomo1989/docker-android-arm-5.1.1|[![](https://images.microbadger.com/badges/image/butomo1989/docker-android-arm-5.1.1.svg)](https://microbadger.com/images/butomo1989/docker-android-arm-5.1.1 "Get your own image badge on microbadger.com")|Yes|
|OSX / Windows|6.0|23|Arm|butomo1989/docker-android-arm-6.0|[![](https://images.microbadger.com/badges/image/butomo1989/docker-android-arm-6.0.svg)](https://microbadger.com/images/butomo1989/docker-android-arm-6.0 "Get your own image badge on microbadger.com")|Yes|
|OSX / Windows|7.0|24|Arm|butomo1989/docker-android-arm-7.0|[![](https://images.microbadger.com/badges/image/butomo1989/docker-android-arm-7.0.svg)](https://microbadger.com/images/butomo1989/docker-android-arm-7.0 "Get your own image badge on microbadger.com")|Yes|
|OSX / Windows|7.1.1|25|Arm|butomo1989/docker-android-arm-7.1.1|[![](https://images.microbadger.com/badges/image/butomo1989/docker-android-arm-7.1.1.svg)](https://microbadger.com/images/butomo1989/docker-android-arm-7.1.1 "Get your own image badge on microbadger.com")|Yes|

List of Devices
---------------

Type   | Device Name
-----  | -----
Phone  | Samsung Galaxy S6
Phone  | Nexus 4
Phone  | Nexus 5
Phone  | Nexus One
Phone  | Nexus S
Tablet | Nexus 7

Requirements
------------

Docker is installed in your system.

Quick Start
-----------

1. Run docker-android

	- For ***Linux OS***, please use image name that contains "x86"

		```bash
		docker run --privileged -d -p 6080:6080 -p 5554:5554 -p 5555:5555 -e DEVICE="Samsung Galaxy S6" --name android-container butomo1989/docker-android-x86-7.1.1
		```

	- For ***OSX*** and ***Windows OS***, please use image name that contains "arm"

		```bash
		docker run --privileged -d -p 6080:6080 -p 5554:5554 -p 5555:5555 -e DEVICE="Samsung Galaxy S6" --name android-container butomo1989/docker-android-arm-7.1.1
		```

2. Verify the ip address of docker host.

   - For OSX, you can find out by using following command:

     ```bash
     docker-machine ip default
     ```

   - For different OS, localhost should work.

3. Open ***http://docker-host-ip-address:6080*** from web browser.

Run Appium Server
-----------------

Appium is automation test framework to test mobile website and mobile application, including android. To be able to use appium, you need to run appium-server. You run appium server inside docker-android container by ***opening port 4723*** and ***passing an environment variable APPIUM=TRUE***.

```bash
docker run --privileged -d -p 6080:6080 -p 5554:5554 -p 5555:5555 -p 4723:4723 -e DEVICE="Samsung Galaxy S6" -e APPIUM=True --name android-container butomo1989/docker-android-x86-7.1.1
```

### Connect to Selenium Grid

It is also possible to connect appium server that run inside docker-android with selenium grid by passing following environment variables:

- CONNECT\_TO\_GRID=True
- APPIUM_HOST="\<host\_ip\_address>"
- APPIUM_PORT=\<port\_number>
- SELENIUM_HOST="\<host\_ip\_address>"
- SELENIUM_PORT=\<port\_number>

To run tests for mobile browser, following parameter can be passed:

- MOBILE\_WEB\_TEST=True

```bash
docker run --privileged -d -p 6080:6080 -p 4723:4723 -p 5554:5554 -p 5555:5555 -e DEVICE="Samsung Galaxy S6" -e APPIUM=True -e CONNECT_TO_GRID=True -e APPIUM_HOST="127.0.0.1" -e APPIUM_PORT=4723 -e SELENIUM_HOST="172.17.0.1" -e SELENIUM_PORT=4444 -e MOBILE_WEB_TEST=True --name android-container butomo1989/docker-android-x86-7.1.1
```

### Share Volume

If you want to use appium to test UI of your android application, you need to share volume where the APK is located to folder ***/root/tmp***.

```bash
docker run --privileged -d -p 6080:6080 -p 4723:4723 -p 5554:5554 -p 5555:5555 -v $PWD/example/sample_apk:/root/tmp -e DEVICE="Nexus 5" -e APPIUM=True -e CONNECT_TO_GRID=True -e APPIUM_HOST="127.0.0.1" -e APPIUM_PORT=4723 -e SELENIUM_HOST="172.17.0.1" -e SELENIUM_PORT=4444 --name android-container butomo1989/docker-android-x86-7.1.1
```

### Docker-Compose

![][compose]
![][connected_devices]

There is [example of compose file] to run complete selenium grid and docker-android container as nodes. [docker-compose] version [1.13.0] or higher is required to be able to execute that compose file.

```bash
docker-compose up -d
```

Control android emulator outside container
------------------------------------------

```bash
adb connect <docker-machine-ip-address>:5555
```

![][adb_connection]

**Note:** You need to have Android Debug Bridge (adb) installed in your host machine.

SMS Simulation
--------------

1. Using telnet
	- Find the auth_token and copy it.

	 ```bash
	 docker exec -it android-container cat /root/.emulator_console_auth_token
	 ```

	- Access emulator using telnet and login with auth_token

	 ```bash
	 telnet <docker-machine-ip-address> 5554
	 ```

	- Login with given auth_token from 1.step

	 ```bash
	 auth <auth_token>
	 ```

	- Send the sms

	 ```bash
	 sms send <phone_number> <message>
	 ```

2. Using adb

	 ```bash
	 docker exec -it android-container adb emu sms send <phone_number> <message>
	 ```

3. You can also integrate it inside project using adb library.

![][sms]

Troubleshooting
---------------
All logs inside container are stored under folder **/var/log/supervisor**. you can print out log file by using **docker exec**. Example:

```bash
docker exec -it android-container tail -f /var/log/supervisor/docker-android.stdout.log
```

[appium]: <https://appium.io>
[espresso]: <https://google.github.io/android-testing-support-library/docs/espresso/>
[robotium]: <https://github.com/RobotiumTech/robotium>
[docker android samsung]: <images/docker_android_samsung.png>
[docker android nexus]: <images/docker_android_nexus.png>
[compose]: <images/compose.png>
[connected_devices]: <images/connected_devices.png>
[example of compose file]: <docker-compose.yml>
[docker-compose]: <https://docs.docker.com/compose/install/>
[1.13.0]: <https://github.com/docker/compose/releases/tag/1.13.0>
[adb_connection]: <images/adb_connection.png>
[sms]: <images/SMS.png>
