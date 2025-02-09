class Wilaya {
  final int number;
  final String name;

  const Wilaya({
    required this.number,
    required this.name,
  });
  String getImage() {
    return "assets/wilayas/$number.jpg";
  }
}
