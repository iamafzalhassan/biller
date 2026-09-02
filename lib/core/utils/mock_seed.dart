import '../../models/business_profile.dart';

abstract final class MockSeed {
  static const String pin = '1111';

  static const BusinessProfile profile = BusinessProfile(
    addressBuilding: '',
    addressCity: 'COLOMBO 01100',
    addressNo: '108',
    addressStreet: 'PRINCE STREET',
    deviceId: 'A',
    invoicePrefix: 'INV',
    name: 'KYTE INTERNATIONAL',
    ownerEmail: 'owner@kyteinternational.lk',
    phone: '077 666 4616',
    terms: BusinessProfile.defaultTerms,
  );
}
