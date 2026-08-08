import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/art_tokens.dart';
import '../widgets/won_input_formatter.dart';
import '../utils/image_url.dart';
import 'art_home_feed_screen.dart' show formatPrice;
import '../models/commission.dart';
import '../services/commission_api_service.dart';
import '../services/user_api_service.dart';
import '../services/image_api_service.dart';

/// 선호 카테고리 (Figma 23:67 — 복수 선택 가능)
const _categories = ['회화', '조각', '일러스트', '디지털 아트', '사진', '콜라주', '설치 미술', '기타'];

/// 제작 의뢰 신청 — Figma 23:67 디자인.
class CommissionScreen extends StatefulWidget {
  const CommissionScreen({super.key, this.focusCommissionId});

  /// 알림에서 넘어온 의뢰 id. 목록이 폼 아래에 있어서, 탭만 바꾸면 화면에
  /// 아무 변화가 없어 보인다 — 해당 카드까지 스크롤해준다.
  final int? focusCommissionId;

  @override
  State<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends State<CommissionScreen> {
  final _api = const CommissionApiService();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  // 제안 시트용 컨트롤러. 시트가 닫히자마자 dispose 하면 리빌드 중 참조돼 크래시가 나므로
  // 화면 State 가 소유하고 dispose 도 여기서 한다.
  final _offerAmountController = TextEditingController();
  final _offerMessageController = TextEditingController();

  final Set<String> _selected = {'회화'};
  DateTime? _desiredDate;
  bool _submitting = false;
  List<Commission> _commissions = const [];

  final _imagePicker = ImagePicker();
  final _imageApi = const ImageApiService();
  String? _localImagePath;
  String? _referenceImageUrl;
  bool _uploadingImage = false;

  /// 제안 등록 시 표시할 내 활동명(프로필에서 조회)
  String? _profileNickname;

  /// 알림에서 지목한 의뢰 카드로 스크롤하기 위한 키
  final _focusedCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadCommissions();
    _loadMyNickname();
    _descriptionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    _offerAmountController.dispose();
    _offerMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadMyNickname() async {
    final profile = await UserApiService.getMe();
    if (!mounted) return;
    setState(() => _profileNickname = profile?.data?.nickname);
  }

  Future<void> _loadCommissions() async {
    try {
      final commissions = await _api.fetchCommissions();
      if (!mounted) return;
      setState(() => _commissions = commissions);
      _scrollToFocused();
    } catch (_) {
      // 목록 조회 실패는 등록 폼 사용을 막지 않는다.
    }
  }

  /// 알림으로 지목된 의뢰가 목록에 있으면 그 카드를 화면에 보여준다.
  void _scrollToFocused() {
    if (widget.focusCommissionId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _focusedCardKey.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(target,
          duration: const Duration(milliseconds: 400), alignment: 0.1);
    });
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _localImagePath = picked.path;
      _referenceImageUrl = null;
      _uploadingImage = true;
    });
    try {
      final url = await _imageApi.upload(picked.path);
      if (mounted) setState(() => _referenceImageUrl = url);
    } catch (error) {
      if (mounted) setState(() => _localImagePath = null);
      _showMessage(error is StateError ? error.message : '이미지 업로드에 실패했습니다');
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _pickDesiredDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 14)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked != null) setState(() => _desiredDate = picked);
  }

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _showMessage('의뢰 세부 내용을 작성해주세요');
      return;
    }
    final budget = WonInputFormatter.digitsOf(_budgetController.text);
    if (budget == null || budget <= 0) {
      _showMessage('예산을 입력해주세요');
      return;
    }
    if (_selected.isEmpty) {
      _showMessage('선호 카테고리를 선택해주세요');
      return;
    }
    setState(() => _submitting = true);
    try {
      // 제목은 세부 내용 첫 줄에서 만든다 (디자인에 별도 제목 필드 없음).
      final firstLine = description.split('\n').first;
      final title =
          firstLine.length > 30 ? '${firstLine.substring(0, 30)}…' : firstLine;
      final created = await _api.create(
        title: title,
        description: description,
        categories: _selected.toList(),
        budget: budget,
        desiredDate: _desiredDate?.toIso8601String().substring(0, 10),
        referenceImageUrl: _referenceImageUrl,
      );
      if (!mounted) return;
      _descriptionController.clear();
      _budgetController.clear();
      setState(() {
        _selected
          ..clear()
          ..add('회화');
        _desiredDate = null;
        _localImagePath = null;
        _referenceImageUrl = null;
      });
      _showMessage(
          '의뢰가 등록되었습니다. ${created.category} 작가 ${created.notifiedArtistCount}명에게 알림을 보냈어요.');
      await _loadCommissions();
    } catch (error) {
      _showMessage(error is StateError ? error.message : '의뢰 등록에 실패했습니다');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// 작가 제안 시트 — 역경매라 현재 최저가보다 낮은 금액만 등록된다.
  void _showOfferSheet(Commission commission) {
    _offerAmountController.clear();
    _offerMessageController.clear();
    final ceiling = commission.lowestOffer ?? commission.budget;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              ArtSpacing.lg, ArtSpacing.lg, ArtSpacing.lg, ArtSpacing.lg),
          decoration: const BoxDecoration(
            color: ArtColors.bgSurface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(ArtRadius.lg)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(commission.title,
                  style: ArtText.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('현재 최저가 ₩${formatPrice(ceiling)} 보다 낮은 금액만 제안할 수 있어요',
                  style: ArtText.caption),
              const SizedBox(height: ArtSpacing.md),
              TextField(
                controller: _offerAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: const [WonInputFormatter()],
                style: const TextStyle(fontSize: 14),
                decoration: _decoration('제안 금액').copyWith(
                  prefixText: '₩ ',
                  prefixStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ArtColors.textPrimary),
                ),
              ),
              const SizedBox(height: ArtSpacing.sm),
              TextField(
                controller: _offerMessageController,
                maxLines: 2,
                style: const TextStyle(fontSize: 14),
                decoration: _decoration('작업 방식·일정을 간단히 적어주세요'),
              ),
              const SizedBox(height: ArtSpacing.md),
              SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ArtColors.brandPrimary,
                    foregroundColor: ArtColors.textOnBrand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ArtRadius.md),
                    ),
                  ),
                  onPressed: () async {
                    final amount =
                        WonInputFormatter.digitsOf(_offerAmountController.text);
                    if (amount == null || amount <= 0) {
                      _showMessage('제안 금액을 입력해주세요');
                      return;
                    }
                    Navigator.pop(sheetContext);
                    await _submitOffer(commission, amount,
                        _offerMessageController.text.trim());
                  },
                  child: const Text('제안 보내기',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitOffer(
      Commission commission, int amount, String message) async {
    try {
      await _api.placeOffer(
        commissionId: commission.id,
        artistName: _profileNickname ?? '익명 작가',
        amount: amount,
        message: message,
      );
      if (!mounted) return;
      _showMessage('제안을 보냈어요');
      _loadCommissions();
    } catch (error) {
      if (!mounted) return;
      _showMessage(error is StateError ? error.message : '제안 등록에 실패했습니다');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          ArtSpacing.lg, ArtSpacing.xs, ArtSpacing.lg, ArtSpacing.lg),
      children: [
        // 화면 제목은 MainScreen 헤더가 그린다(디자인 header-row).
        const _FieldLabel('의뢰 세부 내용'),
        Stack(
          children: [
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 1000,
              style:
                  const TextStyle(fontSize: 14, color: ArtColors.textPrimary),
              decoration: _decoration('원하는 작품의 내용, 느낌, 참고 이미지 등을\n자세히 작성해주세요.')
                  .copyWith(counterText: ''),
            ),
            Positioned(
              right: 12,
              bottom: 10,
              child: Text(
                '${_descriptionController.text.length}/1000',
                style: const TextStyle(
                    fontSize: 11, color: ArtColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: ArtSpacing.xs),
        _ReferenceImageRow(
          onTap: _uploadingImage ? null : _pickImage,
          localImagePath: _localImagePath,
          uploading: _uploadingImage,
        ),
        const SizedBox(height: ArtSpacing.md),
        const _FieldLabel('예산 (₩)'),
        TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          inputFormatters: const [WonInputFormatter()],
          style: const TextStyle(fontSize: 14, color: ArtColors.textPrimary),
          decoration: _decoration('예산을 입력해주세요').copyWith(
            prefixText: '₩ ',
            prefixStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ArtColors.textPrimary),
          ),
        ),
        const SizedBox(height: ArtSpacing.md),
        const _FieldLabel('희망 마감일'),
        GestureDetector(
          onTap: _pickDesiredDate,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: ArtColors.bgSurface,
              borderRadius: BorderRadius.circular(ArtRadius.sm),
              border: Border.all(color: ArtColors.borderSoft),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _desiredDate == null
                      ? '날짜를 선택해주세요'
                      : _desiredDate!.toIso8601String().substring(0, 10),
                  style: TextStyle(
                    fontSize: 14,
                    color: _desiredDate == null
                        ? ArtColors.textSecondary
                        : ArtColors.textPrimary,
                  ),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: ArtColors.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: ArtSpacing.md),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _FieldLabel('선호 카테고리', bottom: 0),
            SizedBox(width: 6),
            Padding(
              padding: EdgeInsets.only(bottom: 1),
              child: Text('(복수 선택 가능)',
                  style: TextStyle(
                      fontSize: 11, color: ArtColors.textSecondary)),
            ),
          ],
        ),
        const SizedBox(height: ArtSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final active = _selected.contains(category);
            return GestureDetector(
              onTap: () => setState(() {
                if (active) {
                  _selected.remove(category);
                } else {
                  _selected.add(category);
                }
              }),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: active
                      ? ArtColors.brandPrimary
                      : ArtColors.bgSurface,
                  // 디자인 23:67 은 pill 칩이다(홈 피드 카테고리 칩과 같은 형태).
                  borderRadius: BorderRadius.circular(ArtRadius.full),
                  border: active
                      ? null
                      : Border.all(color: ArtColors.borderSoft),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active
                        ? ArtColors.textOnBrand
                        : ArtColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: ArtSpacing.lg),
        // 안내 박스 (디자인: bg/info)
        Container(
          padding: const EdgeInsets.all(ArtSpacing.md),
          decoration: BoxDecoration(
            color: ArtColors.bgInfo,
            borderRadius: BorderRadius.circular(ArtRadius.sm),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  size: 18, color: ArtColors.brandPrimary),
              SizedBox(width: ArtSpacing.xs),
              Expanded(
                child: Text(
                  '의뢰가 등록되면 선택한 카테고리의 작가들에게 알림이 가며, 역경매 형식으로 가격을 제안합니다.',
                  style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: ArtColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ArtSpacing.lg),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: ArtColors.brandPrimary,
              foregroundColor: ArtColors.textOnBrand,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ArtRadius.full)),
            ),
            child: Text(_submitting ? '등록 중...' : '의뢰 요청하기',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        if (_commissions.isNotEmpty) ...[
          const SizedBox(height: ArtSpacing.lg * 1.5),
          // 이 목록은 GET /api/commissions — 작가가 제안하려면 남의 의뢰도 봐야 하므로
          // 공개 목록이다. '내 의뢰 현황' 이라고 부르면 작가 화면에서 남의 의뢰가
          // 자기 것처럼 보인다.
          const Text('등록된 의뢰',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ArtColors.textPrimary)),
          const SizedBox(height: ArtSpacing.sm),
          ..._commissions.map((commission) => _CommissionCard(
                key: commission.id == widget.focusCommissionId
                    ? _focusedCardKey
                    : null,
                commission: commission,
                onOffer: () => _showOfferSheet(commission),
              )),
        ],
      ],
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(fontSize: 13, color: ArtColors.textSecondary),
      filled: true,
      fillColor: ArtColors.bgSurface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ArtRadius.sm),
        borderSide: const BorderSide(color: ArtColors.borderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ArtRadius.sm),
        borderSide: const BorderSide(color: ArtColors.borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ArtRadius.sm),
        borderSide: const BorderSide(color: ArtColors.brandPrimary),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.bottom = ArtSpacing.xs});

  final String text;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Text(text,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ArtColors.textPrimary)),
    );
  }
}

