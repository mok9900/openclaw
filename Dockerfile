FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul

# 기본 패키지 및 AMD 드라이버/도구 설치
RUN apt-get update && apt-get install -y \
    sudo wget curl git xfce4 xfce4-goodies \
    chromium-browser x11-xserver-utils \
    kasmvncserver dbus-x11 \
    pciutils cpu-checker kmod \
    python3 nodejs npm \
    && apt-get clean

# KasmVNC 설정 및 유저 생성
RUN useradd -m -s /bin/bash flyuser && \
    echo "flyuser:flypass" | chpasswd && \
    adduser flyuser sudo && \
    echo "flyuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# OpenClaw 실행을 위한 작업 디렉토리 설정
WORKDIR /mnt/data

# 부팅 스크립트 복사
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 포트 개방
EXPOSE 8443

ENTRYPOINT ["/entrypoint.sh"]
