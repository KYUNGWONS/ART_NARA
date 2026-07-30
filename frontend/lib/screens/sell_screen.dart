import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sale.dart';
import '../services/sale_api_service.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _api = const SaleApiService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mediumController = TextEditingController();
  final _sizeController = TextEditingController();
  final _yearController = TextEditingController();
  final _buyNowController = TextEditingController();
  final _auctionStartController = TextEditingController();

  bool _auctionEnabled = false;
  DateTime? _auctionEndDate;
  bool _submitting = false;
  List<Sale> _sales = const [];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

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

  Future<void> _loadSales() async {
    try {
      final sales = await _api.fetchSales();
      if (mounted) setState(() => _sales = sales);
    } catch (_) {
      // 목록 조회 실패는 등록 폼 사용을 막지 않는다.
    }
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
    if (!_formKey.currentState!.validate()) return;
    if (_auctionEnabled && _auctionEndDate == null) {
      _showMessage('경매 마감일을 선택해주세요');
      return;
    }
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
        auctionStartPrice: _auctionEnabled
            ? int.tryParse(_auctionStartController.text)
            : null,
        auctionEndDate: _auctionEnabled
            ? _auctionEndDate!.toIso8601String().substring(0, 10)
            : null,
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _mediumController.clear();
      _sizeController.clear();
      _yearController.clear();
      _buyNowController.clear();
      _auctionStartController.clear();
      setState(() {
        _auctionEnabled = false;
        _auctionEndDate = null;
      });
      _showMessage('판매 등록이 완료되었습니다. 검수 후 피드에 노출됩니다.');
      await _loadSales();
    } catch (error) {
      _showMessage(error is StateError ? error.message : '판매 등록에 실패했습니다');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          const Text('작품 판매 등록',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('등록한 작품은 전문가 검수 후 피드에 노출됩니다. 판매 수수료 8%',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 20),
          _ImageUploadBox(onTap: () => _showMessage('이미지 업로드는 준비 중입니다')),
          const SizedBox(height: 16),
          _LabeledField(
            label: '작품명 *',
            child: TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('작품명을 입력해주세요'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '작품명은 필수입니다' : null,
            ),
          ),
          _LabeledField(
            label: '작품 설명',
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _inputDecoration('작품의 이야기와 제작 배경을 소개해주세요'),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: '재료',
                  child: TextFormField(
                    controller: _mediumController,
                    decoration: _inputDecoration('예: 캔버스에 유화'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledField(
                  label: '크기',
                  child: TextFormField(
                    controller: _sizeController,
                    decoration: _inputDecoration('예: 53.0 x 45.5cm'),
                  ),
                ),
              ),
            ],
          ),
          _LabeledField(
            label: '제작 연도',
            child: TextFormField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('예: 2026'),
            ),
          ),
          _LabeledField(
            label: '즉시 판매가 (원) *',
            child: TextFormField(
              controller: _buyNowController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('예: 300000'),
              validator: (value) {
                final price = int.tryParse(value ?? '');
                if (price == null || price <= 0) return '즉시 판매가를 입력해주세요';
                return null;
              },
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('경매로도 판매하기', style: TextStyle(fontSize: 14)),
            subtitle: const Text('최저가부터 입찰을 받아 더 높은 가격에 판매될 수 있어요',
                style: TextStyle(fontSize: 11)),
            value: _auctionEnabled,
            onChanged: (value) => setState(() => _auctionEnabled = value),
          ),
          if (_auctionEnabled) ...[
            _LabeledField(
              label: '경매 최저가 (원) *',
              child: TextFormField(
                controller: _auctionStartController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration('즉시 판매가보다 낮게 설정해주세요'),
                validator: (value) {
                  if (!_auctionEnabled) return null;
                  final start = int.tryParse(value ?? '');
                  if (start == null || start <= 0) return '경매 최저가를 입력해주세요';
                  final buyNow = int.tryParse(_buyNowController.text);
                  if (buyNow != null && start > buyNow) {
                    return '경매 최저가는 즉시 판매가보다 높을 수 없습니다';
                  }
                  return null;
                },
              ),
            ),
            _LabeledField(
              label: '경매 마감일 *',
              child: OutlinedButton.icon(
                onPressed: _pickEndDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(
                  _auctionEndDate == null
                      ? '마감일 선택'
                      : _auctionEndDate!.toIso8601String().substring(0, 10),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1F2937),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(_submitting ? '등록 중...' : '판매 등록하기'),
          ),
          if (_sales.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text('내 판매 작품',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._sales.map((sale) => _SaleCard(sale: sale)),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      isDense: true,
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _ImageUploadBox extends StatelessWidget {
  const _ImageUploadBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 32, color: Color(0xFF9CA3AF)),
            SizedBox(height: 8),
            Text('작품 사진 등록 (최대 5장)',
                style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale});

  final Sale sale;

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
                Text(sale.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  sale.auctionEnabled
                      ? '즉시 ₩${sale.buyNowPrice} · 경매 시작가 ₩${sale.auctionStartPrice} · ~${sale.auctionEndDate}'
                      : '즉시 ₩${sale.buyNowPrice}',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(sale.status, style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
