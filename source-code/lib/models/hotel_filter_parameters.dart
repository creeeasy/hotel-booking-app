class HotelFilterParameters {
  final int? minRating;
  final int? maxRating;
  final int? minPrice;
  final int? minPeople;
  final int? maxPeople;
  final int? location;

  HotelFilterParameters({
    this.minRating,
    this.maxRating,
    this.minPrice,
    this.minPeople,
    this.maxPeople,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'minRating': minRating,
      'maxRating': maxRating,
      'minPrice': minPrice,
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
      minPeople: map['minPeople'] as int?,
      maxPeople: map['maxPeople'] as int?,
      location: map['location'] as int?,
    );
  }

  HotelFilterParameters copyWith({
    int? minRating,
    int? maxRating,
    int? minPrice,
    int? minPeople,
    int? maxPeople,
    int? location,
  }) {
    return HotelFilterParameters(
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      minPrice: minPrice ?? this.minPrice,
      minPeople: minPeople ?? this.minPeople,
      maxPeople: maxPeople ?? this.maxPeople,
      location: location ?? this.location,
    );
  }
}