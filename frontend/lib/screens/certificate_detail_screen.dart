import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';
import '../models/certificate.dart';
import '../services/certificate_api_service.dart';
import '../widgets/certificate_card.dart';

/// 소유권 인증서 상세 — 인증서 한 장만 보여주는 전용 화면.
///
/// 목록(소유권 카드)에서 넘어와 뒤로가기로 돌아간다.
/// QR 코드는 인증번호 끝자리로 만들어진다(서버 CertificateService.qrCodeOf 와 같은 규칙).
class CertificateDetailScreen extends StatefulWidget {
  const CertificateDetailScreen({
    super.key,
    required this.certificateNo,
    required this.artworkTitle,
  });

  final String certificateNo;

  /// 조회 전에도 헤더에 작품명을 보여주기 위해 목록에서 함께 받는다.
  final String artworkTitle;

  @override
  State<CertificateDetailScreen> createState() =>
      _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends State<CertificateDetailScreen> {
  final _api = const CertificateApiService();

  Certificate? _certificate;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final certificate = await _api.scan(qrCodeOf(widget.certificateNo));
      if (!mounted) return;
      setState(() {
        _certificate = certificate;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is StateError ? error.message : '인증서를 불러오지 못했어요';
        _loading = false;
      });
    }
  }

  /// ARTNARA-2026-0001 → ARTNARA-QR-0001
  static String qrCodeOf(String certificateNo) {
    final index = certificateNo.lastIndexOf('-');
    if (index < 0) return certificateNo;
    return 'ARTNARA-QR-${certificateNo.substring(index + 1)}';
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
        title: const Text('소유권 인증서',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: ArtColors.brandPrimary),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: ArtText.caption),
            const SizedBox(height: ArtSpacing.md),
            OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        Text(widget.artworkTitle,
            textAlign: TextAlign.center,
            style: ArtText.body
                .copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('구매로 이전된 디지털 소유권 인증서입니다.',
            textAlign: TextAlign.center, style: ArtText.caption),
        const SizedBox(height: ArtSpacing.lg),
        CertificateCard(certificate: _certificate!),
      ],
    );
  }
}
