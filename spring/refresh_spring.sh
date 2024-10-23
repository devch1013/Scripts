#!/bin/bash

# 스크립트를 root 권한으로 실행했는지 확인
if [ "$EUID" -ne 0 ]; then 
    echo "이 스크립트는 root 권한으로 실행해야 합니다."
    echo "다음과 같이 실행하세요: sudo $0"
    exit 1
fi

# ECR_CPX가 포함된 프로세스 찾기
echo "{jar-name} 프로세스를 검색 중..."
PROCESSES=$(ps aux | grep {jar-name} | grep -v grep | awk '{print $2}')

if [ -z "$PROCESSES" ]; then
    echo "{jar-name} 프로세스가 없습니다."
else
    # 발견된 프로세스 종료
    echo "다음 프로세스를 종료합니다:"
    for PID in $PROCESSES; do
        echo "PID $PID 종료 중..."
        kill -9 $PID
        if [ $? -eq 0 ]; then
            echo "PID $PID 종료 완료"
        else
            echo "PID $PID 종료 실패"
            exit 1
        fi
    done
fi

# ECR 백엔드 서비스 재시작
echo "{service-name} 서비스를 재시작합니다..."
systemctl restart {service-name}

if [ $? -eq 0 ]; then
    echo "{service-name} 서비스 재시작 완료"
    systemctl status {service-name}
else
    echo "{service-name} 서비스 재시작 실패"
    exit 1
fi

exit 0