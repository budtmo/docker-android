FROM ubuntu:16.04

#=======================
# General Configuration
#=======================
RUN apt-get update && apt-get upgrade -y
RUN apt-get install wget -y

#==============
# Install Java
#==============
RUN apt-get install openjdk-8-jdk -y
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

#=====================
# Install Android SDK
#=====================
RUN wget http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN tar -xvzf android-sdk_r24.4.1-linux.tgz
ENV ANDROID_HOME="/android-sdk-linux"
ENV PATH="${PATH}:${ANDROID_HOME}/tools"

#=====================================================
# Install Platform-tools, Build-tools
# To see list of available packages: android list sdk
#=====================================================
RUN echo y | android update sdk --no-ui --filter 2,3
ENV PATH="${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH="${PATH}:${ANDROID_HOME}/build-tools"

#==================================================
# Fix issue regarding 64bit while running emulator
#==================================================
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 -y
ENV ANDROID_EMULATOR_FORCE_32BIT=true
RUN adb start-server

#============================================
# Install nodejs, npm, appium, appium-doctor
#============================================
RUN apt-get install npm nodejs-legacy -y
ENV APPIUM_VERSION 1.6.3
RUN npm install -g appium@$APPIUM_VERSION

#===================
# Run docker-appium
#===================
COPY service /service
WORKDIR /service
CMD python start.py
