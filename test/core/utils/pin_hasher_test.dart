import 'package:biller/core/utils/pin_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PinHasher', () {
    test('stores a salted hash instead of the PIN', () {
      final String stored = PinHasher.hash('4821');

      expect(stored, isNot(contains('4821')));
      expect(PinHasher.isHashed(stored), isTrue);
    });

    test('matches the original PIN only', () {
      final String stored = PinHasher.hash('4821');

      expect(PinHasher.matches('4821', stored), isTrue);
      expect(PinHasher.matches('4822', stored), isFalse);
      expect(PinHasher.matches('', stored), isFalse);
    });

    test('uses a fresh salt for every hash of the same PIN', () {
      final String first = PinHasher.hash('4821');
      final String second = PinHasher.hash('4821');

      expect(first, isNot(second));
      expect(PinHasher.matches('4821', first), isTrue);
      expect(PinHasher.matches('4821', second), isTrue);
    });

    test('rejects a stored value that is not a hash', () {
      expect(PinHasher.isHashed('4821'), isFalse);
      expect(PinHasher.matches('4821', '4821'), isFalse);
    });
  });
}
