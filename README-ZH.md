<!-- Copyright 2019 The FlutterCandies author. All rights reserved.
Use of this source code is governed by an Apache license
that can be found in the LICENSE file. -->

# Flutter WeChat Camera Picker

[![pub package](https://img.shields.io/pub/v/wechat_camera_picker?logo=dart&label=%E7%A8%B3%E5%AE%9A%E7%89%88&style=flat-square)](https://pub.flutter-io.cn/packages/wechat_camera_picker)
[![pub package](https://img.shields.io/pub/v/wechat_camera_picker?color=42a012&include_prereleases&label=%E5%BC%80%E5%8F%91%E7%89%88&logo=dart&style=flat-square)](https://pub.flutter-io.cn/packages/wechat_camera_picker)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_wechat_camera_picker?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_wechat_camera_picker/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/flutter_wechat_camera_picker?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_wechat_camera_picker/network)
[![Build status](https://img.shields.io/github/actions/workflow/status/fluttercandies/flutter_wechat_camera_picker/runnable.yml?branch=main&label=CI&logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_wechat_camera_picker/actions/workflows/runnable.yml)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/fluttercandies/flutter_wechat_camera_picker?logo=codefactor&label=%E4%BB%A3%E7%A0%81%E8%B4%A8%E9%87%8F&logoColor=%23ffffff&style=flat-square)](https://www.codefactor.io/repository/github/fluttercandies/flutter_wechat_camera_picker)
[![GitHub license](https://img.shields.io/github/license/fluttercandies/flutter_wechat_camera_picker?style=flat-square&label=%E5%8D%8F%E8%AE%AE)](https://github.com/fluttercandies/flutter_wechat_camera_picker/blob/master/LICENSE)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

Language: [English](README.md) | 中文简体

基于微信界面的相机选择器，可单独运行，是
[**仿微信资源选择器**](https://pub.flutter-io.cn/packages/wechat_assets_picker) 的扩展。
选择器基于 `camera` 实现相机相关功能，`photo_manager` 实现资源相关内容。

## 目录 🗂

- [Flutter WeChat Camera Picker](#flutter-wechat-camera-picker)
  - [目录 🗂](#目录-)
  - [特性 ✨](#特性-)
  - [截图 📸](#截图-)
  - [准备工作 🍭](#准备工作-)
  - [使用方法 📖](#使用方法-)
    - [简单的使用方法](#简单的使用方法)
    - [使用配置](#使用配置)
  - [常见问题 💭](#常见问题-)
    - [iOS 上的预览在旋转时行为诡异](#iOS-上的预览在旋转时行为诡异)

## 特性 ✨

- ♻️ 支持基于 `State` 重载的全量自定义
- 💚 99% 的微信风格
- 📷 支持拍照
- 🎥 支持录像
  - ⏱ 支持限制录像时间
  - 🔍 支持录像时缩放
- ☀️ 支持设置曝光参数
- 🔍️ 支持捏合缩放
- 💱 国际化支持
  - ⏪ RTL 语言支持
- 🎏 完整的自定义主题
- 🖾 支持自定义前景 widget 构建
- 🕹️ 保存时拦截自定义操作

## 截图 📸

| ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6yrdqej30u01t017w.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6yh3x4j30u01t0wuo.jpg) |
|-------------------------------------------------------------------------|-------------------------------------------------------------------------|
| ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6z1h7xj30u01t01kx.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggtt6zarvhj30u01t0x5f.jpg) |

## 准备工作 🍭

### 版本限制

Flutter SDK：`>=2.2.0` 。

### 配置

- [wechat_assets_picker#准备工作](https://github.com/fluttercandies/flutter_wechat_assets_picker/blob/master/README-ZH.md#preparing-for-use-)
- [camera#installation](https://pub.flutter-io.cn/packages/camera#installation)

#### Android 13 (API 33) 权限配置

如果你不需要拍照或录像，你可以考虑将对应权限移除：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.your.app">
    <!-- 如果需要拍照，添加该权限 -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <!-- 如果需要录像，添加该权限 -->
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
</manifest>
```

## 使用方法 📖

### 简单的使用方法

```dart
final AssetEntity? entity = await CameraPicker.pickFromCamera(context);
```

### 使用配置

你可以使用 `CameraPickerConfig` 来调整选择时的行为。

```dart
final AssetEntity? entity = await CameraPicker.pickFromCamera(
  context,
  pickerConfig: const CameraPickerConfig(),
);
```

`CameraPickerConfig` 的成员说明：

### 简单的使用方法

```dart
final AssetEntity? entity = await CameraPicker.pickFromCamera(context);
```

你可以使用 `CameraPickerConfig` 来调整选择时的行为。

```dart
final AssetEntity? entity = await CameraPicker.pickFromCamera(
  context,
  pickerConfig: const CameraPickerConfig(),
);
```

`CameraPickerConfig` 的成员说明：

| 参数名                          | 类型                          | 描述                                                 | 默认值                                        |
|------------------------------|-----------------------------|----------------------------------------------------|--------------------------------------------|
| enableRecording              | `bool`                      | 选择器是否可以录像                                          | `false`                                    |
| onlyEnableRecording          | `bool`                      | 选择器是否仅可以录像。只在 `enableRecording` 为 `true` 时有效。      | `false`                                    |
| enableTapRecording           | `bool`                      | 选择器是否可以单击录像。只在 `onlyEnableRecording` 为 `true` 时生效。 | `false`                                    |
| enableAudio                  | `bool`                      | 选择器是否需要录制音频。只在 `enableRecording` 为 `true` 时有效。     | `true`                                     |
| enableSetExposure            | `bool`                      | 用户是否可以在界面上通过点击设定曝光点                                | `true`                                     |
| enableExposureControlOnPoint | `bool`                      | 用户是否可以根据已经设置的曝光点调节曝光度                              | `true`                                     |
| enablePinchToZoom            | `bool`                      | 用户是否可以在界面上双指缩放相机对焦                                 | `true`                                     |
| enablePullToZoomInRecord     | `bool`                      | 用户是否可以在录制视频时上拉缩放                                   | `true`                                     |
| shouldDeletePreviewFile      | `bool`                      | 返回页面时是否删除预览文件                                      | `false`                                    |
| shouldAutoPreviewVideo       | `bool`                      | 在预览时是否直接播放视频                                       | `false`                                    |
| maximumRecordingDuration     | `Duration`                  | 录制视频最长时长                                           | `const Duration(seconds: 15)`              |
| theme                        | `ThemeData?`                | 选择器的主题                                             | `CameraPicker.themeData(wechatThemeColor)` |
| textDelegate                 | `CameraPickerTextDelegate?` | 控制部件中的文字实现                                         | `CameraPickerTextDelegate`                 |
| resolutionPreset             | `ResolutionPreset`          | 相机的分辨率预设                                           | `ResolutionPreset.max`                     |
| cameraQuarterTurns           | `int`                       | 摄像机视图顺时针旋转次数，每次 90 度                               | `0`                                        |
| imageFormatGroup             | `ImageFormatGroup`          | 输出图像的格式描述                                          | `ImageFormatGroup.unknown`                 |
| preferredLensDirection       | `CameraLensDirection`       | 首次使用相机时首选的镜头方向                                     | `CameraLensDirection.back`                 |
| lockCaptureOrientation       | `DeviceOrientation?`        | 摄像机在拍摄时锁定的旋转角度                                     | null                                       |
| foregroundBuilder            | `ForegroundBuilder?`        | 覆盖在相机预览上方的前景构建                                     | null                                       |
| previewTransformBuilder      | `PreviewTransformBuilder?`  | 对相机预览做变换的构建                                        | null                                       |
| onEntitySaving               | `EntitySaveCallback?`       | 在查看器中保存图片时的回调                                      | null                                       |
| onError                      | `CameraErrorHandler?`       | 拍摄照片过程中的自定义错误处理                                    | null                                       |
| onXFileCaptured              | `XFileCapturedCallback?`    | 拍摄文件生成后的回调                                         | null                                       |

### 使用自定义的 `State`

所有的用户界面都可以通过自定义 `State` 实现，包括：
- `CameraPickerState`
- `CameraPickerViewerState`

在完成 `State` 的重载后，可以在调用时进行构建，具体来说：
- `CameraPicker.pickFromCamera(createPickerState: () => CustomCameraPickerState());`
- `CameraPickerViewer.pushToViewer(..., createViewerState: () => CustomCameraPickerViewerState());`

## 常见问题 💭

### iOS 上的预览在旋转时行为诡异

目前，iOS 上的预览画面在旋转时并未正确地同步，
你可以在这个 issue 里了解更多相关的信息：
https://github.com/flutter/flutter/issues/89216 。
除此之外的问题，你可以提交 issue 进行提问。
