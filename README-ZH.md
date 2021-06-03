# Flutter仿微信相机资源选择器

[![pub package](https://img.shields.io/pub/v/wechat_camera_picker?logo=dart&label=%E7%A8%B3%E5%AE%9A%E7%89%88&style=flat-square)](https://pub.flutter-io.cn/packages/wechat_camera_picker)
[![pub package](https://img.shields.io/pub/v/wechat_camera_picker?color=42a012&include_prereleases&label=%E5%BC%80%E5%8F%91%E7%89%88&logo=dart&style=flat-square)](https://pub.flutter-io.cn/packages/wechat_camera_picker)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_wechat_camera_picker?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_wechat_camera_picker/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/flutter_wechat_camera_picker?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_wechat_camera_picker/network)
[![Build status](https://img.shields.io/github/workflow/status/fluttercandies/flutter_wechat_camera_picker/Build%20test?label=%E7%8A%B6%E6%80%81&logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_wechat_camera_picker/actions?query=workflow%3A%22Build+test%22)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/fluttercandies/flutter_wechat_camera_picker?logo=codefactor&label=%E4%BB%A3%E7%A0%81%E8%B4%A8%E9%87%8F&logoColor=%23ffffff&style=flat-square)](https://www.codefactor.io/repository/github/fluttercandies/flutter_wechat_camera_picker)
[![GitHub license](https://img.shields.io/github/license/fluttercandies/flutter_wechat_camera_picker?style=flat-square&label=%E5%8D%8F%E8%AE%AE)](https://github.com/fluttercandies/flutter_wechat_camera_picker/blob/master/LICENSE)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

Language: [English](README.md) | 中文简体

[**仿微信资源选择器**](https://fluttercandies.github.io/flutter_wechat_assets_picker)的扩展。基于 `camera` 实现相机相关功能， `photo_manager` 实现资源相关内容。

## 目录 🗂

- [Flutter WeChat Camera Picker](#flutter-wechat-camera-picker)
  - [目录 🗂](#目录-)
  - [特性 ✨](#特性-)
  - [截图 📸](#截图-)
  - [准备工作 🍭](#准备工作-)
  - [使用方法 📖](#使用方法-)
    - [简单的使用方法](#简单的使用方法)
  - [常见问题 💭](#常见问题-)
    - [当 `shouldLockPortrait` 为 false 时为何有缩放问题？](#当-shouldLockPortrait-为-false-时为何有缩放问题-)


## 特性 ✨

- [x] 🔐 支持健全的空安全
- [x] 💚 99% 的微信风格
- [x] 📷 支持拍照
  - [x] ☀️ 支持设置曝光参数
  - [x] 🔍️ 支持捏合缩放
- [x] 🎥 支持录像
  - [x] ⏱ 支持限制录像时间
  - [x] 🔍 支持录像时缩放
- [x] 🖾 支持自定义前景 widget 构建

## 截图 📸

| ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6yrdqej30u01t017w.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6yh3x4j30u01t0wuo.jpg) |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6z1h7xj30u01t01kx.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6zarvhj30u01t0x5f.jpg) |

## 准备工作 🍭

### 版本限制

Flutter SDK：`>=2.0.0` 。

### 配置

- [wechat_assets_picker#准备工作](https://github.com/fluttercandies/flutter_wechat_assets_picker/blob/master/README-ZH.md#preparing-for-use-)
- [camera#installation](https://pub.dev/packages/camera#installation)

## 使用方法 📖

| 参数名                       | 类型                            | 描述                                                             | 默认值                                 |
| ---------------------------- | ------------------------------- | ---------------------------------------------------------------- | -------------------------------------- |
| enableRecording              | `bool`                          | 选择器是否可以录像                                               | `false`                                |
| onlyEnableRecording          | `bool`                          | 选择器是否仅可以录像。只在 `enableRecording`  为 `true` 时有效。 | `false`                                |
| enableAudio                  | `bool`                          | 选择器是否需要录制音频。只于录像配合有效。                          | `true`                                |
| enableSetExposure            | `bool`                          | 用户是否可以在界面上通过点击设定曝光点                             | `true`                                 |
| enableExposureControlOnPoint | `bool`                          | 用户是否可以根据已经设置的曝光点调节曝光度                         | `true`                                 |
| enablePinchToZoom            | `bool`                          | 用户是否可以在界面上双指缩放相机对焦                               | `true`                                 |
| enablePullToZoomInRecord     | `bool`                          | 用户是否可以在录制视频时上拉缩放                                 | `true`                                 |
| shouldDeletePreviewFile      | `bool`                          | 返回页面时是否删除预览文件                                    | `false`                                |
| maximumRecordingDuration     | `Duration`                      | 录制视频最长时长                                                 | `const Duration(seconds: 15)`          |
| theme                        | `ThemeData?`                    | 选择器的主题                                                     | `CameraPicker.themeData(C.themeColor)` |
| textDelegate                 | `CameraPickerTextDelegate?`     | 控制部件中的文字实现                                             | `DefaultCameraPickerTextDelegate`      |
| resolutionPreset             | `ResolutionPreset`              | 相机的分辨率预设                                                 | `ResolutionPreset.max`                 |
| cameraQuarterTurns           | `int`                           | 摄像机视图顺时针旋转次数，每次90度                               | `0`                                    |
| imageFormatGroup             | `ImageFormatGroup`              | 输出图像的格式描述                                        | `ImageFormatGroup.unknown`             |
| foregroundBuilder            | `Widget Function(CameraValue)?` | 覆盖在相机预览上方的前景构建                                   | null                                   |
| onEntitySaving               | `SaveEntityCallback?`           | 在查看器中保存图片时的回调                                    | null                                   |

### 简单的使用方法

```dart
final AssetEntity? entity = await CameraPicker.pickFromCamera(context);
```

## 常见问题 💭

### 当 `shouldLockPortrait` 为 false 时为何有缩放问题？

当前旋转同步尚未支持。
当用户在旋转设备时，来自 `CameraValue` 的 `DeviceOrientation` 与 Flutter 的不同。
在两者匹配时，缩放问题会消失。
