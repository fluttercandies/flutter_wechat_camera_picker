///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/9/30 17:04
///
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../internals/enums.dart';

/// {@template wechat_camera_picker.EntitySaveCallback}
/// The callback type define for saving entity in the viewer.
/// 在查看器中保存图片时的回调
///
/// ### Notice about the implementation
///  * After the callback is implemented, the default saving method
///    won't called anymore.
///  * Don't call `Navigator.of(context).pop/maybePop` without popping `null` or
///    `AssetEntity`, otherwise there will be a type cast error occurred.
///
/// ### 在实现时需要注意
///  * 实现该方法后，原本的保存方法不会再被调用；
///  * 不要使用 `Navigator.of(context).pop/maybePop` 返回 `null` 或 `AssetEntity`
///    以外类型的内容，否则会抛出类型转换异常。
/// {@endtemplate}
typedef EntitySaveCallback = FutureOr<dynamic> Function({
  BuildContext context,
  CameraPickerViewType viewType,
  File file,
});

/// {@template wechat_camera_picker.CameraErrorHandler}
/// The error handler when any error occurred during the picking process.
/// 拍摄照片过程中的自定义错误处理
/// {@endtemplate}
typedef CameraErrorHandler = void Function(
  Object error,
  StackTrace? stackTrace,
);
