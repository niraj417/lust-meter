import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/database_service.dart';
import '../../../../core/models/partner_connection_model.dart';
import '../../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final db = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
      ),
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<List<PartnerConnectionModel>>(
              stream: db.getUserConnectionsStream(user.uid),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final connections = snap.data ?? [];
                if (connections.isEmpty) {
                  return Center(child: Text('You have no active chats.', style: Theme.of(context).textTheme.bodyLarge));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: connections.length,
                  itemBuilder: (ctx, idx) {
                    final conn = connections[idx];
                    final otherUserId = conn.users.firstWhere((id) => id != user.uid, orElse: () => '');
                    
                    return FutureBuilder<UserModel?>(
                      future: db.getUser(otherUserId),
                      builder: (ctx, userSnap) {
                        final partner = userSnap.data;
                        final name = partner?.displayName ?? 'Unknown Partner';

                        return Card(
                          color: AppColors.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.2),
                              child: const Icon(Icons.person, color: AppColors.primary),
                            ),
                            title: Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary)),
                            subtitle: Text('Connected via ${conn.toMap()['type'] == 'kink' ? 'Kink' : 'Invite'}', style: Theme.of(context).textTheme.bodyMedium),
                            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                            onTap: () {
                              context.push(AppRoutes.chat.replaceFirst(':connectionId', conn.connectionId));
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
