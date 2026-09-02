import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/business_profile.dart';

class SettingsController extends Notifier<BusinessProfile> {
  @override
  BusinessProfile build() => ref.read(settingsRepositoryProvider).profile;

  Future<void> save(BusinessProfile profile) async {
    await ref.read(settingsRepositoryProvider).saveProfile(profile);
    state = profile;
    ref.invalidate(billingControllerProvider);
  }

  Future<void> completeSetup(BusinessProfile profile) async {
    await ref.read(settingsRepositoryProvider).saveProfile(profile);
    await ref.read(settingsRepositoryProvider).markSetupComplete();
    state = profile;
  }
}
