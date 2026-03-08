import 'package:cloud_firestore/cloud_firestore.dart';

class GameSessionModel {
  final String sessionId;
  final String gameType; // 'truth_or_dare', 'spin_wheel', 'fantasy_cards', 'quiz'
  final List<String> participants;
  final int pointsAwarded;
  final DateTime playedAt;

  GameSessionModel({
    required this.sessionId,
    required this.gameType,
    required this.participants,
    required this.pointsAwarded,
    required this.playedAt,
  });

  factory GameSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return GameSessionModel(
      sessionId: id,
      gameType: map['gameType'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      pointsAwarded: map['pointsAwarded'] ?? 0,
      playedAt: (map['playedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameType': gameType,
      'participants': participants,
      'pointsAwarded': pointsAwarded,
      'playedAt': Timestamp.fromDate(playedAt),
    };
  }
}
