class BusinessProfile {
  static const int maxPhones = 3;

  static const List<String> defaultTerms = <String>[
    'Item may be repaired/replaced if returned within 60 days of purchase.',
    'A purchase invoice is required.',
    'No refunds will be issued. No liability for customer misuse.',
    'Goods are checked and accepted by the customer at the time of handover.',
    'Shortages or damage must be reported on the day of purchase.',
  ];

  static const BusinessProfile empty = BusinessProfile(
    addressBuilding: '',
    addressCity: '',
    addressNo: '',
    addressStreet: '',
    deviceId: 'A',
    invoicePrefix: 'INV',
    logoPath: '',
    name: '',
    ownerEmail: '',
    phones: <String>[],
    terms: defaultTerms,
  );

  final String addressBuilding;
  final String addressCity;
  final String addressNo;
  final String addressStreet;
  final String deviceId;
  final String invoicePrefix;
  final String logoPath;
  final String name;
  final String ownerEmail;

  final List<String> phones;
  final List<String> terms;

  const BusinessProfile({
    required this.addressBuilding,
    required this.addressCity,
    required this.addressNo,
    required this.addressStreet,
    required this.deviceId,
    required this.invoicePrefix,
    required this.logoPath,
    required this.name,
    required this.ownerEmail,
    required this.phones,
    required this.terms,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) => BusinessProfile(
    addressBuilding: json['addressBuilding'] as String? ?? '',
    addressCity: json['addressCity'] as String? ?? '',
    addressNo: json['addressNo'] as String? ?? '',
    addressStreet: json['addressStreet'] as String? ?? '',
    deviceId: json['deviceId'] as String? ?? 'A',
    invoicePrefix: json['invoicePrefix'] as String? ?? 'INV',
    logoPath: json['logoPath'] as String? ?? '',
    name: json['name'] as String? ?? '',
    ownerEmail: json['ownerEmail'] as String? ?? '',
    phones: _readPhones(json),
    terms: (json['terms'] as List<dynamic>?)?.map((dynamic e) => e as String).toList() ?? defaultTerms,
  );

  String get addressLine =>
      <String>[addressNo, addressStreet, addressCity, addressBuilding].map((String part) => part.trim()).where((String part) => part.isNotEmpty).join(', ');

  bool get hasLogo => logoPath.trim().isNotEmpty;

  String get phoneLine => printablePhones.map(_grouped).join('  |  ');

  List<String> get printablePhones => phones.map((String phone) => phone.trim()).where((String phone) => phone.isNotEmpty).take(maxPhones).toList();

  List<String> get printableTerms => terms.map((String term) => term.trim()).where((String term) => term.isNotEmpty).toList();

  BusinessProfile copyWith({
    String? addressBuilding,
    String? addressCity,
    String? addressNo,
    String? addressStreet,
    String? deviceId,
    String? invoicePrefix,
    String? logoPath,
    String? name,
    String? ownerEmail,
    List<String>? phones,
    List<String>? terms,
  }) => BusinessProfile(
    addressBuilding: addressBuilding ?? this.addressBuilding,
    addressCity: addressCity ?? this.addressCity,
    addressNo: addressNo ?? this.addressNo,
    addressStreet: addressStreet ?? this.addressStreet,
    deviceId: deviceId ?? this.deviceId,
    invoicePrefix: invoicePrefix ?? this.invoicePrefix,
    logoPath: logoPath ?? this.logoPath,
    name: name ?? this.name,
    ownerEmail: ownerEmail ?? this.ownerEmail,
    phones: phones ?? this.phones,
    terms: terms ?? this.terms,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'addressBuilding': addressBuilding,
    'addressCity': addressCity,
    'addressNo': addressNo,
    'addressStreet': addressStreet,
    'deviceId': deviceId,
    'invoicePrefix': invoicePrefix,
    'logoPath': logoPath,
    'name': name,
    'ownerEmail': ownerEmail,
    'phones': phones,
    'terms': terms,
  };

  static List<String> _readPhones(Map<String, dynamic> json) {
    final List<dynamic>? stored = json['phones'] as List<dynamic>?;
    if (stored != null) return stored.map((dynamic e) => e as String).where((String phone) => phone.trim().isNotEmpty).toList();
    final String legacy = json['phone'] as String? ?? '';
    return legacy.trim().isEmpty ? <String>[] : <String>[legacy.trim()];
  }

  static String _grouped(String phone) {
    final String digits = phone.replaceAll(RegExp('[^0-9]'), '');
    if (digits.length != 10) return phone;
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
  }

  @override
  String toString() => 'BusinessProfile($name, $invoicePrefix-$deviceId)';
}
