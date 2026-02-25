#!/bin/bash
# KVM 무임승차 세팅
sudo mknod /dev/kvm c 10 232 && sudo chmod 666 /dev/kvm

# 탭 A8(1200x1920) 해상도로 가상 화면 생성
Xvfb :1 -screen 0 1200x1920x24 +extension RANDR &
export DISPLAY=:1
xrdb -merge /home/flyuser/.Xresources

# OpenClaw 실행
cd /mnt/data/openclaw
sudo -u flyuser ./openclaw start &

# 내부망으로 화면 송출 (Gateway가 낚아챌 수 있게)
x11vnc -display :1 -forever -nopw -listen 0.0.0.0 -rfbport 5900
