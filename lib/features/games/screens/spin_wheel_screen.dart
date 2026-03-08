import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;
  bool _isSpinning = false;
  String? _result;
  double _totalRotation = 0;

  static const List<_WheelSegment> _segments = [
    _WheelSegment('Massage 💆', Color(0xFFE63950)),
    _WheelSegment('Movie Night 🎬', Color(0xFF9B30FF)),
    _WheelSegment('Cook Together 🍳', Color(0xFFFF8C42)),
    _WheelSegment('Dare 🔥', Color(0xFFE63950)),
    _WheelSegment('Truth 💬', Color(0xFF9B30FF)),
    _WheelSegment('Romantic Walk 🌙', Color(0xFF30B0FF)),
    _WheelSegment('Dance 💃', Color(0xFFFF6B9D)),
    _WheelSegment('Love Letter 💌', Color(0xFFFFD700)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    final random = Random();
    final extraSpins = (5 + random.nextInt(5)) * 2 * pi;
    final segmentAngle = 2 * pi / _segments.length;
    final landingOffset = random.nextDouble() * 2 * pi;

    final targetRotation = _totalRotation + extraSpins + landingOffset;
    _totalRotation = targetRotation;

    _controller.duration = const Duration(milliseconds: 3500);
    _rotationAnim = Tween<double>(
      begin: _controller.value * 2 * pi,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ));

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    _controller.reset();
    _controller.forward().then((_) {
      // Determine which segment is at the top (pointer)
      final normalized =
          targetRotation % (2 * pi);
      final idx =
          ((_segments.length - (normalized / segmentAngle).floor()) %
                  _segments.length)
              .toInt();
      setState(() {
        _isSpinning = false;
        _result = _segments[idx % _segments.length].label;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Spin the Wheel 🌀'),
        backgroundColor: AppColors.background,
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'What surprise awaits you both?',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Pointer
            const Icon(Icons.arrow_drop_down_rounded,
                color: AppColors.goldAccent, size: 48),

            // Wheel
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final angle = _controller.isAnimating
                    ? _rotationAnim.value
                    : _totalRotation;
                return Transform.rotate(
                  angle: angle,
                  child: const _WheelWidget(segments: _segments),
                );
              },
            ),
            const SizedBox(height: 32),

            // Result
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _result != null
                  ? Container(
                      key: ValueKey(_result),
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.fireGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(80),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Text(
                        '🎉 $_result!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                        ),
                      ),
                    )
                  : Container(
                      key: const ValueKey('empty'),
                      height: 72,
                      alignment: Alignment.center,
                      child: Text(
                        _isSpinning
                            ? 'Spinning... 🌀'
                            : 'Tap SPIN to find out!',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                            fontSize: 15),
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
                    gradient:
                        _isSpinning ? null : AppColors.fireGradient,
                    color: _isSpinning ? AppColors.surfaceElevated : null,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      _isSpinning ? 'Spinning...' : 'SPIN! 🌀',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Inter',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _WheelSegment {
  final String label;
  final Color color;
  const _WheelSegment(this.label, this.color);
}

class _WheelWidget extends StatelessWidget {
  final List<_WheelSegment> segments;

  const _WheelWidget({required this.segments});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: _WheelPainter(segments),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<_WheelSegment> segments;
  _WheelPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segAngle = 2 * pi / segments.length;

    for (int i = 0; i < segments.length; i++) {
      final startAngle = i * segAngle - pi / 2;
      final paint = Paint()..color = segments[i].color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segAngle,
        true,
        paint,
      );

      // Divider lines
      final linePaint = Paint()
        ..color = Colors.black26
        ..strokeWidth = 2;
      final lineEnd = Offset(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      );
      canvas.drawLine(center, lineEnd, linePaint);

      // Text labels
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + segAngle / 2);
      final text = segments[i].label;
      const txtStyle = TextStyle(
          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700);
      final tp = TextPainter(
        text: TextSpan(text: text, style: txtStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 0.65);
      tp.paint(canvas, Offset(radius * 0.3, -tp.height / 2));
      canvas.restore();
    }

    // Center
    final centerPaint = Paint()..color = AppColors.background;
    canvas.drawCircle(center, 22, centerPaint);
    const centerStyle = TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900);
    final tpCenter = TextPainter(
      text: const TextSpan(text: '🌀', style: centerStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tpCenter.paint(canvas, center - Offset(tpCenter.width / 2, tpCenter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
