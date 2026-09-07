import 'thermal_paper.dart';

enum PrintTarget { system, thermal }

class PrinterSettings {
  static const PrinterSettings empty = PrinterSettings(address: '', name: '', target: PrintTarget.system, paper: ThermalPaper.mm80);

  final String address;
  final String name;

  final PrintTarget target;

  final ThermalPaper paper;

  const PrinterSettings({required this.address, required this.name, required this.target, required this.paper});

  bool get hasDevice => address.trim().isNotEmpty;

  bool get isThermal => target == PrintTarget.thermal;

  PrinterSettings copyWith({String? address, String? name, PrintTarget? target, ThermalPaper? paper}) => PrinterSettings(address: address ?? this.address, name: name ?? this.name, target: target ?? this.target, paper: paper ?? this.paper);

  @override
  String toString() => 'PrinterSettings(${target.name}, $name, ${paper.label})';
}
