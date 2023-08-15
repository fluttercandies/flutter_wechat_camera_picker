<!-- Copyright 2019 The FlutterCandies author. All rights reserved.
Use of this source code is governed by an Apache license
that can be found in the LICENSE file. -->

# Migration Guide

This document gathered all breaking changes and migrations requirement between major versions.

## Versions

- [4.0.0](#400)

## 4.0.0

### Summary

> If you don't extend your customized `CameraPickerState`
> or you didn't override below methods, you can stop reading.

In order to sync the UI details with the latest WeChat style (v8.3.0),
few naming or signatures of methods are changed. including:
- `restartDisplayModeDisplayTimer`
- `buildBackButton`
- `buildCameraPreview`
- `buildCaptureButton`
- `buildFocusingPoint`
- `buildForegroundBody`

### Details

- `restartDisplayModeDisplayTimer` is renamed to `restartExposureModeDisplayTimer`.
- `buildBackButton` no more requires `BoxConstraints constraints` as an argument,
  the signature is `Widget buildBackButton(BuildContext context)` from now on.
- `buildCameraPreview` no more requires `DeviceOrientation orientation` as an argument
  since the implementation does not really use it.
  It now requires `CameraValue cameraValue` as an argument. So the signature becomes:
  ```dart
  Widget buildCameraPreview({
    required BuildContext context,
    required CameraValue cameraValue,
    required BoxConstraints constraints,
  })
  ```
- `buildCaptureButton` now requires `BuildContext context` as an argument. So the signature becomes:
  ```dart
  Widget buildCaptureButton(BuildContext context, BoxConstraints constraints)
  ```
- `buildFocusingPoint` now adds `int quarterTurns` to make internal quarter turns.
  So the signature becomes:
  ```dart
  Widget buildFocusingPoint({
    required CameraValue cameraValue,
    required BoxConstraints constraints,
    int quarterTurns = 0,
  })
  ```
- `buildForegroundBody` now adds `DeviceOrientation? deviceOrientation`
  to make responsive layouts according to the device orientation.
  So the signature becomes:
  ```dart
  Widget buildForegroundBody(
    BuildContext context,
    BoxConstraints constraints,
    DeviceOrientation? deviceOrientation,
  )
  ```
