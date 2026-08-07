#!/usr/bin/env bash
# 네이버 로그인 앱 설정이 살아 있는지 10초 만에 판별한다.
#
#   ./check-naver.sh                      # 실행 중인 서버(:8080)의 설정으로 검사
#   ./check-naver.sh <client_id>          # 새로 발급받은 키를 서버 없이 바로 검사
#
# 로그인 폼이 나오면 정상, disp_stat=207 이면 네이버 콘솔의 앱 설정 문제다
# (앱 코드와 무관 — redirect_uri·UA·쿠키는 모두 배제됐다).
set -u

UA="Mozilla/5.0 (Linux; Android 15; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36"

if [ $# -ge 1 ]; then
    url="https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=$1&redirect_uri=https%3A%2F%2Fartnara.app%2Foauth%2Fnaver&state=selfcheck"
else
    url=$(curl -s "http://localhost:8080/auth/naver/config?state=selfcheck" \
        | grep -o '"authorizeUrl":"[^"]*"' | cut -d'"' -f4)
    if [ -z "$url" ]; then
        echo "서버에서 authorizeUrl 을 못 받았다 — 백엔드가 떠 있고 NAVER_CLIENT_ID/SECRET 이 주입됐는지 확인할 것"
        exit 1
    fi
fi

echo "요청: $url"
body=$(curl -s -A "$UA" "$url")

if echo "$body" | grep -q "disp_stat=207"; then
    echo "결과: 207 — 네이버 콘솔의 앱 설정 문제 (로그인 거부 상태)"
    exit 1
elif echo "$body" | grep -qi 'name="pw"\|id="id"\|nidlogin'; then
    echo "결과: 로그인 화면 정상 — 앱 설정이 풀렸다"
    exit 0
else
    echo "결과: 판단 불가 — 응답을 직접 확인할 것"
    echo "$body" | head -c 400
    exit 2
fi
