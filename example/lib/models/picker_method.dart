// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

/// Provide common usages of the picker.
/// 提供常见的选择器调用方式。
List<PickMethod> get pickMethods {
  return <PickMethod>[
    PickMethod(
      icon: '📷',
      name: 'Taking photos',
      description: 'Use cameras only to take photos.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(context),
    ),
    PickMethod(
      icon: '📹',
      name: 'Taking photos and videos',
      description: 'Use cameras to take photos and videos.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(enableRecording: true),
      ),
    ),
    PickMethod(
      icon: '🎥',
      name: 'Taking videos',
      description: 'Use cameras only to take videos.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(
          enableRecording: true,
          onlyEnableRecording: true,
        ),
      ),
    ),
    PickMethod(
      icon: '📽',
      name: 'Taking videos by tap',
      description: 'Use cameras only to take videos, but not with long-press, '
          'just a single tap.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(
          enableRecording: true,
          onlyEnableRecording: true,
          enableTapRecording: true,
        ),
      ),
    ),
    PickMethod(
      icon: '🈲',
      name: 'Silence recording',
      description: 'Make recordings silent.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(
          enableRecording: true,
          onlyEnableRecording: true,
          enableTapRecording: true,
          enableAudio: false,
        ),
      ),
    ),
    PickMethod(
      icon: '▶️',
      name: 'Auto preview videos',
      description: 'Play videos automatically in the preview after captured.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(
          enableRecording: true,
          onlyEnableRecording: true,
          enableTapRecording: true,
          shouldAutoPreviewVideo: true,
        ),
      ),
    ),
    PickMethod(
      icon: '⏳',
      name: 'No duration limit',
      description:
          'Record as long as you wish (if your device can stay alive)...',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(
          enableRecording: true,
          onlyEnableRecording: true,
          enableTapRecording: true,
          maximumRecordingDuration: null,
        ),
      ),
    ),
    PickMethod(
      icon: '🎨',
      name: 'Custom theme',
      description: 'Use a customized (different main color) theme.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: CameraPickerConfig(
          theme: CameraPicker.themeData(Colors.blue),
        ),
      ),
    ),
    PickMethod(
      icon: '↩️',
      name: 'Rotate picker in turns',
      description: 'Rotate the picker layout in quarter turns.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(cameraQuarterTurns: 1),
      ),
    ),
    PickMethod(
      icon: '🔍',
      name: 'Prevent scaling for camera preview',
      description: 'Camera preview will not be scaled to cover '
          'the whole screen of the device, only fit with the raw size.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(enableScaledPreview: false),
      ),
    ),
    PickMethod(
      icon: '🌀',
      name: 'Lower resolutions',
      description: 'Use a lower resolution preset might be helpful '
          'in some specific scenarios.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(
          resolutionPreset: ResolutionPreset.low,
        ),
      ),
    ),
    PickMethod(
      icon: '🤳',
      name: 'Prefer front camera',
      description: 'Use the front camera as the preferred lens direction, '
          'if the device has a front camera.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(
          preferredLensDirection: CameraLensDirection.front,
        ),
      ),
    ),
    PickMethod(
      icon: '🪄',
      name: 'Foreground builder',
      description: 'Build your widgets with the given CameraValue.',
      method: (BuildContext context) => CameraPicker.pickFromCamera(
        context,
        pickerConfig: CameraPickerConfig(
          foregroundBuilder: (
            BuildContext context,
            CameraController? controller,
          ) {
            return Center(
              child: Text(
                controller == null
                    ? 'Waiting for initialize...'
                    : '${controller.description.lensDirection}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    ),
  ];
}

/// Define a regular pick method.
class PickMethod {
  const PickMethod({
    required this.icon,
    required this.name,
    required this.description,
    required this.method,
    this.onLongPress,
  });

  final String icon;
  final String name;
  final String description;

  /// The core function that defines how to use the picker.
  final Future<AssetEntity?> Function(BuildContext context) method;

  final GestureLongPressCallback? onLongPress;
}
