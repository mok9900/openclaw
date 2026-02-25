#!/bin/bash
ROLE=$1

# KVM 속임수 및 볼륨 권한 복구
sudo mknod /dev/kvm c 10 232 && sudo chmod 666 /dev/kvm
sudo chown -R flyuser:flyuser /data

if [ "$ROLE" == "worker" ]; then
    echo "[*] Worker Mode: 16-Core Power"
    # 갤탭 A8(1200x1920) 픽셀 매칭 가상 화면
    Xvfb :1 -screen 0 1200x1920x24 +extension RANDR &
    export DISPLAY=:1
    sudo -u flyuser xrdb -merge /home/flyuser/.Xresources
    
    # OpenClaw 실행 (설치 확인 후 자동 진행)
    if [ ! -d "/data/openclaw" ]; then
        cd /data && sudo -u flyuser git clone https://github.com/OpenClaw/OpenClaw.git openclaw
    fi
    cd /data/openclaw && sudo -u flyuser ./openclaw start &
    
    # 내부망 브릿지 (Gateway 연결용)
    x11vnc -display :1 -forever -nopw -listen 0.0.0.0 -rfbport 5900

elif [ "$ROLE" == "gateway" ]; then
    echo "[*] Gateway Mode: High-Speed Streaming"
    sudo -u flyuser pulseaudio -D --exit-idle-time=-1
    
    # KasmVNC 실행 (본체로 연결 및 실시간 해상도 동기화)
    sudo -u flyuser vncserver :1 \
        -name "OpenClaw_Ultra_Stream" \
        -httpd /usr/share/kasmvnc/www \
        -websocket 8443 \
        -FrameRate 60 \
        -ProxyTo worker.process.openclaw.internal:5900 \
        -DynamicResolution \
        -DisableSecurity
fi

tail -f /dev/null
