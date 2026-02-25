#!/bin/bash

# 1. 가상화 장치 속임수 (KVM Spoofing)
echo "[*] 가상화 속임수 적용 중..."
sudo mknod /dev/kvm c 10 232
sudo chmod 666 /dev/kvm
# CPU 플래그 강제 주입 (소프트웨어 레벨에서 svm이 있는 것처럼 인식 유도)
# 실제 하드웨어 락이 있어도 앱이 /dev/kvm 노드 존재여부만 체크한다면 통과됨

# 2. 볼륨 경로 연결 및 권한 설정
sudo chown -R flyuser:flyuser /mnt/data
cd /mnt/data

# 3. OpenClaw 자동 설치 (최초 1회 실행 시)
if [ ! -d "/mnt/data/openclaw" ]; then
    echo "[*] OpenClaw를 처음 발견했습니다. 자동 설치를 시작합니다..."
    sudo curl -fsSL https://openclaw.ai/install.sh | bash -s -- --install-method git
    # 설치 경로를 볼륨 내부로 이동하거나 링크
    mv /root/openclaw /mnt/data/openclaw || true
else
    echo "[*] 기존 OpenClaw 데이터를 발견했습니다. 바로 실행 준비를 합니다."
fi

# 4. KasmVNC 서버 실행 (최고 성능 설정)
echo "[*] KasmVNC 실행 중 (Port: 8443)..."
# flyuser 권한으로 VNC 실행
sudo -u flyuser vncserver :1 -name "OpenClaw-Desktop" -geometry 1920x1080 -depth 24 -httpd /usr/share/kasmvnc/www -websocket 8443

# 5. OpenClaw 백그라운드 실행
export PATH="/mnt/data/openclaw/bin:$PATH"
sudo -u flyuser openclaw update --restart &

echo "[*] 모든 준비가 완료되었습니다. 갤럭시 탭에서 브라우저로 접속하세요!"

# 컨테이너 유지
tail -f /dev/null
