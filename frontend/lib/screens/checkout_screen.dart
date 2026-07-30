import 'package:flutter/material.dart';

import '../models/artwork_detail.dart';
import '../models/order.dart';
import '../services/order_api_service.dart';
import 'certificate_screen.dart';

const _paymentMethods = [
  ('CARD', '신용·체크카드'),
  ('KAKAO_PAY', '카카오페이'),
  ('NAVER_PAY', '네이버페이'),
  ('TOSS', '토스페이'),
];

const _deliveryFee = 15000;

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.artwork});

  final ArtworkDetail artwork;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _api = const OrderApiService();
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _paymentMethod = _paymentMethods.first.$1;
  bool _paying = false;

  @override
  void dispose() {
    _receiverController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _paying = true);
    try {
      final order = await _api.create(
        artworkId: widget.artwork.id,
        paymentMethod: _paymentMethod,
        receiverName: _receiverController.text.trim(),
        phone: _phoneController.text.trim(),
        deliveryAddress: _addressController.text.trim(),
      );
      if (!mounted) return;
      await _showCompleteDialog(order);
    } catch (error) {
      _showMessage(error is StateError ? error.message : '결제에 실패했습니다');
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _showCompleteDialog(Order order) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.verified, color: Color(0xFF059669)),
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
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
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
              backgroundColor: const Color(0xFF1F2937),
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
    final artwork = widget.artwork;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            _ArtworkSummary(artwork: artwork),
            const SizedBox(height: 24),
            const Text('배송지 정보',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _receiverController,
              decoration: _inputDecoration('수령인 이름 *'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '수령인을 입력해주세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('연락처'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: _inputDecoration('배송지 주소 *'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '배송지를 입력해주세요' : null,
            ),
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
            _PriceSummary(price: artwork.price),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _paying ? null : _pay,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                _paying
                    ? '결제 중...'
                    : '₩${_formatPrice(artwork.price + _deliveryFee)} 결제하기',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '구매자 수수료 0% · 결제 완료 시 디지털 소유권이 자동 발급됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      isDense: true,
    );
  }
}

class _ArtworkSummary extends StatelessWidget {
  const _ArtworkSummary({required this.artwork});

  final ArtworkDetail artwork;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.image_outlined,
                size: 22, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(artwork.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${artwork.artistName} · ${artwork.size}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280))),
                const SizedBox(height: 4),
                Text('₩${_formatPrice(artwork.price)}',
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          _row('작품 금액', '₩${_formatPrice(price)}'),
          _row('배송비 (전문 포장·배송)', '₩${_formatPrice(_deliveryFee)}'),
          const Divider(height: 16, color: Color(0xFFE5E7EB)),
          _row('총 결제 금액', '₩${_formatPrice(price + _deliveryFee)}', bold: true),
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
