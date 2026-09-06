abstract final class Validators {
  static const int pinLength = 4;

  static final RegExp _deviceId = RegExp(r'^[A-Z]$');
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phone = RegExp(r'^0[0-9]{9}$');
  static final RegExp _pin = RegExp('^[0-9]{$pinLength}\$');

  static bool isBlank(String? value) => value == null || value.trim().isEmpty;

  static bool isValidPin(String value) => _pin.hasMatch(value);

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  static bool isValidDeviceId(String value) => _deviceId.hasMatch(value.trim());

  static bool isValidPhone(String value) => value.trim().isEmpty || _phone.hasMatch(value.trim());
}