/// 참고 이미지 첨부 (선택) — 첨부되면 썸네일 표시
class _ReferenceImageRow extends StatelessWidget {
  const _ReferenceImageRow({
    required this.onTap,
    required this.localImagePath,
    required this.uploading,
  });

  final VoidCallback? onTap;
  final String? localImagePath;
  final bool uploading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: ArtColors.bgSubtle,
              borderRadius: BorderRadius.circular(ArtRadius.sm),
              border: Border.all(color: ArtColors.borderSoft),
            ),
            child: localImagePath != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(localImagePath!), fit: BoxFit.cover),
                      if (uploading)
                        Container(
                          color: Colors.black38,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                        ),
                    ],
                  )
                : const Icon(Icons.add_photo_alternate_outlined,
                    size: 22, color: ArtColors.textSecondary),
          ),
          const SizedBox(width: ArtSpacing.sm),
          const Text('참고 이미지 첨부 (선택)',
              style:
                  TextStyle(fontSize: 12, color: ArtColors.textSecondary)),
        ],
      ),
    );
  }
}

class _CommissionCard extends StatelessWidget {
  const _CommissionCard(
      {super.key, required this.commission, required this.onOffer});

  /// 작가 제안 등록(역경매)
  final VoidCallback onOffer;

  final Commission commission;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ArtSpacing.sm),
      padding: const EdgeInsets.all(ArtSpacing.md),
      decoration: BoxDecoration(
        color: ArtColors.bgSurface,
        borderRadius: BorderRadius.circular(ArtRadius.md),
        border: Border.all(color: ArtColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (commission.referenceImageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(resolveImageUrl(commission.referenceImageUrl),
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const SizedBox(width: 36, height: 36)),
                ),
                const SizedBox(width: ArtSpacing.xs),
              ],
              Expanded(
                child: Text(commission.title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ArtColors.textPrimary)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ArtColors.bgInfo,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(commission.status,
                    style: const TextStyle(
                        fontSize: 11, color: ArtColors.brandPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            // 고른 카테고리를 모두 보여준다(복수 선택 지원).
            '${commission.categories.isEmpty ? commission.category : commission.categories.join(' · ')}'
            ' · 예산 ₩${formatPrice(commission.budget)}'
            '${commission.desiredDate != null ? ' · 희망일 ${commission.desiredDate}' : ''}',
            style: const TextStyle(
                fontSize: 11, color: ArtColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '작가 ${commission.notifiedArtistCount}명에게 알림 발송'
            '${commission.lowestOffer != null ? ' · 현재 최저 제안 ₩${formatPrice(commission.lowestOffer!)}' : ''}',
            style: const TextStyle(
                fontSize: 11, color: ArtColors.textSecondary),
          ),
          if (commission.offers.isNotEmpty) ...[
            const SizedBox(height: ArtSpacing.xs),
            const Divider(height: 1, color: ArtColors.borderSoft),
            const SizedBox(height: ArtSpacing.xs),
            ...commission.offers.map(
              (offer) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${offer.artistName} · ${offer.message}',
                        style: const TextStyle(
                            fontSize: 11, color: ArtColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: ArtSpacing.xs),
                    Text('₩${formatPrice(offer.amount)}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ArtColors.textPrimary)),
                    const SizedBox(width: ArtSpacing.xs),
                    Text(offer.offerTime,
                        style: const TextStyle(
                            fontSize: 10, color: ArtColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: ArtSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onOffer,
              style: OutlinedButton.styleFrom(
                foregroundColor: ArtColors.brandPrimary,
                side: const BorderSide(color: ArtColors.brandPrimary),
                padding: const EdgeInsets.symmetric(
                    horizontal: ArtSpacing.md, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ArtRadius.full),
                ),
              ),
              child: const Text('제안하기', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
