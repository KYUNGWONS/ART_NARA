import 'package:flutter/material.dart';

import '../models/chat_room_item.dart';
import '../screens/artwork_detail_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/order_history_screen.dart';
import '../services/chat_api_service.dart';

/// 앱 어디서든 알림을 열 수 있게 하는 전역 네비게이터.
///
/// 푸시 알림은 화면 밖(안드로이드 알림함)에서 눌리기 때문에 BuildContext 가 없다.
/// MaterialApp 에 이 키를 달아두고 PushService 가 여기로 이동한다.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// 알림 종류별 이동 규칙. 앱 내 알림 목록과 푸시 알림이 **같은 규칙**을 쓰도록 여기 모아둔다
/// (예전에는 알림 화면 안에 있어서 푸시를 누르면 앱만 열리고 아무 데도 가지 않았다).
///
/// targetId 는 종류마다 다른 것을 가리킨다 — 의뢰 id · 작품 id · 주문 id · 채팅방 id.
/// [onOpenTab] 은 하단 탭으로 이동해야 하는 경우 MainScreen 이 넘겨준다. 푸시 경로에는 없다.
Future<void> openNotificationTarget(
  BuildContext context, {
  required String type,
  int? targetId,
  void Function(int tabIndex)? onOpenTab,
}) async {
  final navigator = Navigator.of(context);

  switch (type) {
    case 'COMMISSION_CREATED':
    case 'COMMISSION_OFFER':
      // 의뢰는 탭 자체가 목록이라 탭 전환으로 충분하다. 탭 전환 수단이 없는
      // 푸시 경로에서는 앱을 열어 주는 것까지만 한다(홈에서 의뢰 탭이 한 번에 보인다).
      onOpenTab?.call(3);
      break;

    case 'AUCTION_CLOSED':
      if (targetId != null) {
        await navigator.push(MaterialPageRoute<void>(
          builder: (_) => ArtworkDetailScreen(artworkId: targetId),
        ));
      }
      break;

    case 'ORDER_COMPLETED':
    case 'ORDER_REFUNDED':
    case 'ORDER_RESERVED':
    case 'ORDER_HANDOVER':
    case 'ORDER_PAYMENT_DUE':
      await navigator.push(MaterialPageRoute<void>(
        builder: (_) => const OrderHistoryScreen(),
      ));
      break;

    case 'CHAT_MESSAGE':
      if (targetId == null) break;
      final rooms = await ChatApiService.getChatRooms();
      if (!context.mounted) return;
      final room = rooms.firstWhere(
        (r) => r.chatRoomId == '$targetId',
        orElse: () => rooms.isNotEmpty
            ? rooms.first
            : const ChatRoomItem(chatRoomId: '', opponentNickname: ''),
      );
      if (room.chatRoomId.isEmpty) break;
      await navigator.push(MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          roomId: room.chatRoomId,
          partnerNickname: room.opponentNickname,
          partnerProfileImageUrl: room.opponentProfileImageUrl,
        ),
      ));
      break;
  }
}
