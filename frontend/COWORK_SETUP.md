# Cowork 인수인계 — 커넥터 · 설정 · 프로젝트 요약

> 목적: **Max 계정으로 전환 후** 동일한 커넥터/폴더/설정을 그대로 다시 연결하기 위한 참고 문서.
> 작성일: 2026-07-23 · 사용자: 신경원 (`kn.29076@knot.by-works.net`)
> 프로젝트: **UniTrip / KNOT** (한국인 대학생 ↔ 외국인 관광객 로컬 여행 매칭)

---

## 1. 재연결 체크리스트 (요약)

새 Max 계정에서 아래 순서로 다시 연결하면 이 세션과 동일한 환경이 된다.

- [ ] Notion 커넥터 연결 → 워크스페이스 **「김우준님의 워크스페이스」**
- [ ] Figma 커넥터 연결 → 계정 **worms21313@gmail.com** (팀: 안형찬의 팀 / 관광벤처 공모전 등)
- [ ] Slack 커넥터 연결
- [ ] n8n 커넥터 연결
- [ ] 폴더 연결: `C:\Backend`, `C:\Frontend`
- [ ] (개발용) 로컬에 Flutter SDK 설치 → §6 참고

---

## 2. 연결된 커넥터 (MCP)

현재 세션에 연결되어 있던 커넥터는 아래 4개다. Claude 데스크톱 앱 **설정 → 커넥터(Connectors)** 에서 동일 이름으로 다시 추가하고, 아래 "연결 계정"으로 로그인하면 된다.

### 2-1. Notion
- **용도**: 어플 기획 DB 열람/검토 (기능 ↔ Figma 화면 연결 점검 등)
- **연결 계정 / 워크스페이스**
  - 워크스페이스: `김우준님의 워크스페이스` (ID `2850a145-cf34-81a5-8b85-0003ea12b0ad`)
  - 사용자: 신경원 (`kn.29076@knot.by-works.net`)
- **주로 사용한 문서**
  - 📱 어플 기획 DB — `https://app.notion.com/p/3950a145cf3480faa8fdc23cdfe47d33`
    - 뷰: "전체 기능 기획", "폴더 트리", "버전별 보기", "진행상태별", "앞으로 추가할 내용"
    - 주요 속성: 화면 ID, 화면, 구분, 상태, 우선순위, **Figma URL**, 노드 ID, 요약, 사용자 시나리오
    - 참고: 옛 속성 `(구)Figma링크_수동삭제요망` 는 삭제 대상

### 2-2. Figma
- **용도**: 기획 DB의 Figma URL이 실제 화면과 맞는지 검토 (스크린샷/메타데이터)
- **연결 계정**: handle `worms21313`, `worms21313@gmail.com`
- **소속 팀(플랜)**: `경원신's team`, `안형찬의 팀`, `관광벤처 공모전` (모두 starter, View 시트)
- **주 사용 파일**: `KNOT V1 (안형찬)`
  - fileKey: `Qfl9V4fmBjYpifbdc07ID8`
  - 페이지: `화면 흐름 - 한국인` (page id `68:3603`)
  - URL 형태: `https://www.figma.com/design/Qfl9V4fmBjYpifbdc07ID8/KNOT-V1--...?node-id=<노드>`

### 2-3. Slack
- **용도**: 팀 커뮤니케이션 (이번 세션에서 직접 사용은 안 함, 연결만 되어 있음)
- **재연결**: 워크스페이스 로그인 후 채널 접근 권한 승인

### 2-4. n8n
- **용도**: 워크플로 자동화 (연결됨. 자격증명 목록은 재연결 후 `list_credentials`로 확인)
- **참고**: Backend 저장소의 git 원격 중 `n8n` 브랜치가 존재 — 자동화/CI 관련 작업으로 추정

> 팁: 커넥터가 목록에 안 보이면 Claude에게 "GitHub/Notion/Figma 커넥터 연결해줘" 처럼 요청하면 커넥터 레지스트리에서 찾아 제안해 준다.

---

## 3. 연결된 폴더 / GitHub 저장소

| 폴더(로컬) | GitHub 원격 | 스택 | 기본 브랜치 |
|---|---|---|---|
| `C:\Frontend` | `github.com/TeamUniTrip/Frontend` | Flutter (Dart) 모바일 앱 | `main` |
| `C:\Backend` | `github.com/TeamUniTrip/Backend` | Spring Boot (Java, Gradle) | (작업 시 `n8n` 브랜치) |

- 재연결: Claude에게 폴더 접근을 요청하면 폴더 선택창이 열림 → 위 두 폴더 선택.
- GitHub 전용 커넥터는 커넥터 레지스트리에 없음 → **로컬 폴더 연결 방식**으로 코드 작업 (편집 + `git` 명령).

---

## 4. 프로젝트 핵심 설정 (Frontend / Flutter)

`C:\Frontend\CLAUDE.md` 에 상세 규칙이 있고, 요점은 아래와 같다.

