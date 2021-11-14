///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/16 11:07
///

/// Text delegate that controls text in widgets.
/// 控制部件中的文字实现
abstract class CameraPickerTextDelegate {
  /// Confirm string for the confirm button.
  /// 确认按钮的字段
  String get confirm;

  /// Tips string above the shooting button before shooting.
  /// 拍摄前确认按钮上方的提示文字
  String get shootingTips;

  /// Load failed string for item.
  /// 资源加载失败时的字段
  String get loadFailed;
}

/// Default text delegate implements with Chinese.
/// 中文文字实现
class DefaultCameraPickerTextDelegate extends CameraPickerTextDelegate {
  @override
  String get confirm => '确认';

  @override
  String get shootingTips => '轻触拍照';

  @override
  String get loadFailed => '加载失败';
}

/// Default text delegate including recording implements with Chinese.
/// 中文文字实现（包括摄像）
class DefaultCameraPickerTextDelegateWithRecording
    extends DefaultCameraPickerTextDelegate {
  @override
  String get shootingTips => '轻触拍照，长按摄像';
}

/// Default text delegate including only recording implements with Chinese.
/// 中文文字实现（仅摄像）
class DefaultCameraPickerTextDelegateWithOnlyRecording
    extends DefaultCameraPickerTextDelegate {
  @override
  String get shootingTips => '长按摄像';
}

/// Default text delegate including tap recording implements with Chinese.
/// 中文文字实现（仅轻触摄像）
class DefaultCameraPickerTextDelegateWithTapRecording
    extends DefaultCameraPickerTextDelegate {
  @override
  String get shootingTips => '轻触摄像';
}

/// Default text delegate implements with English.
/// 英文文字实现
class EnglishCameraPickerTextDelegate implements CameraPickerTextDelegate {
  @override
  String get confirm => 'Confirm';

  @override
  String get shootingTips => 'Tap to take photo.';

  @override
  String get loadFailed => 'Load failed';
}

/// Default text delegate including recording implements with English.
/// 英文文字实现（包括摄像）
class EnglishCameraPickerTextDelegateWithRecording
    extends EnglishCameraPickerTextDelegate {
  @override
  String get shootingTips => 'Tap to take photo. Long press to record video.';
}

/// Default text delegate including only recording implements with English.
/// 英文文字实现（仅摄像）
class EnglishCameraPickerTextDelegateWithOnlyRecording
    extends EnglishCameraPickerTextDelegate {
  @override
  String get shootingTips => 'Long press to record video.';
}

/// Default text delegate including tap recording implements with English.
/// 英文文字实现（仅轻触摄像）
class EnglishCameraPickerTextDelegateWithTapRecording
    extends EnglishCameraPickerTextDelegate {
  @override
  String get shootingTips => 'Tap to record video.';
}
