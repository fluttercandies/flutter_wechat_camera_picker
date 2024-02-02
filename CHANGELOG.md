<!-- Copyright 2019 The FlutterCandies author. All rights reserved.
Use of this source code is governed by an Apache license
that can be found in the LICENSE file. -->

# Changelog

See the [Migration Guide](guides/migration_guide.md) for breaking changes between versions.

## 4.2.0-dev.4

### Improvements

- Use `wechat_picker_library`.

## 4.2.0-dev.3

### Improvements

- Roll `sensors_plus`.
- Catch exceptions when obtain/subscribe to the accelerometer stream.

## 4.2.0-dev.2

### Breaking changes

- Migrate to Flutter 3.16, and drop supports for previous Flutter versions.

### Fixes

- Fix `onEntitySaving` not returned after called. (#223)

## 4.2.0-dev.1

### New features

- Bump `photo_manager` to v3.x.
- Export `photo_manager_image_provider`.

## 4.1.0

### New features

- Automatically determine the capture orientation and lock accordingly.

### Fixes

- Handle exceptions after all flows.
- Fix various problems with the capture button.

## 4.0.3

### Fixes

- Prevent duplicate shooting actions.

### Improvements

- Provide overall invalid wrapping for controller methods.
- Throw exceptions with more accurate stack traces.

## 4.0.2

### Fixes

- Handles exceptions if locking methods are failed.

## 4.0.1

### Fixes

- Fix uncaught exceptions for controller methods.

## 4.0.0

To know more about breaking changes, see [Migration Guide][].

### New features

- Migrate to Flutter 3.3, and drop supports for previous Flutter versions.
- Sync all UI details from WeChat 8.3.x. (#181)

### Improvements

- Adapt layouts according to the device orientation.
- Improve the performance when taking photos.
- Improve the experience when using the exposure slider.
- Prefer `FlashMode.off` for better performance.
- Allow `cameras` to be set repeatedly.

### Fixes

- Fix accessibility on the switch cameras button.

## 3.8.0

### New features

- Add Vietnamese language text delegate. (#166).
- Add `CameraPickerConfig.minimumRecordingDuration`. (#168)

### Improvements

- Hide the loading widget in the preview until an actual saving process has been invoked.
- Remove the implied system UI overlay manipulations.
- Raise the lowest SDK constraint to 2.8.0.

## 3.7.0

### New features

- Add `preferredFlashMode`, allowing users to choose which flash mode is preferred when first using the camera. (#158)

### Improvements

- Allow flash modes failed to switch and can move on to next when switching. (#156)

### Fixes

- Fix lifecycle integrations with the camera preview. (#157)

## 3.6.5

### Fixes

- Correct sizes when using `cameraQuarterTurns`. (#149)

## 3.6.4

### Improvements

- Improve stop-capturing experiences. (#146)
- Precache captured images for better experiences. (#145)

## 3.6.3

### Improvements

- Add the loading indicator when saving. (#140)

## 3.6.2

### Improvements

- Bump `photo_manager` to explicitly remove the requirements of `requiredLegacyExternalStorage`.

## 3.6.1

### New features

- Add torch flashlight support. (#137)

## 3.6.0

### New features

- Upgrade `camera` to `0.10.x`. (#133)
- Upgrade `photo_maanger` for Android 13. (#133)

## 3.5.0+1

### Fixes

- Fix the too early `widget` access in `CameraPickerState`. (#124)

## 3.5.0

### New features

- Support customize UI by override `State`s. (#113)

### Improvements

- Expose multiple internal widgets. (#113)
- Re-export `CameraPicker`'s constructor. (#116)
- Avoid duplicate entity saving. (#117)
- Prevent switching cameras when taking picture or recording video. (#120)

## 3.4.0

### New features

- Add `enableScaledPreview`. (#108)

### Improvements

- Catch more errors with handler. (#110)
- Improve tapping exposure updates. (#109)
- Prevent unnecessary zoom updates. (#107)

## 3.3.0

### Breaking Changes

- Allow the foreground builder to be used all the time (#97) .
  The signature of the `ForegroundBuilder` has changed
  but can be easily migrated.

### Improvements

- Allow text delegates to be obtained by `Locale`. (#99)

## 3.2.0+1

### New features

- Support Flutter 3.

## 3.1.0

### New features

- Add `onXFileCaptured`. (#87)

## 3.0.4

### Fixes

- Unify the method to push to the viewer. (#86)

## 3.0.3

### Fixes

- Correct arguments of `EntitySaveCallback`. (#85)

## 3.0.2

### Improvements

- Export enums and typedefs.

## 3.0.1

### Fixes

- Remove redundant dispose with the controller.

## 3.0.0

### New features

- Add full semantics support. (#72)
- Add `lockCaptureOrientation`, allowing users to determine lock to the specific orientation during captures. (#68)
- Export `CameraPickerPageRoute`.
- Abstract `CamearPickerConfig`, which moved all arguments from `pickFromCamera` to `pickerConfig`.

### Improvements

- Improve camera initializes by adding a lock.
- Tweak asynchronous methods call during initializations.
- Make camera controllers available as soon as possible.

### Fixes

- Fix scaling issues with turns and orientations.
- Fix lint issues on Flutter 2.10.

## 2.6.5

- Remove duplicate future requests when saving an entity.

## 2.6.4

- Drop initialize when the controller has been already initialized. (#70)

## 2.6.3

- Fix set exposure point crashes when switching between cameras. (#66)

## 2.6.2

- Bind circular progress color with the theme.

## 2.6.1

- Allow saving entities when the permission is limited on iOS.

## 2.6.0

- Add `preferredLensDirection`, allowing users to choose which lens direction is preferred when first using the camera.
- Add `enableTapRecording`, allowing users to determine whether to allow the record can start with a single tap.
- Add `shouldAutoPreviewVideo`, allowing users to determine whether the video should be played instantly in the preview.

## 2.5.2

- Request the permission state again when saving.
- Provide better experiences when video records need to be prepared.

## 2.5.1

- Fix invalid widgets binding observer caller.

## 2.5.0

- Add `onError` to handle errors during the picking process.
- `SaveEntityCallback` -> `EntitySaveCallback`.
- Improve folder structure of the plugin.

## 2.4.2

- Flip the preview if the user is using a front camera.

## 2.4.1

- Handle save exceptions more gracefully.
- Dispose the controller when previewing for better performance.

## 2.4.0

- Bump `camera` to `0.9.x` .
- Remove `shouldLockPortrait` in picking.

## 2.3.1

- Expose `enablePullToZoomInRecord` for the `pickFromCamera` method.
- Trigger shooting preparation only when start recording on iOS.

## 2.3.0

- Expose `useRootNavigator` while picking.
- Initialize a new controller if failed to stop recording. (#39)
- Throw or rethrow exceptions that used to be caught. (#41)
- Update the back icon with preview.
- Enhance video capture on iOS with preparation.

## 2.2.0

- Add `EntitySaveCallback` for the custom save method.

## 2.1.2

- Improve the UI of the exposure point widget when manually focus.

## 2.1.1

- Use basename when saving entities.

## 2.1.0

- Add `shouldLockPortrait` to fit orientation for the device.
- Fix exposure offset issue when resetting the exposure point after adjusting the exposure offset manually.

## 2.0.0

### New Features

- Add `enableSetExposure`, allowing users to update the exposure from the point tapped on the screen.
- Add `enableExposureControlOnPoint`, allowing users to control the exposure offset with an offset slide from the exposure point.
- Add `enablePinchToZoom`, allowing users to zoom by pinching the screen.
- Add `enablePullToZoomInRecord`, allowing users to zoom by pulling up when recording video.
- Add `foregroundBuilder`, allowing users to build customized widgets beyond the camera preview.
- Add `shouldDeletePreviewFile`, allowing users to choose whether the captured file should be deleted.
- Sync `imageFormatGroup` from the `camera` plugin.

### Breaking Changes

- Migrate to non-nullable by default.
- `isAllowRecording` -> `enableRecording`
- `isOnlyAllowRecording` -> `onlyAllowRecording`

### Fixes

- All fixes from the `camera` plugin.

## 1.3.1

- Constraint dependencies version. #22

## 1.3.0

- Add `enableAudio` parameter to control whether the package will require audio integration. #17

## 1.2.3

- Fix `maximumRecordingDuration` not passed in static method. #14

## 1.2.2

- Raise dependencies versions.

## 1.2.1

- Add `cameraQuarterTurns`.

## 1.2.0

- Expose resolution preset control.

## 1.1.2

- Remove common exports.

## 1.1.1

- Documents update.

## 1.1.0+1

- Link confirm button's text with delegate. Fix #6.

## 1.1.0

- Add `isOnlyAllowRecording` . Resolves #4.
- Make camera switching available. Resolves #5.

## 1.0.0+1

- Fix potential non exist directory access.

## 1.0.0

- Support taking pictures and videos.
- Support video recording duration limitation.

[Migration Guide]: guides/migration_guide.md
