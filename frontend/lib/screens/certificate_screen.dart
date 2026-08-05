import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';

import '../models/certificate.dart';
import '../services/certificate_api_service.dart';
import '../widgets/certificate_card.dart';
import 'certificate_detail_screen.dart';
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

  /// 소유권 카드를 탭하면 인증서 전용 화면으로 넘어간다(뒤로가기로 목록 복귀).
  void _openCertificateOf(Ownership ownership) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => CertificateDetailScreen(
        certificateNo: ownership.certificateNo,
        artworkTitle: ownership.artworkTitle,
      ),
    ));
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
              style: TextStyle(fontSize: 12, color: ArtColors.textSecondary)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _openCameraScan,
            child: Container(
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ArtColors.bgSurface,
                border: Border.all(color: ArtColors.borderSoft),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 40, color: ArtColors.textSecondary),
                  SizedBox(height: 8),
                  Text('카메라로 QR 스캔',
                      style: TextStyle(fontSize: 11, color: ArtColors.textSecondary)),
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
                        TextStyle(fontSize: 12, color: ArtColors.textSecondary),
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
                  backgroundColor: ArtColors.brandPrimary,
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
            CertificateCard(certificate: _certificate!),
          ],
          const SizedBox(height: 32),
          const Text('내 디지털 소유권',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('구매가 완료된 작품의 소유권이 자동으로 이전되어 영구 보관됩니다.',
              style: TextStyle(fontSize: 12, color: ArtColors.textSecondary)),
          const SizedBox(height: 12),
          if (_ownerships.isEmpty)
            const Text('아직 보유한 디지털 소유권이 없습니다',
                style: TextStyle(fontSize: 12))
          else
            ..._ownerships.map((ownership) => _OwnershipCard(
                  ownership: ownership,
                  onTap: () => _openCertificateOf(ownership),
                )),
        ],
      ),
    );
  }
}


class _OwnershipCard extends StatelessWidget {
  const _OwnershipCard({required this.ownership, this.onTap});

  final Ownership ownership;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        border: Border.all(color: ArtColors.borderSoft),
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
                  style: const TextStyle(fontSize: 11, color: ArtColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ownership.qrIssued
                  ? ArtColors.successBg
                  : ArtColors.bgSubtle,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ownership.qrIssued ? 'QR 발급됨' : 'QR 미발급',
              style: TextStyle(
                fontSize: 11,
                color: ownership.qrIssued
                    ? ArtColors.success
                    : ArtColors.textSecondary,
              ),
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right,
                size: 18, color: ArtColors.textSecondary),
        ],
      ),
      ),
    );
  }
}
