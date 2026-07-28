import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/chat_room_item.dart';
import '../providers/locale_provider.dart';
import '../services/chat_api_service.dart';
import 'chat_screen.dart';

/// 참여 중인 채팅방 목록 화면
/// 진입: 홈 하단 내비 > 채팅 탭
/// GET /chat/rooms API 사용 (서버 미연결 시 ChatApiService 내 mock 폴백)
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
    return Consumer<LocaleProvider>(
      builder: (context, locale, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(locale),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _rooms.isEmpty
                  ? _buildEmpty(locale)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _rooms.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return _ChatRoomTile(
                          room: _rooms[index],
                          locale: locale,
                          onTap: () => _openChat(_rooms[index]),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(LocaleProvider locale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            locale.tr(AppStrings.navChat),
            style: GoogleFonts.gowunDodum(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () {},
                color: AppColors.darkGrey,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {},
                color: AppColors.darkGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(LocaleProvider locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: AppColors.lightGrey,
          ),
          const SizedBox(height: 16),
          Text(
            '참여 중인 채팅방이 없어요',
            style: GoogleFonts.gowunDodum(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(ChatRoomItem room) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ChatScreen(mate: room.toUserLocation()),
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomItem room;
  final LocaleProvider locale;
  final VoidCallback onTap;

  const _ChatRoomTile({
    required this.room,
    required this.locale,
    required this.onTap,
  });

  static String _formatLastMessageTime(DateTime? at) {
    if (at == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(at.year, at.month, at.day);
    final diff = today.difference(msgDay).inDays;
    if (diff == 0) {
      final hour = at.hour;
      final min = at.minute;
      final ampm = hour >= 12 ? '오후' : '오전';
      final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$ampm ${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
    }
    if (diff == 1) return '어제';
    if (diff < 7) return '${diff}일 전';
    return '${at.month}/${at.day}';
  }

  static String _interestLabel(String id) {
    const map = {
      'travel': '여행',
      'food': '맛집',
      'activity': '액티비티',
      'culture': '문화/예술',
      'cafe': '카페',
      'unique': '이색체험',
    };
    return map[id] ?? id;
  }

  static String _planningTag(int score) {
    if (score > 20) return '계획형';
    if (score < -20) return '즉흥형';
    return '중립';
  }

  static String _activityTag(int score) {
    if (score > 20) return '조용한';
    if (score < -20) return '활발한';
    return '중립';
  }

  @override
  Widget build(BuildContext context) {
    final ageNationality = [
      if (room.partnerAge != null) '${room.partnerAge}세',
      if (room.partnerNationality != null) room.partnerNationality,
    ].join(' · ');
    final lastMsg = room.lastMessage ?? '';
    final lastMsgShort = lastMsg.length > 40
        ? '${lastMsg.substring(0, 40)}…'
        : lastMsg;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundImage: room.partnerProfileImageUrl != null
                  ? NetworkImage(room.partnerProfileImageUrl!)
                  : null,
              child: room.partnerProfileImageUrl == null
                  ? Text(
                      room.partnerNickname.isNotEmpty
                          ? room.partnerNickname[0]
                          : '?',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
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
                          room.partnerNickname,
                          style: GoogleFonts.gowunDodum(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatLastMessageTime(room.lastMessageAt),
                        style: GoogleFonts.gowunDodum(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (ageNationality.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      ageNationality,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _planningTag(room.partnerPlanningScore),
                          style: GoogleFonts.gowunDodum(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mint.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _activityTag(room.partnerActivityScore),
                          style: GoogleFonts.gowunDodum(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mint,
                          ),
                        ),
                      ),
                      ...room.partnerInterests
                          .take(3)
                          .map(
                            (id) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _interestLabel(id),
                                style: GoogleFonts.gowunDodum(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                  if (lastMsgShort.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      lastMsgShort,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkGrey,
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
