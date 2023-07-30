import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WeChat Camera Picker Demo';

  @override
  String appVersion(Object version) {
    return 'Version: $version';
  }

  @override
  String get appVersionUnknown => 'unknown';

  @override
  String get selectedAssetsText => 'Selected Assets';

  @override
  String pickMethodNotice(Object dist) {
    return 'Pickers in this page are located at the $dist, defined by `pickMethods`.';
  }

  @override
  String get pickMethodPhotosName => 'Taking photos';

  @override
  String get pickMethodPhotosDescription => 'Use cameras only to take photos.';

  @override
  String get pickMethodPhotosAndVideosName => 'Taking photos and videos';

  @override
  String get pickMethodPhotosAndVideosDescription => 'Use cameras to take photos and videos.';

  @override
  String get pickMethodVideosName => 'Taking videos';

  @override
  String get pickMethodVideosDescription => 'Use cameras only to take videos.';

  @override
  String get pickMethodVideosByTapName => 'Taking videos by tap';

  @override
  String get pickMethodVideosByTapDescription => 'Use cameras only to take videos, but not with long-press, just a single tap.';

  @override
  String get pickMethodSilenceRecordingName => 'Silence recording';

  @override
  String get pickMethodSilenceRecordingDescription => 'Make recordings silent.';

  @override
  String get pickMethodAutoPreviewVideosName => 'Auto preview videos';

  @override
  String get pickMethodAutoPreviewVideosDescription => 'Play videos automatically in the preview after captured.';

  @override
  String get pickMethodNoDurationLimitName => 'No duration limit';

  @override
  String get pickMethodNoDurationLimitDescription => 'Record as long as you with (if your device stays alive)...';

  @override
  String get pickMethodCustomizableThemeName => 'Customizable theme (ThemeData)';

  @override
  String get pickMethodCustomizableThemeDescription => 'Picking assets with the light theme or with a different color.';

  @override
  String get pickMethodRotateInTurnsName => 'Rotate picker in turns';

  @override
  String get pickMethodRotateInTurnsDescription => 'Rotate the picker layout in quarter turns, without the camera preview.';

  @override
  String get pickMethodPreventScalingName => 'Prevent scaling for camera preview';

  @override
  String get pickMethodPreventScalingDescription => 'Camera preview will not be scaled to cover the whole screen of the device, only fit for the raw aspect ratio.';

  @override
  String get pickMethodLowerResolutionName => 'Lower resolutions';

  @override
  String get pickMethodLowerResolutionDescription => 'Use a lower resolution preset might be helpful in some specific scenarios.';

  @override
  String get pickMethodPreferFrontCameraName => 'Prefer front camera';

  @override
  String get pickMethodPreferFrontCameraDescription => 'Use the front camera as the preferred lens direction if the device supports.';

  @override
  String get pickMethodPreferFlashlightOnName => 'Prefer flashlight always on';

  @override
  String get pickMethodPreferFlashlightOnDescription => 'Prefer to keep using the flashlight during captures.';

  @override
  String get pickMethodForegroundBuilderName => 'Foreground builder';

  @override
  String get pickMethodForegroundBuilderDescription => 'Build your widgets with the given CameraController on the top of the camera preview.';
}
