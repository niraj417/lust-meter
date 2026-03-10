import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Play 🎮'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _GameCard(
            emoji: '🍾',
            title: 'Truth or Dare',
            subtitle: 'Spin the bottle and face daring challenges',
            gradient: AppColors.primaryGradient,
            onTap: () => context.push(AppRoutes.truthOrDare),
          ),
          const SizedBox(height: 16),
          _GameCard(
            emoji: '🃏',
            title: 'Fantasy Cards',
            subtitle: 'Swipe through your deepest desires',
            gradient: AppColors.purpleGradient,
            onTap: () => context.push(AppRoutes.fantasyCards),
          ),
          const SizedBox(height: 16),
          _GameCard(
            emoji: '🌀',
            title: 'Spin The Wheel',
            subtitle: 'Let fate decide your next adventure',
            gradient: AppColors.fireGradient,
            onTap: () => context.push(AppRoutes.spinWheel),
          ),
          const SizedBox(height: 16),
          _GameCard(
            emoji: '🧠',
            title: 'Compatibility Quiz',
            subtitle: 'Discover how well you know each other',
            gradient: const LinearGradient(
              colors: [Color(0xFF1A6B4A), Color(0xFF30FF9B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => context.push(AppRoutes.compatibilityQuiz),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _GameCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter')),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white70, size: 18),
        ]),
      ),
    );
  }
}
