import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Privacy Matters',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last Updated: March 2026',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildPolicySection(
              '1. Introduction',
              'LustMeter ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
            ),
            _buildPolicySection(
              '2. Information We Collect',
              'We collect information that you provide directly to us, such as your display name, email address, and interaction data within the app. We also collect device information to improve app performance.',
            ),
            _buildPolicySection(
              '3. How We Use Information',
              'The information we collect is used to provide and maintain the service, enhance user experience, and communicate with you about updates and improvements.',
            ),
            _buildPolicySection(
              '4. Data Encryption',
              'Your personal data and interaction history are encrypted both in transit and at rest. We implement robust security measures to prevent unauthorized access.',
            ),
            _buildPolicySection(
              '5. Your Rights',
              'You have the right to access, update, or delete your personal information at any time through the app settings. Feel free to contact our support for any privacy-related concerns.',
            ),
            const SizedBox(height: 48),
            const Center(
              child: Text(
                'By using LustMeter, you agree to the terms of this Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textHint, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
