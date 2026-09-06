import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/business_profile.dart';

class SetupController extends Notifier<BusinessProfile> {
  void update(BusinessProfile profile) => state = profile;

  Future<String> finish(String pin) async {
    await ref.read(settingsControllerProvider.notifier).completeSetup(state);
    return ref.read(authRepositoryProvider).setPin(pin);
  }

  @override
  BusinessProfile build() => BusinessProfile.empty;
}
