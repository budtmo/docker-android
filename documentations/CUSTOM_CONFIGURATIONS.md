VNC-CLIENT
----------

Vnc-server inside container is run on port 5900

1. Run docker-android:
    ```
    docker run -d -p 5900:5900 -e EMULATOR_DEVICE="Samsung Galaxy S10" --device /dev/kvm --name android-container budtmo/docker-android:emulator_11.0
    ```

2. Connect docker-container using vnc-client

Environment variables that can be passed to docker container for vnc configuration:
|Environment Variable   |Description   |Example|
|:---|:---|:---|
|VNC_PASSWORD|protect vnc connection with password|docker run ... -e VNC_PASSWORD=thisissecret ...|


VNC-WEB
-------

Vnc-web inside container is run on port 6080

Environment variables that can be passed to docker container for vnc configuration:
|Environment Variable   |Description   |Example|
|:---|:---|:---|
|WEB_VNC|access inside of the container through web-ui|docker run ... -p 6080:6080 -e WEB_VNC=true ...|
|WEB_VNC_PORT|access inside of the container through web-ui on given port (default port 6080)|docker run ... -p 6081:6081 -e WEB_VNC=true -e WEB_VNC_PORT=6081 ...|

Possible endpoints if WEB_VNC is activated:
|Endpoint   |Description   |Example|
|:---|:---|:---|
|autoconnect|access web-ui of vnc direclty|http://localhost:6080/?autoconnect=true|
|view_only|give only view access|http://localhost:6080/?autoconnect=true&view_only=true|
|password|access web-ui of vnc directly with protected password|http://localhost:6080/?autoconnect=true&password=thisissecret|


LOG-SHARING
-----------

The user has possibility to access log-files through web-ui:
|Environment Variable   |Description   |Example|
|:---|:---|:---|
|WEB_LOG|access log-files through web-ui|docker run ... -e WEB_LOG=true ...|
|WEB_LOG_PORT|access log-files through web-ui on given port (default port 9000)|docker run ... -e WEB_LOG=true -e WEB_LOG_PORT=9001 ...|


EMULATOR
--------

Possible environment variable to configure the Emulator:
|Environment Variable   |Description   |Example|
|:---|:---|:---|
|EMULATOR_NAME|give emulator name (default name is a combination between Device name and Android version)|docker run ... -e EMULATOR_NAME=my_emu ...|
|EMULATOR_DATA_PARTITION|set data partition on emulator (default value 550m)|docker run ... -e EMULATOR_DATA_PARTITION=900m ...|
|EMULATOR_NO_SKIN|deploying emulator without skin|docker run ... -e EMULATOR_NO_SKIN=true ...|

The user can also pass needed arguments to android emulator through environment variable ***EMULATOR_ADDITIONAL_ARGS***. Please check [this page](https://developer.android.com/studio/run/emulator-commandline) for possible arguments that can be passed.


[<- BACK TO README](../README.md)
