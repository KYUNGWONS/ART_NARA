import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';
import '../models/app_notification.dart';
import '../services/notification_api_service.dart';
import '../utils/notification_navigation.dart';

/// 알림 탭 (디자인 하단 내비 nav-item-notifications)
/// GET /api/notifications — 제작 의뢰·경매 마감·결제 완료 등 도메인 이벤트가 쌓인다.
class NotificationScreen extends StatefulWidget {
  /// 알림을 눌렀을 때 다른 탭으로 이동해야 하는 경우 MainScreen 이 넘겨준다.
  final void Function(int tabIndex, {int? targetId})? onOpenTab;

  /// 안읽음 수가 바뀌면 상위(헤더 배지)에 알린다.
  final void Function(int unread)? onUnreadChanged;

  const NotificationScreen({super.key, this.onOpenTab, this.onUnreadChanged});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> _items = const [];
  int _unread = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await NotificationApiService.list();
    if (!mounted) return;
    setState(() {
      _items = result.items;
      _unread = result.unread;
      _loading = false;
    });
    widget.onUnreadChanged?.call(result.unread);
  }

  Future<void> _readAll() async {
    if (_unread == 0) return;
    await NotificationApiService.markAllAsRead();
    await _load();
  }

  Future<void> _open(AppNotification item) async {
    if (!item.read) {
      await NotificationApiService.markAsRead(item.id);
      await _load();
    }
    if (!mounted) return;

    // 이동 규칙은 푸시 알림과 공유한다(utils/notification_navigation.dart).
    await openNotificationTarget(
      context,
      type: item.type,
      targetId: item.targetId,
      onOpenTab: widget.onOpenTab,
    );
  }

  static IconData _iconFor(String type) {
    switch (type) {
      case 'COMMISSION_CREATED':
        return Icons.campaign_outlined;
      case 'COMMISSION_OFFER':
        return Icons.local_offer_outlined;
      case 'AUCTION_CLOSED':
        return Icons.gavel_rounded;
      case 'ORDER_COMPLETED':
        return Icons.verified_outlined;
      case 'ORDER_REFUNDED':
        return Icons.undo_rounded;
      case 'CHAT_MESSAGE':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  static String _elapsed(DateTime? at) {
    if (at == null) return '';
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${at.month}/${at.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              ArtSpacing.lg, ArtSpacing.md, ArtSpacing.lg, ArtSpacing.sm),
          child: Row(
            children: [
              const Text('알림', style: ArtText.section),
              const SizedBox(width: ArtSpacing.xs),
              if (_unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ArtColors.brandPrimary,
                    borderRadius: BorderRadius.circular(ArtRadius.full),
                  ),
                  child: Text(
                    '$_unread',
                    style: ArtText.caption.copyWith(
                      color: ArtColors.textOnBrand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: _unread == 0 ? null : _readAll,
                child: Text(
                  '모두 읽음',
                  style: ArtText.caption.copyWith(
                    color: _unread == 0
                        ? ArtColors.textSecondary
                        : ArtColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: ArtColors.brandPrimary),
                )
              : _items.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: ArtColors.brandPrimary,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(vertical: ArtSpacing.xs),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, color: ArtColors.borderSoft),
                    itemBuilder: (context, index) =>
                        _tile(_items[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none_rounded,
              size: 64, color: ArtColors.borderSoft),
          const SizedBox(height: ArtSpacing.md),
          Text('새로운 알림이 없어요',
              style: ArtText.body.copyWith(color: ArtColors.textSecondary)),
          const SizedBox(height: ArtSpacing.xs),
          const Text('의뢰 제안·경매 마감·결제 소식이 여기에 쌓입니다',
              style: ArtText.caption),
        ],
      ),
    );
  }

  Widget _tile(AppNotification item) {
    return InkWell(
      onTap: () => _open(item),
      child: Container(
        color: item.read ? Colors.transparent : ArtColors.bgInfo,
        padding: const EdgeInsets.symmetric(
            horizontal: ArtSpacing.lg, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ArtColors.bgSubtle,
                borderRadius: BorderRadius.circular(ArtRadius.sm),
              ),
              child: Icon(_iconFor(item.type),
                  size: 20, color: ArtColors.brandPrimary),
            ),
            const SizedBox(width: ArtSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: ArtText.body.copyWith(
                            fontSize: 15,
                            fontWeight:
                                item.read ? FontWeight.w500 : FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(_elapsed(item.createdAt), style: ArtText.caption),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    style: ArtText.body.copyWith(
                      fontSize: 13,
                      color: ArtColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
