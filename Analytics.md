# Docker-Android's Anonymous Aggregate User Behaviour Analytics
Docker-Android has begun gathering anonymous aggregate user behaviour analytics and reporting these to Google Analytics. You are notified about this when you start Docker-Android.

## Why?
Docker-Android is provided free of charge for our internal and external users and we don't have direct communication with its users nor time resources to ask directly for their feedback. As a result, we now use anonymous aggregate user analytics to help us understand how Docker-Android is being used, the most common used features based on how, where and when people use it. With this information we can prioritize some features over other ones.

## What?
Docker-Android's analytics record some shared information for every event:

- The Google Analytics version i.e. `1` (https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#v)
- The Google Analytics anonymous IP setting is enabled i.e. `1` (https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#aip)
- The Docker-Android analytics tracking ID e.g. `UA-133466903-1` (https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#tid)
- The release version of machine, e.g. `Linux_version_4.4.16-boot2docker_(gcc_version_4.9.2_(Debian_4.9.2-10)_)_#1_SMP_Fri_Jul_29_00:13:24_UTC_2016` This does not allow us to track individual users but does enable us to accurately measure user counts vs. event counts (https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#cid)
- Docker-Android analytics hit type, e.g. `event` (https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#t)
- Application type, e.g. `Emulator` (https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ec)
- Description will contains information about Emulator configuration, e.g. `Processor type`. (https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#el)
- Docker-Android application name, e.g. `docker-android` (https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#an)
- Docker-Android application version, e.g. `1.5-p0` (https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#av)

With the recorded information, it is not possible for us to match any particular real user.

As far as we can tell it would be impossible for Google to match the randomly generated analytics user ID to any other Google Analytics user ID. If Google turned evil the only thing they could do would be to lie about anonymising IP addresses and attempt to match users based on IP addresses.

## When/Where?
Docker-Android's analytics are sent throughout Docker-Android's execution to Google Analytics over HTTPS.

## Who?
Docker-Android's analytics are accessible to Docker-Android's current maintainers. Contact [@budtmo](https://github.com/budtmo) if you are a maintainer and need access.

## How?
The code is viewable in [this script](./src/appium.sh).

## Opting out before starting Docker-Android
Docker-Android analytics helps us, maintainers and leaving it on is appreciated. However, if you want to opt out and not send any information, you can do this by using passing environment variable GA=false to the Docker container.

## Disclaimer
This document and the implementation are based on the great idea implemented by [Homebrew](https://github.com/Homebrew/brew/blob/master/docs/Analytics.md)
