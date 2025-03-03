import 'package:cloud_firestore/cloud_firestore.dart';

class RoomAvailability {
  final bool isAvailable;
  final DateTime? nextAvailableDate;

  RoomAvailability({
    required this.isAvailable,
    this.nextAvailableDate,
  });

  factory RoomAvailability.fromJson(Map<String, dynamic> json) {
    return RoomAvailability(
      isAvailable: json['isAvailable'] as bool? ?? false,
      nextAvailableDate: json['nextAvailableDate'] != null
          ? (json['nextAvailableDate'] is Timestamp)
              ? (json['nextAvailableDate'] as Timestamp).toDate()
              : DateTime.tryParse(json['nextAvailableDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'nextAvailableDate': nextAvailableDate != null
          ? Timestamp.fromDate(nextAvailableDate!)
          : null,
    };
  }
}
