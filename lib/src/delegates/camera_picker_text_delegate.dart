// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:camera/camera.dart' show CameraLensDirection, FlashMode;
import 'package:flutter/rendering.dart';

/// All text delegates.
const List<CameraPickerTextDelegate> cameraPickerTextDelegates =
    <CameraPickerTextDelegate>[
  CameraPickerTextDelegate(),
  EnglishCameraPickerTextDelegate(),
  VietnameseCameraPickerTextDelegate(),
];

/// Obtain the text delegate from the given locale.
CameraPickerTextDelegate cameraPickerTextDelegateFromLocale(Locale? locale) {
  if (locale == null) {
    return const CameraPickerTextDelegate();
  }
  final String languageCode = locale.languageCode.toLowerCase();
  for (final CameraPickerTextDelegate delegate in cameraPickerTextDelegates) {
    if (delegate.languageCode == languageCode) {
      return delegate;
    }
  }
  return const CameraPickerTextDelegate();
}

/// Text delegate implemented with Chinese.
/// 中文文字实现
class CameraPickerTextDelegate {
  const CameraPickerTextDelegate();

  String get languageCode => 'zh';

  /// Confirm string for the confirm button.
  /// 确认按钮的字段
  String get confirm => '确认';

  /// Tips above the shooting button before shooting.
  /// 拍摄前确认按钮上方的提示文字
  String get shootingTips => '轻触拍照';

  /// Tips with recording above the shooting button before shooting.
  /// 拍摄前确认按钮上方的提示文字（带录像）
  String get shootingWithRecordingTips => '轻触拍照，长按摄像';

  /// Tips with only recording above the shooting button before shooting.
  /// 拍摄前确认按钮上方的提示文字（仅录像）
  String get shootingOnlyRecordingTips => '长按摄像';

  /// Tips with tap recording above the shooting button before shooting.
  /// 拍摄前确认按钮上方的提示文字（点击录像）
  String get shootingTapRecordingTips => '轻触摄像';

  /// Load failed string for item.
  /// 资源加载失败时的字段
  String get loadFailed => '加载失败';

  /// Default loading string for the dialog.
  /// 加载中弹窗的默认文字
  String get loading => '加载中…';

  /// Saving string for the dialog.
  /// 保存中弹窗的默认文字
  String get saving => '保存中…';

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
    final String modeString;
    switch (mode) {
      case FlashMode.off:
        modeString = '关闭';
        break;
      case FlashMode.auto:
        modeString = '自动';
        break;
      case FlashMode.always:
        modeString = '拍照时闪光';
        break;
      case FlashMode.torch:
        modeString = '始终闪光';
        break;
    }
    return '闪光模式: $modeString';
  }

  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) {
    return '切换至${sCameraLensDirectionLabel(value)}摄像头';
  }
}

/// Text delegate implements with English.
class EnglishCameraPickerTextDelegate extends CameraPickerTextDelegate {
  const EnglishCameraPickerTextDelegate();

  @override
  String get languageCode => 'en';

  @override
  String get confirm => 'Confirm';

  @override
  String get shootingTips => 'Tap to take photo.';

  @override
  String get shootingWithRecordingTips =>
      'Tap to take photo. Long press to record video.';

  @override
  String get shootingOnlyRecordingTips => 'Long press to record video.';

  @override
  String get shootingTapRecordingTips => 'Tap to record video.';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get loading => 'Loading...';

  @override
  String get saving => 'Saving...';

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

/// Text delegate implemented with Vietnamese.
/// Dịch tiếng Việt
class VietnameseCameraPickerTextDelegate extends CameraPickerTextDelegate {
  const VietnameseCameraPickerTextDelegate();

  @override
  String get languageCode => 'vi';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get shootingTips => 'Chạm để chụp ảnh.';

  @override
  String get shootingWithRecordingTips =>
      'Chạm để chụp ảnh. Giữ để quay video.';

  @override
  String get shootingOnlyRecordingTips => 'Giữ để quay video.';

  @override
  String get shootingTapRecordingTips => 'Chạm để quay video.';

  @override
  String get loadFailed => 'Tải thất bại';

  @override
  String get loading => 'Đang tải...';

  @override
  String get saving => 'Đang lưu...';

  @override
  String get sActionManuallyFocusHint => 'lấy nét bằng tay';

  @override
  String get sActionPreviewHint => 'xem trước';

  @override
  String get sActionRecordHint => 'quay';

  @override
  String get sActionShootHint => 'chụp';

  @override
  String get sActionShootingButtonTooltip => 'nút chụp';

  @override
  String get sActionStopRecordingHint => 'dừng quay';

  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) {
    switch (value) {
      case CameraLensDirection.front:
        return 'trước';
      case CameraLensDirection.back:
        return 'sau';
      case CameraLensDirection.external:
        return 'ngoài';
    }
  }

  @override
  String? sCameraPreviewLabel(CameraLensDirection? value) {
    if (value == null) {
      return null;
    }
    return 'Xem trước camera ${sCameraLensDirectionLabel(value)}';
  }

  @override
  String sFlashModeLabel(FlashMode mode) {
    final String modeString;
    switch (mode) {
      case FlashMode.off:
        modeString = 'Tắt';
        break;
      case FlashMode.auto:
        modeString = 'Tự động';
        break;
      case FlashMode.always:
        modeString = 'Luôn bật đèn flash khi chụp ảnh';
        break;
      case FlashMode.torch:
        modeString = 'Luôn bật đèn flash';
        break;
    }
    return 'Chế độ đèn flash: $modeString';
  }

  @override
  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) =>
      'Chuyển sang camera ${sCameraLensDirectionLabel(value)}';
}
