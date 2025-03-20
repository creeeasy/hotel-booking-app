List<String> generateSearchKeywords(String input) {
  final words = input.toLowerCase().split(' ');
  final keywords = <String>{};

  for (int i = 0; i < words.length; i++) {
    for (int j = i; j < words.length; j++) {
      keywords.add(words.sublist(i, j + 1).join(' '));
    }
  }

  return keywords.toList();
}
