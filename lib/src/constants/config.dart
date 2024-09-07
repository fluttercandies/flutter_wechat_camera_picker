// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../delegates/camera_picker_text_delegate.dart';
import 'type_defs.dart';

/// {@template wechat_camera_picker.CameraPickerConfig}
/// Configurations for the [CameraPicker].
/// [CameraPicker] 的配置项
/// {@endtemplate}
final class CameraPickerConfig {
  const CameraPickerConfig({
    this.enableRecording = false,
    this.onlyEnableRecording = false,
    this.enableTapRecording = false,
    this.enableAudio = true,
    this.enableSetExposure = true,
    this.enableExposureControlOnPoint = true,
    this.enablePinchToZoom = true,
    this.enablePullToZoomInRecord = true,
    this.enableScaledPreview = false,
    this.shouldDeletePreviewFile = false,
    this.shouldAutoPreviewVideo = true,
    this.maximumRecordingDuration = const Duration(seconds: 15),
    this.minimumRecordingDuration = const Duration(seconds: 1),
    this.theme,
    this.textDelegate,
    this.cameraQuarterTurns = 0,
    this.resolutionPreset = ResolutionPreset.ultraHigh,
    this.imageFormatGroup = ImageFormatGroup.unknown,
    this.preferredLensDirection = CameraLensDirection.back,
    this.preferredFlashMode = FlashMode.off,
    this.lockCaptureOrientation,
    this.foregroundBuilder,
    this.previewTransformBuilder,
    this.onEntitySaving,
    this.onError,
    this.onXFileCaptured,
    this.onMinimumRecordDurationNotMet,
  }) : assert(
          enableRecording == true || onlyEnableRecording != true,
          'Recording mode error.',
        );

  /// Whether the picker can record video.
  /// 选择器是否可以录像
  final bool enableRecording;

  /// Whether the picker can record video only.
  /// 选择器是否只可以录像
  final bool onlyEnableRecording;

  /// Whether allow the record can start with single tap.
  /// 选择器是否可以单击录像
  ///
  /// It only works when [onlyEnableRecording] is true.
  /// 仅在 [onlyEnableRecording] 为 true 时生效。
  final bool enableTapRecording;

  /// Whether the picker should record audio.
  /// 选择器录像时是否需要录制声音
  final bool enableAudio;

  /// Whether users can set the exposure point by tapping.
  /// 用户是否可以在界面上通过点击设定曝光点
  final bool enableSetExposure;

  /// Whether users can adjust exposure according to the set point.
  /// 用户是否可以根据已经设置的曝光点调节曝光度
  final bool enableExposureControlOnPoint;

  /// Whether users can zoom the camera by pinch.
  /// 用户是否可以在界面上双指缩放相机对焦
  final bool enablePinchToZoom;

  /// Whether users can zoom by pulling up when recording video.
  /// 用户是否可以在录制视频时上拉缩放
  final bool enablePullToZoomInRecord;

  /// Whether the camera preview should be scaled during captures.
  /// 拍摄过程中相机预览是否需要缩放
  final bool enableScaledPreview;

  /// {@template wechat_camera_picker.shouldDeletePreviewFile}
  /// Whether the preview file will be delete when pop.
  /// 返回页面时是否删除预览文件
  /// {@endtemplate}
  final bool shouldDeletePreviewFile;

  /// {@template wechat_camera_picker.shouldAutoPreviewVideo}
  /// Whether the video should be played instantly in the preview.
  /// 在预览时是否直接播放视频
  /// {@endtemplate}
  final bool shouldAutoPreviewVideo;

  /// The maximum duration of the video recording process.
  /// 录制视频最长时长
  ///
  /// Defaults to 15 seconds, allow `null` for unrestricted video recording.
  /// 默认为 15 秒，可以使用 `null` 来设置无限制的视频录制
  final Duration? maximumRecordingDuration;

  /// The minimum duration of the video recording process.
  /// 录制视频最短时长。
  ///
  /// Defaults to and cannot be lower than 1 second.
  /// 默认且不能少于 1 秒。
  final Duration minimumRecordingDuration;

  /// Theme data for the picker.
  /// 选择器的主题
  final ThemeData? theme;

  /// The number of clockwise quarter turns the camera view should be rotated.
  /// 摄像机视图顺时针旋转次数，每次90度
  final int cameraQuarterTurns;

  /// Text delegate that controls text in widgets.
  /// 控制部件中的文字实现
  final CameraPickerTextDelegate? textDelegate;

  /// Present resolution for the camera.
  /// 相机的分辨率预设
  final ResolutionPreset resolutionPreset;

  /// The [ImageFormatGroup] describes the output of the raw image format.
  /// 输出图像的格式描述
  final ImageFormatGroup imageFormatGroup;

  /// Which lens direction is preferred when first using the camera,
  /// typically with the front or the back direction.
  /// 首次使用相机时首选的镜头方向，通常是前置或后置。
  final CameraLensDirection preferredLensDirection;

  /// {@macro wechat_camera_picker.ForegroundBuilder}
  final ForegroundBuilder? foregroundBuilder;

  /// {@macro wechat_camera_picker.PreviewTransformBuilder}
  final PreviewTransformBuilder? previewTransformBuilder;

  /// Whether the camera should be locked to the specific orientation
  /// during captures.
  /// 摄像机在拍摄时锁定的旋转角度
  final DeviceOrientation? lockCaptureOrientation;

  /// Which flash mode is preferred when first using the camera,
  /// typically with the auto mode.
  /// 首次使用相机时首选的闪光灯，通常是自动模式。
  final FlashMode preferredFlashMode;

  /// {@macro wechat_camera_picker.EntitySaveCallback}
  final EntitySaveCallback? onEntitySaving;

  /// {@macro wechat_camera_picker.CameraErrorHandler}
  final CameraErrorHandler? onError;

  /// {@macro wechat_camera_picker.XFileCapturedCallback}
  final XFileCapturedCallback? onXFileCaptured;

  /// The callback when the recording is not met the minimum recording duration.
  /// 录制时长未达到最小时长时的回调方法。
  final VoidCallback? onMinimumRecordDurationNotMet;
}
