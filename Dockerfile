FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 전체 패키지 설치 (가상화 + 송출 + 오디오)
RUN apt-get update && apt-get install -y \
    sudo wget curl git xfce4 xfce4-goodies xvfb x11vnc \
    kasmvncserver pulseaudio dbus-x11 x11-xserver-utils \
    pciutils cpu-checker kmod mesa-utils-extra \
    python3 python3-pip nodejs npm \
    && apt-get clean

# 유저 설정 및 갤탭 A8 PPI(216) 최적화
RUN useradd -m -s /bin/bash flyuser && echo "flyuser:flypass" | chpasswd && \
    adduser flyuser sudo && echo "flyuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p /home/flyuser/.kasvnc
RUN echo "Xft.dpi: 216" > /home/flyuser/.Xresources

# KasmVNC 16스레드 인코딩 강제 설정
RUN echo 'encoding:\n  default_encoding: "webp"\n  max_fps: 60\n  threads: 16\nnetwork:\n  websocket_port: 8443' > /home/flyuser/.kasvnc/kasmvnc.yaml
RUN chown -R flyuser:flyuser /home/flyuser/.kasvnc

WORKDIR /data
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8443
ENTRYPOINT ["/entrypoint.sh"]
