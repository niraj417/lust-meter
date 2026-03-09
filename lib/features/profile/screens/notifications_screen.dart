import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/database_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/kink_request_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final db = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
      ),
      body: user == null
          ? Center(child: Text('Not logged in', style: Theme.of(context).textTheme.bodyLarge))
          : StreamBuilder<List<KinkRequestModel>>(
              stream: db.getReceivedKinkRequestsStream(user.uid),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                
                final requests = snapshot.data ?? [];
                
                if (requests.isEmpty) {
                  return Center(
                    child: Text('You have no notifications.', style: Theme.of(context).textTheme.bodyLarge),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (ctx, idx) {
                    final req = requests[idx];
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Someone wants to connect over a kink!',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await db.rejectKinkRequest(req.id);
                                  },
                                  style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                                  child: const Text('Decline'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    await db.acceptKinkRequest(req);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Accept'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
