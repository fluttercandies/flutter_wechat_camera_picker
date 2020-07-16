///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/15 02:06
///
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

export 'package:flutter_common_exports/flutter_common_exports.dart';
export 'package:photo_manager/photo_manager.dart';

export '../delegates/camera_picker_text_delegate.dart';
export 'colors.dart';

class Constants {
  const Constants._();

  static CameraPickerTextDelegate textDelegate =
      DefaultCameraPickerTextDelegate();
}
