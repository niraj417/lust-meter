import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore 🌍'),
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          labelStyle: const TextStyle(
              fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Positions'),
            Tab(text: 'Challenges'),
            Tab(text: 'Kinks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PositionsTab(),
          _ChallengesTab(),
          _KinksTab(),
        ],
      ),
    );
  }
}

// ─── Positions ───────────────────────────────────────────────────────────────

class _PositionsTab extends StatelessWidget {
  const _PositionsTab();

  static const _positions = [
    _Position('The Spoon', '🥄', 'Intimate and cozy — perfect for a quiet night.', 'Beginner', Color(0xFF9B30FF)),
    _Position('The Lotus', '🌸', 'Face-to-face connection that deepens emotional bond.', 'Intermediate', Color(0xFFE63950)),
    _Position('The Bridge', '🌉', 'A powerful pose with deep connection.', 'Intermediate', Color(0xFFFF8C42)),
    _Position('The Butterfly', '🦋', 'Deep and passionate with full eye contact.', 'Beginner', Color(0xFF30B0FF)),
    _Position('The Pretzel', '🥨', 'A twist on the classics for adventurous couples.', 'Advanced', Color(0xFFFF6B9D)),
    _Position('The Seated Embrace', '🪑', 'Slow and sensual — focus entirely on each other.', 'Beginner', Color(0xFF4DFF88)),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.88,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _positions.length,
      itemBuilder: (_, i) => _PositionCard(pos: _positions[i]),
    );
  }
}

class _Position {
  final String name;
  final String emoji;
  final String desc;
  final String level;
  final Color color;
  const _Position(this.name, this.emoji, this.desc, this.level, this.color);
}

class _PositionCard extends StatelessWidget {
  final _Position pos;
  const _PositionCard({required this.pos});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pos.color.withAlpha(60), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pos.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(pos.name,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  fontSize: 15)),
          const SizedBox(height: 4),
          Text(pos.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: 12)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: pos.color.withAlpha(30),
                borderRadius: BorderRadius.circular(8)),
            child: Text(pos.level,
                style: TextStyle(
                    color: pos.color,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

// ─── Challenges ──────────────────────────────────────────────────────────────

class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab();

  static const _challenges = [
    _Challenge('7-Day Touch Challenge', '🤝', 'Hold hands for at least 30 min every day this week.', '7 Days', Color(0xFFE63950)),
    _Challenge('Love Language Week', '💌', 'Express love in a different language each day — words, touch, gifts, time, service.', '7 Days', Color(0xFF9B30FF)),
    _Challenge('Screen-Free Evening', '📵', 'Spend one full evening with no phones, no TV — just each other.', '1 Day', Color(0xFFFF8C42)),
    _Challenge('Cook a New Dish Together', '🍳', 'Pick a cuisine you\'ve never tried and cook it from scratch together.', '1 Day', Color(0xFF30B0FF)),
    _Challenge('Memory Jar', '🫙', 'Both write down 10 favourite memories of each other. Read them aloud together.', '2 Days', Color(0xFF4DFF88)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _challenges.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ChallengeCard(c: _challenges[i]),
    );
  }
}

class _Challenge {
  final String title;
  final String emoji;
  final String desc;
  final String duration;
  final Color color;
  const _Challenge(this.title, this.emoji, this.desc, this.duration, this.color);
}

class _ChallengeCard extends StatelessWidget {
  final _Challenge c;
  const _ChallengeCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.color.withAlpha(50), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
              color: c.color.withAlpha(25),
              borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(c.emoji, style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(c.title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                        fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: c.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(c.duration,
                    style: TextStyle(
                        color: c.color,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 11)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(c.desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 13)),
          ]),
        ),
      ]),
    );
  }
}

// ─── Kinks ───────────────────────────────────────────────────────────────────

class _KinksTab extends StatefulWidget {
  const _KinksTab();

  @override
  State<_KinksTab> createState() => _KinksTabState();
}

class _KinksTabState extends State<_KinksTab> {
  final Set<String> _selected = {};

  static const _kinks = [
    '🎭 Role Play', '📸 Photography', '💆 Sensual Touch', '🎲 Games',
    '💬 Dirty Talk', '🌙 Late Nights', '🌹 Romance', '🍷 Wine & Dine',
    '🕯️ Candlelit', '🧘 Mindfulness', '🌊 Nature Play', '🎶 Music',
    '✍️ Love Letters', '🍳 Cooking Together', '🎭 Costumes', '🌺 Massages',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _kinks.map((k) {
                final sel = _selected.contains(k);
                return GestureDetector(
                  onTap: () => setState(() =>
                      sel ? _selected.remove(k) : _selected.add(k)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: sel ? AppColors.primaryGradient : null,
                      color: sel ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: sel ? Colors.transparent : AppColors.divider,
                        width: 1,
                      ),
                    ),
                    child: Text(k,
                        style: TextStyle(
                            color: sel
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontFamily: 'Inter',
                            fontWeight: sel
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (_selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Share ${_selected.length} interests with partner',
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
