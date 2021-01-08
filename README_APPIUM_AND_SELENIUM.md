Run Appium Server
-----------------

Appium is automation test framework to test mobile website and mobile application, including Android. To be able to use Appium, you need to run appium-server. You run Appium-Server inside docker-android container by ***opening port 4723*** and ***passing an environment variable APPIUM=true***.

```bash
docker run --privileged -d -p 6080:6080 -p 5554:5554 -p 5555:5555 -p 4723:4723 -e DEVICE="Samsung Galaxy S6" -e APPIUM=true --name android-container budtmo/docker-android-x86-8.1
```

### Share Volume

If you want to use appium to test UI of your android application, you need to share volume where the APK is located to folder ***/root/tmp***.

```bash
docker run --privileged -d -p 6080:6080 -p 4723:4723 -p 5554:5554 -p 5555:5555 -v $PWD/example/sample_apk:/root/tmp -e DEVICE="Nexus 5" -e APPIUM=true -e CONNECT_TO_GRID=true -e APPIUM_HOST="127.0.0.1" -e APPIUM_PORT=4723 -e SELENIUM_HOST="172.17.0.1" -e SELENIUM_PORT=4444 --name android-container budtmo/docker-android-x86-8.1
```

### Connect to Selenium Grid

It is also possible to connect appium server that run inside docker-android with selenium grid by passing following environment variables:

- CONNECT\_TO\_GRID=true
- APPIUM_HOST="\<host\_ip\_address>"
- APPIUM_PORT=\<port\_number>
- SELENIUM_HOST="\<host\_ip\_address>"
- SELENIUM_PORT=\<port\_number>
- SELENIUM_TIMEOUT=\<timeout\_in\_seconds>
- SELENIUM_PROXY_CLASS=\<selenium\_proxy\_class\_name>

To run tests for mobile browser, following parameter can be passed:

- MOBILE\_WEB\_TEST=true

```bash
docker run --privileged -d -p 6080:6080 -p 4723:4723 -p 5554:5554 -p 5555:5555 -e DEVICE="Samsung Galaxy S6" -e APPIUM=true -e CONNECT_TO_GRID=true -e APPIUM_HOST="127.0.0.1" -e APPIUM_PORT=4723 -e SELENIUM_HOST="172.17.0.1" -e SELENIUM_PORT=4444 -e MOBILE_WEB_TEST=true --name android-container budtmo/docker-android-x86-8.1
```

### Video Recording

You can deactivate auto_record by changing the value to "False" in docker-compose file. e.g. change value to "False" in this [line](docker-compose.yml#L70).

### Relaxed Security

Pass environment variable RELAXED_SECURITY=true to disable additional security check to use some advanced features.

### Docker-Compose

![][compose]

There is [example of compose file](docker-compose.yml) to run complete selenium grid and docker-android container as nodes. [docker-compose](https://docs.docker.com/compose/install/) version [1.13.0](https://github.com/docker/compose/releases/tag/1.13.0) or higher is required to be able to execute that compose file.

```bash
docker-compose up -d
```

[compose]: <images/compose.png>
