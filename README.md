Docker-Android-Appium
=====================

[![Build Status](https://travis-ci.org/butomo1989/docker-appium.svg?branch=master)](https://travis-ci.org/butomo1989/docker-appium)
[![codecov](https://codecov.io/gh/butomo1989/docker-appium/branch/master/graph/badge.svg)](https://codecov.io/gh/butomo1989/docker-appium)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/3f000ffb97db45a59161814e1434c429)](https://www.codacy.com/app/butomo1989/docker-appium?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=butomo1989/docker-appium&amp;utm_campaign=Badge_Grade)

Android emulator and Appium server in docker solution with noVNC supported.

Requirements
------------

Docker is installed in your system.

Features
--------

1. Android emulator with different devices / skins
2. noVNC
3. Appium server
4. Able to connect to selenium grid
5. Browser application for mobile website testing
  - Chrome version 55 (for x86 and armeabi)
  - Firefox version 51 (for x86 and armeabi)

Quick Start
-----------

1. Enable **Virtualization** under **System Setup** in **BIOS**. (It is only for Ubuntu OS. If you use different OS, you can skip this step).

2. Run docker-appium.

  **Optional arguments**

	    --privileged              			: Only for ubuntu OS. This flag allow to use system image x86 for better performance
	    -v <path_of_apk>:/target_apk      	: Path of android apk that want to be tested
	    -e DEVICE="<device_name>"       	: Device name. Default device is Nexus 5
	    -e ANDROID_VERSION=<android_version>: Android version of emulator. Default android version is 5.0
	    -e EMULATOR_TYPE=<armeabi/x86>      : Emulator system image. Default system image is armeabi

    **An Example command to run docker-appium under linux**

    ```bash
    docker run --privileged -d -p 6080:6080 -p 4723:4723 -v $PWD/example/sample_apk:/target_apk -e DEVICE="Nexus 5" -e ANDROID_VERSION=5.0 -e EMULATOR_TYPE=armeabi --name appium-container butomo1989/docker-appium
    ```

2. Verify the ip address of docker-machine.

   - For OSX, you can find out by using following command:

     ```bash
     docker-machine ip default
     ```

   - For different OS, localhost should work.

3. Open ***http://docker-machine-ip-address:6080/vnc.html*** from web browser.

   ![][noVNC]

4. Wait until the installation of selected android version packages is done and appium is ready to use by waiting following message shown in Terminal:

   ![][Appium is ready]

   *The name of created emulator can be seen in that terminal. In screenshot above, the emulator name is* ***nexus\_5_5.0***.

5. Run your UI tests by using docker-appium and Android emulator will be started automatically by following desire capability:

   ```
   desired_caps = {
      'avd': 'nexus_5_5.0'
   }
   ```

***Note: In folder "example" there is an example of Appium-UITest that is written in python.***

Connect to Selenium Grid
------------------------
pass environment variable **CONNECT\_TO\_GRID=True** to connect docker-appium to your selenium grid.

**Optional arguments**

    -e APPIUM_HOST="<host_ip_address>"    : where / on which instance is appium server running. Default value: 127.0.0.1
    -e APPIUM_PORT=<port_number>      : which port is appium server running. Default port: 4723
    -e SELENIUM_HOST="<host_ip_address>"  : where / on which instance is selenium grid running. Default value: 172.17.0.1
    -e SELENIUM_PORT=<port_number>      : which port is selenium grid running. default port: 4444

![][connect to grid 1]  ![][connect to grid 2]

List of Devices
---------------
Type | Device Name
--- | ---
Phone | Galaxy Nexus
Phone | Nexus 4
Phone | Nexus 5
Phone | Nexus 5x
Phone | Nexus 6
Phone | Nexus 6P
Phone | Nexus One
Phone | Nexus S
Tablet | Pixel C
Tablet | Nexus 7
Tablet | Nexus 9
Tablet | Nexus 10

![][nexus 5]

Troubleshooting
---------------
All logs inside container are stored under folder **/var/log/supervisor**. you can print out log file by using **docker exec**. Example:

```bash
docker exec -it appium-container tail -f /var/log/supervisor/docker-appium.stdout.log
```

[noVNC]: <images/noVNC.png> "login with noVNC to see what happen inside container"
[Appium is ready]: <images/appium.png> "appium is ready"
[connect to grid 1]: <images/appium_with_selenium_grid_01.png>
[connect to grid 2]: <images/appium_with_selenium_grid_02.png>
[nexus 5]: <images/run_under_nexus_5.png>
