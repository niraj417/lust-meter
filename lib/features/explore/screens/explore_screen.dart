import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/kink_model.dart';
import '../models/position_model.dart';
import 'kink_detail_screen.dart';
import 'position_detail_screen.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../services/database_service.dart';
import '../models/challenge_model.dart';
import '../models/challenge_interaction_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/comments_bottom_sheet.dart';

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
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<PositionModel>>(
          stream: _dbService.getPositionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load positions', style: TextStyle(color: Colors.white70)));
            }
    
            final positions = snapshot.data ?? [];
            if (positions.isEmpty) {
              return const Center(
                child: Text('No positions yet.\nBe the first to suggest one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter')),
              );
            }
    
            return GridView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80), // Padding for FAB
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Adjusted for buttons
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: positions.length,
              itemBuilder: (_, i) => _PositionCard(pos: positions[i]),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddPositionModal(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Position', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
          ),
        ),
      ],
    );
  }

  void _showAddPositionModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final emojiCtrl = TextEditingController(text: '🔥');
    final instructionCtrl = TextEditingController();
    final tipsCtrl = TextEditingController();
    String selectedLevel = 'Intermediate';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Suggest New Position', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: emojiCtrl,
                              maxLength: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: const Color(0xFF161224),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: nameCtrl,
                              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                              decoration: InputDecoration(
                                hintText: 'Position Name',
                                hintStyle: const TextStyle(color: AppColors.textHint),
                                filled: true,
                                fillColor: const Color(0xFF161224),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Brief description...',
                          hintStyle: const TextStyle(color: AppColors.textHint),
                          filled: true,
                          fillColor: const Color(0xFF161224),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: instructionCtrl,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Detailed instructions...',
                          hintStyle: const TextStyle(color: AppColors.textHint),
                          filled: true,
                          fillColor: const Color(0xFF161224),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Difficulty Level', style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Inter')),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['Beginner', 'Intermediate', 'Advanced'].map((lvl) {
                          final isSel = lvl == selectedLevel;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedLevel = lvl),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primary.withOpacity(0.2) : const Color(0xFF161224),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSel ? AppColors.primary : Colors.transparent),
                              ),
                              child: Text(lvl, style: TextStyle(color: isSel ? Colors.white : Colors.white54, fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (nameCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) return;
                          
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final user = authProvider.user;
                          if (user == null) return;
                
                          final newPos = PositionModel(
                            id: '',
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            emoji: emojiCtrl.text.trim().isEmpty ? '🔥' : emojiCtrl.text.trim(),
                            level: selectedLevel,
                            colorHex: 'E63950', // Default
                            detailedInstruction: instructionCtrl.text.trim(),
                            tips: tipsCtrl.text.trim(),
                            likes: 0,
                            authorId: user.uid,
                            createdAt: DateTime.now(),
                          );
                
                          await _dbService.addPosition(newPos);
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add Position', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }
}

class _PositionCard extends StatelessWidget {
  final PositionModel pos;
  const _PositionCard({required this.pos});

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFE63950);
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(pos.colorHex);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PositionDetailScreen(position: pos)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(60), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(pos.emoji, style: const TextStyle(fontSize: 28)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pos.level,
                    style: TextStyle(
                      color: color,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pos.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                fontSize: 13,
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
                fontSize: 11,
              ),
            ),
            const Spacer(),
            if (user != null)
              StreamBuilder<bool>(
                stream: DatabaseService().getPositionInteractionStream(user.uid, pos.id),
                builder: (context, snapshot) {
                  final isLiked = snapshot.data ?? false;
                  return Row(
                    children: [
                      // Like
                      GestureDetector(
                        onTap: () {
                          DatabaseService().recordPositionInteraction(
                            user.uid,
                            pos.id,
                            isLiked: !isLiked,
                          );
                        },
                        child: Row(
                          children: [
                            Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                                 color: isLiked ? AppColors.primary : Colors.white54, size: 16),
                            const SizedBox(width: 4),
                            Text('${pos.likes}', style: TextStyle(
                              color: isLiked ? AppColors.primary : Colors.white54,
                              fontSize: 11, fontWeight: FontWeight.w500
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Comment
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => CommentsBottomSheet(
                              collection: AppConstants.positionsCollection,
                              documentId: pos.id,
                            ),
                          );
                        },
                        child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white54, size: 16),
                      ),
                    ],
                  );
                }
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Challenges ──────────────────────────────────────────────────────────────

// ─── Challenges ──────────────────────────────────────────────────────────────

class _ChallengesTab extends StatefulWidget {
  const _ChallengesTab();

  @override
  State<_ChallengesTab> createState() => _ChallengesTabState();
}

class _ChallengesTabState extends State<_ChallengesTab> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<ChallengeModel>>(
          stream: _dbService.getChallengesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load challenges', style: TextStyle(color: Colors.white70)));
            }

            final challenges = snapshot.data ?? [];
            if (challenges.isEmpty) {
              return const Center(
                child: Text('No challenges yet.\\nBe the first to add one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter')),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80), // Padding for FAB
              itemCount: challenges.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ChallengeCard(challenge: challenges[i]),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddChallengeModal(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Challenge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
          ),
        ),
      ],
    );
  }

  void _showAddChallengeModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final emojiCtrl = TextEditingController(text: '🔥');
    
    // Pick a random preset color
    final colors = ['E63950', '9B30FF', 'FF8C42', '30B0FF', '4DFF88'];
    colors.shuffle();
    final defaultColor = colors.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('New Challenge', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: emojiCtrl,
                        maxLength: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFF161224),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: titleCtrl,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Challenge Title',
                          hintStyle: const TextStyle(color: AppColors.textHint),
                          filled: true,
                          fillColor: const Color(0xFF161224),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                  decoration: InputDecoration(
                    hintText: 'Describe the challenge...',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    filled: true,
                    fillColor: const Color(0xFF161224),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) return;
                    
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final user = authProvider.user;
                    if (user == null) return;

                    final newChallenge = ChallengeModel(
                      id: '',
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      emoji: emojiCtrl.text.trim().isEmpty ? '🔥' : emojiCtrl.text.trim(),
                      duration: '',
                      colorHex: defaultColor,
                      likes: 0,
                      authorId: user.uid,
                      createdAt: DateTime.now(),
                    );

                    await _dbService.addChallenge(newChallenge);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Post Challenge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  const _ChallengeCard({required this.challenge});

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFE63950);
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final cColor = _parseColor(challenge.colorHex);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cColor.withAlpha(50), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
              color: cColor.withAlpha(25),
              borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(challenge.emoji, style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(challenge.title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                        fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: cColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(challenge.duration,
                    style: TextStyle(
                        color: cColor,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 11)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(challenge.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 13)),
            const SizedBox(height: 12),
            if (user != null)
              StreamBuilder<ChallengeInteractionModel?>(
                stream: DatabaseService().getChallengeInteractionStream(user.uid, challenge.id),
                builder: (context, snapshot) {
                  final interaction = snapshot.data;
                  final isLiked = interaction?.status == 'liked';
                  final isTried = interaction?.isTried == true;

                  return Row(
                    children: [
                      // Like Button
                      GestureDetector(
                        onTap: () {
                          DatabaseService().recordChallengeInteraction(
                            user.uid,
                            challenge.id,
                            // If it's already liked, tell the DB to unlike it (decrement)
                            isLiked: !isLiked,
                          );
                        },
                        child: Row(
                          children: [
                            Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                                 color: isLiked ? AppColors.primary : Colors.white54, size: 18),
                            const SizedBox(width: 4),
                            Text('${challenge.likes}', style: TextStyle(
                              color: isLiked ? AppColors.primary : Colors.white54,
                              fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Inter'
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Tried Button
                      GestureDetector(
                        onTap: () {
                          DatabaseService().recordChallengeInteraction(
                            user.uid,
                            challenge.id,
                            isTried: !isTried,
                          );
                        },
                        child: Row(
                          children: [
                            Icon(isTried ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded, 
                                 color: isTried ? Colors.greenAccent : Colors.white54, size: 18),
                            const SizedBox(width: 4),
                            Text('Tried', style: TextStyle(
                              color: isTried ? Colors.greenAccent : Colors.white54,
                              fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Inter'
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Comments Button
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => CommentsBottomSheet(
                              collection: AppConstants.challengesCollection,
                              documentId: challenge.id,
                            ),
                          );
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.chat_bubble_outline_rounded, 
                                 color: Colors.white54, size: 18),
                            SizedBox(width: 4),
                            Text('Comment', style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Inter'
                            )),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
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
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Sensory', 'Power Play', 'Roleplay', 'Bondage', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<KinkModel>>(
          stream: _dbService.getKinksFromDbStream(),
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
                  child: kinks.isEmpty 
                    ? const Center(child: Text('No kinks found', style: TextStyle(color: Colors.white54, fontFamily: 'Inter')))
                    : ListView.separated(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
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
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddKinkModal(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Kink', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
          ),
        ),
      ],
    );
  }

  void _showAddKinkModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final safetyTipsCtrl = TextEditingController();
    String selectedCategory = 'Other';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Add New Kink', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleCtrl,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Kink Title',
                          hintStyle: const TextStyle(color: AppColors.textHint),
                          filled: true,
                          fillColor: const Color(0xFF161224),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Description...',
                          hintStyle: const TextStyle(color: AppColors.textHint),
                          filled: true,
                          fillColor: const Color(0xFF161224),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: safetyTipsCtrl,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Safety tips (Optional)...',
                          hintStyle: const TextStyle(color: AppColors.textHint),
                          filled: true,
                          fillColor: const Color(0xFF161224),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Inter')),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.where((c) => c != 'All').map((cat) {
                          final isSel = cat == selectedCategory;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primary.withOpacity(0.2) : const Color(0xFF161224),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSel ? AppColors.primary : Colors.transparent),
                              ),
                              child: Text(cat, style: TextStyle(color: isSel ? Colors.white : Colors.white54, fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) return;
                          
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final user = authProvider.user;
                          if (user == null) return;
                
                          final newKink = KinkModel(
                            id: '',
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            category: selectedCategory,
                            likes: 0,
                            iconName: 'auto_awesome',
                            colorHex: '9B30FF', // Default
                            safetyTips: safetyTipsCtrl.text.trim(),
                            authorId: user.uid,
                            createdAt: DateTime.now(),
                          );
                
                          await _dbService.addKink(newKink);
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add Kink', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }
}

class _KinkListCard extends StatelessWidget {
  final KinkModel kink;
  const _KinkListCard({required this.kink});

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF9B30FF);
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(kink.colorHex);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

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
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: color,
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
                  if (user != null)
                    StreamBuilder<Map<String, bool>>(
                      stream: DatabaseService().getKinkInteractionStream(user.uid, kink.id),
                      builder: (context, snapshot) {
                        final interaction = snapshot.data ?? {'isLiked': false, 'isTried': false};
                        final isLiked = interaction['isLiked'] == true;
                        
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                DatabaseService().recordKinkInteraction(
                                  user.uid,
                                  kink.id,
                                  isLiked: !isLiked,
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                                       color: isLiked ? AppColors.primary : Colors.white54, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${kink.likes}',
                                    style: TextStyle(
                                      color: isLiked ? AppColors.primary : Colors.white54,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => CommentsBottomSheet(
                                    collection: AppConstants.kinksCollection,
                                    documentId: kink.id,
                                  ),
                                );
                              },
                              child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white54, size: 16),
                            ),
                            const Spacer(),
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
                        );
                      }
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
