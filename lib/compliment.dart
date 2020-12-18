class Compliment {
  Map<String, String> complimentMap = Map<String, String>();

  Compliment() {
    complimentMap['A'] = 'T';
    complimentMap['T'] = 'A';
    complimentMap['G'] = 'C';
    complimentMap['C'] = 'G';
    complimentMap['a'] = 't';
    complimentMap['t'] = 'a';
    complimentMap['g'] = 'c';
    complimentMap['c'] = 'g';
  }

  String operator [](String key) {
    return complimentMap[key];
  }
}
