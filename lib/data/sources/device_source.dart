import '../../core/constants/app_channels.dart';

class DeviceSource {
  static const String methodAndroidId = 'androidId';

  late final String androidId;

  Future<void> init() async => androidId = await _readAndroidId();

  Future<String> _readAndroidId() async {
    try {
      return await AppChannels.device.invokeMethod<String>(methodAndroidId) ?? '';
    } catch (_) {
      return '';
    }
  }
}
