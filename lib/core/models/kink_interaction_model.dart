class KinkInteractionModel {
  final String interactionId;
  final String userId;
  final String kinkId;
  final String status; // 'liked', 'disliked', 'tried', 'interested_multiplayer'
  final bool partnerMatch;

  KinkInteractionModel({
    required this.interactionId,
    required this.userId,
    required this.kinkId,
    required this.status,
    this.partnerMatch = false,
  });

  factory KinkInteractionModel.fromMap(Map<String, dynamic> map, String id) {
    return KinkInteractionModel(
      interactionId: id,
      userId: map['userId'] ?? '',
      kinkId: map['kinkId'] ?? '',
      status: map['status'] ?? '',
      partnerMatch: map['partnerMatch'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'kinkId': kinkId,
      'status': status,
      'partnerMatch': partnerMatch,
    };
  }
}
