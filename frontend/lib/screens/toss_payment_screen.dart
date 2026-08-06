import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/art_tokens.dart';

/// 토스 결제창(결제위젯)을 띄우는 화면.
///
/// 결제가 끝나면 토스가 `https://artnara.app/payment/success|fail` 로 이동하는데,
/// 그 이동을 여기서 가로채 결과를 [TossPaymentResult] 로 돌려준다.
/// **승인은 서버에서** 한다 — 이 화면은 paymentKey 를 받아오기만 한다.
class TossPaymentScreen extends StatefulWidget {
  const TossPaymentScreen({
    super.key,
    required this.clientKey,
    required this.orderId,
    required this.orderName,
    required this.amount,
  });

  final String clientKey;

  /// 토스 주문번호(6~64자). 서버 승인 때 그대로 다시 보낸다.
  final String orderId;
  final String orderName;
  final int amount;

  @override
  State<TossPaymentScreen> createState() => _TossPaymentScreenState();
}

/// 결제창 결과. 성공이면 paymentKey 가 채워진다.
class TossPaymentResult {
  const TossPaymentResult.success(this.paymentKey, this.orderId, this.amount)
      : message = null;
  const TossPaymentResult.failure(this.message)
      : paymentKey = null,
        orderId = null,
        amount = null;

  final String? paymentKey;
  final String? orderId;
  final int? amount;
  final String? message;

  bool get isSuccess => paymentKey != null;
}

class _TossPaymentScreenState extends State<TossPaymentScreen> {
  static const _successUrl = 'https://artnara.app/payment/success';
  static const _failUrl = 'https://artnara.app/payment/fail';

  late final WebViewController _controller;
  bool _loading = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        onNavigationRequest: (request) {
          if (request.url.startsWith(_successUrl)) {
            _complete(_readSuccess(request.url));
            return NavigationDecision.prevent;
          }
          if (request.url.startsWith(_failUrl)) {
            final message = Uri.parse(request.url).queryParameters['message'];
            _complete(TossPaymentResult.failure(message ?? '결제를 취소했어요'));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadFlutterAsset(_assetUrl());
  }

  /// 위젯 호스트 페이지에 결제 정보를 쿼리로 넘긴다.
  String _assetUrl() {
    final query = Uri(queryParameters: {
      'clientKey': widget.clientKey,
      'orderId': widget.orderId,
      'orderName': widget.orderName,
      'amount': '${widget.amount}',
    }).query;
    return 'assets/toss_checkout.html?$query';
  }

  TossPaymentResult _readSuccess(String url) {
    final params = Uri.parse(url).queryParameters;
    final paymentKey = params['paymentKey'];
    final orderId = params['orderId'];
    final amount = int.tryParse(params['amount'] ?? '');
    if (paymentKey == null || orderId == null || amount == null) {
      return const TossPaymentResult.failure('결제 결과를 확인하지 못했어요');
    }
    return TossPaymentResult.success(paymentKey, orderId, amount);
  }

  /// 결과는 한 번만 돌려준다(리다이렉트가 중복될 수 있다).
  void _complete(TossPaymentResult result) {
    if (_finished || !mounted) return;
    _finished = true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArtColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: ArtColors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () =>
              _complete(const TossPaymentResult.failure('결제를 취소했어요')),
        ),
        title: const Text('결제',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: ArtColors.brandPrimary),
            ),
        ],
      ),
    );
  }
}
