/**
 * UniTrip 채팅 테스트용 WebSocket 서버
 * - 접속한 모든 클라이언트에게 메시지 브로드캐스트
 * - 백엔드 준비 전 Flutter 앱에서 실시간 채팅 UI 테스트용
 *
 * 실행: npm install && npm start
 * Flutter에서 연결:
 *   - iOS 시뮬레이터: ws://localhost:8080
 *   - Android 에뮬레이터: ws://10.0.2.2:8080
 */

const WebSocket = require('ws');

const PORT = 8080;
const wss = new WebSocket.Server({ port: PORT });

const clients = new Set();

wss.on('connection', (ws, req) => {
  const id = clients.size + 1;
  clients.add(ws);
  console.log(`[${new Date().toISOString()}] 클라이언트 #${id} 연결 (총 ${clients.size}명)`);

  ws.on('message', (data) => {
    const text = data.toString();
    console.log(`[${new Date().toISOString()}] 수신: ${text}`);
    // 접속한 모든 클라이언트에게 전달 (브로드캐스트)
    clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(text);
      }
    });
  });

  ws.on('close', () => {
    clients.delete(ws);
    console.log(`[${new Date().toISOString()}] 클라이언트 #${id} 연결 해제 (총 ${clients.size}명)`);
  });

  ws.on('error', (err) => {
    console.error(`[${new Date().toISOString()}] 클라이언트 #${id} 에러:`, err.message);
    clients.delete(ws);
  });
});

wss.on('listening', () => {
  console.log(`WebSocket 테스트 서버 실행 중: ws://localhost:${PORT}`);
  console.log('Flutter 앱에서 위 주소로 연결 후 메시지를 보내면 모든 클라이언트에 브로드캐스트됩니다.');
});
