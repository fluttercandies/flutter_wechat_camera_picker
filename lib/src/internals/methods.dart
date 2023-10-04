// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../constants/type_defs.dart';

/// Log only in debug mode.
/// 只在调试模式打印
void realDebugPrint(dynamic message) {
  if (!kReleaseMode) {
    log('$message', name: 'CameraPicker - LOG');
  }
}

void handleErrorWithHandler(
  Object e,
  StackTrace s,
  CameraErrorHandler? handler,
) {
  if (handler != null) {
    handler(e, s);
    return;
  }
  Error.throwWithStackTrace(e, s);
}

T? ambiguate<T>(T value) => value;
