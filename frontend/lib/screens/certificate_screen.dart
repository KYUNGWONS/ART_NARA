import 'package:flutter/material.dart';

import '../models/certificate.dart';
import '../services/certificate_api_service.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('정품 인증',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          const Text('QR 정품 인증 스캔',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('작품 뒤에 부착된 QR 코드를 스캔하면 디지털 인증서를 확인할 수 있어요.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showMessage('카메라 스캔은 준비 중입니다. 코드를 직접 입력해주세요.'),
            child: Container(
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: const Color(0xFFD1D5DB)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 40, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 8),
                  Text('카메라로 QR 스캔',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
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
                        TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
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
                  backgroundColor: const Color(0xFF1F2937),
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
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
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

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.certificate});

  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                certificate.verified ? Icons.verified : Icons.error_outline,
                size: 18,
                color: certificate.verified
                    ? const Color(0xFF34D399)
                    : const Color(0xFFF87171),
              ),
              const SizedBox(width: 6),
              Text(
                certificate.verified ? '정품 인증 완료' : '인증 실패',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _certRow('인증 번호', certificate.certificateNo),
          _certRow('작품명', certificate.artworkTitle),
          _certRow('작가', certificate.artistName),
          _certRow('소유자', certificate.ownerName),
          _certRow('발급일', certificate.issuedDate),
          if (certificate.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(certificate.note,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ],
        ],
      ),
    );
  }

  Widget _certRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12, color: Colors.white)),
          ),
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ownership.qrIssued
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ownership.qrIssued ? 'QR 발급됨' : 'QR 미발급',
              style: TextStyle(
                fontSize: 11,
                color: ownership.qrIssued
                    ? const Color(0xFF059669)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
