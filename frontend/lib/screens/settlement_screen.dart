import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';
import '../models/settlement.dart';
import '../services/settlement_api_service.dart';
import 'art_home_feed_screen.dart' show formatPrice;

/// 작가 판매 정산 화면.
///
/// 판매 금액에서 플랫폼 수수료를 뺀 정산 예정액과 건별 내역을 보여준다.
/// 대상은 서버가 로그인 신원으로 정하므로 화면에는 식별자를 넘기지 않는다.
class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  final _api = const SettlementApiService();
  late Future<Settlement> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchMySettlement();
  }

  void _reload() {
    _future = _api.fetchMySettlement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArtColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: ArtColors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('판매 정산',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
        centerTitle: true,
      ),
      body: FutureBuilder<Settlement>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: OutlinedButton(
                onPressed: () => setState(_reload),
                child: const Text('다시 시도'),
              ),
            );
          }
          final settlement = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                ArtSpacing.lg, ArtSpacing.sm, ArtSpacing.lg, ArtSpacing.lg),
            children: [
              _SummaryCard(settlement: settlement),
              const SizedBox(height: ArtSpacing.lg),
              Text('판매 내역',
                  style: ArtText.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: ArtSpacing.sm),
              if (settlement.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: ArtSpacing.lg),
                  child: Text('아직 판매된 작품이 없어요',
                      textAlign: TextAlign.center,
                      style: ArtText.caption
                          .copyWith(color: ArtColors.textSecondary)),
                )
              else
                ...settlement.items.map((item) => _ItemCard(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.settlement});

  final Settlement settlement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ArtSpacing.lg),
      decoration: BoxDecoration(
        color: ArtColors.bgSurface,
        borderRadius: BorderRadius.circular(ArtRadius.md),
        border: Border.all(color: ArtColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('정산 예정액',
              style: ArtText.caption.copyWith(color: ArtColors.textSecondary)),
          const SizedBox(height: 4),
          Text('₩${formatPrice(settlement.netAmount)}',
              style: ArtText.heading.copyWith(color: ArtColors.brandPrimary)),
          const SizedBox(height: ArtSpacing.md),
          const Divider(height: 1, color: ArtColors.borderSoft),
          const SizedBox(height: ArtSpacing.md),
          _row('판매 금액 (${settlement.saleCount}건)',
              '₩${formatPrice(settlement.totalSales)}'),
          const SizedBox(height: ArtSpacing.xs),
          _row('플랫폼 수수료 ${settlement.feeRate}%',
              '- ₩${formatPrice(settlement.feeAmount)}'),
          const SizedBox(height: ArtSpacing.xs),
          _row('이번 달 판매', '₩${formatPrice(settlement.thisMonthSales)}'),
          const SizedBox(height: ArtSpacing.md),
          Text('환불된 주문은 합계에서 제외됩니다.',
              style: ArtText.caption.copyWith(color: ArtColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: ArtText.caption.copyWith(color: ArtColors.textSecondary)),
          Text(value, style: ArtText.body.copyWith(fontSize: 14)),
        ],
      );
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final SettlementItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ArtSpacing.sm),
      padding: const EdgeInsets.all(ArtSpacing.md),
      decoration: BoxDecoration(
        color: ArtColors.bgSurface,
        borderRadius: BorderRadius.circular(ArtRadius.md),
        border: Border.all(color: ArtColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.artworkTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ArtText.body.copyWith(fontWeight: FontWeight.w600)),
              ),
              Text(
                item.refunded
                    ? '환불'
                    : '+ ₩${formatPrice(item.netAmount)}',
                style: ArtText.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: item.refunded
                      ? ArtColors.textSecondary
                      : ArtColors.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.soldDate} · ${item.buyerName} · '
            '판매 ₩${formatPrice(item.amount)} · 수수료 ₩${formatPrice(item.feeAmount)}',
            style: ArtText.caption.copyWith(color: ArtColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
