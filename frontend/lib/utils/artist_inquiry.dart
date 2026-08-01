import 'package:flutter/material.dart';

import '../screens/chat_screen.dart';
import '../services/chat_api_service.dart';

/// 작가에게 1:1 문의 방을 열고 대화 화면으로 이동한다.
/// (작품 상세·홈 피드 작가 리스트·작가 포트폴리오에서 공통으로 쓴다)
Future<void> openArtistInquiry(BuildContext context, String artistName) async {
  final room = await ChatApiService.openDirectRoom(artistName);
  if (!context.mounted) return;
  if (room == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('작가에게 문의할 수 없어요. 잠시 후 다시 시도해주세요')),
    );
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChatScreen(
        roomId: room.chatRoomId,
        partnerNickname: room.opponentNickname,
        partnerProfileImageUrl: room.opponentProfileImageUrl,
      ),
    ),
  );
}
