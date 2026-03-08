class DoctorModel {
  final String doctorId;
  final String name;
  final String specialty;
  final String photoUrl;
  final double rating;
  final bool isOnline;

  DoctorModel({
    required this.doctorId,
    required this.name,
    required this.specialty,
    required this.photoUrl,
    required this.rating,
    this.isOnline = false,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      doctorId: id,
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      isOnline: map['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'photoUrl': photoUrl,
      'rating': rating,
      'isOnline': isOnline,
    };
  }
}
