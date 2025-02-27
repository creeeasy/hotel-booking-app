class RoomAvailability {
  final bool isAvailable;
  final DateTime? nextAvailableDate;

  RoomAvailability({
    required this.isAvailable,
    this.nextAvailableDate,
  });

  factory RoomAvailability.fromJson(Map<String, dynamic> json) {
    return RoomAvailability(
      isAvailable: json['isAvailable'],
      nextAvailableDate: json['nextAvailableDate'] != null
          ? DateTime.parse(json['nextAvailableDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'nextAvailableDate': nextAvailableDate?.toIso8601String(),
    };
  }
}
