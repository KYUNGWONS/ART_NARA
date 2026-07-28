import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/brand_intro.dart';
import '../services/brand_api_service.dart';
import 'landing_screen.dart';
import 'onboarding_screen.dart';

class BrandIntroScreen extends StatefulWidget {
  const BrandIntroScreen({super.key});

  @override
  State<BrandIntroScreen> createState() => _BrandIntroScreenState();
}

class _BrandIntroScreenState extends State<BrandIntroScreen> {
  final _api = const BrandApiService();
  late Future<BrandIntro> _introFuture;

  @override
  void initState() {
    super.initState();
    _introFuture = _api.fetchIntro();
  }

  void _openOnboarding() {
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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: FutureBuilder<BrandIntro>(
          future: _introFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorView(
                onRetry: () => setState(() => _introFuture = _api.fetchIntro()),
              );
            }
            return _BrandIntroContent(
              intro: snapshot.data!,
              onStart: _openOnboarding,
              onSkip: _skip,
            );
          },
        ),
      ),
    );
  }
}

class _BrandIntroContent extends StatelessWidget {
  const _BrandIntroContent({
    required this.intro,
    required this.onStart,
    required this.onSkip,
  });

  final BrandIntro intro;
  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        const SizedBox(
          height: 48,
          child: Center(
            child: Text('브랜드 소개', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFD0D0D0)),
        const SizedBox(height: 24),
        _BrandImage(imageUrl: intro.imageUrl),
        const SizedBox(height: 16),
        Text(intro.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(intro.description, style: const TextStyle(fontSize: 12, height: 1.4)),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1F2937),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(intro.primaryActionLabel),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
            child: Text(intro.secondaryActionLabel),
          ),
        ),
      ],
    );
  }
}

class _BrandImage extends StatelessWidget {
  const _BrandImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
    );
  }
}
