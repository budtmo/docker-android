Docker-Android-Pro
------------------

Docker-Android-Pro is a sponsor based project which mean that the docker image of pro-version can be pulled only by [active sponsor](https://github.com/sponsors/budtmo). After donation, please send email [here](mailto:budtmo2.os@gmail.com) with following format on subject email: ```<github_id>-<date-when-donation-is-made>-<email>``` e.g. ```budtmo-30.01.2021-myemail@test.com```. The script will validate everything and it will send the access token to that email within 48 hours to be able to pull the pro version of docker-android image. Contact [@budtmo](https://github.com/budtmo) if you dont get access token after donation. The access token will be removed as soon as the user become inactive sponsor.

The differences between normal version and pro version are:

|Feature   |Normal   |Pro   |Comment|
|:---|:---|:---|:---|
|user-behavior-analytics|Yes|No|-|
|AI-Agent|No|Yes|Currently supported local-LLM server: Ollama, VLLM, It can also control emulator via REST-API|
|proxy|No|Yes|Set up company proxy on Android emulator on fly|
|language|No|Yes|Set up language on Android emulator on fly|
|Older Android version|No|Yes|Support other newer Android version e.g. Android 9 and Android 10|
|Newer Android version|No|Yes|Support other newer Android version e.g. Android 15, Android 16, Android 17, etc|
|root-privileged|No|Yes|Able to run command with security privileged|
|Selenium 4.x integration|No|Yes|Running Appium UI-Tests againt one (Selenium Hub) endpoint for Android- and iOS emulator(s) / device(s)|
|multiple Android-Simulators|No|Yes (soon)|Save resources by having multiple Android-Simulators on one docker-container|
|Google Play Store|No|Yes (soon)|-|
|Video Recording|No|Yes (soon)|Helpful for debugging|


List of Docker-Images
---------------------
|Android   |API   |Usage Type   |Image with latest release version   |Image with specific release version|
|:---|:---|:---|:---|:---|
|9.0|28|Development |budtmo2/docker-android-pro:emulator_9.0|budtmo2/docker-android-pro:emulator_9.0_<release_version>|
|10.0|29|Development |budtmo2/docker-android-pro:emulator_10.0|budtmo2/docker-android-pro:emulator_10.0_<release_version>|
|11.0|30|Development |budtmo2/docker-android-pro:emulator_11.0|budtmo2/docker-android-pro:emulator_11.0_<release_version>|
|12.0|32|Development |budtmo2/docker-android-pro:emulator_12.0|budtmo2/docker-android-pro:emulator_12.0_<release_version>|
|13.0|33|Development |budtmo2/docker-android-pro:emulator_13.0|budtmo2/docker-android-pro:emulator_13.0_<release_version>|
|14.0|34|Development |budtmo2/docker-android-pro:emulator_14.0|budtmo2/docker-android-pro:emulator_14.0_<release_version>|
|15.0|35|Development |budtmo2/docker-android-pro:emulator_15.0|budtmo2/docker-android-pro:emulator_15.0_<release_version>|
|16.0|36|Development |budtmo2/docker-android-pro:emulator_16.0|budtmo2/docker-android-pro:emulator_16.0_<release_version>|
|17.0|37|Development |budtmo2/docker-android-pro:emulator_17.0|budtmo2/docker-android-pro:emulator_17.0_<release_version>|
|9.0|28|Production-like |budtmo2/docker-android-pro:emulator_playstore_9.0|budtmo2/docker-android-pro:emulator_playstore_9.0_<release_version>|
|10.0|29|Production-like |budtmo2/docker-android-pro:emulator_playstore_10.0|budtmo2/docker-android-pro:emulator_playstore_10.0_<release_version>|
|11.0|30|Production-like |budtmo2/docker-android-pro:emulator_playstore_11.0|budtmo2/docker-android-pro:emulator_playstore_11.0_<release_version>|
|12.0|32|Production-like |budtmo2/docker-android-pro:emulator_playstore_12.0|budtmo2/docker-android-pro:emulator_playstore_12.0_<release_version>|
|13.0|33|Production-like |budtmo2/docker-android-pro:emulator_playstore_13.0|budtmo2/docker-android-pro:emulator_playstore_13.0_<release_version>|
|14.0|34|Production-like |budtmo2/docker-android-pro:emulator_playstore_14.0|budtmo2/docker-android-pro:emulator_playstore_14.0_<release_version>|
|15.0|35|Production-like |budtmo2/docker-android-pro:emulator_playstore_15.0|budtmo2/docker-android-pro:emulator_playstore_15.0_<release_version>|
|16.0|36|Production-like |budtmo2/docker-android-pro:emulator_playstore_16.0|budtmo2/docker-android-pro:emulator_playstore_16.0_<release_version>|
|17.0|37|Production-like |budtmo2/docker-android-pro:emulator_playstore_17.0|budtmo2/docker-android-pro:emulator_playstore_17.0_<release_version>|
|-|-|-|budtmo2/docker-android-pro:agent|budtmo2/docker-android-pro:agent_<release_version>|
|-|-|-|budtmo2/docker-android-pro:selenium|budtmo2/docker-android-pro:selenium_<release_version>|

You can always pull the latest image tag. In case you want to see the release version that has been built with a changelog note and use that specific release version, the information will be sent to you as well.


List of Devices
---------------

Type   | Device Name
-----  | -----
Phone  | Samsung Galaxy S10
Phone  | Samsung Galaxy S9
Phone  | Samsung Galaxy S8
Phone  | Samsung Galaxy S7 Edge
Phone  | Samsung Galaxy S7
Phone  | Samsung Galaxy S6
Phone  | Nexus 4
Phone  | Nexus 5
Phone  | Nexus One
Phone  | Nexus S
Tablet | Nexus 7
Tablet | Pixel C


Proxy
-----

You can enable proxy inside container and Android emulator by passing following environment variables:

- HTTP_PROXY="http://\<docker\_bridge\_ip>:<port>"
- HTTPS_PROXY="http://\<docker\_bridge\_ip>:<port>"
- NO_PROXY="localhost"
- EMULATOR_PROXY_URL="http://\<docker\_bridge\_ip>:<port>"
- EMULATOR_PROXY_USER="\<proxy_user>"
- EMULATOR_PROXY_PASS="\<proxy_pass>"


Language
--------

You can change the language setting of Android Emulator on the fly by passing following environment variable:

- EMULATOR_LANGUAGE="\<language>"
- EMULATOR_COUNTRY="\<country>"


Selenium
--------

Pull and run image that contains Selenium with Appium urls and its capabilities which is stored inside node.json file:

```
docker run -t --rm --name selenium -p 4444:4444 -v $PWD/pro-example/node.json:/home/seleniumusr/selenium_node_config/node.json budtmo2/docker-android-pro:selenium
```

[<- BACK TO README](../README.md)
