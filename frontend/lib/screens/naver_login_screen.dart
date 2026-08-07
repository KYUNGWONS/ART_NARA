import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/art_tokens.dart';

/// 네이버 로그인 동의 화면(앱 자체 WebView).
///
/// 네이버 SDK 는 커스텀탭 → `intent://` 로 결과를 돌려주는데, 그 전달이 막히는 환경이 있어
/// (에뮬레이터에서 실측) 동의만 WebView 로 받고 **인가 코드**를 돌려주도록 했다.
/// 코드를 액세스 토큰으로 바꾸는 일은 서버가 한다 — 클라이언트 시크릿이 앱에 남지 않는다.
class NaverLoginScreen extends StatefulWidget {
  const NaverLoginScreen({
    super.key,
    required this.authorizeUrl,
    required this.redirectUri,
    required this.state,
  });

  final String authorizeUrl;

  /// 실제로 열리는 주소가 아니라, 여기로 이동하는 걸 가로채는 표식이다.
  final String redirectUri;

  /// 요청할 때 만든 값. 콜백의 state 와 다르면 버린다(요청 위조 방지).
  final String state;

  @override
  State<NaverLoginScreen> createState() => _NaverLoginScreenState();
}

/// 동의 결과. 성공이면 code 가 채워진다.
class NaverLoginResultData {
  const NaverLoginResultData.success(this.code) : message = null;
  const NaverLoginResultData.failure(this.message) : code = null;

  final String? code;
  final String? message;

  bool get isSuccess => code != null;
}

class _NaverLoginScreenState extends State<NaverLoginScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // 로그인이 실패하면 어디서 막혔는지 알아야 한다. 인증 정보가 새지 않도록
      // 주소는 경로까지만(쿼리에 코드·토큰이 실린다) 남긴다.
      ..setOnConsoleMessage((msg) => debugPrint('[Naver][web] ${msg.message}'))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          debugPrint('[Naver] 페이지 로드: ${_safe(url)}');
          if (mounted) setState(() => _loading = false);
        },
        onWebResourceError: (error) {
          debugPrint('[Naver] 로드 실패: ${error.errorCode} ${error.description}');
        },
        onNavigationRequest: (request) {
          if (!request.url.startsWith(widget.redirectUri)) {
            return NavigationDecision.navigate;
          }
          final params = Uri.parse(request.url).queryParameters;
          final code = params['code'];
          final state = params['state'];
          if (code == null || code.isEmpty) {
            _complete(NaverLoginResultData.failure(
                params['error_description'] ?? '로그인이 취소되었어요'));
          } else if (state != widget.state) {
            // 내가 시작한 요청이 아니면 코드를 쓰지 않는다.
            _complete(const NaverLoginResultData.failure('로그인 검증에 실패했어요'));
          } else {
            _complete(NaverLoginResultData.success(code));
          }
          return NavigationDecision.prevent;
        },
      ))
      ..loadRequest(Uri.parse(widget.authorizeUrl));
  }

  /// 로그에 남길 주소. 쿼리에는 인가 코드가 실리므로 잘라낸다.
  static String _safe(String url) {
    final parsed = Uri.tryParse(url);
    return parsed == null ? '(파싱 실패)' : '${parsed.origin}${parsed.path}';
  }

  /// 결과는 한 번만 돌려준다(리다이렉트가 중복될 수 있다).
  void _complete(NaverLoginResultData result) {
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
              _complete(const NaverLoginResultData.failure('로그인을 취소했어요')),
        ),
        title: const Text('네이버 로그인',
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
