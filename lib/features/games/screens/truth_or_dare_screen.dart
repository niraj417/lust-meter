import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/game_session_model.dart';
import '../../../services/database_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/gemini_service.dart';
import '../../../services/sound_service.dart';

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
  String? _suggestedCard;
  String _mode = 'truth'; // 'truth' or 'dare'
  bool _isSpicyMode = false;

  static const _normalTruths = [
    'What is your most adventurous fantasy?',
    'What is something you have always wanted to try with me?',
    'When did you first realize you had feelings for me?',
    'What is your favourite memory of us together?',
    'What makes you feel most loved in our relationship?',
    'What is something you wish I knew about you?',
    'Describe your perfect romantic evening.',
    'What is your biggest relationship fear?',
  ];

  static const _normalDares = [
    'Give your partner a 60-second massage on the spot.',
    'Whisper something sweet in your partner\'s ear.',
    'Do your best impression of your partner.',
    'Stare into your partner\'s eyes for 30 seconds without laughing.',
    'Write a love note in 30 seconds and read it aloud.',
    'Recreate your first kiss.',
    'Tell your partner three things you find irresistible about them.',
    'Dance to one song of your partner\'s choice right now.',
  ];

  static const _spicyTruths = [
    'What is your wildest undiscovered fantasy?',
    'Have you ever had a dream about me? What happened?',
    'What is your favorite part of my body?',
    'If we had a free pass for a night, what would you ask for?',
    'Where is the public place you most want to get intimate?',
    'What outfit of mine turns you on the most?',
    'What is your biggest turn on and turn off?',
    'What is the naughtiest text you have ever sent?',
  ];

  static const _spicyDares = [
    'Give me a 60-second lap dance.',
    'Remove one piece of clothing right now.',
    'Kiss my neck passionately for 30 seconds.',
    'Show me the most provocative photo on your phone.',
    'Send a risky text to me right now.',
    'Blindfold me and use a feather or ice cube on my skin.',
    'Whisper your deepest, darkest fantasy in my ear.',
    'Let me take off one item of your clothing with just my teeth.',
  ];

  late Map<String, List<String>> _promptCache;
  bool _isOnlineMode = false;
  String? _connectionId;
  StreamSubscription? _gameStateSubscription;
  String? _userName;
  String? _partnerName;
  String? _userPhotoUrl;
  String? _partnerPhotoUrl;
  String? _partnerId;
  bool _isPartnerJoined = false;
  String _currentPlayerTurn = ''; // UID of the player whose turn it is

  @override
  void initState() {
    super.initState();
    _promptCache = {
      'normal_truth': List.from(_normalTruths)..shuffle(),
      'normal_dare': List.from(_normalDares)..shuffle(),
      'spicy_truth': List.from(_spicyTruths)..shuffle(),
      'spicy_dare': List.from(_spicyDares)..shuffle(),
    };
    _spinController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));
    _spinAnim = CurvedAnimation(parent: _spinController, curve: Curves.easeOutBack)
        .drive(Tween(begin: 0.0, end: 4 * pi));
    
    _loadUserContext();
  }

  Future<void> _loadUserContext() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.user?.uid;
    if (uid != null) {
      final user = await DatabaseService().getUser(uid);
      _userName = user?.displayName;
      _userPhotoUrl = user?.photoUrl;
      _currentPlayerTurn = uid; // Default to self
      
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
    setState(() {
      _isOnlineMode = val;
      _currentCard = null;
      _suggestedCard = null;
    });

    _gameStateSubscription?.cancel();
    if (val && _connectionId != null) {
      final authData = context.read<AuthProvider>();
      final uid = authData.user?.uid;
      
      // Mark self as joined
      DatabaseService().updateGameState(_connectionId!, 'truth_or_dare', {
        'joined': FieldValue.arrayUnion([uid]),
        'status': 'joined',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _gameStateSubscription = DatabaseService()
          .getGameStateStream(_connectionId!, 'truth_or_dare')
          .listen((snapshot) {
        if (!snapshot.exists) return;
        final data = snapshot.data() as Map<String, dynamic>;
        final lastSpinner = data['lastSpinner'] as String?;
        final joined = List<String>.from(data['joined'] ?? []);
        final turn = data['turn'] as String?;
        
        setState(() {
          _isPartnerJoined = _partnerId != null && joined.contains(_partnerId);
          if (turn != null) _currentPlayerTurn = turn;
        });

        // Turn management: if it's not our turn, we might be watching a spin
        if (lastSpinner != uid) {
          final result = data['result'] as String?;
          final mode = data['mode'] as String?;
          final isSpicy = data['isSpicy'] as bool? ?? false;
          final status = data['status'] as String?;

          if (status == 'accepted' && result != null && mode != null) {
             _spinController.stop(); 
             setState(() {
                _currentCard = result;
                _mode = mode;
                _isSpicyMode = isSpicy;
                _isSpinning = false;
                _suggestedCard = null;
             });
          } else if (status == 'spinning') {
             if (!_isSpinning) {
               setState(() {
                  _isSpinning = true;
                  _currentCard = null;
                  _suggestedCard = null;
               });
               _spinController.repeat();
             }
          } else if (status == 'reset') {
             _spinController.stop();
             _spinController.reset();
             setState(() {
                _isSpinning = false;
                _currentCard = null;
                _suggestedCard = null;
             });
          }
        }
      });
    } else {
      // If turning off online mode, maybe reset state
      if (_connectionId != null) {
        final uid = context.read<AuthProvider>().user?.uid;
        DatabaseService().updateGameState(_connectionId!, 'truth_or_dare', {
          'joined': FieldValue.arrayRemove([uid]),
          'status': 'reset',
        });
      }
    }
  }

  Future<void> _playSpinSound() async {
    SoundService().play('sounds/bottle_spin.mp3');
  }

  void _spin() {
    final uid = context.read<AuthProvider>().user?.uid;
    // In online mode, verify if it's our turn
    if (_isOnlineMode && _currentPlayerTurn.isNotEmpty && _currentPlayerTurn != uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("It's your partner's turn!")),
      );
      return;
    }

    final type = _mode;
    final isSpicy = _isSpicyMode;
    final key = '${isSpicy ? 'spicy' : 'normal'}_$type';

    if (_promptCache[key]!.length < 5) {
      _fetchMorePrompts(type, isSpicy, key);
    }

    final list = _promptCache[key]!;
    final result = list.isNotEmpty ? list.removeAt(0) : 'Tell your partner something you love about them.';
    
    // Calculate angle based on target player
    // If it's my turn, the bottle points to ME (assume I am at bottom: pi)
    // If it's partner's turn, bottle points to PARTNER (assume partner is at top: 0)
    // Wait, the user said "mark at their profile picture". 
    // Usually the spinner spins and points to the SUBJECT of the action.
    // Let's say bottle points to the person who HAS to do the task.
    // If I spin, maybe it points to me? Or points to the partner for them to give me a task?
    // Let's assume the bottle points to the person who should perform the Truth/Dare.
    // We'll alternate turns.
    
    double targetAngle;
    if (_currentPlayerTurn == uid) {
      // Points to me (Bottom)
      targetAngle = 4 * pi + pi; 
    } else {
      // Points to partner (Top)
      targetAngle = 4 * pi + 0;
    }
    // Add some random variation within the segment if needed, but for now exact
    targetAngle += (Random().nextDouble() - 0.5) * 0.2; 

    setState(() {
      _isSpinning = true;
      _currentCard = null;
      _suggestedCard = null;
      _spinAnim = CurvedAnimation(parent: _spinController, curve: Curves.easeOutBack)
          .drive(Tween(begin: 0.0, end: targetAngle));
    });

    if (_isOnlineMode && _connectionId != null) {
      DatabaseService().updateGameState(_connectionId!, 'truth_or_dare', {
        'lastSpinner': uid,
        'status': 'spinning',
        'turn': _currentPlayerTurn,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    _playSpinSound();
    _spinController.reset();

    _spinController.forward().then((_) async {
      setState(() {
        _isSpinning = false;
        _suggestedCard = result;
      });
    });
  }

  void _acceptTask(String task) {
    setState(() {
      _currentCard = task;
      _suggestedCard = null;
    });

    if (_isOnlineMode && _connectionId != null) {
      final uid = context.read<AuthProvider>().user?.uid;
      final nextTurn = _partnerId ?? uid; // Toggle turn
      DatabaseService().updateGameState(_connectionId!, 'truth_or_dare', {
        'lastSpinner': uid,
        'result': task,
        'mode': _mode,
        'isSpicy': _isSpicyMode,
        'status': 'accepted',
        'turn': nextTurn,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Award points
    _awardPoints();
  }

  void _regenerateTask() {
    final type = _mode;
    final isSpicy = _isSpicyMode;
    final key = '${isSpicy ? 'spicy' : 'normal'}_$type';
    final list = _promptCache[key]!;
    
    setState(() {
      _suggestedCard = list.isNotEmpty ? list.removeAt(0) : 'Tell your partner something you love about them.';
    });

    if (list.length < 5) {
      _fetchMorePrompts(type, isSpicy, key);
    }
  }
  void _showCustomTaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Custom ${_mode == 'truth' ? 'Truth' : 'Dare'}', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Type your challenge here...',
            hintStyle: TextStyle(color: AppColors.textHint),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _acceptTask(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _awardPoints() async {
    if (mounted) {
      final authData = context.read<AuthProvider>();
      if (authData.user != null) {
        final uid = authData.user!.uid;
        try {
          await DatabaseService().recordGameSession(GameSessionModel(
            sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
            gameType: _mode,
            participants: [uid],
            pointsAwarded: 5,
            playedAt: DateTime.now(),
          ));
        } catch (_) {}
      }
    }
  }

  Future<void> _fetchMorePrompts(String type, bool spicy, String key) async {
    try {
      final geminiService = GeminiService(apiKey: 'AIzaSyAZu2a2p5vLsMgB5cDjgWzSJTEAsLLoLCE');
      final newPrompts = await geminiService.generateTruthOrDarePrompts(
        type: type, 
        count: 5, 
        spicy: spicy,
        userName: _userName,
        partnerName: _partnerName,
      );
      if (mounted) {
        setState(() {
          final existing = _promptCache[key]!;
          _promptCache[key]!.addAll(newPrompts.where((p) => !existing.contains(p)));
        });
      }
    } catch (_) {}
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

  @override
  void dispose() {
    _gameStateSubscription?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Truth or Dare 🍾'),
        backgroundColor: AppColors.background,
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search_rounded, color: Colors.white),
            tooltip: 'Find connected partner',
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
                          _currentCard = null;
                          _suggestedCard = null;
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

            // Player Profiles and Spinning bottle
            Stack(
              alignment: Alignment.center,
              children: [
                // Partner (Top)
                Positioned(
                  top: 0,
                  child: Column(
                    children: [
                      _PlayerAvatar(
                        url: _partnerPhotoUrl,
                        name: _partnerName ?? 'Partner',
                        isJoined: _isPartnerJoined,
                        isTurn: _isOnlineMode && _currentPlayerTurn == _partnerId,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                
                // User (Bottom)
                Positioned(
                  bottom: 0,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _PlayerAvatar(
                        url: _userPhotoUrl,
                        name: _userName ?? 'You',
                        isJoined: true, // Self is always joined if in screen
                        isTurn: _isOnlineMode && _currentPlayerTurn == context.read<AuthProvider>().user?.uid,
                      ),
                    ],
                  ),
                ),

                // Bottle
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: AnimatedBuilder(
                    animation: _spinAnim,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _spinAnim.value * 2 * pi,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 280,
                      height: 280,
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
                                .withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text('🍾', style: TextStyle(fontSize: 60)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Card reveal / Suggestion
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _suggestedCard != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ChallengeCard(
                            text: _suggestedCard!,
                            mode: _mode,
                            isSuggestion: true,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ActionButton(
                                icon: Icons.refresh_rounded,
                                label: 'Regenerate',
                                color: Colors.blue,
                                onTap: _regenerateTask,
                              ),
                              const SizedBox(width: 16),
                              _ActionButton(
                                icon: Icons.check_circle_rounded,
                                label: 'Accept',
                                color: Colors.green,
                                onTap: () => _acceptTask(_suggestedCard!),
                              ),
                              const SizedBox(width: 16),
                              _ActionButton(
                                icon: Icons.edit_note_rounded,
                                label: 'Custom',
                                color: Colors.orange,
                                onTap: _showCustomTaskDialog,
                              ),
                            ],
                          ),
                        ],
                      )
                    : _currentCard != null
                        ? _ChallengeCard(
                            text: _currentCard!,
                            mode: _mode,
                            isSuggestion: false,
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
            ),

            // Spin button
            const SizedBox(height: 24),
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

class _ChallengeCard extends StatelessWidget {
  final String text;
  final String mode;
  final bool isSuggestion;

  const _ChallengeCard({
    required this.text,
    required this.mode,
    required this.isSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(text),
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: mode == 'truth'
            ? AppColors.purpleGradient
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (mode == 'truth'
                    ? AppColors.secondary
                    : AppColors.primary)
                .withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          if (isSuggestion)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'SUGGESTION',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
