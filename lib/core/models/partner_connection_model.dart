import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerConnectionModel {
  final String connectionId;
  final List<String> users;
  final String status; // 'pending', 'active', 'rejected'
  final DateTime createdAt;

  PartnerConnectionModel({
    required this.connectionId,
    required this.users,
    required this.status,
    required this.createdAt,
  });

  factory PartnerConnectionModel.fromMap(Map<String, dynamic> map, String id) {
    return PartnerConnectionModel(
      connectionId: id,
      users: List<String>.from(map['users'] ?? []),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'users': users,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
