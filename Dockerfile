FROM ubuntu:16.04

#=======================
# General Configuration
#=======================
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y

#=====================================
# Install virtual display framebuffer
#=====================================
RUN apt-get install xvfb x11vnc -y

#=========================================================
# Install Windows Manager, Debian Menu, Numpy and Netstat
# https://github.com/novnc/websockify/issues/77
#=========================================================
RUN apt-get install openbox menu python-numpy net-tools -y

#====================
# Install Supervisor
#====================
RUN apt-get install supervisor -y

#=============
# Set WORKDIR
#=============
WORKDIR /root

#======================
# Clone noVNC projects
#======================
RUN apt-get install git -y
RUN git clone https://github.com/kanaka/noVNC.git && \
    cd noVNC/utils && git clone https://github.com/kanaka/websockify websockify

#==============
# Install Java
#==============
RUN apt-get install openjdk-8-jdk -y
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

#=====================
# Install Android SDK
#=====================
RUN apt-get install wget unzip libqt5webkit5 -y

RUN wget https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
RUN unzip tools_r25.2.3-linux.zip && rm tools_r25.2.3-linux.zip
ENV ANDROID_HOME="/root"
ENV PATH="${PATH}:${ANDROID_HOME}/tools"

#=====================================================
# Install Platform-tools, Build-tools
# To see list of available packages: android list sdk
#=====================================================
RUN echo y | android update sdk --no-ui --filter 2,3
ENV PATH="${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH="${PATH}:${ANDROID_HOME}/build-tools"
RUN mv ${ANDROID_HOME}/tools/emulator ${ANDROID_HOME}/tools/emulator.backup

#====================================
# Install latest nodejs, npm, appium
#====================================
RUN apt-get install curl -y
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install nodejs -y
ENV APPIUM_VERSION 1.6.3
RUN npm install -g appium@$APPIUM_VERSION

#============================================================
# Install KVM for emulator x86
# Source: https://help.ubuntu.com/community/KVM/Installation
#============================================================
RUN apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils -y

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

#==============
# Expose Ports
#==============
EXPOSE 4723
EXPOSE 6080

#==================
# Add Browser APKs
#==================
COPY browser_apk /root/browser_apk

#====================
# Add Emulator Skins
#====================
COPY skins /root/skins

#===================
# Run docker-appium
#===================
COPY supervisord.conf /root/
COPY src /root/src
CMD /usr/bin/supervisord --configuration supervisord.conf
