///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/15 02:06
///
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

export 'package:photo_manager/photo_manager.dart';

export '../delegates/camera_picker_text_delegate.dart';
export '../utils/device_utils.dart';
export 'colors.dart';
export 'screens.dart';

class Constants {
  const Constants._();

  static CameraPickerTextDelegate textDelegate =
      DefaultCameraPickerTextDelegate();
}

/// Log only in debug mode.
/// 只在调试模式打印
void realDebugPrint(dynamic message) {
  if (!kReleaseMode) {
    log('$message');
  }
}

int get currentTimeStamp => DateTime.now().millisecondsSinceEpoch;

const BorderRadius maxBorderRadius = BorderRadius.all(Radius.circular(999999));