import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';
import '../models/app_notification.dart';
import '../services/notification_api_service.dart';
import 'artwork_detail_screen.dart';
import 'order_history_screen.dart';

/// 알림 탭 (디자인 하단 내비 nav-item-notifications)
/// GET /api/notifications — 제작 의뢰·경매 마감·결제 완료 등 도메인 이벤트가 쌓인다.
class NotificationScreen extends StatefulWidget {
  /// 알림을 눌렀을 때 다른 탭으로 이동해야 하는 경우 MainScreen 이 넘겨준다.
  final void Function(int tabIndex)? onOpenTab;

  const NotificationScreen({super.key, this.onOpenTab});

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

    // 알림 종류별 이동 (targetId 해석: 의뢰 id · 작품 id · 주문 id)
    switch (item.type) {
      case 'COMMISSION_CREATED':
      case 'COMMISSION_OFFER':
        widget.onOpenTab?.call(3); // 제작 의뢰 탭
        break;
      case 'AUCTION_CLOSED':
        if (item.targetId != null) {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => ArtworkDetailScreen(artworkId: item.targetId!),
          ));
        }
        break;
      case 'ORDER_COMPLETED':
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => const OrderHistoryScreen(),
        ));
        break;
    }
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
              DustSpacing.lg, DustSpacing.md, DustSpacing.lg, DustSpacing.sm),
          child: Row(
            children: [
              const Text('알림', style: DustText.section),
              const SizedBox(width: DustSpacing.xs),
              if (_unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: DustColors.brandPrimary,
                    borderRadius: BorderRadius.circular(DustRadius.full),
                  ),
                  child: Text(
                    '$_unread',
                    style: DustText.caption.copyWith(
                      color: DustColors.textOnBrand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: _unread == 0 ? null : _readAll,
                child: Text(
                  '모두 읽음',
                  style: DustText.caption.copyWith(
                    color: _unread == 0
                        ? DustColors.textSecondary
                        : DustColors.brandPrimary,
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
                      CircularProgressIndicator(color: DustColors.brandPrimary),
                )
              : _items.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: DustColors.brandPrimary,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(vertical: DustSpacing.xs),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, color: DustColors.borderSoft),
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
              size: 64, color: DustColors.borderSoft),
          const SizedBox(height: DustSpacing.md),
          Text('새로운 알림이 없어요',
              style: DustText.body.copyWith(color: DustColors.textSecondary)),
          const SizedBox(height: DustSpacing.xs),
          const Text('의뢰 제안·경매 마감·결제 소식이 여기에 쌓입니다',
              style: DustText.caption),
        ],
      ),
    );
  }

  Widget _tile(AppNotification item) {
    return InkWell(
      onTap: () => _open(item),
      child: Container(
        color: item.read ? Colors.transparent : DustColors.bgInfo,
        padding: const EdgeInsets.symmetric(
            horizontal: DustSpacing.lg, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DustColors.bgSubtle,
                borderRadius: BorderRadius.circular(DustRadius.sm),
              ),
              child: Icon(_iconFor(item.type),
                  size: 20, color: DustColors.brandPrimary),
            ),
            const SizedBox(width: DustSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: DustText.body.copyWith(
                            fontSize: 15,
                            fontWeight:
                                item.read ? FontWeight.w500 : FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(_elapsed(item.createdAt), style: DustText.caption),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    style: DustText.body.copyWith(
                      fontSize: 13,
                      color: DustColors.textSecondary,
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
