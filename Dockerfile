FROM ubuntu:14.04

#=======================
# General Configuration
#=======================
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -y

#=====================================
# Install virtual display framebuffer
#=====================================
RUN apt-get install Xvfb x11vnc -y

#================================================
# Install Windows Manager, Debian Menu and Numpy
# https://github.com/novnc/websockify/issues/77
#================================================
RUN apt-get install openbox menu python-numpy -y

#======================
# Clone noVNC projects
#======================
RUN apt-get install git -y
WORKDIR /root
RUN git clone https://github.com/kanaka/noVNC.git && \
    cd noVNC/utils && git clone https://github.com/kanaka/websockify websockify

#==============
# Install Java
#==============
RUN apt-get install openjdk-7-jdk -y
ENV JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64/jre"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

#=====================
# Install Android SDK
#=====================
RUN apt-get install wget -y
RUN wget http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN tar -xvzf android-sdk_r24.4.1-linux.tgz && rm android-sdk_r24.4.1-linux.tgz
ENV ANDROID_HOME="/root/android-sdk-linux"
ENV PATH="${PATH}:${ANDROID_HOME}/tools"

#=====================================================
# Install Platform-tools, Build-tools
# To see list of available packages: android list sdk
#=====================================================
RUN echo y | android update sdk --no-ui --filter 2,3
ENV PATH="${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH="${PATH}:${ANDROID_HOME}/build-tools"
RUN mv ${ANDROID_HOME}/tools/emulator ${ANDROID_HOME}/tools/emulator.backup
RUN ln -s ${ANDROID_HOME}/tools/emulator64-arm ${ANDROID_HOME}/tools/emulator

#====================================
# Install latest nodejs, npm, appium
#====================================
RUN apt-get install curl -y
RUN curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
RUN apt-get install nodejs -y
ENV APPIUM_VERSION 1.6.3
RUN npm install -g appium@$APPIUM_VERSION

#======================
# noVNC Configurations
#======================
ENV DISPLAY=:0 \
    SCREEN=0 \
    SCREEN_WIDTH=1600 \
    SCREEN_HEIGHT=900 \
    SCREEN_DEPTH=16 \
    LOCAL_PORT=5900 \
    TARGET_PORT=6080 \
    TIMEOUT=1
RUN ln -s noVNC/vnc_auto.html noVNC/index.html

#===================
# Run docker-appium
#===================
COPY service /root/service
CMD python -m service.start
