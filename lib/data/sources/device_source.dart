import '../../core/constants/app_channels.dart';

class DeviceSource {
  static const String methodAndroidId = 'androidId';

  late final String _androidId;

  String get androidId => _androidId;

  Future<void> init() async => _androidId = await _readAndroidId();

  Future<String> _readAndroidId() async {
    try {
      return await AppChannels.device.invokeMethod<String>(methodAndroidId) ?? '';
    } catch (_) {
      return '';
    }
  }
}
