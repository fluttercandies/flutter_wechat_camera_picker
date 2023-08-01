import 'app_localizations.dart';

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'WeChat Camera Picker 示例';

  @override
  String appVersion(Object version) {
    return '版本：$version';
  }

  @override
  String get appVersionUnknown => '未知';

  @override
  String get selectedAssetsText => '已选的资源';

  @override
  String pickMethodNotice(Object dist) {
    return '该页面的所有选择器的代码位于 $dist，由 `pickMethods` 定义。';
  }

  @override
  String get pickMethodPhotosName => '拍照';

  @override
  String get pickMethodPhotosDescription => '使用相机拍照。';

  @override
  String get pickMethodPhotosAndVideosName => '拍照和录像';

  @override
  String get pickMethodPhotosAndVideosDescription => '使用相机进行拍照和录像。';

  @override
  String get pickMethodVideosName => '录像';

  @override
  String get pickMethodVideosDescription => '使用相机录像。';

  @override
  String get pickMethodVideosByTapName => '轻触录像';

  @override
  String get pickMethodVideosByTapDescription => '轻触录像按钮进行录像，而不是长按。';

  @override
  String get pickMethodSilenceRecordingName => '静音录像';

  @override
  String get pickMethodSilenceRecordingDescription => '录像时不录制声音。';

  @override
  String get pickMethodAutoPreviewVideosName => '自动预览录制的视频';

  @override
  String get pickMethodAutoPreviewVideosDescription => '预览录制的视频时，自动播放。';

  @override
  String get pickMethodNoDurationLimitName => '无时长限制录像';

  @override
  String get pickMethodNoDurationLimitDescription => '想录多久，就录多久（只要手机健在）。';

  @override
  String get pickMethodCustomizableThemeName => '自定义主题 (ThemeData)';

  @override
  String get pickMethodCustomizableThemeDescription => '可以用亮色或其他颜色及自定义的主题进行选择。';

  @override
  String get pickMethodRotateInTurnsName => '旋转选择器的布局';

  @override
  String get pickMethodRotateInTurnsDescription => '顺时针旋转选择器的元素布局，不旋转相机视图。';

  @override
  String get pickMethodPreventScalingName => '禁止缩放相机预览';

  @override
  String get pickMethodPreventScalingDescription => '相机预览视图不会被放大到覆盖整个屏幕，仅适应原始的预览比例。';

  @override
  String get pickMethodLowerResolutionName => '低分辨率拍照';

  @override
  String get pickMethodLowerResolutionDescription => '某些情况或机型使用低分辨率拍照会有稳定性改善。';

  @override
  String get pickMethodPreferFrontCameraName => '首选前置摄像头';

  @override
  String get pickMethodPreferFrontCameraDescription => '在设备支持时首选使用前置摄像头。';

  @override
  String get pickMethodPreferFlashlightOnName => '首选闪光灯始终启用';

  @override
  String get pickMethodPreferFlashlightOnDescription => '在设备支持时首选闪光灯始终启用。';

  @override
  String get pickMethodForegroundBuilderName => '构建前景';

  @override
  String get pickMethodForegroundBuilderDescription => '通过 CameraController 构建在相机预览部分的前景 widget。';
}
