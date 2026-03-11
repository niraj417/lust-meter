import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/database_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';
import 'package:provider/provider.dart';
import '../../../core/models/partner_connection_model.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:rxdart/rxdart.dart';
import '../../../services/sound_service.dart';
import '../../explore/models/kink_model.dart';
import '../../explore/screens/position_detail_screen.dart';
import '../../explore/screens/kink_detail_screen.dart';
import '../../explore/models/position_model.dart';
import '../../../services/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _aiTip = 'Loading your daily intimacy tip...';
  bool _isLoadingTip = true;
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    UserModel? userModel;
    if (user != null) {
      userModel = await DatabaseService().getUser(user.uid);
    }
    await _fetchAiTip(userModel);
  }

  Future<void> _fetchAiTip(UserModel? userModel) async {
    try {
      String tip;
      if (userModel != null) {
        final geminiService = GeminiService(apiKey: 'AIzaSyAZu2a2p5vLsMgB5cDjgWzSJTEAsLLoLCE');
        tip = await geminiService.generateRelationshipTip(
          userName: userModel.displayName,
          lustScore: userModel.lustScore,
          emotionalScore: userModel.emotionalScore,
          physicalScore: 0,
        );
      } else {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        tip = await GeminiService.generateText(
          'Generate a short, romantic, and actionable intimacy tip for a couple in a long-term relationship. Max 2 sentences. Make it completely unique and different from previous tips. (Seed: $timestamp)',
        );
      }
      
      if (mounted) {
        setState(() {
          _aiTip = tip;
          _isLoadingTip = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiTip = 'Focus on quality time tonight — try a shared activity without distractions.';
          _isLoadingTip = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<UserModel?>(
              stream: DatabaseService().getUserStream(user.uid),
              builder: (context, snapshot) {
                final userModel = snapshot.data;
                
                return CustomScrollView(
                  slivers: [
                    _buildAppBar(context, user),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 24),
                          _LustScoreCard(userModel: userModel),
                          const SizedBox(height: 20),
                          _AiTipCard(tip: _aiTip, isLoading: _isLoadingTip),
                          const SizedBox(height: 20),
                          _QuickActionsGrid(),
                          const SizedBox(height: 20),
                          _StreakCard(userModel: userModel),
                          const SizedBox(height: 100),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, firebase_auth.User? user) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      pinned: false,
      elevation: 0,
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${user!.displayName!.split(' ').first} \u{1F44B}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  'Ready to turn up the heat?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          StreamBuilder<List<PartnerConnectionModel>>(
            stream: _db.getUserConnectionsStream(user.uid),
            builder: (ctx, snap) {
              final connections = snap.data ?? [];
              if (connections.isNotEmpty) {
                return TextButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textSecondary, size: 20),
                  label: const Text('Chat', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  onPressed: () => context.push(AppRoutes.chatList),
                );
              }
              return const SizedBox();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary, size: 20),
            label: const Text('Alerts', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }
}

class _LustScoreCard extends StatelessWidget {
  final UserModel? userModel;
  const _LustScoreCard({this.userModel});

  @override
  Widget build(BuildContext context) {
    final score = userModel?.lustScore ?? 0;
    final emotionalScore = userModel?.emotionalScore ?? 0;
    final physicalScore = userModel?.physicalScore ?? 0;
    final bondScore = userModel?.bondScore ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.fireGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Lust Score', style: TextStyle(
                    color: Colors.white70, fontSize: 13, fontFamily: 'Inter',
                  )),
                  const SizedBox(height: 4),
                  Text('$score', style: const TextStyle(
                    color: Colors.white, fontSize: 56,
                    fontWeight: FontWeight.w900, fontFamily: 'Inter',
                    height: 1,
                  )),
                ],
              ),
              _ScoreRing(score: score / 100.0, emoji: '🔥'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ScorePill(label: 'Emotional', value: emotionalScore, color: Colors.purpleAccent),
              const SizedBox(width: 10),
              _ScorePill(label: 'Physical', value: physicalScore, color: Colors.orangeAccent),
              const SizedBox(width: 10),
              _ScorePill(label: 'Bond', value: bondScore, color: Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final double score;
  final String emoji;
  const _ScoreRing({required this.score, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80, height: 80,
            child: CircularProgressIndicator(
              value: score,
              strokeWidth: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 30)),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _ScorePill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.w800,
              fontSize: 18, fontFamily: 'Inter')),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'Inter')),
        ]),
      ),
    );
  }
}

class _AiTipCard extends StatelessWidget {
  final String tip;
  final bool isLoading;

