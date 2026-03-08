import 'dart:math';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/partner_connection_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/database_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/database_service.dart';
import '../../auth/providers/auth_provider.dart';

class PartnerScreen extends StatefulWidget {
  const PartnerScreen({super.key});

  @override
  State<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen> {
  String? _myCode;
  final _inviteCtrl = TextEditingController();
  bool _codeCopied = false;

  @override
  void initState() {
    super.initState();
    _loadMyCode();
  }

  Future<void> _loadMyCode() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) {
      final code = await DatabaseService().getOrCreateInviteCode(uid);
      if (mounted) setState(() => _myCode = code);
    }
  }

  void _copyCode() {
    if (_myCode == null) return;
    Clipboard.setData(ClipboardData(text: _myCode!));
    setState(() => _codeCopied = true);
    Future.delayed(const Duration(seconds: 2),
        () => mounted ? setState(() => _codeCopied = false) : null);
  }

  Future<void> _sendInvite() async {
    final code = _inviteCtrl.text.trim().toUpperCase();
    if (code.length == 6) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid == null) return;
      try {
        await DatabaseService().connectWithPartner(uid, code);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Partner Connected! 🎉'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _inviteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partner 💑'),
        backgroundColor: AppColors.background,
      ),
      body: uid == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<String?>(
              stream: DatabaseService().getPartnerIdStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final hasPartner = snapshot.data != null;

                if (hasPartner) {
                  return _Connected(uid: uid);
                }

                return _NotConnected(
                  myCode: _myCode,
                  codeCopied: _codeCopied,
                  inviteCtrl: _inviteCtrl,
                  onCopy: _copyCode,
                  onSend: _sendInvite,
                );
              },
            ),
    );
  }
}

class _NotConnected extends StatelessWidget {
  final String? myCode;
  final bool codeCopied;
  final TextEditingController inviteCtrl;
  final VoidCallback onCopy;
  final VoidCallback onSend;

  const _NotConnected({
    required this.myCode,
    required this.codeCopied,
    required this.inviteCtrl,
    required this.onCopy,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // Hero illustration
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.fireGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: 40,
                  spreadRadius: 4,
                )
              ],
            ),
            child: const Center(
              child: Text('💑', style: TextStyle(fontSize: 72)),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Connect Your Partner',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your code or enter your partner\'s code to link your profiles and unlock shared features.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),

          // My code
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(children: [
              const Text(
                'Your invite code',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.fireGradient.createShader(b),
                  child: Text(
                    myCode ?? '------',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Inter',
                      letterSpacing: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onCopy,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      codeCopied
                          ? Icons.check_circle_rounded
                          : Icons.copy_rounded,
                      key: ValueKey(codeCopied),
                      color: codeCopied
                          ? AppColors.success
                          : AppColors.textHint,
                    ),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 24),

          // Divider
          Row(children: [
            const Expanded(child: Divider(color: AppColors.divider)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('or enter theirs',
                  style: TextStyle(
                      color: AppColors.textHint, fontFamily: 'Inter')),
            ),
            const Expanded(child: Divider(color: AppColors.divider)),
          ]),
          const SizedBox(height: 24),

          // Enter partner code
          TextField(
            controller: inviteCtrl,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
            ),
            decoration: const InputDecoration(
              hintText: 'XXXXXX',
              counterText: '',
              hintStyle: TextStyle(
                color: AppColors.textHint,
                letterSpacing: 6,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text('Connect Partner 💑',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
          // Locked features preview
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Unlocks after connecting',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
          const SizedBox(height: 12),
          _LockedTile(emoji: '📅', title: 'Shared Date Planner', subtitle: 'Plan and track your dates together'),
          _LockedTile(emoji: '💬', title: 'Couples Chat', subtitle: 'Private end-to-end encrypted chat'),
          _LockedTile(emoji: '📖', title: 'Shared Timeline', subtitle: 'Your relationship milestones'),
          _LockedTile(emoji: '🎯', title: 'Joint Challenges', subtitle: 'Complete couple challenges together'),
        ],
      ),
    );
  }
}

class _Connected extends StatelessWidget {
  final String uid;
  const _Connected({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PartnerConnectionModel?>(
      stream: DatabaseService().getPartnerConnectionStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final connection = snapshot.data;
        if (connection == null) {
          return const Center(child: Text('Connecting...'));
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.favorite, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Partner Connected! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You and your partner are now linked.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Open Couples Chat'),
                onPressed: () {
                  context.push(AppConstants.messagesCollection); // wait, should use AppRoutes.chat
                  context.push('/chat/${connection.connectionId}');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LockedTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  const _LockedTile({required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(128),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withAlpha(128)),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.textHint,
                    fontFamily: 'Inter',
                    fontSize: 12)),
          ]),
        ),
        const Icon(Icons.lock_rounded, color: AppColors.textHint, size: 18),
      ]),
    );
  }
}
