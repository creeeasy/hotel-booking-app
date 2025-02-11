class WilayaModel {
  final int number;
  final String name;

  const WilayaModel({
    required this.number,
    required this.name,
  });

  String getImage() {
    return "assets/wilayas/$number.jpg";
  }
}
