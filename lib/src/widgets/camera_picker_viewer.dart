// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../constants/config.dart';
import '../internals/singleton.dart';
import '../constants/enums.dart';
import '../states/camera_picker_viewer_state.dart';

class CameraPickerViewer extends StatefulWidget {
  const CameraPickerViewer._({
    // ignore: unused_element
    super.key,
    required this.viewType,
    required this.previewXFile,
    required this.pickerConfig,
    this.createViewerState,
  });

  /// The type of the viewer. (Image | Video)
  /// 预览的类型（图片或视频）
  final CameraPickerViewType viewType;

  /// The [XFile] of the preview file.
  /// 预览文件的 [XFile] 实例
  final XFile previewXFile;

  /// {@macro wechat_camera_picker.CameraPickerConfig}
  final CameraPickerConfig pickerConfig;

  /// Creates a customized [CameraPickerViewerState].
  /// 构建一个自定义的 [CameraPickerViewerState]。
  final CameraPickerViewerState Function()? createViewerState;

  /// Static method to push with the navigator.
  /// 跳转至选择预览的静态方法
  static Future<AssetEntity?> pushToViewer(
    BuildContext context, {
    required CameraPickerConfig pickerConfig,
    required CameraPickerViewType viewType,
    required XFile previewXFile,
    CameraPickerViewerState Function()? createViewerState,
    bool useRootNavigator = true,
  }) {
    return Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).push<AssetEntity?>(
      PageRouteBuilder<AssetEntity?>(
        pageBuilder: (_, __, ___) => CameraPickerViewer._(
          viewType: viewType,
          previewXFile: previewXFile,
          pickerConfig: pickerConfig,
          createViewerState: createViewerState,
        ),
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  CameraPickerViewerState createState() =>
      // ignore: no_logic_in_create_state
      createViewerState?.call() ?? CameraPickerViewerState();
}
