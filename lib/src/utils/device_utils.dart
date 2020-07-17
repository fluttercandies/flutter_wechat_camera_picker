///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/17 10:09
///
import 'dart:io';

import 'package:device_info/device_info.dart';

export 'package:device_info/device_info.dart';

class DeviceUtils {
  const DeviceUtils._();

  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static dynamic deviceInfo;

  static Future<void> getDeviceInfo() async {
    if (Platform.isAndroid) {
      deviceInfo = await _deviceInfoPlugin.androidInfo;
    } else if (Platform.isIOS) {
      deviceInfo = await _deviceInfoPlugin.iosInfo;
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  static bool get isLowerThanAndroidQ {
    return (deviceInfo as AndroidDeviceInfo).version.sdkInt < 29;
  }
}
