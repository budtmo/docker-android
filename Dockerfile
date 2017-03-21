FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

#=============
# Set WORKDIR
#=============
WORKDIR /root

#==================
# General Packages
#------------------
# git
#   Clone git repository
# wget
#   Network downloader
# unzip
#   Unzip zip file
# curl
#   Transfer data from or to a server
# supervisor
#   Process manager
# openjdk-8-jdk
#   Java
# libqt5webkit5
#   Web content engine (Fix issue in Android)
#------------------
#  NoVNC Packages
#------------------
# xvfb
#   X virtual framebuffer
# x11vnc
#   VNC server for X display
# openbox
#   Windows manager
# menu
#   Debian menu
# python-numpy
#   Numpy, For faster performance: https://github.com/novnc/websockify/issues/77
# net-tools
#   Netstat
#------------------
#    KVM Package
# for emulator x86
# https://help.ubuntu.com/community/KVM/Installation
#------------------
# qemu-kvm
# libvirt-bin
# ubuntu-vm-builder
# bridge-utils
#==================
RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    curl \
    supervisor \
    openjdk-8-jdk \
    libqt5webkit5 \
    xvfb \
    x11vnc \
    openbox \
    menu \
    python-numpy \
    net-tools \
    qemu-kvm \
    libvirt-bin \
    ubuntu-vm-builder \
    bridge-utils \
 && rm -rf /var/lib/apt/lists/*

#======================
# Clone noVNC projects
#======================
RUN git clone https://github.com/kanaka/noVNC.git \
 && cd noVNC/utils && git clone https://github.com/kanaka/websockify websockify

#======================================
# Install Android SDK and its packages
#======================================
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre
ENV PATH ${PATH}:${JAVA_HOME}/bin

ENV SDK_VERSION=25.2.3 \
    BUILD_TOOL=25.0.2 \
    ANDROID_HOME=/root
RUN wget -O android.zip https://dl.google.com/android/repository/tools_r${SDK_VERSION}-linux.zip \
 && unzip android.zip && rm android.zip
ENV PATH ${PATH}:${ANDROID_HOME}/tools
RUN echo y | android update sdk --no-ui --filter platform-tools,build-tools-${BUILD_TOOL}
ENV PATH ${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools
RUN mv ${ANDROID_HOME}/tools/emulator ${ANDROID_HOME}/tools/emulator.backup

#====================================
# Install latest nodejs, npm, appium
#====================================
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
 && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*
ENV APPIUM_VERSION 1.6.3
RUN npm install -g appium@$APPIUM_VERSION && npm cache clean

#================================================
# noVNC Default Configurations
# These Configurations can be changed through -e
#================================================
ENV DISPLAY=:0 \
    SCREEN=0 \
    SCREEN_WIDTH=1600 \
    SCREEN_HEIGHT=900 \
    SCREEN_DEPTH=16 \
    LOCAL_PORT=5900 \
    TARGET_PORT=6080 \
    TIMEOUT=1 \
    LOG_PATH=/var/log/supervisor
RUN ln -s noVNC/vnc_auto.html noVNC/index.html

#===============
# Expose Ports
#---------------
# 4723
#   appium port
# 6080
#   noVNC port
#===============
EXPOSE 4723 6080

#==================
# Add Browser APKs
#==================
COPY browser_apk /root/browser_apk

#======================
# Add Emulator Devices
#======================
COPY devices /root/devices

#===================
# Run docker-appium
#===================
COPY supervisord.conf /root/
COPY src /root/src
CMD /usr/bin/supervisord --configuration supervisord.conf
