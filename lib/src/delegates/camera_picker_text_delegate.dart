///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/16 11:07
///
import 'package:camera/camera.dart' show CameraLensDirection, FlashMode;

/// Text delegate that controls text in widgets, implemented with Chinese.
/// 控制部件中的文字实现，中文。
class CameraPickerTextDelegate {
  /// Confirm string for the confirm button.
  /// 确认按钮的字段
  String get confirm => '确认';

  /// Tips string above the shooting button before shooting.
  /// 拍摄前确认按钮上方的提示文字
  String get shootingTips => '轻触拍照';

  /// Load failed string for item.
  /// 资源加载失败时的字段
  String get loadFailed => '加载失败';

  /// Semantics fields.
  ///
  /// Fields below are only for semantics usage. For customizable these fields,
  /// head over to [EnglishCameraPickerTextDelegate] for fields understanding.
  String get sActionManuallyFocusHint => '手动聚焦';

  String get sActionRecordHint => '录像';

  String get sActionShootHint => '拍照';

  String get sActionShootingButtonTooltip => '拍照按钮';

  String get sActionStopRecordingHint => '停止录像';

  String get sActionSwitchCameraTooltip => '切换摄像头';

  String get sActionToggleFlashModeTooltip => '切换闪光模式';

  String sCameraLensDirectionLabel(CameraLensDirection value) {
    final String _direction;
    switch (value) {
      case CameraLensDirection.front:
        _direction = '前置';
        break;
      case CameraLensDirection.back:
        _direction = '后置';
        break;
      case CameraLensDirection.external:
        _direction = '外置';
        break;
    }
    return '当前摄像头: $_direction';
  }

  String sFlashModeLabel(FlashMode mode) {
    final String _modeString;
    switch (mode) {
      case FlashMode.off:
        _modeString = '关闭';
        break;
      case FlashMode.auto:
        _modeString = '自动';
        break;
      case FlashMode.always:
        _modeString = '拍照时闪光';
        break;
      case FlashMode.torch:
        _modeString = '始终闪光';
        break;
    }
    return '当前闪光模式: $_modeString';
  }
}

/// Default text delegate including recording implements with Chinese.
/// 中文文字实现（包括摄像）
class CameraPickerTextDelegateWithRecording extends CameraPickerTextDelegate {
  @override
  String get shootingTips => '轻触拍照，长按摄像';
}

/// Default text delegate including only recording implements with Chinese.
/// 中文文字实现（仅摄像）
class CameraPickerTextDelegateWithOnlyRecording
    extends CameraPickerTextDelegate {
  @override
  String get shootingTips => '长按摄像';
}

/// Default text delegate including tap recording implements with Chinese.
/// 中文文字实现（仅轻触摄像）
class CameraPickerTextDelegateWithTapRecording
    extends CameraPickerTextDelegate {
  @override
  String get shootingTips => '轻触摄像';
}

/// Default text delegate implements with English.
/// 英文文字实现
class EnglishCameraPickerTextDelegate extends CameraPickerTextDelegate {
  @override
  String get confirm => 'Confirm';

  @override
  String get shootingTips => 'Tap to take photo.';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get sActionManuallyFocusHint => 'manually focus';

  @override
  String get sActionRecordHint => 'record';

  @override
  String get sActionShootHint => 'take picture';

  @override
  String get sActionShootingButtonTooltip => 'shooting button';

  @override
  String get sActionStopRecordingHint => 'stop recording';

  @override
  String get sActionSwitchCameraTooltip => 'switch camera';

  @override
  String get sActionToggleFlashModeTooltip => 'toggle flashlight';

  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) =>
      'Current camera lens direction: ${value.name}';

  @override
  String sFlashModeLabel(FlashMode mode) =>
      'Current flashlight mode: ${mode.name}';
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
