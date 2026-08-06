import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
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
        onWebResourceError: (error) {
          debugPrint('[toss] resourceError ${error.errorCode} ${error.description} ${error.url}');
        },
        onNavigationRequest: (request) {
          debugPrint('[toss] navigate ${request.url}');
          if (request.url.startsWith(_successUrl)) {
            _complete(_readSuccess(request.url));
            return NavigationDecision.prevent;
          }
          if (request.url.startsWith(_failUrl)) {
            final message = Uri.parse(request.url).queryParameters['message'];
            _complete(TossPaymentResult.failure(message ?? '결제를 취소했어요'));
            return NavigationDecision.prevent;
          }
          // 카드사·간편결제 앱으로 넘기는 스킴(intent://, kb-acp://, supertoss:// …)은
          // WebView 가 열지 못해 ERR_UNKNOWN_URL_SCHEME 로 끊긴다. 외부 앱으로 넘긴다.
          if (!request.url.startsWith('http')) {
            _openExternal(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ));
    _loadCheckout();
  }

  /// 호스트 페이지에 결제 정보를 심어 로드한다.
  ///
  /// `loadFlutterAsset` 은 쿼리스트링을 붙일 수 없어(에셋 키를 그대로 찾는다)
  /// 에셋을 문자열로 읽어 설정 스크립트를 치환한 뒤 `loadHtmlString` 으로 띄운다.
  /// baseUrl 을 성공/실패 URL 과 같은 오리진으로 둬야 토스가 리다이렉트할 때
  /// NavigationDelegate 가 가로챌 수 있다.
  Future<void> _loadCheckout() async {
    try {
      final template = await rootBundle.loadString('assets/toss_checkout.html');
      final config = jsonEncode({
        'clientKey': widget.clientKey,
        'orderId': widget.orderId,
        'orderName': widget.orderName,
        'amount': widget.amount,
      });
      final html = template.replaceFirst(
        '/*__PAYMENT_CONFIG__*/',
        'window.__ARTNARA_PAYMENT__ = $config;',
      );
      await _controller.loadHtmlString(html, baseUrl: 'https://artnara.app/checkout');
    } catch (_) {
      _complete(const TossPaymentResult.failure('결제창을 불러오지 못했어요'));
    }
  }

  /// 결제 앱을 띄운다. 앱이 없으면 마켓으로, 그것도 안 되면 안내만 한다.
  ///
  /// intent:// URL 은 `;package=com.xxx;` 로 대상 앱을,
  /// `S.browser_fallback_url=` 로 웹 대체 주소를 알려준다.
  Future<void> _openExternal(String url) async {
    if (await _launch(url)) return;

    final fallback = RegExp(r'S\.browser_fallback_url=([^;]+)').firstMatch(url);
    if (fallback != null) {
      final decoded = Uri.decodeComponent(fallback.group(1)!);
      if (await _launch(decoded)) return;
    }
    final package = RegExp(r'package=([^;]+)').firstMatch(url);
    if (package != null &&
        await _launch('market://details?id=${package.group(1)}')) {
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('결제 앱을 열지 못했어요. 앱이 설치되어 있는지 확인해 주세요.')),
      );
    }
  }

  Future<bool> _launch(String url) async {
    try {
      return await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
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
