import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../services/database_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/kink_model.dart';

class KinkDetailScreen extends StatefulWidget {
  final KinkModel kink;
  const KinkDetailScreen({super.key, required this.kink});

  @override
  State<KinkDetailScreen> createState() => _KinkDetailScreenState();
}

class _KinkDetailScreenState extends State<KinkDetailScreen> {
  bool _isLiked = false;
  bool _isTried = false;

  @override
  void initState() {
    super.initState();
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(widget.kink.colorHex);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white54),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.kink.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),
            // Huge colored card with icon
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Description',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.kink.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),
            
            // Safety Tips Box (if any, otherwise we add a generic one)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2438), // slightly lighter than background, warm tint
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4A3F5E), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.error_outline_rounded, color: Colors.orangeAccent, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Safety Tips',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.kink.safetyTips ?? 'Clean before and after, use appropriate lubricant, start small.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      setState(() => _isLiked = !_isLiked);
                      final uid = context.read<AuthProvider>().user?.uid;
                      if (uid != null) {
                        try {
                          await DatabaseService().recordKinkInteraction(uid, widget.kink.id ?? widget.kink.title, _isLiked ? 'liked' : 'none');
                        } catch (_) {}
                      }
                    },
                    icon: Icon(
                      _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isLiked ? AppColors.primary : Colors.white,
                    ),
                    label: Text(
                      'Like',
                      style: TextStyle(
                        color: _isLiked ? AppColors.primary : Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: _isLiked ? AppColors.primary : Colors.white24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      setState(() => _isTried = !_isTried);
                      final uid = context.read<AuthProvider>().user?.uid;
                      if (uid != null) {
                        try {
                          await DatabaseService().recordKinkInteraction(uid, widget.kink.id ?? widget.kink.title, _isTried ? 'tried' : 'none');
                        } catch (_) {}
                      }
                    },
                    icon: Icon(
                      Icons.check_rounded,
                      color: _isTried ? Colors.white : Colors.white70,
                    ),
                    label: Text(
                      _isTried ? 'Tried It!' : 'Mark as Tried',
                      style: TextStyle(
                        color: _isTried ? Colors.white : Colors.white70,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTried ? AppColors.primary : const Color(0xFF2A2438),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
