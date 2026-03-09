import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/message_model.dart';
import '../../../services/database_service.dart';
import '../../auth/providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String connectionId;
  const ChatScreen({super.key, required this.connectionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  
  // _messageType is inferred from imageUrl
  int _timerSeconds = 0; // 0 means no timer
  bool _isProtected = false;
  bool _isSending = false;

  final Set<String> _revealedMessages = {};

  Future<void> _sendMessage({String? text, String? imageUrl}) async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;

    final msgText = text ?? _messageController.text.trim();
    if (msgText.isEmpty && imageUrl == null) return;

    setState(() => _isSending = true);

    DateTime? expiresAt;
    if (_timerSeconds > 0) {
      expiresAt = DateTime.now().add(Duration(seconds: _timerSeconds));
    }

    final msg = MessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: uid,
      text: msgText,
      timestamp: DateTime.now(),
      isRead: false,
      type: imageUrl != null ? 'image' : 'text',
      imageUrl: imageUrl,
      expiresAt: expiresAt,
      isProtected: _isProtected,
    );

    if (imageUrl == null) {
      _messageController.clear();
    }
    
    await DatabaseService().sendMessage(widget.connectionId, msg);
    
    setState(() {
      _isSending = false;
      // Reset modes after sending? Maybe keep them for next message if user wants.
      // Let's reset for now to prevent accidental "secret" messages.
      _timerSeconds = 0;
      _isProtected = false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isSending = true);
    
    try {
      final url = await DatabaseService().uploadChatImage(widget.connectionId, File(image.path));
      await _sendMessage(imageUrl: url, text: 'Sent an image');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                    'Message Settings',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Timer Section
                  const Text('Self-Destruct Timer', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _timerOption(0, 'None', setModalState),
                      _timerOption(10, '10s', setModalState),
                      _timerOption(30, '30s', setModalState),
                      _timerOption(60, '1m', setModalState),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Protection Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Screen Protection', style: TextStyle(color: Colors.white, fontSize: 16)),
                          Text('Blur message until tapped', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                      Switch(
                        value: _isProtected,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          setModalState(() => _isProtected = val);
                          setState(() => _isProtected = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _timerOption(int seconds, String label, StateSetter setModalState) {
    final isSelected = _timerSeconds == seconds;
    return GestureDetector(
      onTap: () {
        setModalState(() => _timerSeconds = seconds);
        setState(() => _timerSeconds = seconds);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().user?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Couples Chat'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: Icon(
              _timerSeconds > 0 ? Icons.timer : Icons.timer_outlined,
              color: _timerSeconds > 0 ? AppColors.primary : Colors.white,
            ),
            onPressed: _showTypeSelector,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: DatabaseService().getMessagesStream(widget.connectionId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nStart the conversation 💬',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;

                    // Check expiration
                    if (msg.expiresAt != null && DateTime.now().isAfter(msg.expiresAt!)) {
                      return const SizedBox.shrink(); // Hide expired messages
                    }

                    return _MessageBubble(
                      message: msg,
                      isMe: isMe,
                      isRevealed: _revealedMessages.contains(msg.messageId),
                      onReveal: () {
                        setState(() => _revealedMessages.add(msg.messageId));
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (_isSending)
             const LinearProgressIndicator(backgroundColor: Colors.transparent, color: AppColors.primary),
          
          // Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              children: [
                if (_timerSeconds > 0 || _isProtected)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        if (_timerSeconds > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text('${_timerSeconds}s', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        if (_isProtected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.remove_red_eye, size: 14, color: Colors.orange),
                                SizedBox(width: 4),
                                Text('Protected', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() {
                            _timerSeconds = 0;
                            _isProtected = false;
                          }),
                          child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                      onPressed: _pickImage,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: const TextStyle(color: AppColors.textHint),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 24,
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool isRevealed;
  final VoidCallback onReveal;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.isRevealed,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    final needsReveal = message.isProtected && !isRevealed && !isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: needsReveal ? onReveal : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 4, top: 4),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: message.type == 'image' ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.type == 'image' && message.imageUrl != null)
                            Image.network(
                              message.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white24),
                            ),
                          if (message.text.isNotEmpty && (message.type != 'image' || !isMe))
                             Padding(
                               padding: message.type == 'image' ? const EdgeInsets.all(12) : EdgeInsets.zero,
                               child: Text(
                                message.text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : AppColors.textPrimary,
                                  fontSize: 15,
                                ),
                            ),
                             ),
                        ],
                      ),
                    ),
                    if (needsReveal)
                      Positioned.fill(
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_outline, color: Colors.white, size: 24),
                                    SizedBox(height: 4),
                                    Text('Tap to Reveal', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (message.expiresAt != null)
             _TimerBadge(expiresAt: message.expiresAt!),
        ],
      ),
    );
  }
}

class _TimerBadge extends StatefulWidget {
  final DateTime expiresAt;
  const _TimerBadge({required this.expiresAt});

  @override
  State<_TimerBadge> createState() => _TimerBadgeState();
}

class _TimerBadgeState extends State<_TimerBadge> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.expiresAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeLeft = widget.expiresAt.difference(DateTime.now());
          if (_timeLeft.isNegative) {
            _timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            'Expires in ${_timeLeft.inSeconds}s',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
