import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: const Center(
        child: Text('Privacy & Security settings coming soon.', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
