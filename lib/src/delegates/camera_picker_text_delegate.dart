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
  /// head over to [EnglishCameraPickerTextDelegate] for better understanding.
  String get sActionManuallyFocusHint => '手动聚焦';

  String get sActionPreviewHint => '预览';

  String get sActionRecordHint => '录像';

  String get sActionShootHint => '拍照';

  String get sActionShootingButtonTooltip => '拍照按钮';

  String get sActionStopRecordingHint => '停止录像';

  String sCameraLensDirectionLabel(CameraLensDirection value) {
    switch (value) {
      case CameraLensDirection.front:
        return '前置';
      case CameraLensDirection.back:
        return '后置';
      case CameraLensDirection.external:
        return '外置';
    }
  }

  String? sCameraPreviewLabel(CameraLensDirection? value) {
    if (value == null) {
      return null;
    }
    return '${sCameraLensDirectionLabel(value)}画面预览';
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
    return '闪光模式: $_modeString';
  }

  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) {
    return '切换至${sCameraLensDirectionLabel(value)}摄像头';
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
  String get sActionPreviewHint => 'preview';

  @override
  String get sActionRecordHint => 'record';

  @override
  String get sActionShootHint => 'take picture';

  @override
  String get sActionShootingButtonTooltip => 'shooting button';

  @override
  String get sActionStopRecordingHint => 'stop recording';

  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) => value.name;

  @override
  String? sCameraPreviewLabel(CameraLensDirection? value) {
    if (value == null) {
      return null;
    }
    return '${sCameraLensDirectionLabel(value)} camera preview';
  }

  @override
  String sFlashModeLabel(FlashMode mode) => 'Flash mode: ${mode.name}';

  @override
  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) =>
      'Switch to the ${sCameraLensDirectionLabel(value)} camera';
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
