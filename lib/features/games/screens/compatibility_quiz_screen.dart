import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../../core/theme/app_theme.dart';

class CompatibilityQuizScreen extends StatefulWidget {
  const CompatibilityQuizScreen({super.key});

  @override
  State<CompatibilityQuizScreen> createState() => _CompatibilityQuizScreenState();
}

class _CompatibilityQuizScreenState extends State<CompatibilityQuizScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isLoading = false;
  final Map<int, int> _answers = {};
  
  // Mock questions for now - ideally these could come from Gemini too
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How do you prefer to spend a romantic evening?',
      'options': ['Quiet night in with a movie', 'Fancy dinner and drinks', 'Adventurous outdoor activity', 'A playful game night'],
    },
    {
      'question': 'What is your primary love language?',
      'options': ['Physical Touch', 'Words of Affirmation', 'Acts of Service', 'Quality Time'],
    },
    {
      'question': 'How comfortable are you discussing new fantasies?',
      'options': ['Very comfortable', 'Somewhat comfortable', 'A bit shy at first', 'Prefer the partner to lead'],
    },
    {
      'question': 'Which element characterizes your ideal relationship?',
      'options': ['Stability and trust', 'Passion and excitement', 'Deep intellectual connection', 'Playfulness and humor'],
    },
    {
      'question': 'How important is spontaneous physical intimacy to you?',
      'options': ['Essential', 'Very important', 'Moderately important', 'Not a top priority'],
    },
  ];

  void _nextPage() {
    if (_currentIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _showResults();
    }
  }

  Future<void> _showResults() async {
    setState(() => _isLoading = true);
    
    // Simulate AI analysis
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Weighted random score for demo
    final score = 75 + Random().nextInt(20);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ResultSheet(score: score),
    ).then((_) {
      if (mounted) context.pop();
    });
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Compatibility Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Question ${index + 1} of ${_questions.length}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            q['question'],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Inter',
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ...List.generate(
                            q['options'].length,
                            (optIdx) => _OptionCard(
                              text: q['options'][optIdx],
                              isSelected: _answers[index] == optIdx,
                              onTap: () {
                                setState(() => _answers[index] = optIdx);
                                Future.delayed(const Duration(milliseconds: 300), _nextPage);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 24),
                    const Text(
                      'AI Analyzing Compatibility...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

class _OptionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(30) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}

class _ResultSheet extends StatelessWidget {
  final int score;

  const _ResultSheet({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Your Compatibility Score',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Match',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Pure Magic! ✨',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your connection levels are remarkably high. You both share a deep understanding of intimacy and playfulness.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Great! 🎉'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
