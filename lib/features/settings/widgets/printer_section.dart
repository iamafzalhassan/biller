import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/printer_settings.dart';
import '../../../models/thermal_paper.dart';

class PrinterSection extends StatelessWidget {
  const PrinterSection({super.key, required this.isLoadingDevices, required this.devices, required this.settings, required this.onTargetChanged, required this.onSelectDevice, required this.onPaperChanged, required this.onRefreshDevices});

  static const EdgeInsets tilePadding = EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding);

  final bool isLoadingDevices;

  final List<BluetoothInfo> devices;

  final PrinterSettings settings;

  final ValueChanged<PrintTarget> onTargetChanged;
  final ValueChanged<String> onSelectDevice;
  final ValueChanged<ThermalPaper> onPaperChanged;

  final VoidCallback onRefreshDevices;

  Widget _inset(Widget child) => Padding(padding: tilePadding, child: child);

  Widget _targetTile(PrintTarget target, String title, String subtitle) {
    return RadioListTile<PrintTarget>(
      contentPadding: tilePadding,
      groupValue: settings.target,
      onChanged: (PrintTarget? value) => value == null ? null : onTargetChanged(value),
      subtitle: Text(subtitle, style: AppTextStyles.listSecondary),
      title: Text(title, maxLines: 1, style: AppTextStyles.listPrimary),
      value: target,
    );
  }

  Widget _deviceList() {
    if (isLoadingDevices) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (devices.isEmpty) {
      return _inset(
        const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: Text('No paired printers found. Pair the printer in the phone Bluetooth settings first, then tap Refresh.', style: AppTextStyles.listSecondary),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final BluetoothInfo device in devices)
          RadioListTile<String>(
            contentPadding: tilePadding,
            groupValue: settings.address,
            onChanged: (String? value) => value == null ? null : onSelectDevice(value),
            subtitle: Text(device.macAdress, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.listSecondary),
            title: Text(device.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.listPrimary),
            value: device.macAdress,
          ),
      ],
    );
  }

  Widget _paperChooser() {
    return Row(
      children: <Widget>[
        for (final ThermalPaper paper in ThermalPaper.values) ...<Widget>[
          if (paper != ThermalPaper.values.first) const SizedBox(width: AppSpacing.md),
          Expanded(
            child: OutlinedButton(
              onPressed: () => onPaperChanged(paper),
              style: OutlinedButton.styleFrom(
                backgroundColor: settings.paper == paper ? AppColors.surfaceField : null,
                foregroundColor: settings.paper == paper ? AppColors.primary : AppColors.textSecondary,
                side: BorderSide(color: settings.paper == paper ? AppColors.primary : AppColors.divider),
              ),
              child: Text(paper.label, maxLines: 1),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _thermalOptions() {
    return <Widget>[
      const SizedBox(height: AppSpacing.md),
      _inset(const Text('PAPER WIDTH', maxLines: 1, style: AppTextStyles.overline)),
      const SizedBox(height: AppSpacing.sm),
      _inset(_paperChooser()),
      const SizedBox(height: AppSpacing.lg),
      _inset(
        Row(
          children: <Widget>[
            const Expanded(child: Text('PAIRED PRINTERS', maxLines: 1, style: AppTextStyles.overline)),
            TextButton.icon(
              icon: const Icon(Icons.refresh, size: AppSpacing.iconButton),
              label: const Text('Refresh', maxLines: 1),
              onPressed: isLoadingDevices ? null : onRefreshDevices,
            ),
          ],
        ),
      ),
      _deviceList(),
      if (!settings.hasDevice) _inset(const Text('Choose a printer, or bills cannot be printed.', style: AppTextStyles.errorHint)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _targetTile(PrintTarget.system, 'WiFi / system printer', 'Full A5 receipt through the Android print dialog. Works with any WiFi or shared printer.'),
        _targetTile(PrintTarget.thermal, 'Bluetooth thermal printer', 'Compact roll receipt sent straight to a paired 58 mm or 80 mm counter printer.'),
        if (settings.isThermal) ..._thermalOptions(),
      ],
    );
  }
}
