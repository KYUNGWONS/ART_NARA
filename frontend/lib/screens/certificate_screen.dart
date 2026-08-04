import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';

import '../models/certificate.dart';
import '../services/certificate_api_service.dart';
import 'qr_scan_screen.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final _api = const CertificateApiService();
  final _qrController = TextEditingController();
  List<Ownership> _ownerships = const [];
  Certificate? _certificate;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _loadOwnerships();
  }

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  Future<void> _loadOwnerships() async {
    try {
      final ownerships = await _api.fetchOwnerships();
      if (mounted) setState(() => _ownerships = ownerships);
    } catch (_) {
      // 소유권 목록 조회 실패는 QR 스캔 사용을 막지 않는다.
    }
  }

  Future<void> _openCameraScan() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (code == null || code.isEmpty || !mounted) return;
    _qrController.text = code;
    await _scan();
  }

  Future<void> _scan() async {
    final code = _qrController.text.trim();
    if (code.isEmpty) {
      _showMessage('QR 코드를 입력해주세요');
      return;
    }
    setState(() {
      _scanning = true;
      _certificate = null;
    });
    try {
      final certificate = await _api.scan(code);
      if (mounted) setState(() => _certificate = certificate);
    } catch (error) {
      _showMessage(error is StateError ? error.message : 'QR 인증에 실패했습니다');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DustColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: DustColors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('소유권 인증',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          const Text('QR 소유권 인증 스캔',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('작품 뒤에 부착된 QR 코드를 스캔하면 디지털 인증서를 확인할 수 있어요.',
              style: TextStyle(fontSize: 12, color: DustColors.textSecondary)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _openCameraScan,
            child: Container(
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: DustColors.bgSurface,
                border: Border.all(color: DustColors.borderSoft),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 40, color: DustColors.textSecondary),
                  SizedBox(height: 8),
                  Text('카메라로 QR 스캔',
                      style: TextStyle(fontSize: 11, color: DustColors.textSecondary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qrController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _scan(),
                  decoration: const InputDecoration(
                    hintText: 'QR 코드 직접 입력 (예: ARTNARA-QR-0001)',
                    hintStyle:
                        TextStyle(fontSize: 12, color: DustColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _scanning ? null : _scan,
                style: FilledButton.styleFrom(
                  backgroundColor: DustColors.brandPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(_scanning ? '확인 중...' : '인증하기'),
              ),
            ],
          ),
          if (_certificate != null) ...[
            const SizedBox(height: 16),
            _CertificateCard(certificate: _certificate!),
          ],
          const SizedBox(height: 32),
          const Text('내 디지털 소유권',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('구매가 완료된 작품의 소유권이 자동으로 이전되어 영구 보관됩니다.',
              style: TextStyle(fontSize: 12, color: DustColors.textSecondary)),
          const SizedBox(height: 12),
          if (_ownerships.isEmpty)
            const Text('아직 보유한 디지털 소유권이 없습니다',
                style: TextStyle(fontSize: 12))
          else
            ..._ownerships.map((ownership) => _OwnershipCard(ownership: ownership)),
        ],
      ),
    );
  }
}

/// 디지털 인증서 카드 — Figma 50:1034 골드 프레임 디자인
class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.certificate});

  final Certificate certificate;

  static const _gold = Color(0xFFB98A2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: DustColors.bgSurface,
        borderRadius: BorderRadius.circular(DustRadius.sm),
        border: Border.all(color: _gold, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(DustSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(color: _gold.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            const Text('ART NARA',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6,
                    color: DustColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('─  소유권 인증서  ─',
                style: TextStyle(
                    fontSize: 13, color: DustColors.textSecondary)),
            const SizedBox(height: DustSpacing.lg),
            // 디자인 소유권 인증서1/2 항목 순서
            _certRow('작품 제목', certificate.artworkTitle),
            _certRow('작가', certificate.artistName),
            if (certificate.yearCreated != null)
              _certRow('제작 연도', '${certificate.yearCreated}'),
            if (certificate.sizeInfo != null && certificate.sizeInfo!.isNotEmpty)
              _certRow('크기', certificate.sizeInfo!),
            if (certificate.medium != null && certificate.medium!.isNotEmpty)
              _certRow('재료', certificate.medium!),
            _certRow('고유 인증 ID', certificate.certificateNo),
            _certRow('소유자', certificate.ownerName),
            _certRow('발급일', certificate.issuedDate),
            const SizedBox(height: DustSpacing.lg),
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: _gold, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.qr_code_2,
                  size: 76, color: DustColors.textPrimary),
            ),
            const SizedBox(height: DustSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      certificate.verified
                          ? Icons.verified
                          : Icons.error_outline,
                      size: 16,
                      color: certificate.verified
                          ? DustColors.brandPrimary
                          : DustColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      certificate.verified ? '소유권 인증 완료' : '인증 실패',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DustColors.textPrimary),
                    ),
                  ],
                ),
                // 왁스 씰
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFFD9AC4C), _gold],
                    ),
                  ),
                  child: const Text('DA',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ],
            ),
            if (certificate.note.isNotEmpty) ...[
              const SizedBox(height: DustSpacing.xs),
              Text(certificate.note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11, color: DustColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _certRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 96,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: DustColors.textSecondary)),
              ),
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DustColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: DustColors.borderSoft),
        ],
      ),
    );
  }
}

class _OwnershipCard extends StatelessWidget {
  const _OwnershipCard({required this.ownership});

  final Ownership ownership;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        border: Border.all(color: DustColors.borderSoft),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ownership.artworkTitle,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  '${ownership.artistName} · ${ownership.certificateNo} · 취득일 ${ownership.acquiredDate}',
                  style: const TextStyle(fontSize: 11, color: DustColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ownership.qrIssued
                  ? DustColors.successBg
                  : DustColors.bgSubtle,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ownership.qrIssued ? 'QR 발급됨' : 'QR 미발급',
              style: TextStyle(
                fontSize: 11,
                color: ownership.qrIssued
                    ? DustColors.success
                    : DustColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
