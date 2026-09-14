import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/repositories/activation_repository.dart';

class ActivationController extends Notifier<bool> {
  bool get isSetupComplete => ref.read(settingsRepositoryProvider).isSetupComplete;

  String get deviceCode => ref.read(activationRepositoryProvider).deviceCode;

  Future<bool> activate(String key) async {
    final ActivationRepository repository = ref.read(activationRepositoryProvider);
    if (!repository.isValidKey(key)) return false;
    await repository.saveKey(key);
    state = true;
    return true;
  }

  @override
  bool build() => ref.read(activationRepositoryProvider).isActivated;
}
