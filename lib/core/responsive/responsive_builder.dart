import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.phone, required this.tablet});

  final WidgetBuilder phone;
  final WidgetBuilder tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) => Breakpoints.isTabletWidth(constraints.maxWidth) ? tablet(context) : phone(context));
  }
}
