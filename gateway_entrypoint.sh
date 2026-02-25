#!/bin/bash
# 오디오 서버 가동
sudo -u flyuser pulseaudio -D --exit-idle-time=-1

# 본체의 화면을 땡겨와서 탭 A8 브라우저에 쏴줌
# DynamicResolution 옵션으로 브라우저 크기에 따라 픽셀 자동 매칭
sudo -u flyuser vncserver :1 \
    -name "GameKorea_Ultra_Stream" \
    -httpd /usr/share/kasmvnc/www \
    -websocket 8443 \
    -FrameRate 60 \
    -ProxyTo worker.process.gamekorea.internal:5900 \
    -DynamicResolution \
    -DisableSecurity
