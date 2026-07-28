import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/content_options_data.dart';
import '../models/content_draft.dart';
import '../providers/locale_provider.dart';
import '../services/content_api_service.dart';

/// "Ready to knot" 진입점에서 시작하는 콘텐츠 생성 온보딩 플로우(5단계).
///
/// 단일 라우트 안에서 [PageView]로 step을 전환하며, [ContentDraft] 한 인스턴스에
/// 선택값을 누적한다. (1) 가이드라인 → (2) 장소 → (3) 활동 → (4) 최종 확인 →
/// (5) 완료. 완료 화면에서 홈(MainScreen)으로 복귀한다.
class ContentCreateFlowScreen extends StatefulWidget {
  const ContentCreateFlowScreen({super.key});

  @override
  State<ContentCreateFlowScreen> createState() =>
      _ContentCreateFlowScreenState();
}

class _ContentCreateFlowScreenState extends State<ContentCreateFlowScreen> {
  static const int _doneStep = 4;

  final PageController _pageController = PageController();
  final ContentDraft _draft = ContentDraft();
  final TextEditingController _descController = TextEditingController();

  int _step = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _goNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _selectPlace(ContentOption place) {
    setState(() {
      _draft.place = place.label;
      _draft.placeImage = place.imageUrl;
      // 장소가 바뀌면 이전 활동 선택은 무효화
      _draft.activity = null;
      _draft.activityImage = null;
    });
    _goNext();
  }

  void _selectActivity(ContentOption activity) {
    setState(() {
      _draft.activity = activity.label;
      _draft.activityImage = activity.imageUrl;
    });
    _goNext();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    _draft.description = _descController.text.trim();
    await ContentApiService.submitContent(_draft);
    if (!mounted) return;
    setState(() => _submitting = false);
    _goNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, _) {
        return PopScope(
          canPop: _step == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (_step == _doneStep) return; // 완료 화면에서는 뒤로가기 차단
            _goBack();
          },
          child: Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(locale),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) => setState(() => _step = index),
                      children: [
                        _Step1Guideline(
                          draft: _draft,
                          locale: locale,
                          onChanged: () => setState(() {}),
                          onNext: _goNext,
                        ),
                        _Step2Place(locale: locale, onSelect: _selectPlace),
                        _Step3Activity(
                          draft: _draft,
                          locale: locale,
                          onSelect: _selectActivity,
                        ),
                        _Step4Confirm(
                          draft: _draft,
                          locale: locale,
                          descController: _descController,
                          submitting: _submitting,
                          onSubmit: _submit,
                        ),
                        _Step5Done(
                          locale: locale,
                          onGoHome: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(LocaleProvider locale) {
    // 완료 화면(step 4)에서는 뒤로가기를 숨긴다.
    if (_step >= _doneStep) {
      return const SizedBox(height: 12);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 4),
        child: IconButton(
          onPressed: _goBack,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 공용 위젯
// ─────────────────────────────────────────────────────────────

/// 단계 상단의 "라벨(보라) + 타이틀" 헤더.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.label, required this.title});

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.gowunDodum(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.gowunDodum(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

/// Step 1에서 사용하는 선택 칩(요일/테마/시간 공용).
class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.lightGrey,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.gowunDodum(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }
}

/// Step 2·3에서 사용하는 이미지 그리드 카드(이미지 + 하단 좌측 라벨).
class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.option, required this.onTap});

  final ContentOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              option.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _placeholder(loading: true);
              },
              errorBuilder: (_, _, _) => _placeholder(),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  option.label,
                  style: GoogleFonts.gowunDodum(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      color: AppColors.lightGrey,
      child: Center(
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.image_outlined, color: AppColors.grey, size: 32),
      ),
    );
  }
}

