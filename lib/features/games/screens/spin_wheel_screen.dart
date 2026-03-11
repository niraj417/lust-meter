import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/game_session_model.dart';
import '../../../services/database_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/sound_service.dart';

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

  bool _isSpicyMode = false;
  bool _isOnlineMode = false;
  String? _connectionId;
  String? _partnerId;
  String? _userName;
  String? _partnerName;
  String? _userPhotoUrl;
  String? _partnerPhotoUrl;
  bool _isPartnerJoined = false;
  String _currentPlayerTurn = '';
  StreamSubscription? _gameStateSubscription;

  static const List<_WheelSegment> _normalSegments = [
    _WheelSegment('Massage 💆', Color(0xFFE63950)),
    _WheelSegment('Movie Night 🎬', Color(0xFF9B30FF)),
    _WheelSegment('Cook Together 🍳', Color(0xFFFF8C42)),
    _WheelSegment('Dare 🔥', Color(0xFFE63950)),
    _WheelSegment('Truth 💬', Color(0xFF9B30FF)),
    _WheelSegment('Romantic Walk 🌙', Color(0xFF30B0FF)),
    _WheelSegment('Dance 💃', Color(0xFFFF6B9D)),
    _WheelSegment('Love Letter 💌', Color(0xFFFFD700)),
  ];

  static const List<_WheelSegment> _spicySegments = [
    _WheelSegment('Strip Tease 🥵', Color(0xFFD50000)),
    _WheelSegment('Sensual 💦', Color(0xFFC51162)),
    _WheelSegment('Spicy Truth 😈', Color(0xFFAA00FF)),
    _WheelSegment('Spicy Dare 🌶️', Color(0xFFFF3D00)),
    _WheelSegment('Blindfold 🙈', Color(0xFF212121)),
    _WheelSegment('Roleplay 🎭', Color(0xFF6200EA)),
    _WheelSegment('Take a shot 🥃', Color(0xFFFF6D00)),
    _WheelSegment('Kiss anywhere 💋', Color(0xFFE65100)),
  ];

  List<_WheelSegment> get _currentSegments => _isSpicyMode ? _spicySegments : _normalSegments;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _loadUserContext();
  }

  Future<void> _loadUserContext() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.user?.uid;
    if (uid != null) {
      final user = await DatabaseService().getUser(uid);
      _userName = user?.displayName;
      _userPhotoUrl = user?.photoUrl;
      _currentPlayerTurn = uid;
      
      final conn = await DatabaseService().getFirstConnection(uid);
      if (conn != null) {
        _connectionId = conn.connectionId;
        final partnerUid = conn.users.firstWhere((id) => id != uid, orElse: () => '');
        if (partnerUid.isNotEmpty) {
          _partnerId = partnerUid;
          final partner = await DatabaseService().getUser(partnerUid);
          _partnerName = partner?.displayName;
          _partnerPhotoUrl = partner?.photoUrl;
        }
      }
      setState(() {});
    }
  }

  void _toggleOnlineMode(bool val) {
    setState(() => _isOnlineMode = val);
    _gameStateSubscription?.cancel();
    if (val && _connectionId != null) {
      final uid = context.read<AuthProvider>().user?.uid;
      DatabaseService().updateGameState(_connectionId!, 'spin_wheel', {
        'joined': FieldValue.arrayUnion([uid]),
        'status': 'joined',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _gameStateSubscription = DatabaseService()
          .getGameStateStream(_connectionId!, 'spin_wheel')
          .listen((snapshot) {
        if (!snapshot.exists) return;
        final data = snapshot.data() as Map<String, dynamic>;
        final joined = List<String>.from(data['joined'] ?? []);
        final turn = data['turn'] as String?;
        final lastSpinner = data['lastSpinner'] as String?;

        setState(() {
          _isPartnerJoined = _partnerId != null && joined.contains(_partnerId);
          if (turn != null) _currentPlayerTurn = turn;
        });

        if (lastSpinner != uid) {
          final status = data['status'] as String?;
          if (status == 'spinning') {
            if (!_isSpinning) {
              _remoteSpin();
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _gameStateSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _remoteSpin() {
    // This will be called when partner spins
    // Logic to start the animation without trigger Firestore update
    // We might need to receive the target rotation or seed from Firestore
    // For simplicity, let's just trigger a local spin visual
    _spin(isRemote: true);
  }

  void _showPartnerSearchDialog() {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Select Connected Partner', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder(
            stream: DatabaseService().getUserConnectionsStream(uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final connections = snapshot.data!;
              if (connections.isEmpty) {
                return const Center(child: Text('No connected partners found. Connect with someone in the Partner tab first!', style: TextStyle(color: AppColors.textSecondary)));
              }
              return ListView.builder(
                itemCount: connections.length,
                itemBuilder: (context, index) {
                  final conn = connections[index];
                  final partnerUid = conn.users.firstWhere((id) => id != uid);
                  return FutureBuilder(
                    future: DatabaseService().getUser(partnerUid),
                    builder: (context, userSnap) {
                      final user = userSnap.data;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                          child: user?.photoUrl == null ? const Icon(Icons.person) : null,
                        ),
                        title: Text(user?.displayName ?? 'Loading...', style: const TextStyle(color: Colors.white)),
                        subtitle: const Text('Connected', style: TextStyle(color: Colors.green, fontSize: 12)),
                        onTap: () {
                          setState(() {
                            _connectionId = conn.connectionId;
                            _partnerId = partnerUid;
                            _partnerName = user?.displayName;
                            _partnerPhotoUrl = user?.photoUrl;
                            _isOnlineMode = false; // Reset to allow re-enabling with new connection
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Selected partner: ${user?.displayName}')),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _spin({bool isRemote = false}) {
    if (_isSpinning) return;

    final uid = context.read<AuthProvider>().user?.uid;
    if (_isOnlineMode && !isRemote && _currentPlayerTurn.isNotEmpty && _currentPlayerTurn != uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("It's your partner's turn!")),
      );
      return;
    }

    final random = Random();
    final extraSpins = (5 + random.nextInt(5)) * 2 * pi;
    final currentSegments = _currentSegments;
    final segmentAngle = 2 * pi / currentSegments.length;
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

    SoundService().play('sounds/wheel_spin.mp3');

    if (_isOnlineMode && !isRemote && _connectionId != null) {
      DatabaseService().updateGameState(_connectionId!, 'spin_wheel', {
        'lastSpinner': uid,
        'status': 'spinning',
        'turn': _currentPlayerTurn,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    _controller.reset();
    _controller.forward().then((_) async {
      final currentSegments = _currentSegments;
      final normalized = (2 * pi - (targetRotation % (2 * pi))) % (2 * pi);
      final idx = (normalized / segmentAngle).floor();
      
      setState(() {
        _isSpinning = false;
        _result = currentSegments[idx % currentSegments.length].label;
      });

      if (!isRemote && _isOnlineMode && _connectionId != null) {
        final nextTurn = _partnerId ?? uid;
        DatabaseService().updateGameState(_connectionId!, 'spin_wheel', {
           'status': 'stopped',
           'result': _result,
           'turn': nextTurn,
           'lastSpinner': uid,
           'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // --- Record Game Session for Points ---
      if (mounted && !isRemote) {
        final authData = context.read<AuthProvider>();
        if (authData.user != null) {
          final uid = authData.user!.uid;
          try {
            await DatabaseService().recordGameSession(GameSessionModel(
              sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
              gameType: 'spin_wheel',
              participants: [uid],
              pointsAwarded: 5,
              playedAt: DateTime.now(),
            ));
          } catch (_) {}
        }
      }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search_rounded, color: Colors.white),
            onPressed: _showPartnerSearchDialog,
          ),
          Row(
            children: [
              const Text('Online 🌐', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Switch(
                value: _isOnlineMode,
                activeThumbColor: AppColors.primary,
                onChanged: _isSpinning || _connectionId == null ? null : _toggleOnlineMode,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const Text('Spicy 🔥', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Switch(
                value: _isSpicyMode,
                activeThumbColor: AppColors.primary,
                onChanged: _isSpinning
                    ? null
                    : (val) {
                        setState(() {
                          _isSpicyMode = val;
                          _result = null;
                        });
                      },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
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

            // Wheel Area
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isOnlineMode) ...[
                    // Partner Avatar (Top)
                    Positioned(
                      top: 0,
                      child: _PlayerAvatar(
                        url: _partnerPhotoUrl,
                        name: _partnerName ?? 'Partner',
                        isJoined: _isPartnerJoined,
                        isTurn: _currentPlayerTurn == _partnerId,
                      ),
                    ),
                    // User Avatar (Bottom)
                    Positioned(
                      bottom: 0,
                      child: _PlayerAvatar(
                        url: _userPhotoUrl,
                        name: _userName ?? 'You',
                        isJoined: true,
                        isTurn: _currentPlayerTurn == context.read<AuthProvider>().user?.uid,
                      ),
                    ),
                  ],
                  // The Wheel
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final angle = _controller.isAnimating
                          ? _rotationAnim.value
                          : _totalRotation;
                      return Transform.rotate(
                        angle: angle,
                        child: _WheelWidget(segments: _currentSegments),
                      );
                    },
                  ),
                ],
              ),
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
                  child: Center(
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

class _PlayerAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final bool isJoined;
  final bool isTurn;

  const _PlayerAvatar({
    this.url,
    required this.name,
    required this.isJoined,
    required this.isTurn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isTurn ? AppColors.goldAccent : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isTurn
                    ? [
                        BoxShadow(
                          color: AppColors.goldAccent.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.surface,
                backgroundImage: url != null ? NetworkImage(url!) : null,
                child: url == null
                    ? const Icon(Icons.person, color: Colors.white, size: 30)
                    : null,
              ),
            ),
            if (isJoined)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isTurn ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
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
