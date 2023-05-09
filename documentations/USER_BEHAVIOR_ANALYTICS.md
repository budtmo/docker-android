# Docker-Android's Anonymous Aggregate User Behavior Analytics
Docker-Android has begun gathering anonymous aggregate user behavior analytics and reporting these to Google Sheets through Google Forms API (Google Form ID: 1FAIpQLSdrKWQdMh6Nt8v8NQdYvTIntohebAgqWCpXT3T9NofAoxcpkw). You are notified about this when you start Docker-Android.

## Why?
We don't have direct communication with its users nor time resources to ask directly for their feedback. As a result, we now use anonymous aggregate user behavior analytics to help us understand how Docker-Android is being used, the most common used features based on how, where and when people use it. With this information we can prioritize some features over other ones.

## What?
Docker-Android's Sheets record some shared information for every event:

* Date and time when Docker-Android started
* User (it will collect the information about Release Version of Machine), e.g. Linux-5.4.0-146-generic-x86_64-with-glibc2.29_#163-Ubuntu_SMP_Fri_Mar_17_18:26:02_UTC_2023. This does not allow us to track individual users but does enable us to accurately measure user counts
* City (the information come from https://ipinfo.io)
* Region (the information come from https://ipinfo.io)
* Country (the information come from https://ipinfo.io)
* Release version of Docker-Android
* Appium (Whether user use Appium or not - The possible value will be "true" or "false")
* Appium Additional Arguments
* Web-Log (Whether user use Web-Log feature or not - The possible value will be "true" or "false")
* Web-Vnc (Whether user use Web-Vnc feature or not - The possible value will be "true" or "false")
* Screen-Resolution
* Device Type (Which docker image is used - The possible value will be "emulator" or "geny_cloud" or "geny_aws")
* Emulator Device (Which device profile and skin is used if the user use device_type "emulator")
* Emulator Android Version (Which Android version is used if the user use device_type "emulator"
* Emulator No-Skin feature (Whether user use no-skin feature or not - The possible value will be "true" or "false")
* Emulator Data Partition
* Emulator Additional Arguments

With the recorded information, it is not possible for us to match any particular real user.

## When/Where?
Docker-Android's user behavior analytics are sent throughout Docker-Android's execution to Google Sheets through Google Forms API over HTTPS.

## Who?
Docker-Android's analytics are accessible to Docker-Android's current maintainers. Contact [@budtmo](https://github.com/budtmo) if you are a maintainer and need access.

## How?
The code is viewable in [these scripts](../cli/src/device).

## Opting out before starting Docker-Android
Docker-Android analytics helps us, maintainers and leaving it on is appreciated. However, if you want to opt out and not send any information, you can do this by using passing environment variable USER_BEHAVIOR_ANALYTICS=false to the Docker container.

## Disclaimer
This document and the implementation are based on the great idea implemented by [Homebrew](https://github.com/Homebrew/brew/blob/master/docs/Analytics.md)


[<- BACK TO LICENSE](../LICENSE.md)
