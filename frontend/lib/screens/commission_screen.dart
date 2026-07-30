import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/commission.dart';
import '../services/commission_api_service.dart';

const _categories = ['회화', '일러스트', '조소', '공예', '디지털 아트'];

class CommissionScreen extends StatefulWidget {
  const CommissionScreen({super.key});

  @override
  State<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends State<CommissionScreen> {
  final _api = const CommissionApiService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  String _category = _categories.first;
  DateTime? _desiredDate;
  bool _submitting = false;
  List<Commission> _commissions = const [];

  @override
  void initState() {
    super.initState();
    _loadCommissions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadCommissions() async {
    try {
      final commissions = await _api.fetchCommissions();
      if (mounted) setState(() => _commissions = commissions);
    } catch (_) {
      // 목록 조회 실패는 등록 폼 사용을 막지 않는다.
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final created = await _api.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        budget: int.parse(_budgetController.text),
        desiredDate: _desiredDate?.toIso8601String().substring(0, 10),
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _budgetController.clear();
      setState(() {
        _category = _categories.first;
        _desiredDate = null;
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
          const Text('제작 의뢰',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('원하는 작품을 설명하면 카테고리 매칭 작가 전원에게 알림이 발송되고,\n최저가 역경매로 작가가 정해집니다.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 20),
          _ReferenceImageBox(onTap: () => _showMessage('참고 이미지 업로드는 준비 중입니다')),
          const SizedBox(height: 16),
          _LabeledField(
            label: '의뢰 제목 *',
            child: TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('예: 거실에 걸 바다 풍경화 의뢰'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '의뢰 제목은 필수입니다' : null,
            ),
          ),
          _LabeledField(
            label: '미술품 카테고리 *',
            child: DropdownButtonFormField<String>(
              initialValue: _category,
              items: _categories
                  .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _category = value ?? _categories.first),
              decoration: _inputDecoration(''),
            ),
          ),
          _LabeledField(
            label: '요청사항',
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _inputDecoration('크기, 색감, 분위기 등 원하는 내용을 자세히 적어주세요'),
            ),
          ),
          _LabeledField(
            label: '예산 (원) *',
            child: TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('예: 500000'),
              validator: (value) {
                final budget = int.tryParse(value ?? '');
                if (budget == null || budget <= 0) return '예산을 입력해주세요';
                return null;
              },
            ),
          ),
          _LabeledField(
            label: '희망 완성일',
            child: OutlinedButton.icon(
              onPressed: _pickDesiredDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text(
                _desiredDate == null
                    ? '날짜 선택 (선택 사항)'
                    : _desiredDate!.toIso8601String().substring(0, 10),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
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
            child: Text(_submitting ? '등록 중...' : '제작 의뢰 등록하기'),
          ),
          if (_commissions.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text('내 의뢰 현황',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._commissions.map((commission) =>
                _CommissionCard(commission: commission)),
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

class _ReferenceImageBox extends StatelessWidget {
  const _ReferenceImageBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
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
            Icon(Icons.image_outlined, size: 32, color: Color(0xFF9CA3AF)),
            SizedBox(height: 8),
            Text('참고 이미지 등록',
                style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

class _CommissionCard extends StatelessWidget {
  const _CommissionCard({required this.commission});

  final Commission commission;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(commission.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(commission.status,
                    style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${commission.category} · 예산 ₩${commission.budget}'
            '${commission.desiredDate != null ? ' · 희망일 ${commission.desiredDate}' : ''}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 4),
          Text(
            '작가 ${commission.notifiedArtistCount}명에게 알림 발송'
            '${commission.lowestOffer != null ? ' · 현재 최저 제안 ₩${commission.lowestOffer}' : ''}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          if (commission.offers.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 8),
            ...commission.offers.map(
              (offer) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${offer.artistName} · ${offer.message}',
                        style: const TextStyle(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('₩${offer.amount}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(offer.offerTime,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
