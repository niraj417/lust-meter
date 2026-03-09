import 'package:cloud_firestore/cloud_firestore.dart';

class KinkRequestModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String kinkId;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  KinkRequestModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.kinkId,
    required this.status,
    required this.createdAt,
  });

  factory KinkRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return KinkRequestModel(
      id: id,
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      kinkId: map['kinkId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'kinkId': kinkId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
