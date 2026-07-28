import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/appointment.dart';
import '../providers/locale_provider.dart';
import 'appointment_detail_dialog.dart';

/// 홈 화면의 날짜 선택 영역.
/// "날짜 선택" 월 달력을 제공하며, 오늘 이후 날짜를 탭하면 해당 날짜의
/// 약속 상세 정보 팝업을 띄운다.
/// 현재는 백엔드 연동 없이 위젯 내부 로컬 상태만 유지한다.
class DateSelector extends StatefulWidget {
  const DateSelector({super.key});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  /// 현재 표시 중인 달(1일 기준).
  late DateTime _displayedMonth;

  /// 오늘(시각 제거) — 과거 날짜 비활성 판정 기준.
  late final DateTime _today;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _displayedMonth = DateTime(now.year, now.month);
  }

  bool _isDateEnabled(DateTime date) {
    return !date.isBefore(_today);
  }

  void _onDateTap(DateTime date) {
    // 약속이 있는 날짜만 상세 팝업을 띄운다.
    final appointment = appointmentOn(date);
    if (appointment == null) return;
    showDialog<void>(
      context: context,
      builder: (_) => AppointmentDetailDialog(appointment: appointment),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
      );
    });
  }

  /// 로케일별 달력 헤더("2026년 4월" / "April 2026" 등).
  String _calendarHeader(AppLanguage lang) {
    final y = _displayedMonth.year;
    final m = _displayedMonth.month;
    switch (lang) {
      case AppLanguage.en:
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        return '${months[m - 1]} $y';
      case AppLanguage.ja:
      case AppLanguage.zh:
        return '$y年$m月';
      case AppLanguage.ko:
        return '$y년 $m월';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final weekdayLabels = locale.tr(AppStrings.homeWeekdayShort).split(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── 날짜 선택 ───
        _sectionLabel(locale.tr(AppStrings.homeDateLabel)),
        const SizedBox(height: 12),
        _buildCalendar(locale, weekdayLabels),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.gowunDodum(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildCalendar(LocaleProvider locale, List<String> weekdayLabels) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: Column(
        children: [
          // 헤더: ‹ 2026년 4월 ›
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _arrowButton(Icons.chevron_left_rounded, () => _changeMonth(-1)),
              Text(
                _calendarHeader(locale.currentLanguage),
                style: GoogleFonts.gowunDodum(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              _arrowButton(Icons.chevron_right_rounded, () => _changeMonth(1)),
            ],
          ),
          const SizedBox(height: 12),
          // 요일 헤더 행
          Row(
            children: List.generate(7, (column) {
              return Expanded(
                child: Center(
                  child: Text(
                    weekdayLabels[column],
                    style: GoogleFonts.gowunDodum(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // 날짜 그리드
          ..._buildDateRows(),
        ],
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 24, color: AppColors.darkGrey),
        ),
      ),
    );
  }

  List<Widget> _buildDateRows() {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final firstDay = DateTime(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // 1일 앞에 들어갈 빈 칸 수(일요일 시작 기준): 일=0 … 토=6
    final leadingBlanks = firstDay.weekday % 7;

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const Expanded(child: SizedBox()));
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(Expanded(child: _buildDateCell(DateTime(year, month, day))));
    }
    // 마지막 행을 7칸으로 채우기
    while (cells.length % 7 != 0) {
      cells.add(const Expanded(child: SizedBox()));
    }

    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 7) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: cells.sublist(i, i + 7)),
        ),
      );
    }
    return rows;
  }

  Widget _buildDateCell(DateTime date) {
    final enabled = _isDateEnabled(date);
    final isToday = date == _today;
    // 활성 날짜 중 약속이 있으면 색칠하고 매칭된 외국인 이름을 표시한다.
    final appointment = enabled ? appointmentOn(date) : null;
    final hasAppointment = appointment != null;

    return GestureDetector(
      // 약속이 있는 날짜만 탭 가능(상세 팝업).
      onTap: hasAppointment ? () => _onDateTap(date) : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hasAppointment ? AppColors.accent : AppColors.offWhite,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: !enabled
            // 비활성(과거) 날짜: 빗금 아이콘으로 표시
            ? const Icon(
                Icons.block_rounded,
                size: 16,
                color: AppColors.lightGrey,
              )
            : hasAppointment
            // 약속이 있는 날짜: 날짜 + 매칭된 외국인 이름
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: GoogleFonts.gowunDodum(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      appointment.mateName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              )
            // 약속 없는 활성 날짜: 날짜만
            : Text(
                '${date.day}',
                style: GoogleFonts.gowunDodum(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
              ),
      ),
    );
  }
}
