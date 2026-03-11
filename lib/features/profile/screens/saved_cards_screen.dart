import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/database_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../explore/models/kink_model.dart';
import '../../explore/models/position_model.dart';
import '../../explore/screens/kink_detail_screen.dart';
import '../../explore/screens/position_detail_screen.dart';

class SavedCardsScreen extends StatefulWidget {
  const SavedCardsScreen({super.key});

  @override
  State<SavedCardsScreen> createState() => _SavedCardsScreenState();
}

class _SavedCardsScreenState extends State<SavedCardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Loved & Starred'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Positions'),
            Tab(text: 'Kinks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LikedPositionsList(userId: user.uid),
          _LikedKinksList(userId: user.uid),
        ],
      ),
    );
  }
}

class _LikedPositionsList extends StatelessWidget {
  final String userId;
  const _LikedPositionsList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PositionModel>>(
      stream: DatabaseService().getUserLikedPositionsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No liked positions yet', style: TextStyle(color: Colors.white54)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _PosListTile(pos: items[index]),
        );
      },
    );
  }
}

class _PosListTile extends StatelessWidget {
  final PositionModel pos;
  const _PosListTile({required this.pos});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PositionDetailScreen(position: pos))),
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(pos.emoji, style: const TextStyle(fontSize: 24))),
      ),
      title: Text(pos.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(pos.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
    );
  }
}

class _LikedKinksList extends StatelessWidget {
  final String userId;
  const _LikedKinksList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<KinkModel>>(
      stream: DatabaseService().getUserLikedKinksStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No liked kinks yet', style: TextStyle(color: Colors.white54)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _KinkListTile(kink: items[index]),
        );
      },
    );
  }
}

class _KinkListTile extends StatelessWidget {
  final KinkModel kink;
  const _KinkListTile({required this.kink});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KinkDetailScreen(kink: kink))),
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Icon(Icons.auto_awesome, color: AppColors.secondary, size: 24)),
      ),
      title: Text(kink.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(kink.category, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
    );
  }
}
