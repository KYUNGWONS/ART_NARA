import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/chat_message.dart';
import '../models/user_location.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket URL 설정
/// - Echo 서버: 테스트용 (내가 보낸 메시지가 그대로 돌아옴)
/// - 로컬 서버: server/ 폴더의 Node.js 서버 실행 후 사용
///   - iOS 시뮬레이터: ws://localhost:8080
///   - Android 에뮬레이터: ws://10.0.2.2:8080
/// TODO: 백엔드 준비 후 실제 채팅 서버 URL로 교체
//const String kWebSocketUrl = 'wss://echo.websocket.org';
const String kWebSocketUrl = 'ws://localhost:8080'; // 로컬 테스트 서버

class ChatScreen extends StatefulWidget {
  final UserLocation mate;

  const ChatScreen({super.key, required this.mate});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  String? _errorMessage;

  /// 브로드캐스트 서버에서 내가 보낸 메시지가 다시 돌아오는 경우 중복 표시 방지
  String? _lastSentText;
  DateTime? _lastSentTime;
  static const Duration _sentEchoThreshold = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    setState(() {
      _errorMessage = null;
      _isConnected = false;
    });
    try {
      final uri = Uri.parse(kWebSocketUrl);
      _channel = WebSocketChannel.connect(uri);
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          if (mounted) {
            setState(() {
              _errorMessage = e.toString();
              _isConnected = false;
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() => _isConnected = false);
          }
        },
        cancelOnError: false,
      );
      setState(() => _isConnected = true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isConnected = false;
      });
    }
  }

  void _onMessage(dynamic data) {
    if (!mounted) return;
    final text = data is String ? data : data.toString();
    // 브로드캐스트 서버가 발신자에게도 보내므로, 방금 내가 보낸 메시지가 돌아오면 중복 추가하지 않음
    if (_lastSentText != null &&
        _lastSentTime != null &&
        text == _lastSentText &&
        DateTime.now().difference(_lastSentTime!) < _sentEchoThreshold) {
      _lastSentText = null;
      _lastSentTime = null;
      return;
    }
    setState(() {
      _messages.add(ChatMessage(text: text, isMe: false));
    });
    _scrollToBottom();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _channel == null) return;

    _textController.clear();
    _lastSentText = text;
    _lastSentTime = DateTime.now();
    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true));
    });
    _channel!.sink.add(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 플러스 버튼: 첨부 메뉴 (약속 신청 등)
  void _showAttachmentMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.event_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      '약속 신청',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    subtitle: Text(
                      '날짜·시간·비용을 정해 채팅에 보내기',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showPromiseRequestSheet();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 약속 신청 시트: 날짜, 시간, 비용 입력 후 채팅에 자동 입력
  void _showPromiseRequestSheet() {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final costController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '약속 신청',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      title: Text(
                        '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                        style: GoogleFonts.gowunDodum(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      title: Text(
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.gowunDodum(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setSheetState(() => selectedTime = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: costController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.payments_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        hintText: '비용 (원)',
                        hintStyle: GoogleFonts.gowunDodum(
                          fontSize: 15,
                          color: AppColors.grey,
                        ),
                        filled: true,
                        fillColor: AppColors.offWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: GoogleFonts.gowunDodum(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final cost = costController.text.trim();
                          final costStr = cost.isEmpty
                              ? '미정'
                              : '${int.tryParse(cost) ?? 0}원';
                          final text =
                              '[약속 신청]\n'
                              '날짜: ${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일\n'
                              '시간: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}\n'
                              '비용: $costStr';
                          Navigator.pop(context);
                          _sendPromiseMessage(text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          '채팅에 입력하기',
                          style: GoogleFonts.gowunDodum(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => costController.dispose());
  }

  void _sendPromiseMessage(String text) {
    if (text.isEmpty || _channel == null) return;
    _lastSentText = text;
    _lastSentTime = DateTime.now();
    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true));
    });
    _channel!.sink.add(text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _channel?.sink.close();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.black,
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: widget.mate.profileImageUrl != null
                  ? NetworkImage(widget.mate.profileImageUrl!)
                  : null,
              child: widget.mate.profileImageUrl == null
                  ? Text(
                      widget.mate.nickname.isNotEmpty
                          ? widget.mate.nickname[0]
                          : '?',
                      style: GoogleFonts.gowunDodum(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.mate.nickname,
                    style: GoogleFonts.gowunDodum(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  if (_isConnected)
                    Text(
                      '연결됨',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mint,
                      ),
                    )
                  else if (_errorMessage != null)
                    Text(
                      '연결 실패',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.accent.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 12,
                        color: AppColors.accent,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: _connect,
                    child: Text(
                      '재연결',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isMe ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                        bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: msg.isMe ? AppColors.white : AppColors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: _showAttachmentMenu,
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요',
                        hintStyle: GoogleFonts.gowunDodum(
                          fontSize: 15,
                          color: AppColors.grey,
                        ),
                        filled: true,
                        fillColor: AppColors.offWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      style: GoogleFonts.gowunDodum(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    child: IconButton(
                      onPressed: _isConnected ? _sendMessage : null,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
