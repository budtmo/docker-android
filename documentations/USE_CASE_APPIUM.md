Run Appium Server
-----------------

Appium is automation test framework to test mobile website and mobile application, including Android. To be able to use Appium, you need to run Appium-Server. You run Appium-Server inside docker-android container by ***opening port 4723*** and ***passing an environment variable APPIUM=true***.

```
docker run -d -p 6080:6080 -p 4723:4723 -e EMULATOR_DEVICE="Samsung Galaxy S10" -e WEB_VNC=true -e APPIUM=true --device /dev/kvm --name android-container budtmo/docker-android:emulator_11.0
```

### Additional parameters to Appium Server

The user can pass the additional parameter to Appium Server through environment variable ***APPIUM_ADDITIONAL_ARGS***. Please check [this page](http://appium.io/docs/en/2.0/cli/args/) for possible arguments that can be passed to Appium 2.x.

### Connect to Selenium Grid 4.x

The user can connect docker-android that contains Appium 2.x to Selenium Grid 4.x without any additional configurations / changes in docker-android project. Please check [this page](http://appium.io/docs/en/2.0/guides/grid/) for detail information 


[<- BACK TO README](../README.md)
