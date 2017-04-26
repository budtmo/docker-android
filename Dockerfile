FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

#=============
# Set WORKDIR
#=============
WORKDIR /root

#==================
# General Packages
#------------------
# wget
#   Network downloader
# unzip
#   Unzip zip file
# curl
#   Transfer data from or to a server
# xterm
#   Terminal emulator
# supervisor
#   Process manager
# openjdk-8-jdk
#   Java
# libqt5webkit5
#   Web content engine (Fix issue in Android)
# socat
#   Port forwarder
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
RUN apt-get -qqy update && apt-get -qqy install --no-install-recommends \
    wget \
    unzip \
    curl \
    xterm \
    supervisor \
    openjdk-8-jdk \
    libqt5webkit5 \
    socat \
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

#=======
# noVNC
# Use same commit id that docker-selenium uses
# https://github.com/elgalu/docker-selenium/blob/236b861177bd2917d864e52291114b1f5e4540d7/Dockerfile#L412-L413
#=======
ENV NOVNC_SHA="b403cb92fb8de82d04f305b4f14fa978003890d7" \
    WEBSOCKIFY_SHA="558a6439f14b0d85a31145541745e25c255d576b"
RUN  wget -nv -O noVNC.zip "https://github.com/kanaka/noVNC/archive/${NOVNC_SHA}.zip" \
 && unzip -x noVNC.zip \
 && rm noVNC.zip  \
 && mv noVNC-${NOVNC_SHA} noVNC \
 && wget -nv -O websockify.zip "https://github.com/kanaka/websockify/archive/${WEBSOCKIFY_SHA}.zip" \
 && unzip -x websockify.zip \
 && mv websockify-${WEBSOCKIFY_SHA} ./noVNC/utils/websockify \
 && rm websockify.zip \
 && ln noVNC/vnc_auto.html noVNC/index.html

#=====================
# Install Android SDK
#=====================
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre
ENV PATH ${PATH}:${JAVA_HOME}/bin

ENV SDK_VERSION=25.2.3 \
    ANDROID_HOME=/root
RUN wget -nv -O android.zip https://dl.google.com/android/repository/tools_r${SDK_VERSION}-linux.zip \
 && unzip android.zip && rm android.zip
ENV PATH ${PATH}:${ANDROID_HOME}/tools
RUN echo y | android update sdk --no-ui -a --filter platform-tools
ENV PATH ${PATH}:${ANDROID_HOME}/platform-tools

#====================================
# Install latest nodejs, npm, appium
#====================================
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
 && apt-get -qqy update && apt-get -qqy install nodejs && rm -rf /var/lib/apt/lists/*
ENV APPIUM_VERSION 1.6.3
RUN npm install -g appium@$APPIUM_VERSION && npm cache clean

#======================
# Install SDK packages
#======================
ARG ANDROID_VERSION=5.0.1
ARG BUILD_TOOL=21.1.2
ARG API_LEVEL=21
ARG PROCESSOR=x86
ARG SYS_IMG=x86_64
ARG IMG_TYPE=google_apis
ENV ANDROID_VERSION=$ANDROID_VERSION \
    BUILD_TOOL=$BUILD_TOOL \
    API_LEVEL=$API_LEVEL \
    PROCESSOR=$PROCESSOR \
    SYS_IMG=$SYS_IMG \
    IMG_TYPE=$IMG_TYPE
RUN echo y | android update sdk --no-ui -a --filter build-tools-${BUILD_TOOL}
ENV PATH ${PATH}:${ANDROID_HOME}/build-tools

RUN rm ${ANDROID_HOME}/tools/emulator \
 && ln -s ${ANDROID_HOME}/tools/emulator64-${PROCESSOR} ${ANDROID_HOME}/tools/emulator
RUN echo y | android update sdk --no-ui -a -t android-${API_LEVEL},sys-img-${SYS_IMG}-${IMG_TYPE}-${API_LEVEL}

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

#===============
# Expose Ports
#---------------
# 4723
#   Appium port
# 6080
#   noVNC port
# 5554
#   Emulator port
# 5555
#   ADB connection port
#===============
EXPOSE 4723 6080 5554 5555

#======================
# Add Emulator Devices
#======================
COPY devices /root/devices

#===================
# Run docker-appium
#===================
COPY src /root/src
COPY supervisord.conf /root/
RUN chmod -R +x /root/src && chmod +x /root/supervisord.conf
CMD /usr/bin/supervisord --configuration supervisord.conf
