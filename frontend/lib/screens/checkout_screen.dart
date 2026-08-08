import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';

import '../models/order.dart';
import '../services/order_api_service.dart';
import 'certificate_screen.dart';
import 'toss_payment_screen.dart';

const _paymentMethods = [
  ('CARD', '신용·체크카드'),
  ('KAKAO_PAY', '카카오페이'),
  ('NAVER_PAY', '네이버페이'),
  ('TOSS', '토스페이'),
];

/// 예약한 거래를 결제하는 화면.
///
/// 직거래라 결제는 **만나서 양쪽이 수령을 확인한 뒤**에만 열린다.
/// 그래서 여기서 주문을 만들지 않고, 이미 있는 예약([orderId])을 결제한다.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.orderId,
    required this.artworkTitle,
    required this.price,
  });

  final int orderId;
  final String artworkTitle;
  final int price;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _api = const OrderApiService();

  String _paymentMethod = _paymentMethods.first.$1;
  bool _paying = false;

  int get _price => widget.price;

  Future<void> _pay() async {
    setState(() => _paying = true);
    try {
      // 실 PG 가 켜져 있으면 토스 결제창을 먼저 거치고, 거기서 받은 키로 서버가 승인한다.
      final config = await _api.fetchPaymentConfig();
      String? paymentKey;
      String? tossOrderId;

      if (config.enabled && config.clientKey != null) {
        if (!mounted) return;
        tossOrderId = _newOrderId();
        final result = await Navigator.of(context).push<TossPaymentResult>(
          MaterialPageRoute(
            builder: (_) => TossPaymentScreen(
              clientKey: config.clientKey!,
              orderId: tossOrderId!,
              orderName: widget.artworkTitle,
              amount: _price,
            ),
          ),
        );
        if (!mounted) return;
        if (result == null || !result.isSuccess) {
          _showMessage(result?.message ?? '결제를 취소했어요');
          return;
        }
        paymentKey = result.paymentKey;
      }

      final order = await _api.pay(
        orderId: widget.orderId,
        paymentMethod: _paymentMethod,
        paymentKey: paymentKey,
        tossOrderId: paymentKey == null ? null : tossOrderId,
      );
      if (!mounted) return;
      await _showCompleteDialog(order);
    } catch (error) {
      _showMessage(error is StateError ? error.message : '결제에 실패했습니다');
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  /// 토스 주문번호는 6~64자여야 하고 결제마다 달라야 한다.
  String _newOrderId() =>
      'artnara-${widget.orderId}-${DateTime.now().millisecondsSinceEpoch}';

  Future<void> _showCompleteDialog(Order order) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.verified, color: ArtColors.success),
            SizedBox(width: 8),
            Text('결제 완료', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.artworkTitle} 작품의 결제가 완료되었습니다.',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Text('디지털 소유권이 발급되었습니다.\n인증 번호: ${order.certificateNo}',
                style: const TextStyle(fontSize: 12, color: ArtColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context); // 결제 화면 닫기
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const CertificateScreen()),
              );
            },
            child: const Text('소유권 확인'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context); // 결제 화면 닫기
            },
            style: FilledButton.styleFrom(
              backgroundColor: ArtColors.brandPrimary,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
        title: const Text('주문 / 결제',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          _ArtworkSummary(title: widget.artworkTitle, price: _price),
          const SizedBox(height: 24),
          const Text('결제 수단',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._paymentMethods.map(
            (method) => RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(method.$2, style: const TextStyle(fontSize: 13)),
              value: method.$1,
              groupValue: _paymentMethod,
              onChanged: (value) => setState(
                  () => _paymentMethod = value ?? _paymentMethods.first.$1),
            ),
          ),
          const SizedBox(height: 16),
          _PriceSummary(price: _price),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _paying ? null : _pay,
            style: FilledButton.styleFrom(
              backgroundColor: ArtColors.brandPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              _paying ? '결제 중...' : '₩${_formatPrice(_price)} 결제하기',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '구매자 수수료 0% · 결제 완료 시 디지털 소유권이 자동 발급됩니다',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: ArtColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ArtworkSummary extends StatelessWidget {
  const _ArtworkSummary({required this.title, required this.price});

  final String title;
  final int price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: ArtColors.bgSurface,
        border: Border.all(color: ArtColors.borderSoft),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: ArtColors.borderSoft),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.verified_outlined,
                size: 22, color: ArtColors.brandPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                const Text('수령 확인 완료 · 결제만 남았어요',
                    style: TextStyle(
                        fontSize: 11, color: ArtColors.textSecondary)),
                const SizedBox(height: 4),
                Text('₩${_formatPrice(price)}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        border: Border.all(color: ArtColors.borderSoft),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          _row('작품 금액', '₩${_formatPrice(price)}'),
          const Divider(height: 16, color: ArtColors.borderSoft),
          _row('총 결제 금액', '₩${_formatPrice(price)}', bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 14 : 12,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

String _formatPrice(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return buffer.toString();
}
