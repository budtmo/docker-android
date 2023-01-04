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

### Connect to Selenium Grid 4 (new architecture)

Now it is possbile to connect appium server that run inside docker-android with the new selenium grid architecture released starting [selenium 4](https://www.selenium.dev/documentation/grid/architecture/) by passing following environment variables:

- CONNECT\_TO\_GRID_4=true
- APPIUM_HOST="\<host\_ip\_address>"
- APPIUM_PORT=\<port\_number>
- SE_EVENT_BUS_HOST=<event_bus_ip|event_bus_name>
- SE_EVENT_BUS_PUBLISH_PORT=4442
- SE_EVENT_BUS_SUBSCRIBE_PORT=4443

Here it is an [example of compose file](docker-compose-grid-4.yml) to run docker-android container as nodes and connect to the new selenium hub version.

<img width="1478" alt="Screenshot 2023-01-03 at 9 54 00 PM" src="https://user-images.githubusercontent.com/33426940/210650123-65ceda10-a62b-4ed3-82e6-b037a37ca851.png">

**Notes**: 
- The selenium hub image version has to be higher than 4, otherwise nodes will fail trying to connect to selenium hub with the error: `[Appium] An attempt to register with the grid was unsuccessful: Request failed with status code 404` inside node logs at `var/log/supervisor/appium.log` 
