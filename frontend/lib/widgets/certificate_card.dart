import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';
import '../models/certificate.dart';

/// 디지털 인증서 카드 — Figma 50:1034 골드 프레임 디자인
class CertificateCard extends StatelessWidget {
  const CertificateCard({super.key, required this.certificate});

  final Certificate certificate;

  static const _gold = Color(0xFFB98A2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: ArtColors.bgSurface,
        borderRadius: BorderRadius.circular(ArtRadius.sm),
        border: Border.all(color: _gold, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(ArtSpacing.lg),
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
                    color: ArtColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('─  소유권 인증서  ─',
                style: TextStyle(
                    fontSize: 13, color: ArtColors.textSecondary)),
            const SizedBox(height: ArtSpacing.lg),
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
            const SizedBox(height: ArtSpacing.lg),
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: _gold, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.qr_code_2,
                  size: 76, color: ArtColors.textPrimary),
            ),
            const SizedBox(height: ArtSpacing.md),
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
                          ? ArtColors.brandPrimary
                          : ArtColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      certificate.verified ? '소유권 인증 완료' : '인증 실패',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ArtColors.textPrimary),
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
                  // ART NARA 이니셜 씰.
                  child: const Text('AN',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ],
            ),
            if (certificate.note.isNotEmpty) ...[
              const SizedBox(height: ArtSpacing.xs),
              Text(certificate.note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11, color: ArtColors.textSecondary)),
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
                        fontSize: 11, color: ArtColors.textSecondary)),
              ),
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ArtColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: ArtColors.borderSoft),
        ],
      ),
    );
  }
}
