import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Admin({
    required this.id,
    required this.email,
    required this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Admin copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Admin(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Admin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Admin(
      id: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}