  const _AiTipCard({required this.tip, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('AI Tip of the Day', style: TextStyle(
              color: AppColors.secondary, fontWeight: FontWeight.w700,
              fontFamily: 'Inter', fontSize: 13,
            )),
          ]),
          const SizedBox(height: 14),
          if (isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(AppColors.secondary),
              minHeight: 2,
            )
          else
            Text(
              tip,
              style: const TextStyle(
                color: AppColors.textPrimary, fontFamily: 'Inter',
                fontSize: 14, height: 1.6,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final List<_ActionItem> _actions = const [
    _ActionItem(icon: '🎯', label: 'Quiz', color: Color(0xFFE63950), route: AppRoutes.compatibilityQuiz),
    _ActionItem(icon: '🃏', label: 'Fantasy\nCards', color: Color(0xFF9B30FF), route: AppRoutes.fantasyCards),
    _ActionItem(icon: '🌀', label: 'Spin\nWheel', color: Color(0xFFFF8C42), route: AppRoutes.spinWheel),
    _ActionItem(icon: '💬', label: 'Consult', color: Color(0xFF30B0FF), route: AppRoutes.consultation),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Play', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700,
          fontFamily: 'Inter', color: AppColors.textPrimary,
        )),
        const SizedBox(height: 14),
        Row(
          children: _actions.map((a) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _ActionCard(item: a),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _ActionItem {
  final String icon;
  final String label;
  final Color color;
  final String route;
  const _ActionItem({required this.icon, required this.label, required this.color, required this.route});
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;
  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(children: [
          Text(item.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(item.label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontFamily: 'Inter',
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final UserModel? userModel;
  const _StreakCard({this.userModel});

  @override
  Widget build(BuildContext context) {
    final streak = userModel?.streak ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🔥 Daily Streak', style: TextStyle(
                fontFamily: 'Inter', fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, fontSize: 16,
              )),
              const SizedBox(height: 4),
              Text(streak > 0 ? '$streak days in a row! Keep it up 💪' : 'Start your daily streak today! 💪', style: const TextStyle(
                fontFamily: 'Inter', color: AppColors.textSecondary, fontSize: 13,
              )),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$streak 🔥', style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800,
            fontFamily: 'Inter', fontSize: 18,
          )),
        ),
      ]),
    );
  }
}

class _DiscoverySection extends StatefulWidget {
  final String userId;
  const _DiscoverySection({required this.userId});

  @override
  State<_DiscoverySection> createState() => _DiscoverySectionState();
}

class _DiscoverySectionState extends State<_DiscoverySection> {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Discover', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              fontFamily: 'Inter', color: AppColors.textPrimary,
            )),
            TextButton(
              onPressed: () => context.push(AppRoutes.savedCards),
              child: const Text('Saved Cards', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 380,
          child: StreamBuilder<List<dynamic>>(
            stream: _getDiscoveryStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) return const Center(child: Text('No new discoveries today!', style: TextStyle(color: Colors.white38)));
              
              // Shuffle for variety as requested
              items.shuffle(Random());

              return CardSwiper(
                cardsCount: items.length,
                numberOfCardsDisplayed: 3,
                backCardOffset: const Offset(20, 20),
                padding: const EdgeInsets.all(0),
                cardBuilder: (context, index, horizontalThresholdPercentage, verticalThresholdPercentage) {
                  final item = items[index];
                  if (item is PositionModel) return _PositionDiscoveryCard(pos: item);
                  if (item is KinkModel) return _KinkDiscoveryCard(kink: item);
                  return const SizedBox();
                },
                onSwipe: (prevIndex, currentIndex, direction) {
                   final item = items[prevIndex];
                    SoundService().play('sounds/card_swipe.mp3');
                   
                   if (direction == CardSwiperDirection.right) {
                     // Love/Like
                     if (item is PositionModel) _db.recordPositionInteraction(widget.userId, item.id, isLiked: true);
                     if (item is KinkModel) _db.recordKinkInteraction(widget.userId, item.id, isLiked: true);
                   }
                   return true;
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<List<dynamic>> _getDiscoveryStream() {
    // Combine positions and kinks into one stream for the swiper
    return CombineLatestStream.combine2(
      _db.getPositionsStream(),
      _db.getKinksFromDbStream(),
      (List<PositionModel> p, List<KinkModel> k) => [...p, ...k],
    );
  }
}

class _PositionDiscoveryCard extends StatelessWidget {
  final PositionModel pos;
  const _PositionDiscoveryCard({required this.pos});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PositionDetailScreen(position: pos))),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          image: pos.imageUrl != null ? DecorationImage(image: NetworkImage(pos.imageUrl!), fit: BoxFit.cover, opacity: 0.4) : null,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: Text(pos.emoji, style: const TextStyle(fontSize: 32))),
            const SizedBox(height: 16),
            Text(pos.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
            const SizedBox(height: 8),
            Text(pos.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text(pos.level, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}

class _KinkDiscoveryCard extends StatelessWidget {
  final KinkModel kink;
  const _KinkDiscoveryCard({required this.kink});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KinkDetailScreen(kink: kink))),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.surface, AppColors.secondary.withValues(alpha: 0.1)]),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 32)),
            const SizedBox(height: 16),
            Text(kink.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
            const SizedBox(height: 8),
            Text(kink.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: Text(kink.category, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
