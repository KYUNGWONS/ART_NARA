import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';
import '../models/chat_room_item.dart';
import '../services/chat_api_service.dart';
import 'chat_screen.dart';

/// 참여 중인 채팅방 목록 화면
/// 진입: 홈 하단 내비 > 채팅 탭
/// GET /api/chat/rooms/my (서버 미연결 시 ChatApiService 내 mock 폴백)
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ChatRoomItem> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final rooms = await ChatApiService.getChatRooms();
    if (!mounted) return;
    rooms.sort((a, b) {
      final at = a.lastMessageAt ?? DateTime(0);
      final bt = b.lastMessageAt ?? DateTime(0);
      return bt.compareTo(at);
    });
    setState(() {
      _rooms = rooms;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Expanded(
          child: _loading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: ArtColors.brandPrimary),
                )
              : _rooms.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: ArtColors.brandPrimary,
                  onRefresh: _loadRooms,
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(vertical: ArtSpacing.xs),
                    itemCount: _rooms.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: ArtColors.borderSoft,
                    ),
                    itemBuilder: (context, index) => _ChatRoomTile(
                      room: _rooms[index],
                      onTap: () => _openChat(_rooms[index]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
          ArtSpacing.lg, ArtSpacing.md, ArtSpacing.lg, ArtSpacing.sm),
      // 화면 제목은 헤더(앱바)에서만 그린다 — 본문에 또 쓰면 '작품 문의' 가 두 줄로 겹쳐 보인다.
      child: Text(
        '작가와 직접 이야기해보세요',
        style: ArtText.caption,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: ArtColors.borderSoft,
          ),
          const SizedBox(height: ArtSpacing.md),
          Text(
            '아직 진행 중인 대화가 없어요',
            style: ArtText.body.copyWith(color: ArtColors.textSecondary),
          ),
          const SizedBox(height: ArtSpacing.xs),
          const Text('마음에 드는 작품에서 작가에게 문의해보세요', style: ArtText.caption),
        ],
      ),
    );
  }

  void _openChat(ChatRoomItem room) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ChatScreen(
          roomId: room.chatRoomId,
          partnerNickname: room.opponentNickname,
          partnerProfileImageUrl: room.opponentProfileImageUrl,
        ),
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomItem room;
  final VoidCallback onTap;

  const _ChatRoomTile({required this.room, required this.onTap});

  static String _formatLastMessageTime(DateTime? at) {
    if (at == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(at.year, at.month, at.day);
    final diff = today.difference(msgDay).inDays;
    if (diff == 0) {
      final hour = at.hour;
      final ampm = hour >= 12 ? '오후' : '오전';
      final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$ampm ${h.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    }
    if (diff == 1) return '어제';
    if (diff < 7) return '$diff일 전';
    return '${at.month}/${at.day}';
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = room.opponentRoleLabel;
    final waiting = room.status == 'WAITING';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: ArtSpacing.lg, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: ArtColors.bgSubtle,
              backgroundImage: room.opponentProfileImageUrl != null
                  ? NetworkImage(room.opponentProfileImageUrl!)
                  : null,
              child: room.opponentProfileImageUrl == null
                  ? Text(
                      room.opponentNickname.isNotEmpty
                          ? room.opponentNickname[0]
                          : '?',
                      style: ArtText.body.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ArtColors.brandPrimary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.opponentNickname,
                          style: ArtText.body
                              .copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatLastMessageTime(room.lastMessageAt),
                        style: ArtText.caption,
                      ),
                      if (room.unreadCount > 0) ...[
                        const SizedBox(width: ArtSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: ArtColors.brandPrimary,
                            borderRadius:
                                BorderRadius.circular(ArtRadius.full),
                          ),
                          child: Text(
                            '${room.unreadCount}',
                            style: ArtText.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ArtColors.textOnBrand,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (roleLabel != null || waiting) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (roleLabel != null) _Badge(label: roleLabel),
                        if (waiting) ...[
                          if (roleLabel != null)
                            const SizedBox(width: ArtSpacing.xs),
                          const _Badge(label: '상대 대기 중', muted: true),
                        ],
                      ],
                    ),
                  ],
                  if (room.lastMessage != null &&
                      room.lastMessage!.isNotEmpty) ...[
                    const SizedBox(height: ArtSpacing.xs),
                    Text(
                      room.lastMessage!,
                      style: ArtText.body.copyWith(
                        fontSize: 14,
                        color: ArtColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: ArtSpacing.xs, vertical: 3),
      decoration: BoxDecoration(
        color: muted ? ArtColors.bgSubtle : ArtColors.brandPrimary,
        borderRadius: BorderRadius.circular(ArtRadius.full),
      ),
      child: Text(
        label,
        style: ArtText.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: muted ? ArtColors.textSecondary : ArtColors.textOnBrand,
        ),
      ),
    );
  }
}
