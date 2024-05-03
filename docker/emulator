ARG DOCKER_ANDROID_VERSION
FROM budtmo/docker-android:base_${DOCKER_ANDROID_VERSION}

#==================
# Android Packages
#==================
ARG EMULATOR_ANDROID_VERSION
ARG EMULATOR_API_LEVEL
ENV EMULATOR_ANDROID_VERSION=${EMULATOR_ANDROID_VERSION} \
    EMULATOR_API_LEVEL=${EMULATOR_API_LEVEL} \
    EMULATOR_SYS_IMG=x86_64 \
    EMULATOR_IMG_TYPE=google_apis \
    EMULATOR_BROWSER=chrome
ENV PATH ${PATH}:${ANDROID_HOME}/build-tools
RUN yes | sdkmanager --licenses \
 && sdkmanager "platforms;android-${EMULATOR_API_LEVEL}" \
 "system-images;android-${EMULATOR_API_LEVEL};${EMULATOR_IMG_TYPE};${EMULATOR_SYS_IMG}" "emulator" \
 && ln -s ${ANDROID_HOME}/emulator/emulator /usr/bin/

#=============
# UI Packages
#-------------
# ffmpeg
#   Video recorder
# feh
#   Screen background
# libxcomposite-dev
#   Window System for Emulator
# menu
#   Debian menu
# openbox
#   Windows manager
# x11vnc
#   VNC server
# xterm
#   Terminal emulator
#==================
RUN apt-get -qqy update && apt-get -qqy install --no-install-recommends \
    ffmpeg \
    feh \
    libxcomposite-dev \
    menu \
    openbox \
    x11vnc \
    xterm \
 && apt autoremove -y \
 && apt clean all \
 && rm -rf /var/lib/apt/lists/*

#=======
# noVNC
#=======
ENV NOVNC_VERSION="1.4.0" \
    WEBSOCKIFY_VERSION="0.11.0" \
    OPT_PATH="/opt"
RUN  wget -nv -O noVNC.zip "https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.zip" \
 && unzip -x noVNC.zip \
 && rm noVNC.zip  \
 && mv noVNC-${NOVNC_VERSION} ${OPT_PATH}/noVNC \
 && wget -nv -O websockify.zip "https://github.com/novnc/websockify/archive/refs/tags/v${WEBSOCKIFY_VERSION}.zip" \
 && unzip -x websockify.zip \
 && mv websockify-${WEBSOCKIFY_VERSION} ${OPT_PATH}/noVNC/utils/websockify \
 && rm websockify.zip \
 && ln ${OPT_PATH}/noVNC/vnc.html ${OPT_PATH}/noVNC/index.html

ENV DISPLAY=:0 \
    SCREEN_NUMBER=0 \
    SCREEN_WIDTH=1600 \
    SCREEN_HEIGHT=900 \
    SCREEN_DEPTH=24+32 \
    VNC_PORT=5900 \
    WEB_VNC_PORT=6080

EXPOSE 5900 6080

#==========
# Copy app
#==========
RUN rm -rf ${SCRIPT_PATH}
ENV SCRIPT_PATH="docker-android"
ENV WORK_PATH="/home/androidusr"
ENV APP_PATH=${WORK_PATH}/${SCRIPT_PATH}
RUN mkdir -p ${APP_PATH}
COPY mixins ${APP_PATH}/mixins
COPY cli ${APP_PATH}/cli
RUN chown -R 1300:1301 ${APP_PATH} \
 && pip install --quiet -e ${APP_PATH}/cli

#===================
# Configure OpenBox
#===================
RUN echo ${APP_PATH}/mixins/configs/display/.fehbg >> /etc/xdg/openbox/autostart

#==================
# Use created user
#==================
USER 1300:1301
ENV LOG_PATH=${WORK_PATH}/logs \
    WEB_LOG_PORT=9000
EXPOSE 9000
RUN mkdir -p ${LOG_PATH}
RUN mkdir -p "${WORK_PATH}/.config/Android Open Source Project" \
 && echo "[General]\nshowNestedWarning=false\n" > "${WORK_PATH}/.config/Android Open Source Project/Emulator.conf"

#=========
# Run App
#=========
STOPSIGNAL SIGTERM
ENV DEVICE_TYPE=emulator
ENTRYPOINT ["/home/androidusr/docker-android/mixins/scripts/run.sh"]
