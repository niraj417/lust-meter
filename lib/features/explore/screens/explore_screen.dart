import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../services/explore_service.dart';
import '../models/kink_model.dart';
import '../models/position_model.dart';
import 'kink_detail_screen.dart';
import 'position_detail_screen.dart';

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

class _PositionsTab extends StatefulWidget {
  const _PositionsTab();

  @override
  State<_PositionsTab> createState() => _PositionsTabState();
}

class _PositionsTabState extends State<_PositionsTab> {
  final ExploreService _service = ExploreService();
  late Future<List<PositionModel>> _positionsFuture;

  @override
  void initState() {
    super.initState();
    _positionsFuture = _service.getPositions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PositionModel>>(
      future: _positionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load positions', style: TextStyle(color: Colors.white70)));
        }

        final positions = snapshot.data ?? [];

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.88,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: positions.length,
          itemBuilder: (_, i) => _PositionCard(pos: positions[i]),
        );
      },
    );
  }
}

class _PositionCard extends StatelessWidget {
  final PositionModel pos;
  const _PositionCard({required this.pos});

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(pos.colorHex);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PositionDetailScreen(position: pos)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(60), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pos.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              pos.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pos.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pos.level,
                style: TextStyle(
                  color: color,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
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
    _Challenge('Cook a New Dish Together', '🍳', 'Pick a cuisine you\\'ve never tried and cook it from scratch together.', '1 Day', Color(0xFF30B0FF)),
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
  final ExploreService _service = ExploreService();
  late Future<List<KinkModel>> _kinksFuture;
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Sensory', 'Power Play', 'Roleplay', 'Bondage'];

  @override
  void initState() {
    super.initState();
    _kinksFuture = _service.getKinks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<KinkModel>>(
      future: _kinksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load kinks', style: TextStyle(color: Colors.white70)));
        }

        var kinks = snapshot.data ?? [];
        
        // Filter by search
        final query = _searchController.text.toLowerCase();
        if (query.isNotEmpty) {
          kinks = kinks.where((k) => k.title.toLowerCase().contains(query)).toList();
        }

        // Filter by category
        if (_selectedCategory != 'All') {
          kinks = kinks.where((k) => k.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
        }

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Search kinks...',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                  filled: true,
                  fillColor: const Color(0xFF161224),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            // Chip Filters
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF381B53) : const Color(0xFF1E1A29),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontFamily: 'Inter',
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Kinks List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: kinks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _KinkListCard(kink: kinks[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KinkListCard extends StatelessWidget {
  final KinkModel kink;
  const _KinkListCard({required this.kink});

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(kink.colorHex);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => KinkDetailScreen(kink: kink)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF221D32),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Square
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kink.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kink.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.favorite_border_rounded, color: Colors.white54, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${kink.likes}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          kink.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
