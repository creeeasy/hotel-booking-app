class HotelFilterParameters {
  final int? minRating;
  final int? maxRating;
  final int? minPrice;
  final int? maxPrice;
  final int? minPeople;
  final int? maxPeople;
  final int? location;

  const HotelFilterParameters({
    this.minRating,
    this.maxRating,
    this.minPrice,
    this.maxPrice,
    this.minPeople,
    this.maxPeople,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'minRating': minRating,
      'maxRating': maxRating,
      'minPrice': minPrice,
      'maxPrice': maxPrice, // Added this line
      'minPeople': minPeople,
      'maxPeople': maxPeople,
      'location': location,
    };
  }

  factory HotelFilterParameters.fromMap(Map<String, dynamic> map) {
    return HotelFilterParameters(
      minRating: map['minRating'] as int?,
      maxRating: map['maxRating'] as int?,
      minPrice: map['minPrice'] as int?,
      maxPrice: map['maxPrice'] as int?, // Added this line
      minPeople: map['minPeople'] as int?,
      maxPeople: map['maxPeople'] as int?,
      location: map['location'] as int?,
    );
  }

  HotelFilterParameters copyWith({
    int? minRating,
    int? maxRating,
    int? minPrice,
    int? maxPrice, // Added this parameter
    int? minPeople,
    int? maxPeople,
    int? location,
  }) {
    return HotelFilterParameters(
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice, // Added this line
      minPeople: minPeople ?? this.minPeople,
      maxPeople: maxPeople ?? this.maxPeople,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HotelFilterParameters &&
        other.minRating == minRating &&
        other.maxRating == maxRating &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice && // Added this line
        other.minPeople == minPeople &&
        other.maxPeople == maxPeople &&
        other.location == location;
  }

  @override
  int get hashCode {
    return minRating.hashCode ^
        maxRating.hashCode ^
        minPrice.hashCode ^
        maxPrice.hashCode ^ // Added this line
        minPeople.hashCode ^
        maxPeople.hashCode ^
        location.hashCode;
  }
}
