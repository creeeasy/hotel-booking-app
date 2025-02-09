class Hotel {
  final String id;
  final String name;
  final String email;

  Hotel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Hotel.fromFirestore(Map<String, dynamic> data) {
    return Hotel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
