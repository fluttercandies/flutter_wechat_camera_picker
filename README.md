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

A **camera picker** which is an extension for [wechat_assets_picker](https://pub.dev/packages/wechat_assets_picker). Based on `camera` for camera functions and `photo_manager` for asset implementation.


## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):
<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- ALL-CONTRIBUTORS-LIST:END -->
This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

## Category 🗂

* [Features](#features-)
* [Screenshots](#screenshots-)
* [Preparing for use](#preparing-for-use-)
* [Usage](#usage-)

## Features ✨

- [x] 💚 99% simillar to WeChat style.
- [x] 📷 Picture taking support
- [x] 🎥 Video recording support
  - [x] ⏱ Duration limitation support

## Screenshots  📸

| ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6yrdqej30u01t017w.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6yh3x4j30u01t0wuo.jpg) |
|-----------------|------------------|
| ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6z1h7xj30u01t01kx.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6zarvhj30u01t0x5f.jpg) |

## Preparing for use 🍭

Reference: [wechat_assets_picker#preparing-for-use](https://github.com/fluttercandies/flutter_wechat_assets_picker#preparing-for-use-)

## Usage 📖

| Name                     | Type                       | Description                                          | Default Value                          |
| ------------------------ | -------------------------- | ---------------------------------------------------- | -------------------------------------- |
| isAllowRecording         | `bool`                     | Whether the picker can record video.                 | `false`                                |
| maximumRecordingDuration | `Duration`                 | The maximum duration of the video recording process. | `const Duration(seconds: 15)`          |
| theme                    | `ThemeData`                | Theme data for the picker.                           | `CameraPicker.themeData(C.themeColor)` |
| textDelegate             | `CameraPickerTextDelegate` | Text delegate that controls text in widgets.         | `DefaultCameraPickerTextDelegate`      |

### Simple usage

```dart
final AssetEntity entity = await CameraPicker.pickFromCamera(context);
```

After called and the picker displayed, plus `isAllowRecording` is `true`, tap the shooting button to take a picture, long press the shooting button to record a video.