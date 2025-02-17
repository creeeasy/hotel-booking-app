enum Wilaya {
  Adrar(1, "Adrar"),
  Chlef(2, "Chlef"),
  Laghouat(3, "Laghouat"),
  OumElBouaghi(4, "Oum El Bouaghi"),
  Batna(5, "Batna"),
  Bejaia(6, "Béjaïa"),
  Biskra(7, "Biskra"),
  Bechar(8, "Béchar"),
  Blida(9, "Blida"),
  Bouira(10, "Bouira"),
  Tamanrasset(11, "Tamanrasset"),
  Tebessa(12, "Tébessa"),
  Tlemcen(13, "Tlemcen"),
  Tiaret(14, "Tiaret"),
  TiziOuzou(15, "Tizi Ouzou"),
  Alger(16, "Alger"),
  Djelfa(17, "Djelfa"),
  Jijel(18, "Jijel"),
  Setif(19, "Sétif"),
  Saida(20, "Saïda"),
  Skikda(21, "Skikda"),
  SidiBelAbbes(22, "Sidi Bel Abbès"),
  Annaba(23, "Annaba"),
  Guelma(24, "Guelma"),
  Constantine(25, "Constantine"),
  Medea(26, "Médéa"),
  Mostaganem(27, "Mostaganem"),
  MSila(28, "M'Sila"),
  Mascara(29, "Mascara"),
  Ouargla(30, "Ouargla"),
  Oran(31, "Oran"),
  ElBayadh(32, "El Bayadh"),
  Illizi(33, "Illizi"),
  BordjBouArreridj(34, "Bordj Bou Arréridj"),
  Boumerdes(35, "Boumerdès"),
  ElTarf(36, "El Tarf"),
  Tindouf(37, "Tindouf"),
  Tissemsilt(38, "Tissemsilt"),
  ElOued(39, "El Oued"),
  Khenchela(40, "Khenchela"),
  SoukAhras(41, "Souk Ahras"),
  Tipaza(42, "Tipaza"),
  Mila(43, "Mila"),
  AinDefla(44, "Aïn Defla"),
  Naama(45, "Naâma"),
  AinTemouchent(46, "Aïn Témouchent"),
  Ghardaia(47, "Ghardaïa"),
  Relizane(48, "Relizane"),
  Timimoun(49, "Timimoun"),
  BordjBadjiMokhtar(50, "Bordj Badji Mokhtar"),
  OuledDjellal(51, "Ouled Djellal"),
  BeniAbbes(52, "Béni Abbès"),
  InSalah(53, "In Salah"),
  InGuezzam(54, "In Guezzam"),
  Touggourt(55, "Touggourt"),
  Djanet(56, "Djanet"),
  ElMghair(57, "El M'Ghair"),
  ElMeniaa(58, "El Meniaa");

  final int ind;
  final String name;

  const Wilaya(this.ind, this.name);
  static List<Wilaya> get wilayasList => Wilaya.values;
  static List<Wilaya> get getRandomWilayasList {
    List<Wilaya> shuffledList = List.from(wilayasList);
    shuffledList.shuffle();
    return shuffledList.take(5).toList();
  }

  static Wilaya? fromIndex(int index) {
    return Wilaya.values.firstWhere((wilaya) => wilaya.ind == index,
        orElse: () => throw ArgumentError("Invalid index"));
  }
}
