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
  FrenchCameraPickerTextDelegate(),
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

/// Text delegate implements with French.
class FrenchCameraPickerTextDelegate extends CameraPickerTextDelegate {
  const FrenchCameraPickerTextDelegate();

  @override
  String get languageCode => 'fr';

  @override
  String get confirm => 'Confirmer';

  @override
  String get shootingTips => 'Appuyez pour prendre une photo.';

  @override
  String get shootingWithRecordingTips =>
      'Appuyez pour prendre une photo. Appuyez longuement pour enregistrer la vidéo.';

  @override
  String get shootingOnlyRecordingTips => 'Long press to record video.';

  @override
  String get shootingTapRecordingTips =>
      'Appuyez longuement pour enregistrer la vidéo.';

  @override
  String get loadFailed => 'Échec du chargement';

  @override
  String get sActionManuallyFocusHint => 'mise au point manuelle';

  @override
  String get sActionPreviewHint => 'Aperçu';

  @override
  String get sActionRecordHint => 'enregistrer';

  @override
  String get sActionShootHint => 'prendre une photo';

  @override
  String get sActionShootingButtonTooltip => 'bouton de prise de vue';

  @override
  String get sActionStopRecordingHint => "arrêter l'enregistrement";

  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) {
    switch (value) {
      case CameraLensDirection.back:
        return 'arrière';
      case CameraLensDirection.front:
        return 'frontale';
      case CameraLensDirection.external:
        return 'externe';
      default:
        return value.name;
    }
  }

  @override
  String? sCameraPreviewLabel(CameraLensDirection? value) {
    if (value == null) {
      return null;
    }
    return 'aperçu de la caméra ${sCameraLensDirectionLabel(value)}';
  }

  @override
  String sFlashModeLabel(FlashMode mode) => 'Mode flash: ${mode.name}';

  @override
  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) =>
      'Basculer vers la caméra ${sCameraLensDirectionLabel(value)}>';
}
