enum FilterOption {
  rating("Rating"),
  price("Price"),
  minPeople("Min. People"),
  location("Localisation");

  final String displayName;

  const FilterOption(this.displayName);
}