/// 하단 고정 기본 버튼(다음 / 콘텐츠 등록하기).
class _PrimaryBottomButton extends StatelessWidget {
  const _PrimaryBottomButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: (enabled && !loading) ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.lightGrey,
            disabledForegroundColor: AppColors.grey,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.gowunDodum(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 1 — 가이드라인
// ─────────────────────────────────────────────────────────────

class _Step1Guideline extends StatelessWidget {
  const _Step1Guideline({
    required this.draft,
    required this.locale,
    required this.onChanged,
    required this.onNext,
  });

  final ContentDraft draft;
  final LocaleProvider locale;
  final VoidCallback onChanged;
  final VoidCallback onNext;

  bool get _isComplete =>
      draft.days.isNotEmpty && draft.theme != null && draft.timeSlot != null;

  void _toggleDay(String day) {
    if (draft.days.contains(day)) {
      draft.days.remove(day);
    } else {
      draft.days.add(day);
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: _StepHeader(
                    label: locale.tr(AppStrings.ccLabelGuideline),
                    title: locale.tr(AppStrings.ccStep1Title),
                  ),
                ),
                const SizedBox(height: 32),
                _sectionLabel(locale.tr(AppStrings.ccDaysLabel)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final day in kDayOptions)
                      _SelectChip(
                        label: day,
                        selected: draft.days.contains(day),
                        onTap: () => _toggleDay(day),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                _sectionLabel(locale.tr(AppStrings.ccThemeLabel)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final theme in kThemeOptions)
                      _SelectChip(
                        label: theme,
                        selected: draft.theme == theme,
                        onTap: () {
                          draft.theme = theme;
                          onChanged();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                _sectionLabel(locale.tr(AppStrings.ccTimeLabel)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final slot in kTimeSlotOptions)
                      _SelectChip(
                        label: slot,
                        selected: draft.timeSlot == slot,
                        onTap: () {
                          draft.timeSlot = slot;
                          onChanged();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _PrimaryBottomButton(
          label: locale.tr(AppStrings.ccNext),
          enabled: _isComplete,
          onPressed: onNext,
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.gowunDodum(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.grey,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 2 — 장소 선택
// ─────────────────────────────────────────────────────────────

class _Step2Place extends StatelessWidget {
  const _Step2Place({required this.locale, required this.onSelect});

  final LocaleProvider locale;
  final ValueChanged<ContentOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
          child: _StepHeader(
            label: locale.tr(AppStrings.ccLabelPlace),
            title: locale.tr(AppStrings.ccStep2Title),
          ),
        ),
        const SizedBox(height: 28),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
            children: [
              for (final place in kPlaceOptions)
                _OptionCard(option: place, onTap: () => onSelect(place)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 3 — 활동 선택
// ─────────────────────────────────────────────────────────────

class _Step3Activity extends StatelessWidget {
  const _Step3Activity({
    required this.draft,
    required this.locale,
    required this.onSelect,
  });

  final ContentDraft draft;
  final LocaleProvider locale;
  final ValueChanged<ContentOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final placeId = kPlaceOptions
        .cast<ContentOption?>()
        .firstWhere((p) => p?.label == draft.place, orElse: () => null)
        ?.id;
    final activities = activitiesForPlace(placeId);
    final title = locale
        .tr(AppStrings.ccStep3Title)
        .replaceAll('{place}', draft.place ?? '');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
          child: _StepHeader(
            label: locale.tr(AppStrings.ccLabelActivity),
            title: title,
          ),
        ),
        const SizedBox(height: 28),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
            children: [
              for (final activity in activities)
                _OptionCard(
                  option: activity,
                  onTap: () => onSelect(activity),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 4 — 최종 확인
// ─────────────────────────────────────────────────────────────

class _Step4Confirm extends StatelessWidget {
  const _Step4Confirm({
    required this.draft,
    required this.locale,
    required this.descController,
    required this.submitting,
    required this.onSubmit,
  });

  final ContentDraft draft;
  final LocaleProvider locale;
  final TextEditingController descController;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: _StepHeader(
                    label: locale.tr(AppStrings.ccLabelConfirm),
                    title: locale.tr(AppStrings.ccStep4Title),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.lightGrey),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _summaryRow(
                        label: locale.tr(AppStrings.ccThemeLabel),
                        value: draft.theme ?? '-',
                      ),
                      _summaryRow(
                        label: locale.tr(AppStrings.ccSummaryPlace),
                        value: draft.place ?? '-',
                        imageUrl: draft.placeImage,
                      ),
                      _summaryRow(
                        label: locale.tr(AppStrings.ccSummaryActivity),
                        value: draft.activity ?? '-',
                        imageUrl: draft.activityImage,
                      ),
                      _summaryRow(
                        label: locale.tr(AppStrings.ccSummaryDays),
                        value: draft.days.isEmpty ? '-' : draft.days.join(', '),
                      ),
                      _summaryRow(
                        label: locale.tr(AppStrings.ccSummaryTime),
                        value: draft.timeSlot ?? '-',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  locale.tr(AppStrings.ccDescLabel),
                  style: GoogleFonts.gowunDodum(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  style: GoogleFonts.gowunDodum(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: locale.tr(AppStrings.ccDescHint),
                    hintStyle: GoogleFonts.gowunDodum(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _PrimaryBottomButton(
          label: locale.tr(AppStrings.ccSubmit),
          enabled: true,
          loading: submitting,
          onPressed: onSubmit,
        ),
      ],
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    String? imageUrl,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              label,
              style: GoogleFonts.gowunDodum(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 32,
                  height: 32,
                  color: AppColors.lightGrey,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: GoogleFonts.gowunDodum(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 5 — 완료
// ─────────────────────────────────────────────────────────────

class _Step5Done extends StatelessWidget {
  const _Step5Done({required this.locale, required this.onGoHome});

  final LocaleProvider locale;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _AnimatedCheck(),
          const SizedBox(height: 28),
          Text(
            locale.tr(AppStrings.ccDoneTitle),
            textAlign: TextAlign.center,
            style: GoogleFonts.gowunDodum(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            locale.tr(AppStrings.ccDoneSubtitle),
            textAlign: TextAlign.center,
            style: GoogleFonts.gowunDodum(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: onGoHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                locale.tr(AppStrings.ccGoHome),
                style: GoogleFonts.gowunDodum(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 완료 체크 애니메이션 (원이 팝업되며 체크가 그려짐) ───
class _AnimatedCheck extends StatefulWidget {
  const _AnimatedCheck();

  @override
  State<_AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<_AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  // 0~45%: 원이 팝업(스케일), 45~100%: 체크가 그려짐
  late final Animation<double> _circleScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
  );
  late final Animation<double> _checkProgress = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _circleScale.value.clamp(0.0, 1.2),
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(44, 44),
                painter: _CheckPainter(
                  progress: _checkProgress.value,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 체크 마크를 [progress](0~1)만큼 점진적으로 그리는 페인터.
class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.18, h * 0.52)
      ..lineTo(w * 0.42, h * 0.74)
      ..lineTo(w * 0.82, h * 0.30);

    // PathMetric으로 진행률만큼만 잘라서 그린다 (체크가 그어지는 효과)
    final drawn = Path();
    for (final metric in path.computeMetrics()) {
      drawn.addPath(
        metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0)),
        Offset.zero,
      );
    }
    canvas.drawPath(drawn, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
