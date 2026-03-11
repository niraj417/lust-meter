import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HelpFAQScreen extends StatelessWidget {
  const HelpFAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            'What is LustMeter?',
            'LustMeter is a fun application designed for couples to strengthen their bond through games, challenges, and exploring their common interests.',
          ),
          _buildFAQItem(
            'Is my data safe?',
            'Yes, we use industry-standard encryption to protect your data. Your private interactions with your partner are only accessible to the two of you.',
          ),
          _buildFAQItem(
            'How do I connect with my partner?',
            'Go to your profile, tap on "Invite Partner," and share your unique invite code. Once your partner enters the code, you will be connected!',
          ),
          _buildFAQItem(
            'What are Kinks and Challenges?',
            'Kinks are specific interests you can explore together, and Challenges are fun activities you can try to spice things up. You can like them, mark them as "tried," and leave comments!',
          ),
          _buildFAQItem(
            'How do I earn points?',
            'You earn points by completing challenges and interacting with your partner through the app. These points reflect your shared activities and spice level.',
          ),
          _buildFAQItem(
            'Can I use the app anonymously?',
            'While you need an account to save progress, we encourage using a fun nickname or stage name for your display name to maintain privacy.',
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.email_outlined, color: AppColors.primary, size: 40),
                const SizedBox(height: 16),
                const Text(
                  'Need more help?',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Our support team is always here for you.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Contact Support'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      iconColor: AppColors.primary,
      collapsedIconColor: Colors.white54,
      children: [
        Text(
          answer,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}
