import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/draft_repository.dart';
import '../data/repositories/receipt_storage_repository.dart';
import '../data/repositories/recent_invoices_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/sources/prefs_source.dart';
import '../data/sources/receipt_file_source.dart';
import '../data/sources/secure_storage_source.dart';
import '../data/sources/sqflite_source.dart';
import '../features/billing/controller/billing_controller.dart';
import '../features/billing/controller/billing_state.dart';
import '../features/recent/controller/recent_controller.dart';
import '../features/settings/controller/settings_controller.dart';
import '../features/setup/controller/setup_controller.dart';
import '../models/business_profile.dart';
import '../models/invoice.dart';

final Provider<PrefsSource> prefsSourceProvider = Provider<PrefsSource>(
  (Ref ref) => throw UnimplementedError('prefsSourceProvider must be overridden in main'),
);

final Provider<SecureStorageSource> secureStorageSourceProvider = Provider<SecureStorageSource>((Ref ref) => SecureStorageSource());

final Provider<SqfliteSource> sqfliteSourceProvider = Provider<SqfliteSource>((Ref ref) {
  final SqfliteSource source = SqfliteSource();
  ref.onDispose(source.close);
  return source;
});

final Provider<ReceiptFileSource> receiptFileSourceProvider = Provider<ReceiptFileSource>((Ref ref) => ReceiptFileSource());

final Provider<ReceiptStorageRepository> receiptStorageRepositoryProvider = Provider<ReceiptStorageRepository>(
  (Ref ref) => ReceiptStorageRepository(ref.watch(receiptFileSourceProvider)),
);

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((Ref ref) => AuthRepository(ref.watch(secureStorageSourceProvider)));

final Provider<DraftRepository> draftRepositoryProvider = Provider<DraftRepository>((Ref ref) {
  final DraftRepository repository = DraftRepository(ref.watch(prefsSourceProvider));
  ref.onDispose(repository.dispose);
  return repository;
});

final Provider<RecentInvoicesRepository> recentInvoicesRepositoryProvider = Provider<RecentInvoicesRepository>(
  (Ref ref) => RecentInvoicesRepository(ref.watch(sqfliteSourceProvider)),
);

final Provider<SettingsRepository> settingsRepositoryProvider = Provider<SettingsRepository>((Ref ref) => SettingsRepository(ref.watch(prefsSourceProvider)));

final NotifierProvider<BillingController, BillingState> billingControllerProvider = NotifierProvider<BillingController, BillingState>(BillingController.new);

final AsyncNotifierProvider<RecentController, List<Invoice>> recentControllerProvider = AsyncNotifierProvider<RecentController, List<Invoice>>(
  RecentController.new,
);

final NotifierProvider<SettingsController, BusinessProfile> settingsControllerProvider = NotifierProvider<SettingsController, BusinessProfile>(
  SettingsController.new,
);

final NotifierProvider<SetupController, BusinessProfile> setupControllerProvider = NotifierProvider<SetupController, BusinessProfile>(SetupController.new);
