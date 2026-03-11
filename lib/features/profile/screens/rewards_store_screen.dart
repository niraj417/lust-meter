import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../services/database_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';

class RewardsStoreScreen extends StatelessWidget {
  const RewardsStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rewards Store'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<UserModel?>(
              stream: DatabaseService().getUserStream(user.uid),
              builder: (context, snapshot) {
                final points = snapshot.data?.points ?? 0;
                
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _PointsCard(points: points),
                      ),
                    ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Available Rewards',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        delegate: SliverChildListDelegate([
                          _RewardItem(
                            title: 'Candlelight Dinner',
                            cost: 500,
                            icon: '🕯️',
                            color: Colors.orangeAccent,
                            isAvailable: points >= 500,
                          ),
                          _RewardItem(
                            title: 'Weekend Getaway',
                            cost: 2500,
                            icon: '✈️',
                            color: Colors.lightBlueAccent,
                            isAvailable: points >= 2500,
                          ),
                          _RewardItem(
                            title: 'Massage Coupon',
                            cost: 300,
                            icon: '💆‍♀️',
                            color: Colors.pinkAccent,
                            isAvailable: points >= 300,
                          ),
                          _RewardItem(
                            title: 'Movie Night',
                            cost: 200,
                            icon: '🍿',
                            color: Colors.redAccent,
                            isAvailable: points >= 200,
                          ),
                          _RewardItem(
                            title: 'Breakfast in Bed',
                            cost: 400,
                            icon: '🥐',
                            color: Colors.yellowAccent,
                            isAvailable: points >= 400,
                          ),
                          _RewardItem(
                            title: 'Dance Class',
                            cost: 800,
                            icon: '💃',
                            color: Colors.deepPurpleAccent,
                            isAvailable: points >= 800,
                          ),
                        ]),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
              },
            ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  final int points;
  const _PointsCard({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'Lust Points',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Icon(Icons.stars_rounded, color: Colors.white, size: 64),
        ],
      ),
    );
  }
}

class _RewardItem extends StatelessWidget {
  final String title;
  final int cost;
  final String icon;
  final Color color;
  final bool isAvailable;

  const _RewardItem({
    required this.title,
    required this.cost,
    required this.icon,
    required this.color,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isAvailable ? 1.0 : 0.5,
            child: Text(icon, style: const TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isAvailable ? AppColors.textPrimary : AppColors.textHint,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$cost pts',
              style: TextStyle(
                color: isAvailable ? color : AppColors.textHint,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
