# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2.2.1

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
