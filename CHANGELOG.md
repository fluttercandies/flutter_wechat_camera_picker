# Changelog

## 2.6.1

- Allow saving entities when the permission is limited on iOS.

## 2.6.0

- Add `preferredLensDirection`, allow users to choose which lens direction is preferred when first using the camera.
- Add `enableTapRecording`, allow users to determine whether to allow the record can start with single tap.
- Add `shouldAutoPreviewVideo`, allow users to determine whether the video should be played instantly in the preview.

## 2.5.2

- Request the permission state again when saving.
- Provide better experiences when video record need to prepare.

## 2.5.1

- Fix invalid widgets binding observer caller.

## 2.5.0

- Add `onError` to handle errors during the picking process.
- `SaveEntityCallback` -> `EntitySaveCallback`.
- Improve folder structure of the plugin.

## 2.4.2

- Flip the preview if the user is using a front camera.

## 2.4.1

- Handle save exceptions more graceful.
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

- Add `EntitySaveCallback` for custom save method.

## 2.1.2

- Improve the UI of the exposure point widget when manually focus.

## 2.1.1

- Use basename when saving entities.

## 2.1.0

- Add `shouldLockPortrait` to fit orientation for the device.
- Fix exposure offset issue when reset the exposure point after adjust the exposure offset manually.

## 2.0.0

### New Features

- Add `enableSetExposure`, allow users to update the exposure from the point tapped on the screen.
- Add `enableExposureControlOnPoint`, allow users to control the exposure offset with a offset slide from the exposure point.
- Add `enablePinchToZoom`, allow users to zoom by pinch the screen.
- Add `enablePullToZoomInRecord`, allow users to zoom by pulling up when recording video.
- Add `foregroundBuilder`, allow users to build customize widget beyond the camera preview.
- Add `shouldDeletePreviewFile`, allow users to choose whether the captured file should be deleted.
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

- Link confirm button's text with delegate. Fix #6 .

## 1.1.0

- Add `isOnlyAllowRecording` . Resolves #4 .
- Make camera switching available. Resolves #5 .

## 1.0.0+1

- Fix potential non exist directory access.

## 1.0.0

- Support take picture and video.
- Support video recording duration limitation.
