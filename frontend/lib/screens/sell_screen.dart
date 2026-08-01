import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/dust_tokens.dart';
import '../models/sale.dart';
import '../services/image_api_service.dart';
import '../services/sale_api_service.dart';

// 디자인(작품 판매 등록)의 스텝은 작품 정보·상세 정보·가격 설정·배송 정보·등록 완료지만,
// 아트나라는 배송이 없어(사용자 확정) 배송 정보를 뺀 4스텝으로 운영한다.
const _stepLabels = ['작품 정보', '상세 정보', '가격 설정', '등록 완료'];
const _categories = ['회화', '조각', '디지털', '사진', '일러스트', '공예'];

/// 작품 판매 등록 — Figma 1:274 스텝 위저드 디자인.
class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _api = const SaleApiService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mediumController = TextEditingController();
  final _sizeController = TextEditingController();
  final _yearController = TextEditingController();
  final _buyNowController = TextEditingController();
  final _auctionStartController = TextEditingController();

  int _step = 0;
  String _category = _categories.first;
  bool _auctionEnabled = false;
  DateTime? _auctionEndDate;
  bool _submitting = false;
  bool _completed = false;
  List<Sale> _sales = const [];

  final _imagePicker = ImagePicker();
  final _imageApi = const ImageApiService();
  String? _localImagePath;
  String? _imageUrl;
  bool _uploadingImage = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mediumController.dispose();
    _sizeController.dispose();
    _yearController.dispose();
    _buyNowController.dispose();
    _auctionStartController.dispose();
    super.dispose();
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
      _imageUrl = null;
      _uploadingImage = true;
    });
    try {
      final url = await _imageApi.upload(picked.path);
      if (mounted) setState(() => _imageUrl = url);
    } catch (error) {
      if (mounted) setState(() => _localImagePath = null);
      _showMessage(error is StateError ? error.message : '이미지 업로드에 실패했습니다');
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _next() {
    if (_step == 0) {
      if (_titleController.text.trim().isEmpty) {
        _showMessage('작품 제목을 입력해주세요');
        return;
      }
      final price = int.tryParse(_buyNowController.text);
      if (price == null || price <= 0) {
        _showMessage('예상 가격을 입력해주세요');
        return;
      }
    }
    if (_step == 2 && _auctionEnabled) {
      final start = int.tryParse(_auctionStartController.text);
      if (start == null || start <= 0) {
        _showMessage('경매 최저가를 입력해주세요');
        return;
      }
      final buyNow = int.tryParse(_buyNowController.text);
      if (buyNow != null && start > buyNow) {
        _showMessage('경매 최저가는 즉시 판매가보다 높을 수 없습니다');
        return;
      }
      if (_auctionEndDate == null) {
        _showMessage('경매 마감일을 선택해주세요');
        return;
      }
    }
    setState(() => _step++);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _auctionEndDate = picked);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await _api.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        medium: _mediumController.text.trim(),
        size: _sizeController.text.trim(),
        year: int.tryParse(_yearController.text),
        buyNowPrice: int.parse(_buyNowController.text),
        auctionEnabled: _auctionEnabled,
        auctionStartPrice:
            _auctionEnabled ? int.tryParse(_auctionStartController.text) : null,
        auctionEndDate: _auctionEnabled
            ? _auctionEndDate!.toIso8601String().substring(0, 10)
            : null,
        imageUrl: _imageUrl,
        category: _category,
      );
      if (!mounted) return;
      final sales = await _api.fetchSales();
      if (!mounted) return;
      setState(() {
        _completed = true;
        _sales = sales;
      });
    } catch (error) {
      _showMessage(error is StateError ? error.message : '판매 등록에 실패했습니다');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _reset() {
    _titleController.clear();
    _descriptionController.clear();
    _mediumController.clear();
    _sizeController.clear();
    _yearController.clear();
    _buyNowController.clear();
    _auctionStartController.clear();
    setState(() {
      _step = 0;
      _category = _categories.first;
      _auctionEnabled = false;
      _auctionEndDate = null;
      _completed = false;
      _localImagePath = null;
      _imageUrl = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) return _CompletedView(sales: _sales, onReset: _reset);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DustSpacing.lg, DustSpacing.xs, DustSpacing.lg, 0),
          child: Column(
            children: [
              // 화면 제목은 MainScreen 헤더가 그린다(디자인 header-row). 여기선 진행 표기만.
              Align(
                alignment: Alignment.centerRight,
                child: Text('${_step + 1}/${_stepLabels.length}',
                    style: const TextStyle(
                        fontSize: 13, color: DustColors.textSecondary)),
              ),
              const SizedBox(height: DustSpacing.xs),
              _StepIndicator(current: _step),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                DustSpacing.lg, DustSpacing.lg, DustSpacing.lg, DustSpacing.lg),
            children: _buildStepFields(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DustSpacing.lg, 0, DustSpacing.lg, DustSpacing.lg),
          child: Row(
            children: [
              if (_step > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DustColors.brandPrimary,
                    side: const BorderSide(color: DustColors.borderSoft),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DustRadius.sm)),
                  ),
                  child: const Text('이전'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _submitting
                    ? null
                    : (_step == _stepLabels.length - 1 ? _submit : _next),
                style: FilledButton.styleFrom(
                  backgroundColor: DustColors.brandPrimary,
                  foregroundColor: DustColors.textOnBrand,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DustRadius.sm)),
                ),
                child: Text(_submitting
                    ? '등록 중...'
                    : _step == _stepLabels.length - 1
                        ? '판매 등록하기'
                        : '다음 단계'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStepFields() {
    switch (_step) {
      case 0:
        return [
          const _FieldLabel('작품 이미지'),
          _UploadBox(
            onTap: _uploadingImage ? null : _pickImage,
            localImagePath: _localImagePath,
            uploading: _uploadingImage,
          ),
          const SizedBox(height: DustSpacing.md),
          const _FieldLabel('작품 제목'),
          _input(_titleController, '제목을 입력하세요'),
          const SizedBox(height: DustSpacing.md),
          const _FieldLabel('작품 설명'),
          _input(_descriptionController, '작품에 대해 설명해주세요', maxLines: 3),
          const SizedBox(height: DustSpacing.md),
          const _FieldLabel('카테고리'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: _categories
                .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: const TextStyle(fontSize: 14))))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _categories.first),
            decoration: _decoration(''),
          ),
          const SizedBox(height: DustSpacing.md),
          const _FieldLabel('예상 가격 (₩)'),
          _input(_buyNowController, '가격을 입력하세요', number: true),
        ];
      case 1:
        return [
          const _FieldLabel('재료'),
          _input(_mediumController, '예: 캔버스에 유화'),
          const SizedBox(height: DustSpacing.md),
          const _FieldLabel('크기'),
          _input(_sizeController, '예: 53.0 x 45.5cm (10호)'),
          const SizedBox(height: DustSpacing.md),
          const _FieldLabel('제작 연도'),
          _input(_yearController, '예: 2026', number: true),
        ];
      case 2:
        return [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: DustColors.brandPrimary,
            title: const Text('경매로도 판매하기',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: DustColors.textPrimary)),
            subtitle: const Text('최저가부터 입찰을 받아 더 높은 가격에 판매될 수 있어요',
                style:
                    TextStyle(fontSize: 12, color: DustColors.textSecondary)),
            value: _auctionEnabled,
            onChanged: (v) => setState(() => _auctionEnabled = v),
          ),
          if (_auctionEnabled) ...[
            const SizedBox(height: DustSpacing.md),
            const _FieldLabel('경매 최저가 (₩)'),
            _input(_auctionStartController, '즉시 판매가보다 낮게 설정하세요', number: true),
            const SizedBox(height: DustSpacing.md),
            const _FieldLabel('경매 마감일'),
            OutlinedButton.icon(
              onPressed: _pickEndDate,
              style: OutlinedButton.styleFrom(
                foregroundColor: DustColors.textPrimary,
                side: const BorderSide(color: DustColors.borderSoft),
                backgroundColor: DustColors.bgSurface,
              ),
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text(
                _auctionEndDate == null
                    ? '마감일 선택'
                    : _auctionEndDate!.toIso8601String().substring(0, 10),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ];
      default:
        final price = int.tryParse(_buyNowController.text) ?? 0;
        return [
          const Text('등록 내용을 확인해주세요',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: DustColors.textPrimary)),
          const SizedBox(height: DustSpacing.md),
          _SummaryCard(rows: [
            ('작품 제목', _titleController.text),
            ('카테고리', _category),
            if (_mediumController.text.isNotEmpty) ('재료', _mediumController.text),
            if (_sizeController.text.isNotEmpty) ('크기', _sizeController.text),
            ('즉시 판매가', '₩$price'),
            ('경매', _auctionEnabled
                ? '최저가 ₩${_auctionStartController.text} · ~${_auctionEndDate?.toIso8601String().substring(0, 10) ?? ''}'
                : '사용 안 함'),
            ('판매 수수료', '8%'),
          ]),
        ];
    }
  }

  Widget _input(TextEditingController controller, String hint,
      {int maxLines = 1, bool number = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: number ? TextInputType.number : null,
      inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(fontSize: 14, color: DustColors.textPrimary),
      decoration: _decoration(hint),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(fontSize: 13, color: DustColors.textSecondary),
      filled: true,
      fillColor: DustColors.bgSurface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DustRadius.sm),
        borderSide: const BorderSide(color: DustColors.borderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DustRadius.sm),
        borderSide: const BorderSide(color: DustColors.borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DustRadius.sm),
        borderSide: const BorderSide(color: DustColors.brandPrimary),
      ),
    );
  }
}

