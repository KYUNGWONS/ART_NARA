#!/usr/bin/env bash
# 개발 서버 실행. 비밀값은 git 미추적 local.properties 에서 읽어 환경변수로 넘긴다
# (키를 명령줄에 적지 않아 셸 히스토리에 남지 않는다).
#
#   ./run-dev.sh              # 포그라운드
#   ./run-dev.sh --bg         # 백그라운드(boot.log 로 출력)
set -eu

cd "$(dirname "$0")"

prop() {
    [ -f local.properties ] || return 0
    grep "^$1=" local.properties | head -1 | cut -d= -f2- | tr -d '\r'
}

export NAVER_CLIENT_ID="$(prop naverClientId)"
export NAVER_CLIENT_SECRET="$(prop naverClientSecret)"
export TOSS_SECRET_KEY="$(prop tossSecretKey)"

# FCM 서비스 계정 JSON 경로. 파일이 실제로 있을 때만 넘긴다 —
# 경로만 있고 파일이 없으면 서버가 켜진 줄 알고 발송을 시도한다.
fcm="$(prop fcmCredentialsPath)"
if [ -n "$fcm" ] && [ -f "$fcm" ]; then
    export FCM_CREDENTIALS="$fcm"
    echo "FCM 푸시 사용: $fcm"
elif [ -n "$fcm" ]; then
    echo "경고: fcmCredentialsPath 가 가리키는 파일이 없다 ($fcm) — 푸시 없이 뜬다"
fi

[ -n "$NAVER_CLIENT_ID" ] || echo "경고: naverClientId 없음 — 네이버 로그인은 꺼진 채로 뜬다"

# 이전 서버가 8080 을 잡고 있으면 새 코드가 반영되지 않은 채 계속 응답한다(과거에 겪은 함정).
pid=$(netstat -ano 2>/dev/null | grep ":8080 .*LISTENING" | head -1 | awk '{print $NF}')
if [ -n "${pid:-}" ]; then
    echo "포트 8080 을 쓰던 프로세스 $pid 종료"
    taskkill //F //PID "$pid" >/dev/null 2>&1 || kill -9 "$pid" 2>/dev/null || true
    sleep 2
fi

if [ "${1:-}" = "--bg" ]; then
    ./gradlew bootRun > boot.log 2>&1 &
    echo "백그라운드 기동 — boot.log 에서 'Started ArtNaraApplication' 확인할 것"
else
    ./gradlew bootRun
fi
