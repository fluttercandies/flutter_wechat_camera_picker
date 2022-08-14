// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/config.dart';
import '../constants/constants.dart';
import '../states/camera_picker_state.dart';

import 'camera_picker_page_route.dart';

/// The camera picker widget.
/// 拍照选择器。
///
/// The picker provides create an [AssetEntity] through the [CameraController].
/// 该选择器可以通过 [CameraController] 创建 [AssetEntity]。
class CameraPicker extends StatefulWidget {
  const CameraPicker({
    Key? key,
    this.pickerConfig = const CameraPickerConfig(),
    this.createPickerState,
    this.locale,
  }) : super(key: key);

  /// {@macro wechat_camera_picker.CameraPickerConfig}
  final CameraPickerConfig pickerConfig;

  /// Creates a customized [CameraPickerState].
  /// 构建一个自定义的 [CameraPickerState]。
  final CameraPickerState Function()? createPickerState;

  /// The [Locale] to determine text delegates for the picker.
  final Locale? locale;

  /// Static method to create [AssetEntity] through camera.
  /// 通过相机创建 [AssetEntity] 的静态方法
  static Future<AssetEntity?> pickFromCamera(
    BuildContext context, {
    CameraPickerConfig pickerConfig = const CameraPickerConfig(),
    CameraPickerState Function()? createPickerState,
    bool useRootNavigator = true,
    CameraPickerPageRoute<AssetEntity> Function(Widget picker)?
        pageRouteBuilder,
    Locale? locale,
  }) {
    final Widget picker = CameraPicker(
      pickerConfig: pickerConfig,
      createPickerState: createPickerState,
      locale: locale,
    );
    return Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).push<AssetEntity>(
      pageRouteBuilder?.call(picker) ??
          CameraPickerPageRoute<AssetEntity>(builder: (_) => picker),
    );
  }

  /// Build a dark theme according to the theme color.
  /// 通过主题色构建一个默认的暗黑主题
  static ThemeData themeData(Color themeColor) {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.grey[900],
      primaryColorLight: Colors.grey[900],
      primaryColorDark: Colors.grey[900],
      canvasColor: Colors.grey[850],
      scaffoldBackgroundColor: Colors.grey[900],
      bottomAppBarColor: Colors.grey[900],
      cardColor: Colors.grey[900],
      highlightColor: Colors.transparent,
      toggleableActiveColor: themeColor,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: themeColor,
        selectionColor: themeColor.withAlpha(100),
        selectionHandleColor: themeColor,
      ),
      indicatorColor: themeColor,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        elevation: 0,
      ),
      buttonTheme: ButtonThemeData(buttonColor: themeColor),
      colorScheme: ColorScheme(
        primary: Colors.grey[900]!,
        primaryVariant: Colors.grey[900],
        secondary: themeColor,
        secondaryVariant: themeColor,
        background: Colors.grey[900]!,
        surface: Colors.grey[900]!,
        brightness: Brightness.dark,
        error: const Color(0xffcf6679),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
      ),
    );
  }

  @override
  CameraPickerState createState() =>
      // ignore: no_logic_in_create_state
      createPickerState?.call() ?? CameraPickerState();
}
