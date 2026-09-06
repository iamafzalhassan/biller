import 'thermal_paper.dart';

enum PrintTarget { system, thermal }

class PrinterSettings {
  static const PrinterSettings empty = PrinterSettings(address: '', name: '', paper: ThermalPaper.mm80, target: PrintTarget.system);

  final String address;
  final String name;

  final ThermalPaper paper;
  final PrintTarget target;

  const PrinterSettings({required this.address, required this.name, required this.paper, required this.target});

  bool get hasDevice => address.trim().isNotEmpty;

  bool get isThermal => target == PrintTarget.thermal;

  PrinterSettings copyWith({String? address, String? name, ThermalPaper? paper, PrintTarget? target}) =>
      PrinterSettings(address: address ?? this.address, name: name ?? this.name, paper: paper ?? this.paper, target: target ?? this.target);

  @override
  String toString() => 'PrinterSettings(${target.name}, $name, ${paper.label})';
}
