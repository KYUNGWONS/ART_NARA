# UniTrip WebSocket 테스트 서버

백엔드 채팅 API 준비 전, Flutter 앱에서 실시간 채팅 UI를 테스트하기 위한 로컬 WebSocket 서버입니다.

## 실행 방법

```bash
cd server
npm install
npm start
```

서버가 `ws://localhost:8080` 에서 대기합니다.

## Flutter 앱에서 로컬 서버 사용

`lib/screens/chat_screen.dart` 상단의 `kWebSocketUrl`을 아래처럼 바꿉니다.

- **iOS 시뮬레이터**: `ws://localhost:8080`
- **Android 에뮬레이터**: `ws://10.0.2.2:8080`

```dart
// const String kWebSocketUrl = 'wss://echo.websocket.org';
const String kWebSocketUrl = 'ws://localhost:8080';  // 로컬 테스트 서버
```

Android 에뮬레이터에서는 `localhost` 대신 `10.0.2.2`를 사용해야 호스트 PC의 서버에 접속할 수 있습니다.

## 동작

- 클라이언트가 보낸 메시지를 **접속한 모든 클라이언트**에게 그대로 전달(브로드캐스트)합니다.
- 앱 두 개를 띄우거나, 브라우저에서 WebSocket 클라이언트로 접속해 서로 메시지를 주고받는 것처럼 테스트할 수 있습니다.

## 참고

실제 백엔드가 준비되면 이 서버는 사용하지 않고, Flutter 앱의 `kWebSocketUrl`만 실제 백엔드 URL로 변경하면 됩니다.
