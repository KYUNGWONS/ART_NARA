import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../constants/api_config.dart';
import '../constants/dust_tokens.dart';
import '../models/chat_message.dart';
import '../services/auth_api_service.dart';
import '../services/chat_api_service.dart';

/// 백엔드 STOMP 엔드포인트. REST 베이스 URL(http/https)을 ws/wss 로 바꿔 쓴다.
String get chatWebSocketUrl =>
    '${apiBaseUrl.replaceFirst(RegExp(r'^http'), 'ws')}/ws';

/// 작품 문의 채팅 상세 화면.
///
/// - 이전 대화: GET /api/chat/rooms/{roomId}/messages
/// - 실시간 수신: STOMP 구독 /topic/chat/{roomId}
/// - 전송: STOMP /app/chat/send  {roomId, senderId, content, messageType}
class ChatScreen extends StatefulWidget {
  final String roomId;
  final String partnerNickname;
  final String? partnerProfileImageUrl;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.partnerNickname,
    this.partnerProfileImageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 약속 시트용. 시트를 닫자마자 dispose 하면 리빌드 중 참조될 수 있어 State 가 소유한다.
  final TextEditingController _placeController = TextEditingController();

  StompClient? _client;
  bool _connected = false;
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _connect();
  }

  Future<void> _loadHistory() async {
    final history = await ChatApiService.getMessages(widget.roomId);
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(history);
      _loadingHistory = false;
    });
    _scrollToBottom();
  }

  void _connect() {
    _client = StompClient(
      config: StompConfig(
        url: chatWebSocketUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic e) {
          debugPrint('[Chat] WebSocket 오류: $e');
          if (mounted) setState(() => _connected = false);
        },
        onDisconnect: (_) {
          if (mounted) setState(() => _connected = false);
        },
        reconnectDelay: const Duration(seconds: 3),
      ),
    )..activate();
  }

  void _onConnect(StompFrame frame) {
    debugPrint('[Chat] STOMP 연결됨 → /topic/chat/${widget.roomId} 구독');
    if (mounted) setState(() => _connected = true);
    _markAsRead();
    _client?.subscribe(
      destination: '/topic/chat/${widget.roomId}',
      callback: (StompFrame f) {
        if (f.body == null) return;
        final json = jsonDecode(f.body!) as Map<String, dynamic>;
        final message = ChatMessage.fromJson(json, AuthApiService.userId);
        if (!mounted) return;
        setState(() => _messages.add(message));
        _scrollToBottom();
        if (!message.isMe) _markAsRead();
      },
    );
  }

  /// 방에 들어와 있는 동안은 상대 메시지를 읽은 것으로 처리한다.
  void _markAsRead() {
    final userId = AuthApiService.userId;
    if (userId == null) return;
    _client?.send(
      destination: '/app/chat/read/${widget.roomId}',
      body: jsonEncode({'userId': userId}),
    );
  }

  void _send(String text, {String messageType = 'TEXT'}) {
    final content = text.trim();
    if (content.isEmpty) return;
    final senderId = AuthApiService.userId;
    if (senderId == null) {
      _showSnack('로그인 정보가 없어 메시지를 보낼 수 없어요');
      return;
    }
    if (!_connected) {
      _showSnack('채팅 서버에 연결 중이에요. 잠시 후 다시 시도해주세요');
      return;
    }

    // 서버가 /topic 으로 되돌려주는 메시지로 목록이 채워지므로 여기서 직접 추가하지 않는다.
    _client?.send(
      destination: '/app/chat/send',
      body: jsonEncode({
        'roomId': int.tryParse(widget.roomId),
        'senderId': senderId,
        'content': content,
        'messageType': messageType,
      }),
    );
    _textController.clear();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

  /// 첨부 메뉴 — 작품 실물을 보기 위한 약속 잡기
  void _showAttachmentMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: DustColors.bgSurface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(DustRadius.lg)),
        ),
        child: SafeArea(
          top: false,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: DustSpacing.lg, vertical: DustSpacing.xs),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DustColors.bgInfo,
                borderRadius: BorderRadius.circular(DustRadius.md),
              ),
              child: const Icon(Icons.event_rounded,
                  color: DustColors.brandPrimary, size: 24),
            ),
            title: Text(
              '작품 보기 약속',
              style: DustText.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              '작업실·전시 등 실물을 볼 장소와 시간을 정해 보내기',
              style: DustText.caption,
            ),
            onTap: () {
              Navigator.pop(context);
              _showAppointmentSheet();
            },
          ),
        ),
      ),
    );
  }

  /// 약속 시트: 날짜·시간·장소를 정해 채팅으로 보낸다.
  void _showAppointmentSheet() {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    _placeController.clear();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
              DustSpacing.lg,
              DustSpacing.lg,
              DustSpacing.lg,
              DustSpacing.lg + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(
            color: DustColors.bgSurface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(DustRadius.lg)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '작품 보기 약속',
                  style: DustText.body
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: DustSpacing.lg),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded,
                      color: DustColors.brandPrimary, size: 22),
                  title: Text(
                    '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                    style: DustText.body.copyWith(fontSize: 15),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setSheetState(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time_rounded,
                      color: DustColors.brandPrimary, size: 22),
                  title: Text(
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    style: DustText.body.copyWith(fontSize: 15),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                        context: context, initialTime: selectedTime);
                    if (picked != null) {
                      setSheetState(() => selectedTime = picked);
                    }
                  },
                ),
                const SizedBox(height: DustSpacing.xs),
                TextField(
                  controller: _placeController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.place_outlined,
                        color: DustColors.brandPrimary, size: 22),
                    hintText: '장소 (예: 서촌 작업실)',
                    hintStyle: DustText.body.copyWith(
                        fontSize: 15, color: DustColors.textSecondary),
                    filled: true,
                    fillColor: DustColors.bgSubtle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DustRadius.md),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: DustSpacing.md, vertical: 14),
                  ),
                  style: DustText.body.copyWith(fontSize: 15),
                ),
                const SizedBox(height: DustSpacing.lg),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      final place = _placeController.text.trim();
                      final text = '[작품 보기 약속]\n'
                          '날짜: ${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일\n'
                          '시간: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}\n'
                          '장소: ${place.isEmpty ? '미정' : place}';
                      Navigator.pop(context);
                      _send(text, messageType: 'APPOINTMENT');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: DustColors.brandPrimary,
                      foregroundColor: DustColors.textOnBrand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DustRadius.md),
                      ),
                    ),
                    child: const Text('채팅으로 보내기',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _client?.deactivate();
    _textController.dispose();
    _placeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DustColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: DustColors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: DustColors.textPrimary,
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: DustColors.bgSubtle,
              backgroundImage: widget.partnerProfileImageUrl != null
                  ? NetworkImage(widget.partnerProfileImageUrl!)
                  : null,
              child: widget.partnerProfileImageUrl == null
                  ? Text(
                      widget.partnerNickname.isNotEmpty
                          ? widget.partnerNickname[0]
                          : '?',
                      style: DustText.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: DustColors.brandPrimary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: DustSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.partnerNickname,
                    style: DustText.body.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _connected ? '실시간 연결됨' : '연결 중…',
                    style: DustText.caption.copyWith(
                      color: _connected
                          ? DustColors.brandPrimary
                          : DustColors.textSecondary,
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
          Expanded(
            child: _loadingHistory
                ? const Center(
                    child: CircularProgressIndicator(
                        color: DustColors.brandPrimary),
                  )
                : _messages.isEmpty
                ? const Center(
                    child: Text(
                      '작품에 대해 궁금한 점을 물어보세요',
                      style: DustText.caption,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(DustSpacing.md,
                        DustSpacing.md, DustSpacing.md, DustSpacing.xs),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: _messages[index]),
                  ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      decoration: const BoxDecoration(
        color: DustColors.bgSurface,
        border: Border(top: BorderSide(color: DustColors.borderSoft)),
      ),
      padding: const EdgeInsets.fromLTRB(
          DustSpacing.md, DustSpacing.sm, DustSpacing.md, DustSpacing.sm),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: _showAttachmentMenu,
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: DustColors.brandPrimary, size: 28),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요',
                  hintStyle: DustText.body.copyWith(
                      fontSize: 15, color: DustColors.textSecondary),
                  filled: true,
                  fillColor: DustColors.bgSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DustRadius.full),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: DustSpacing.sm),
                ),
                style: DustText.body.copyWith(fontSize: 15),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (value) => _send(value),
              ),
            ),
            const SizedBox(width: DustSpacing.xs),
            Material(
              color:
                  _connected ? DustColors.brandPrimary : DustColors.borderSoft,
              borderRadius: BorderRadius.circular(DustRadius.full),
              child: IconButton(
                onPressed: () => _send(_textController.text),
                icon: const Icon(Icons.send_rounded,
                    color: DustColors.textOnBrand, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  String get _time {
    final h = message.sentAt.hour;
    final ampm = h >= 12 ? '오후' : '오전';
    final hh = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$ampm $hh:${message.sentAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final isAppointment = message.messageType == 'APPOINTMENT';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: DustSpacing.sm),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isAppointment
                  ? DustColors.bgInfo
                  : (isMe ? DustColors.brandPrimary : DustColors.bgSurface),
              border: isMe && !isAppointment
                  ? null
                  : Border.all(color: DustColors.borderSoft),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(DustRadius.md),
                topRight: const Radius.circular(DustRadius.md),
                bottomLeft: Radius.circular(isMe ? DustRadius.md : 4),
                bottomRight: Radius.circular(isMe ? 4 : DustRadius.md),
              ),
            ),
            child: Text(
              message.text,
              style: DustText.body.copyWith(
                fontSize: 15,
                color: isMe && !isAppointment
                    ? DustColors.textOnBrand
                    : DustColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: DustSpacing.xs),
            child: Text(_time, style: DustText.caption.copyWith(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
