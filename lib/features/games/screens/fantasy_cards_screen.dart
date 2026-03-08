import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../../core/theme/app_theme.dart';

class FantasyCardsScreen extends StatefulWidget {
  const FantasyCardsScreen({super.key});

  @override
  State<FantasyCardsScreen> createState() => _FantasyCardsScreenState();
}

class _FantasyCardsScreenState extends State<FantasyCardsScreen> {
  late CardSwiperController _controller;
  int _liked = 0;
  int _passed = 0;

  static const List<_FantasyCard> _cards = [
    _FantasyCard(
      emoji: '🌹',
      title: 'Candlelit Dinner',
      description:
          'Cook your partner\'s favourite meal from scratch, set the table romantically, and dine with no phones.',
      color: Color(0xFFE63950),
    ),
    _FantasyCard(
      emoji: '💆',
      title: 'Spa Night',
      description:
          'Give each other full-body massages with scented oils. Take turns and take your time.',
      color: Color(0xFF9B30FF),
    ),
    _FantasyCard(
      emoji: '🌙',
      title: 'Midnight Picnic',
      description:
          'Pack blankets and snacks, head somewhere quiet under the stars, and just talk about everything.',
      color: Color(0xFF30B0FF),
    ),
    _FantasyCard(
      emoji: '🎲',
      title: 'Couples Game Night',
      description:
          'Pick a board game or card game and bet on dares/tasks the loser must complete.',
      color: Color(0xFFFF8C42),
    ),
    _FantasyCard(
      emoji: '🛁',
      title: 'Bubble Bath Ritual',
      description:
          'Run a warm bath with essential oils, play soft music, and sip something together.',
      color: Color(0xFF4DFFB4),
    ),
    _FantasyCard(
      emoji: '📸',
      title: 'Boudoir Shoot',
      description:
          'Dress your best, set up lighting, and take a private couples photoshoot.',
      color: Color(0xFFFFD700),
    ),
    _FantasyCard(
      emoji: '🏕️',
      title: 'Camping Under Stars',
      description:
          'Escape the city for one night. Stargazing, a campfire, storytelling, and just each other.',
      color: Color(0xFF4DFF88),
    ),
    _FantasyCard(
      emoji: '💌',
      title: 'Love Letter Exchange',
      description:
          'Each write a heartfelt letter to the other. Swap and read them aloud. Keep them forever.',
      color: Color(0xFFFF6B9D),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = CardSwiperController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fantasy Cards 🃏'),
        backgroundColor: AppColors.background,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Stats bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatChip(
                    icon: Icons.favorite_rounded,
                    value: _liked,
                    color: AppColors.primary),
                const SizedBox(width: 24),
                _StatChip(
                    icon: Icons.close_rounded,
                    value: _passed,
                    color: AppColors.textHint),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Card swiper
          Expanded(
            child: CardSwiper(
              controller: _controller,
              cardsCount: _cards.length,
              onSwipe: (prev, curr, dir) {
                setState(() {
                  if (dir == CardSwiperDirection.right) {
                    _liked++;
                  } else {
                    _passed++;
                  }
                });
                return true;
              },
              numberOfCardsDisplayed: 3,
              backCardOffset: const Offset(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              cardBuilder: (ctx, idx, percentX, percentY) {
                final card = _cards[idx % _cards.length];
                return _FantasyCardWidget(card: card);
              },
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.close_rounded,
                  color: AppColors.textHint,
                  onTap: () => _controller.swipe(CardSwiperDirection.left),
                ),
                _ActionButton(
                  icon: Icons.favorite_rounded,
                  color: AppColors.primary,
                  onTap: () => _controller.swipe(CardSwiperDirection.right),
                  large: true,
                ),
                _ActionButton(
                  icon: Icons.star_rounded,
                  color: AppColors.goldAccent,
                  onTap: () => _controller.swipe(CardSwiperDirection.top),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FantasyCard {
  final String emoji;
  final String title;
  final String description;
  final Color color;
  const _FantasyCard(
      {required this.emoji,
      required this.title,
      required this.description,
      required this.color});
}

class _FantasyCardWidget extends StatelessWidget {
  final _FantasyCard card;
  const _FantasyCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            card.color.withAlpha(200),
            card.color.withAlpha(100),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: card.color.withAlpha(80), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: card.color.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(card.emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 24),
            Text(
              card.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              card.description,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                fontFamily: 'Inter',
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_left_rounded,
                    color: Colors.white38, size: 20),
                const SizedBox(width: 8),
                Text('Swipe to explore',
                    style: TextStyle(
                        color: Colors.white38,
                        fontFamily: 'Inter',
                        fontSize: 12)),
                const SizedBox(width: 8),
                Icon(Icons.swipe_right_rounded,
                    color: Colors.white38, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  const _StatChip(
      {required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 6),
      Text('$value',
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              fontSize: 16)),
    ]);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool large;
  const _ActionButton(
      {required this.icon,
      required this.color,
      required this.onTap,
      this.large = false});

  @override
  Widget build(BuildContext context) {
    final size = large ? 70.0 : 54.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(30),
          border: Border.all(color: color, width: 2),
          boxShadow: large
              ? [
                  BoxShadow(
                      color: color.withAlpha(80),
                      blurRadius: 20,
                      spreadRadius: 2)
                ]
              : null,
        ),
        child: Icon(icon, color: color, size: large ? 34 : 26),
      ),
    );
  }
}