/// 스텝 진행 인디케이터 (점 + 연결선 + 라벨)
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_stepLabels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final done = i ~/ 2 < current;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 18),
              color: done ? DustColors.brandPrimary : DustColors.borderSoft,
            ),
          );
        }
        final index = i ~/ 2;
        final active = index <= current;
        return Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? DustColors.brandPrimary : DustColors.bgSurface,
                border: Border.all(
                    color: active
                        ? DustColors.brandPrimary
                        : DustColors.borderSoft),
              ),
            ),
            const SizedBox(height: 6),
            Text(_stepLabels[index],
                style: TextStyle(
                    fontSize: 10,
                    color: active
                        ? DustColors.brandPrimary
                        : DustColors.textSecondary)),
          ],
        );
      }),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DustSpacing.xs),
      child: Text(text,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DustColors.textPrimary)),
    );
  }
}

/// 이미지 업로드 박스 (디자인: 점선 테두리 + 업로드 아이콘)
class _UploadBox extends StatelessWidget {
  const _UploadBox({
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
      child: Container(
        height: 190,
        width: double.infinity,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: DustColors.bgSubtle,
          border: Border.all(color: DustColors.borderSoft),
          borderRadius: BorderRadius.circular(DustRadius.md),
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
                      child:
                          const CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_upload_outlined,
                      size: 32, color: DustColors.brandPrimary),
                  SizedBox(height: DustSpacing.sm),
                  Text('이미지 업로드',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DustColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('JPG, PNG 지원 (최대 10MB)',
                      style: TextStyle(
                          fontSize: 12, color: DustColors.textSecondary)),
                ],
              ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DustSpacing.md),
      decoration: BoxDecoration(
        color: DustColors.bgSurface,
        borderRadius: BorderRadius.circular(DustRadius.md),
        border: Border.all(color: DustColors.borderSoft),
      ),
      child: Column(
        children: rows
            .map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(row.$1,
                            style: const TextStyle(
                                fontSize: 12,
                                color: DustColors.textSecondary)),
                      ),
                      Expanded(
                        child: Text(row.$2,
                            style: const TextStyle(
                                fontSize: 13,
                                color: DustColors.textPrimary)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// 등록 완료 뷰 — 체크 + 내 판매 작품 목록
class _CompletedView extends StatelessWidget {
  const _CompletedView({required this.sales, required this.onReset});

  final List<Sale> sales;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(DustSpacing.lg),
      children: [
        const SizedBox(height: DustSpacing.lg),
        const Icon(Icons.check_circle,
            size: 56, color: DustColors.brandPrimary),
        const SizedBox(height: DustSpacing.md),
        const Text('판매 등록이 완료되었습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: DustColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('검수 후 홈 피드에 노출됩니다 · 판매 수수료 8%',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: DustColors.textSecondary)),
        const SizedBox(height: DustSpacing.lg),
        Center(
          child: FilledButton(
            onPressed: onReset,
            style: FilledButton.styleFrom(
              backgroundColor: DustColors.brandPrimary,
              foregroundColor: DustColors.textOnBrand,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DustRadius.full)),
            ),
            child: const Text('새 작품 등록하기'),
          ),
        ),
        const SizedBox(height: DustSpacing.lg),
        if (sales.isNotEmpty) ...[
          const Text('내 판매 작품',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: DustColors.textPrimary)),
          const SizedBox(height: DustSpacing.sm),
          ...sales.map((sale) => Container(
                margin: const EdgeInsets.only(bottom: DustSpacing.xs),
                padding: const EdgeInsets.all(DustSpacing.sm),
                decoration: BoxDecoration(
                  color: DustColors.bgSurface,
                  borderRadius: BorderRadius.circular(DustRadius.sm),
                  border: Border.all(color: DustColors.borderSoft),
                ),
                child: Row(
                  children: [
                    if (sale.imageUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(sale.imageUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const SizedBox(width: 44, height: 44)),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sale.title,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: DustColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                            sale.auctionEnabled
                                ? '즉시 ₩${sale.buyNowPrice} · 경매 시작가 ₩${sale.auctionStartPrice}'
                                : '즉시 ₩${sale.buyNowPrice}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: DustColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DustColors.bgSubtle,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(sale.status,
                          style: const TextStyle(
                              fontSize: 11,
                              color: DustColors.textSecondary)),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}
