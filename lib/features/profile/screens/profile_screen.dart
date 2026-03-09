import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final name = user?.displayName ?? 'Mystery Lover';
    final email = user?.email ?? '';
    final photo = user?.photoURL;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with profile header
          SliverAppBar(
            expandedHeight: 240,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A0A14), AppColors.background],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    // Avatar
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withAlpha(80),
                              blurRadius: 20,
                              spreadRadius: 3)
                        ],
                      ),
                      child: photo != null
                          ? ClipOval(child: Image.network(photo, fit: BoxFit.cover))
                          : Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(name,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter')),
                    const SizedBox(height: 4),
                    Text(email,
                        style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 13,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Stats row
                Row(children: [
                  _StatBox(label: 'Lust Score', value: '72', icon: '🔥'),
                  const SizedBox(width: 10),
                  _StatBox(label: 'Streak', value: '5d', icon: '⚡'),
                  const SizedBox(width: 10),
                  _StatBox(label: 'Points', value: '320', icon: '⭐'),
                ]),
                const SizedBox(height: 28),

                // Rewards
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.fireGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 16,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Row(children: [
                    const Text('🏆', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Reward Store',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontFamily: 'Inter', fontSize: 16)),
                        Text('Redeem your points for couple treats',
                            style: TextStyle(color: Colors.white70, fontFamily: 'Inter', fontSize: 12)),
                      ]),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                  ]),
                ),
                const SizedBox(height: 24),

                // Menu items
                const _SectionLabel('Account'),
                const SizedBox(height: 10),
                _MenuItem(icon: Icons.edit_rounded, label: 'Edit Profile', onTap: () => context.push(AppRoutes.editProfile)),
                _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => context.push(AppRoutes.notifications)),
                _MenuItem(icon: Icons.lock_outline_rounded, label: 'Privacy & Security', onTap: () => context.push(AppRoutes.privacyPolicy)),
                const SizedBox(height: 20),
                const _SectionLabel('Support'),
                const SizedBox(height: 10),
                _MenuItem(icon: Icons.help_outline_rounded, label: 'Help & FAQ', onTap: () => context.push(AppRoutes.helpFaq)),
                _MenuItem(icon: Icons.info_outline_rounded, label: 'About Lust Meter', onTap: () => context.push(AppRoutes.about)),
                const SizedBox(height: 24),

                // Sign out
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().signOut();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.error),
                    label: const Text('Sign Out',
                        style: TextStyle(
                            color: AppColors.error,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _StatBox({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                  fontSize: 18)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textHint,
                  fontFamily: 'Inter',
                  fontSize: 11)),
        ]),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          color: AppColors.textHint, size: 14),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(
              color: AppColors.textHint,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.8)),
    );
  }
}
