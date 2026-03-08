import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TruthOrDareScreen extends StatefulWidget {
  const TruthOrDareScreen({super.key});

  @override
  State<TruthOrDareScreen> createState() => _TruthOrDareScreenState();
}

class _TruthOrDareScreenState extends State<TruthOrDareScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnim;
  bool _isSpinning = false;
  String? _currentCard;
  String _mode = 'truth'; // 'truth' or 'dare'

  static const _truths = [
    'What is your most adventurous fantasy?',
    'What is something you have always wanted to try with me?',
    'When did you first realize you had feelings for me?',
    'What is your favourite memory of us together?',
    'What makes you feel most loved in our relationship?',
    'What is something you wish I knew about you?',
    'Describe your perfect romantic evening.',
    'What is your biggest relationship fear?',
  ];

  static const _dares = [
    'Give your partner a 60-second massage on the spot.',
    'Whisper something sweet in your partner\'s ear.',
    'Do your best impression of your partner.',
    'Stare into your partner\'s eyes for 30 seconds without laughing.',
    'Write a love note in 30 seconds and read it aloud.',
    'Recreate your first kiss.',
    'Tell your partner three things you find irresistible about them.',
    'Dance to one song of your partner\'s choice right now.',
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _spinAnim = CurvedAnimation(parent: _spinController, curve: Curves.easeOutBack)
        .drive(Tween(begin: 0.0, end: 4 * pi));
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _currentCard = null;
    });
    _spinController.reset();
    _spinController.forward().then((_) {
      final list = _mode == 'truth' ? _truths : _dares;
      setState(() {
        _isSpinning = false;
        _currentCard = list[Random().nextInt(list.length)];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Truth or Dare 🍾'),
        backgroundColor: AppColors.background,
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Mode toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  _ModeTab(
                    label: '💬 Truth',
                    selected: _mode == 'truth',
                    onTap: () => setState(() => _mode = 'truth'),
                    gradient: AppColors.purpleGradient,
                  ),
                  _ModeTab(
                    label: '🔥 Dare',
                    selected: _mode == 'dare',
                    onTap: () => setState(() => _mode = 'dare'),
                    gradient: AppColors.primaryGradient,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Spinning bottle
            AnimatedBuilder(
              animation: _spinAnim,
              builder: (_, __) => Transform.rotate(
                angle: _spinAnim.value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _mode == 'truth'
                        ? AppColors.purpleGradient
                        : AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: (_mode == 'truth'
                                ? AppColors.secondary
                                : AppColors.primary)
                            .withAlpha(100),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text('🍾', style: TextStyle(fontSize: 68)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Card reveal
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _currentCard != null
                  ? Container(
                      key: ValueKey(_currentCard),
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: _mode == 'truth'
                            ? AppColors.purpleGradient
                            : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (_mode == 'truth'
                                    ? AppColors.secondary
                                    : AppColors.primary)
                                .withAlpha(80),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Text(
                        _currentCard!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(
                      key: const ValueKey('empty'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppColors.divider, width: 1.5,
                            style: BorderStyle.solid),
                      ),
                      child: const Text(
                        'Spin the bottle to reveal your challenge!',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
            const Spacer(),

            // Spin button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isSpinning ? null : _spin,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _mode == 'truth'
                        ? AppColors.purpleGradient
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      _isSpinning ? 'Spinning...' : 'Spin the Bottle! 🍾',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final LinearGradient gradient;
  const _ModeTab(
      {required this.label,
      required this.selected,
      required this.onTap,
      required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: selected
              ? BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                )
              : null,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontFamily: 'Inter',
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
