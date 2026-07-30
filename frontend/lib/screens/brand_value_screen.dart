import 'package:flutter/material.dart';

import '../models/brand_value.dart';
import '../services/brand_value_api_service.dart';
import 'landing_screen.dart';
import 'onboarding_screen.dart';

class BrandValueScreen extends StatefulWidget {
  const BrandValueScreen({super.key});

  @override
  State<BrandValueScreen> createState() => _BrandValueScreenState();
}

class _BrandValueScreenState extends State<BrandValueScreen> {
  final _api = const BrandValueApiService();
  late Future<BrandValue> _valueFuture;

  @override
  void initState() {
    super.initState();
    _valueFuture = _api.fetch();
  }

  void _openPreferences() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
    );
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LandingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<BrandValue>(
          future: _valueFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: OutlinedButton(
                  onPressed: () => setState(() => _valueFuture = _api.fetch()),
                  child: const Text('다시 시도'),
                ),
              );
            }
            return _BrandValueContent(
              value: snapshot.data!,
              onBack: () => Navigator.pop(context),
              onPrimary: _openPreferences,
              onSecondary: _skip,
            );
          },
        ),
      ),
    );
  }
}

class _BrandValueContent extends StatelessWidget {
  const _BrandValueContent({
    required this.value,
    required this.onBack,
    required this.onPrimary,
    required this.onSecondary,
  });

  final BrandValue value;
  final VoidCallback onBack;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        SizedBox(
          height: 48,
          child: Row(
            children: [
              IconButton(onPressed: onBack, icon: const Icon(Icons.chevron_left)),
              const Expanded(
                child: Center(
                  child: Text('서비스 가치 소개', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFD0D0D0)),
        const SizedBox(height: 24),
        Text(value.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(value.description, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 24),
        _BrandImage(imageUrl: value.imageUrl),
        const SizedBox(height: 24),
        const Text('왜 ART NARA인가요?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...value.reasons.map((reason) => _ReasonCard(reason: reason)),
        const SizedBox(height: 24),
        const Text('신뢰 인증 체계', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: value.trustTags
              .map((tag) => Chip(label: Text(tag), visualDensity: VisualDensity.compact))
              .toList(),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: onPrimary,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1F2937),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(value.primaryActionLabel),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onSecondary,
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
            child: Text(value.secondaryActionLabel),
          ),
        ),
      ],
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({required this.reason});

  final BrandReason reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reason.title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(reason.description, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _BrandImage extends StatelessWidget {
  const _BrandImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: imageUrl.isEmpty
          ? const Text('Image', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)))
          : Image.network(imageUrl, fit: BoxFit.cover),
    );
  }
}
