enum ThermalPaper {
  mm58,
  mm80;

  static ThermalPaper fromName(String? name) => ThermalPaper.values.firstWhere((ThermalPaper paper) => paper.name == name, orElse: () => ThermalPaper.mm80);

  String get label => this == ThermalPaper.mm58 ? '58 mm' : '80 mm';
}
