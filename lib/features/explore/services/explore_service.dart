import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../models/kink_model.dart';
import '../models/position_model.dart';

class ExploreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<KinkModel>> getKinks() async {
    await _seedMockDataIfEmpty();
    final snapshot = await _firestore.collection(AppConstants.kinksCollection).get();
    return snapshot.docs.map((doc) => KinkModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<PositionModel>> getPositions() async {
    await _seedMockDataIfEmpty();
    final snapshot = await _firestore.collection(AppConstants.positionsCollection).get();
    return snapshot.docs.map((doc) => PositionModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> _seedMockDataIfEmpty() async {
    try {
      final kinksSnapshot = await _firestore.collection(AppConstants.kinksCollection).limit(1).get();
      if (kinksSnapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        
        // Mock Kinks
        final mockKinks = [
          {'title': 'Sex Toys', 'description': 'Incorporating vibrators, dildos, and other pleasure devices', 'category': 'Fetish', 'likes': 467, 'iconName': 'toys', 'colorHex': '21C990'},
          {'title': 'Dirty Talk', 'description': 'Verbal communication of desires and fantasies', 'category': 'Roleplay', 'likes': 445, 'iconName': 'chat', 'colorHex': 'FF8C42'},
          {'title': 'Praise Kink', 'description': 'Being aroused by compliments and positive affirmations', 'category': 'Power Play', 'likes': 423, 'iconName': 'star', 'colorHex': '9B30FF'},
          {'title': 'Massage & Body Worship', 'description': "Sensual touching and appreciation of partner's body", 'category': 'Sensory', 'likes': 412, 'iconName': 'spa', 'colorHex': 'E63950'},
          {'title': 'Light Bondage', 'description': 'Using silk ties, cuffs, or soft ropes playfully', 'category': 'Bondage', 'likes': 380, 'iconName': 'link', 'colorHex': '30B0FF'},
        ];

        for (var kink in mockKinks) {
          final docRef = _firestore.collection(AppConstants.kinksCollection).doc();
          batch.set(docRef, kink);
        }

        // Mock Positions
        final mockPositions = [
          {'name': 'The Spoon', 'emoji': '🥄', 'description': 'Intimate and cozy — perfect for a quiet night.', 'level': 'Beginner', 'colorHex': '9B30FF', 'detailedInstruction': 'Lie on your sides facing the same direction, with the larger partner wrapping their arms around the smaller partner.', 'tips': 'Maintain slow, steady rhythm. Great for lazy mornings.'},
          {'name': 'The Lotus', 'emoji': '🌸', 'description': 'Face-to-face connection that deepens emotional bond.', 'level': 'Intermediate', 'colorHex': 'E63950', 'detailedInstruction': 'One partner sits cross-legged while the other straddles them, wrapping their legs around the sitting partner’s waist.', 'tips': 'Requires some flexibility but offers incredible intimacy and eye contact.'},
          {'name': 'The Bridge', 'emoji': '🌉', 'description': 'A powerful pose with deep connection.', 'level': 'Intermediate', 'colorHex': 'FF8C42', 'detailedInstruction': 'Receiving partner lies back with hips elevated (perhaps on a pillow), while the penetrating partner kneels in front.', 'tips': 'Perfect for stimulating deeper zones and finding a new angle.'},
          {'name': 'The Butterfly', 'emoji': '🦋', 'description': 'Deep and passionate with full eye contact.', 'level': 'Beginner', 'colorHex': '30B0FF', 'detailedInstruction': 'Receiving partner lies on edge of bed with legs resting on partner’s shoulders.', 'tips': 'Great for achieving depth without too much physical exertion.'},
        ];

        for (var pos in mockPositions) {
          final docRef = _firestore.collection(AppConstants.positionsCollection).doc();
          batch.set(docRef, pos);
        }

        await batch.commit();
      }
    } catch (e) {
      // Ignore errors for seeding
    }
  }
}
