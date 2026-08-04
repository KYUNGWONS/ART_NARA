import 'dart:async';

import 'package:flutter/material.dart';

/// 경매 남은 시간 카운트다운.
///
/// 서버는 remainingTime 을 "D-n"(하루 이상) 또는 "HH:mm:ss"(24시간 미만)로
/// 내려준다. 매초 서버를 두드리는 대신 응답 시점을 기준으로 마감 시각을
/// 역산해 **로컬에서 1초씩** 줄인다(트래픽 0). "D-n" 은 초 단위 표시가
/// 의미 없으므로 서버 표기 그대로 둔다.
///
/// 0에 도달하면 [onExpired] 를 한 번 호출한다 — 화면은 이때 서버를 다시
/// 조회해 마감 상태(낙찰자·입찰 종료)를 반영하면 된다.
class AuctionCountdown extends StatefulWidget {
  const AuctionCountdown(
    this.remainingTime, {
    super.key,
    this.prefix = '',
    this.style,
    this.onExpired,
  });

  /// 서버가 내려준 남은 시간 문자열 ("D-3" | "07:29:31" | null)
  final String? remainingTime;

  /// 앞에 붙일 문구 (예: '남은 시간 ')
  final String prefix;

  final TextStyle? style;

  /// 카운트다운이 00:00:00 에 도달했을 때 한 번 호출.
  final VoidCallback? onExpired;

  @override
  State<AuctionCountdown> createState() => _AuctionCountdownState();
}

class _AuctionCountdownState extends State<AuctionCountdown> {
  static final _hms = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$');

  Timer? _timer;
  Duration? _remaining; // HH:mm:ss 형식일 때만 설정 — 틱마다 1초씩 줄인다
  bool _expiredFired = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(AuctionCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 새로고침으로 서버 값이 갱신되면 남은 시간을 다시 잡는다.
    if (oldWidget.remainingTime != widget.remainingTime) _sync();
  }

  void _sync() {
    _timer?.cancel();
    _timer = null;
    _remaining = null;
    _expiredFired = false;

    final match = _hms.firstMatch(widget.remainingTime ?? '');
    if (match == null) return; // null 또는 "D-n" — 정적 표시
    _remaining = Duration(
      hours: int.parse(match.group(1)!),
      minutes: int.parse(match.group(2)!),
      seconds: int.parse(match.group(3)!),
    );
    if (_remaining! > Duration.zero) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } else {
      _expiredFired = true; // 이미 00:00:00 으로 내려온 경우
    }
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _remaining = _remaining! - const Duration(seconds: 1);
      if (_remaining! <= Duration.zero) {
        _remaining = Duration.zero;
        _timer?.cancel();
        if (!_expiredFired) {
          _expiredFired = true;
          widget.onExpired?.call();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _text {
    final remaining = _remaining;
    if (remaining == null) return widget.remainingTime ?? '';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(remaining.inHours)}:${two(remaining.inMinutes % 60)}:${two(remaining.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.remainingTime == null) return const SizedBox.shrink();
    return Text('${widget.prefix}$_text', style: widget.style);
  }
}
