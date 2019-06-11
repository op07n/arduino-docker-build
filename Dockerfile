FROM gitpod/workspace-full-vnc

MAINTAINER suculent

USER root

RUN apt-get update \
    && apt-get install -y python-serial python3-serial \
    && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

RUN curl https://downloads.arduino.cc/arduino-1.8.9-linux64.tar.xz > ./arduino-1.8.9-linux64.tar.xz \
 && unxz ./arduino-1.8.9-linux64.tar.xz \
 && tar -xvf arduino-1.8.9-linux64.tar \
 && rm -rf arduino-1.8.9-linux64.tar \
 && mv ./arduino-1.8.9 /opt/arduino \
 && cd /opt/arduino \
 && ./install.sh

RUN mkdir /opt/workspace

RUN mkdir -p /opt/arduino/hardware/espressif \
 && cd /opt/arduino/hardware/espressif \
 && git clone https://github.com/espressif/arduino-esp32.git esp32 \
 && cd esp32 \
 && git submodule update --init --recursive \
 && cd tools \
 && python get.py && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# RUN cd /opt/arduino/hardware/espressif \
#   && git clone https://github.com/esp8266/Arduino.git esp8266 \
#   && cd esp8266 \
#   && git checkout tags/2.5.0 \
#   && cd ./tools \
#   && python get.py #   && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add boards manager URL (warning, mismatch in boardsmanager vs. boards_manager in 2.6.0 coming up)
RUN /opt/arduino/arduino --pref "boardsmanager.additional.urls=http://arduino.esp8266.com/stable/package_esp8266com_index.json" --save-prefs \
    && /opt/arduino/arduino --install-boards esp8266:esp8266 --save-prefs

WORKDIR /opt/workspace
COPY cmd.sh /opt/
CMD /opt/cmd.sh
