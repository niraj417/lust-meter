import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/database_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';
import 'package:provider/provider.dart';

class KinkPartnersScreen extends StatefulWidget {
  final String kinkId;
  const KinkPartnersScreen({super.key, required this.kinkId});

  @override
  State<KinkPartnersScreen> createState() => _KinkPartnersScreenState();
}

class _KinkPartnersScreenState extends State<KinkPartnersScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  List<UserModel> _partners = [];
  Set<String> _sentRequests = {};

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) return;
      final users = await _db.getUsersInterestedInKink(widget.kinkId, user.uid);
      if (mounted) {
        setState(() {
          _partners = users;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendRequest(String partnerId) async {
    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) return;
      
      setState(() => _sentRequests.add(partnerId));
      await _db.sendKinkRequest(user.uid, partnerId, widget.kinkId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent!')),
        );
      }
    } catch (_) {
      setState(() => _sentRequests.remove(partnerId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interested Partners', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _partners.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No other users have expressed interest in this yet.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _partners.length,
                  itemBuilder: (ctx, idx) {
                    final partner = _partners[idx];
                    final hasSent = _sentRequests.contains(partner.uid);
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        tileColor: const Color(0xFF2A2438),
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: const Icon(Icons.person, color: AppColors.primary),
                        ),
                        title: Text(partner.displayName.isNotEmpty ? partner.displayName : 'Anonymous User', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary)),
                        subtitle: Text('Lust Score: ${partner.lustScore}', style: Theme.of(context).textTheme.bodyMedium),
                        trailing: ElevatedButton(
                          onPressed: hasSent ? null : () => _sendRequest(partner.uid),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasSent ? AppColors.surfaceElevated : AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(hasSent ? 'Sent' : 'Connect'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
