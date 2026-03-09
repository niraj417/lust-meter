import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Lust Meter')),
      body: const Center(
        child: Text('About Lust Meter coming soon.', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
