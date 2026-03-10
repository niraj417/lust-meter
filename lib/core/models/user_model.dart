class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? partnerId;
  final int lustScore;
  final int emotionalScore;
  final int physicalScore;
  final int bondScore;
  final int streak;
  final int points;

  int get calculatedLustScore => ((emotionalScore + physicalScore + bondScore) / 3).round();

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.partnerId,
    this.lustScore = 0,
    this.emotionalScore = 0,
    this.physicalScore = 0,
    this.bondScore = 0,
    this.streak = 0,
    this.points = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? map['name'] ?? '',
      partnerId: map['partnerId'],
      lustScore: map['lustScore'] ?? 0,
      emotionalScore: map['emotionalScore'] ?? 0,
      physicalScore: map['physicalScore'] ?? 0,
      bondScore: map['bondScore'] ?? 0,
      streak: map['streak'] ?? map['dailyStreak'] ?? 0,
      points: map['points'] ?? map['totalPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'partnerId': partnerId,
      'lustScore': lustScore,
      'emotionalScore': emotionalScore,
      'physicalScore': physicalScore,
      'bondScore': bondScore,
      'streak': streak,
      'points': points,
    };
  }
}
