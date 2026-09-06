import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/business_profile.dart';

class SettingsController extends Notifier<BusinessProfile> {
  Future<void> save(BusinessProfile profile) async {
    await ref.read(settingsRepositoryProvider).saveProfile(profile);
    state = profile;
  }

  Future<void> completeSetup(BusinessProfile profile) async {
    await ref.read(settingsRepositoryProvider).saveProfile(profile);
    await ref.read(settingsRepositoryProvider).markSetupComplete();
    state = profile;
    ref.invalidate(billingControllerProvider);
  }

  @override
  BusinessProfile build() => ref.read(settingsRepositoryProvider).profile;
}