- **API Base URL**: `lib/constants/api_config.dart` 에서 런타임 결정
  - Android 에뮬레이터 → `http://10.0.2.2:8080`, 그 외 → `http://localhost:8080`
  - 서비스 코드에서 URL 하드코딩 금지, `apiBaseUrl` 사용
- **인증(JWT)**: `AuthApiService` 가 `accessToken`/`refreshToken` 을 static 보관.
  다른 서비스는 `AuthApiService.accessToken` 을 읽어 `Authorization: Bearer …` 를 직접 추가.
- **로그인 흐름**: Kakao/Google OAuth 토큰 → `POST /auth/login {provider, accessToken}` → 앱 JWT 발급 (`provider` = `"KAKAO"` | `"GOOGLE"`)
- **오프라인 mock 폴백 패턴**: 서비스 메서드는 실패 시 `try { … } catch { return _mockXForOffline(); }` + `TODO(서버 연동)` 마커
- **i18n**: `AppLanguage {ko,en,ja,zh}`, 문구는 `AppStrings` 에 4개 언어 모두 등록, 화면에서 `context.watch<LocaleProvider>().tr(...)`
- **채팅/WebSocket**: `lib/screens/chat_screen.dart` 상단 `kWebSocketUrl` (현재 로컬 테스트 서버 `ws://localhost:8080`)
- **네이티브 SDK 키**: Kakao 앱키 / Naver Map 클라이언트 ID 는 `lib/main.dart` 에 존재
- **커밋 트리거**: 메시지에 `commit` 또는 `커밋` 포함 시 → `flutter test` 통과 → 영어 커밋 메시지 자동 생성 → `git add/commit/push`

---

## 5. 이번 세션에서 한 작업 (참고)

1. **Notion ↔ Figma 연결 검토**: 어플 기획 DB 31개 화면의 노드 ID ↔ Figma URL 일치 + 실제 화면 내용 대조. 링크는 전부 정상, 경미한 데이터/네이밍 이슈만 존재.
2. **Frontend 구현 완성도 리뷰**: 지도·콘텐츠 생성·프로필·i18n 은 탄탄. 미연결 항목 = 매거진/위시 탭(Coming Soon), `CommunityScreen`·`MateMatchScreen`(고아 화면), 채팅 목록 상단 버튼 등.
3. **Frontend ↔ Backend API 싱크 수정** (아래 파일):
   - `lib/services/user_api_service.dart` — `/api/users/me`, `PUT→PATCH`, userId 캐시
   - `lib/services/chat_api_service.dart` — `/api/chat/rooms/my?userId=`
   - `lib/services/content_api_service.dart` — `/api/contents`
   - `lib/services/auth_api_service.dart` — `userId` 필드 추가
   - `lib/models/user_profile_response.dart` — 백엔드 필드 매핑(id/aboutMe/region/travelStyle)
   - `lib/models/content_draft.dart` — enum/요일 매핑, coverImageUrl/title/price
   - `lib/models/chat_room_item.dart` — `roomId` 수용
   - ⚠️ 아직 `flutter analyze` 미검증. 로컬에서 확인 필요.

### 남은 큰 작업
- 백엔드 `ChatRoomResponse` 에 상대방 프로필·마지막 메시지 필드 추가(현재 목록 UI가 빔)
- 채팅 WebSocket 을 백엔드 STOMP(`/ws`, SockJS) 방식으로 전환 (`stomp_dart_client` 도입)
- 백엔드에 `POST /auth/logout` 엔드포인트 없음 (프론트는 로컬 토큰만 정리 중)

---

## 6. Flutter 설치 (개발/검증용, VS Code 방식) — Flutter 3.44 기준

1. **사전 설치**: Git for Windows(`git-scm.com/downloads/win`) + VS Code(`code.visualstudio.com`)
2. **VS Code 확장**: Extensions(`Ctrl+Shift+X`)에서 `Flutter` 설치 (Dart 확장 동반 설치)
3. **SDK 설치**: `Ctrl+Shift+P` → `Flutter: New Project` → **Download SDK** → 설치 폴더 선택(예: `C:\src`, 공백/한글 없는 경로) → **Clone Flutter** → **Add SDK to PATH** → VS Code 재시작
4. **확인**: 터미널에서 `flutter doctor -v`
5. **프로젝트 분석**:
   ```
   cd C:\Frontend
   flutter pub get
   flutter analyze
   ```
   - VS Code에서 폴더를 연 채 `.dart` 파일을 열면 **Problems 패널(`Ctrl+Shift+M`)** 에 실시간으로 동일 결과가 뜬다.

> ⚠️ `pubspec.yaml` 의 Dart SDK 제약이 `sdk: ^3.10.8` 로 높게 잡혀 있음. 설치된 Dart가 더 낮으면 `flutter pub get` 에서 버전 에러가 날 수 있음 → 그 경우 Flutter 업그레이드 또는 제약 조정 필요.

공식 문서: https://docs.flutter.dev/install/with-vs-code
