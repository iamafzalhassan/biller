enum SetupStep {
  businessName,
  address,
  phones,
  email,
  terms,
  numbering,
  pin,
  recoveryCode;

  static int get count => SetupStep.values.length;

  static SetupStep get first => SetupStep.values.first;

  static SetupStep get last => SetupStep.values.last;

  bool get isFirst => this == first;

  bool get isLast => this == last;

  SetupStep get next => isLast ? this : SetupStep.values[index + 1];

  bool get opensKeyboard => this != SetupStep.terms && this != SetupStep.recoveryCode;

  int get position => index + 1;

  SetupStep get previous => isFirst ? this : SetupStep.values[index - 1];

  String get title => switch (this) {
    SetupStep.businessName => 'Business Name',
    SetupStep.address => 'Address',
    SetupStep.phones => 'Phone Numbers',
    SetupStep.email => 'Email',
    SetupStep.terms => 'Terms and Conditions',
    SetupStep.numbering => 'Invoice Numbering',
    SetupStep.pin => 'Set a 4-Digit PIN',
    SetupStep.recoveryCode => 'Write This Down',
  };
}
