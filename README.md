# Flutter WeChat Camera Picker

[![pub package](https://img.shields.io/pub/v/wechat_camera_picker?logo=dart&label=stable&style=flat-square)](https://pub.dev/packages/wechat_camera_picker)
[![pub package](https://img.shields.io/pub/v/wechat_camera_picker?color=42a012&include_prereleases&label=dev&logo=dart&style=flat-square)](https://pub.dev/packages/wechat_camera_picker)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_wechat_camera_picker?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_wechat_camera_picker/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/flutter_wechat_camera_picker?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_wechat_camera_picker/network)
[![Build status](https://img.shields.io/github/workflow/status/fluttercandies/flutter_wechat_camera_picker/Build%20test?label=CI&logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_wechat_camera_picker/actions?query=workflow%3A%22Build+test%22)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/fluttercandies/flutter_wechat_camera_picker?logo=codefactor&logoColor=%23ffffff&style=flat-square)](https://www.codefactor.io/repository/github/fluttercandies/flutter_wechat_camera_picker)
[![GitHub license](https://img.shields.io/github/license/fluttercandies/flutter_wechat_camera_picker?style=flat-square)](https://github.com/fluttercandies/flutter_wechat_camera_picker/blob/master/LICENSE)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

Language: English | [中文简体](README-ZH.md)

A **camera picker** which is an extension for [wechat_assets_picker](https://fluttercandies.github.io/flutter_wechat_assets_picker). Based on `camera` for camera functions and `photo_manager` for asset implementation.

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):
<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://blog.alexv525.com"><img src="https://avatars1.githubusercontent.com/u/15884415?v=4" width="50px;" alt=""/><br /><sub><b>Alex Li</b></sub></a><br /><a href="https://github.com/fluttercandies/flutter_wechat_camera_picker/commits?author=AlexV525" title="Code">💻</a> <a href="#design-AlexV525" title="Design">🎨</a> <a href="https://github.com/fluttercandies/flutter_wechat_camera_picker/commits?author=AlexV525" title="Documentation">📖</a> <a href="#example-AlexV525" title="Examples">💡</a> <a href="#ideas-AlexV525" title="Ideas, Planning, & Feedback">🤔</a> <a href="#maintenance-AlexV525" title="Maintenance">🚧</a> <a href="#question-AlexV525" title="Answering Questions">💬</a> <a href="https://github.com/fluttercandies/flutter_wechat_camera_picker/pulls?q=is%3Apr+reviewed-by%3AAlexV525" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://www.kikt.top"><img src="https://avatars0.githubusercontent.com/u/14145407?v=4" width="50px;" alt=""/><br /><sub><b>Caijinglong</b></sub></a><br /><a href="#example-CaiJingLong" title="Examples">💡</a> <a href="#ideas-CaiJingLong" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/LaelLuo"><img src="https://avatars3.githubusercontent.com/u/26056971?v=4" width="50px;" alt=""/><br /><sub><b>Lael</b></sub></a><br /><a href="https://github.com/fluttercandies/flutter_wechat_camera_picker/commits?author=LaelLuo" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/mjl0602"><img src="https://avatars1.githubusercontent.com/u/32868496?v=4" width="50px;" alt=""/><br /><sub><b>mjl0602</b></sub></a><br /><a href="https://github.com/fluttercandies/flutter_wechat_camera_picker/commits?author=mjl0602" title="Code">💻</a> <a href="#ideas-mjl0602" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/siyukok"><img src="https://avatars0.githubusercontent.com/u/21030561?v=4" width="50px;" alt=""/><br /><sub><b>AliasWang</b></sub></a><br /><a href="https://github.com/fluttercandies/flutter_wechat_camera_picker/commits?author=siyukok" title="Code">💻</a> <a href="#ideas-siyukok" title="Ideas, Planning, & Feedback">🤔</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->
This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

## Category 🗂

- [Flutter WeChat Camera Picker](#flutter-wechat-camera-picker)
  - [Contributors ✨](#contributors-)
  - [Category 🗂](#category-)
  - [Features ✨](#features-)
  - [Screenshots 📸](#screenshots-)
  - [Preparing for use 🍭](#preparing-for-use-)
  - [Usage 📖](#usage-)
    - [Simple usage](#simple-usage)
  - [Frequent asked question 💭](#frequent-asked-question-)
    - [Why there are over-scaled issue when `shouldLockPortrait` set to false ?](#why-there-are-over-scales-issue-when-shouldLockPortrait-set-to-false-)

## Features ✨

- [x] 🔐 Non-nullable by default
- [x] 💚 99% similar to WeChat style
- [x] 📷 Picture taking support
  - [x] ☀️ Exposure adjust support
  - [x] 🔍️ Scale with pinch support
- [x] 🎥 Video recording support
  - [x] ⏱ Duration limitation support
  - [x] 🔍 Scale when recording support
- [x] 🖾 Foreground custom widget builder support

## Screenshots 📸

| ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6yrdqej30u01t017w.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6yh3x4j30u01t0wuo.jpg) |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6z1h7xj30u01t01kx.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6zarvhj30u01t0x5f.jpg) |

## Preparing for use 🍭

### Version constraints

Flutter SDK: `>=2.0.0` .

### Setup

- [wechat_assets_picker#preparing-for-use](https://github.com/fluttercandies/flutter_wechat_assets_picker#preparing-for-use-)
- [camera#installation](https://pub.dev/packages/camera#installation)

## Usage 📖

| Name                         | Type                            | Description                                                                                 | Default Value                          |
| ---------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------- | -------------------------------------- |
| enableRecording              | `bool`                          | Whether the picker can record video.                                                        | `false`                                |
| onlyEnableRecording          | `bool`                          | Whether the picker can only record video. Only available when `enableRecording` is `true `. | `false`                                |
| enableAudio                  | `bool`                          | Whether Whether the picker should record audio. Only available with recording.              | `true`                                 |
| enableSetExposure            | `bool`                          | Whether users can set the exposure point by tapping.                                        | `true`                                 |
| enableExposureControlOnPoint | `bool`                          | Whether users can adjust exposure according to the set point.                               | `true`                                 |
| enablePinchToZoom            | `bool`                          | Whether users can zoom the camera by pinch.                                                 | `true`                                 |
| enablePullToZoomInRecord     | `bool`                          | Whether users can zoom by pulling up when recording video.                                  | `true`                                 |
| shouldDeletePreviewFile      | `bool`                          | Whether the preview file will be delete when pop.                                           | `false`                                |
| shouldLockPortrait           | `bool`                          | Whether the orientation should be set to portrait                                           | `true`                                 |
| maximumRecordingDuration     | `Duration`                      | The maximum duration of the video recording process.                                        | `const Duration(seconds: 15)`          |
| theme                        | `ThemeData?`                    | Theme data for the picker.                                                                  | `CameraPicker.themeData(C.themeColor)` |
| textDelegate                 | `CameraPickerTextDelegate?`     | Text delegate that controls text in widgets.                                                | `DefaultCameraPickerTextDelegate`      |
| resolutionPreset             | `ResolutionPreset`              | Present resolution for the camera.                                                          | `ResolutionPreset.max`                 |
| cameraQuarterTurns           | `int`                           | The number of clockwise quarter turns the camera view should be rotated.                    | `0`                                    |
| imageFormatGroup             | `ImageFormatGroup`              | Describes the output of the raw image format.                                               | `ImageFormatGroup.unknown`             |
| foregroundBuilder            | `Widget Function(CameraValue)?` | The foreground widget builder which will cover the whole camera preview.                    | null                                   |
| onEntitySaving               | `SaveEntityCallback?`           | The callback type define for saving entity in the viewer.                                   | null                                   |

### Simple usage

```dart
final AssetEntity? entity = await CameraPicker.pickFromCamera(context);
```

## Frequent asked question 💭

### Why there are over-scaled issue when `shouldLockPortrait` set to false?

Currently the rotate synchronization is not supported.
The `DeviceOrientation` from the `CameraValue` is different from the one
comes from flutter when the user is rotating devices.
The preview widget is synchronized when both orientation is the same.
