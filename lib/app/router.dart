import 'package:flutter/material.dart';

import '../features/billing/view/billing_screen.dart';
import '../features/preview/view/preview_screen.dart';
import '../features/recent/view/recent_screen.dart';
import '../features/settings/view/settings_screen.dart';
import '../features/setup/view/setup_screen.dart';

abstract final class Routes {
  static const String preview = '/preview';
  static const String recent = '/recent';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get map => <String, WidgetBuilder>{
    preview: (BuildContext context) => const PreviewScreen(),
    recent: (BuildContext context) => const RecentScreen(),
    settings: (BuildContext context) => const SettingsScreen(),
  };

  static Route<void> billing() => MaterialPageRoute<void>(builder: (BuildContext context) => const BillingScreen());

  static Route<void> setup() => MaterialPageRoute<void>(builder: (BuildContext context) => const SetupScreen());
}
