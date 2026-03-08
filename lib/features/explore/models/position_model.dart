class PositionModel {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String level;
  final String colorHex;
  final String detailedInstruction;
  final String tips;

  PositionModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.level,
    required this.colorHex,
    required this.detailedInstruction,
    required this.tips,
  });

  factory PositionModel.fromMap(Map<String, dynamic> map, String id) {
    return PositionModel(
      id: id,
      name: map['name'] ?? '',
      emoji: map['emoji'] ?? '🔥',
      description: map['description'] ?? '',
      level: map['level'] ?? 'Intermediate',
      colorHex: map['colorHex'] ?? 'E63950',
      detailedInstruction: map['detailedInstruction'] ?? '',
      tips: map['tips'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'emoji': emoji,
      'description': description,
      'level': level,
      'colorHex': colorHex,
      'detailedInstruction': detailedInstruction,
      'tips': tips,
    };
  }
}
