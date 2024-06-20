import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WeChat Camera Picker Demo'**
  String get appTitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String appVersion(Object version);

  /// No description provided for @appVersionUnknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get appVersionUnknown;

  /// No description provided for @selectedAssetsText.
  ///
  /// In en, this message translates to:
  /// **'Selected Assets'**
  String get selectedAssetsText;

  /// No description provided for @pickMethodNotice.
  ///
  /// In en, this message translates to:
  /// **'Pickers in this page are located at the {dist}, defined by `pickMethods`.'**
  String pickMethodNotice(Object dist);

  /// No description provided for @pickMethodPhotosName.
  ///
  /// In en, this message translates to:
  /// **'Taking photos'**
  String get pickMethodPhotosName;

  /// No description provided for @pickMethodPhotosDescription.
  ///
  /// In en, this message translates to:
  /// **'Use cameras only to take photos.'**
  String get pickMethodPhotosDescription;

  /// No description provided for @pickMethodPhotosAndVideosName.
  ///
  /// In en, this message translates to:
  /// **'Taking photos and videos'**
  String get pickMethodPhotosAndVideosName;

  /// No description provided for @pickMethodPhotosAndVideosDescription.
  ///
  /// In en, this message translates to:
  /// **'Use cameras to take photos and videos.'**
  String get pickMethodPhotosAndVideosDescription;

  /// No description provided for @pickMethodVideosName.
  ///
  /// In en, this message translates to:
  /// **'Taking videos'**
  String get pickMethodVideosName;

  /// No description provided for @pickMethodVideosDescription.
  ///
  /// In en, this message translates to:
  /// **'Use cameras only to take videos.'**
  String get pickMethodVideosDescription;

  /// No description provided for @pickMethodVideosByTapName.
  ///
  /// In en, this message translates to:
  /// **'Taking videos by tap'**
  String get pickMethodVideosByTapName;

  /// No description provided for @pickMethodVideosByTapDescription.
  ///
  /// In en, this message translates to:
  /// **'Use cameras only to take videos, but not with long-press, just a single tap.'**
  String get pickMethodVideosByTapDescription;

  /// No description provided for @pickMethodSilenceRecordingName.
  ///
  /// In en, this message translates to:
  /// **'Silence recording'**
  String get pickMethodSilenceRecordingName;

  /// No description provided for @pickMethodSilenceRecordingDescription.
  ///
  /// In en, this message translates to:
  /// **'Make recordings silent.'**
  String get pickMethodSilenceRecordingDescription;

  /// No description provided for @pickMethodNoDurationLimitName.
  ///
  /// In en, this message translates to:
  /// **'No duration limit'**
  String get pickMethodNoDurationLimitName;

  /// No description provided for @pickMethodNoDurationLimitDescription.
  ///
  /// In en, this message translates to:
  /// **'Record as long as you with (if your device stays alive)...'**
  String get pickMethodNoDurationLimitDescription;

  /// No description provided for @pickMethodCustomizableThemeName.
  ///
  /// In en, this message translates to:
  /// **'Customizable theme (ThemeData)'**
  String get pickMethodCustomizableThemeName;

  /// No description provided for @pickMethodCustomizableThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Picking assets with the light theme or with a different color.'**
  String get pickMethodCustomizableThemeDescription;

  /// No description provided for @pickMethodRotateInTurnsName.
  ///
  /// In en, this message translates to:
  /// **'Rotate picker in turns'**
  String get pickMethodRotateInTurnsName;

  /// No description provided for @pickMethodRotateInTurnsDescription.
  ///
  /// In en, this message translates to:
  /// **'Rotate the picker layout in quarter turns, without the camera preview.'**
  String get pickMethodRotateInTurnsDescription;

  /// No description provided for @pickMethodScalingPreviewName.
  ///
  /// In en, this message translates to:
  /// **'Scaling for camera preview'**
  String get pickMethodScalingPreviewName;

  /// No description provided for @pickMethodScalingPreviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Camera preview will be scaled to cover the whole screen of the device with the original aspect ratio.'**
  String get pickMethodScalingPreviewDescription;

  /// No description provided for @pickMethodLowerResolutionName.
  ///
  /// In en, this message translates to:
  /// **'Lower resolutions'**
  String get pickMethodLowerResolutionName;

  /// No description provided for @pickMethodLowerResolutionDescription.
  ///
  /// In en, this message translates to:
  /// **'Use a lower resolution preset might be helpful in some specific scenarios.'**
  String get pickMethodLowerResolutionDescription;

  /// No description provided for @pickMethodPreferFrontCameraName.
  ///
  /// In en, this message translates to:
  /// **'Prefer front camera'**
  String get pickMethodPreferFrontCameraName;

  /// No description provided for @pickMethodPreferFrontCameraDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the front camera as the preferred lens direction if the device supports.'**
  String get pickMethodPreferFrontCameraDescription;

  /// No description provided for @pickMethodPreferFlashlightOnName.
  ///
  /// In en, this message translates to:
  /// **'Prefer flashlight always on'**
  String get pickMethodPreferFlashlightOnName;

  /// No description provided for @pickMethodPreferFlashlightOnDescription.
  ///
  /// In en, this message translates to:
  /// **'Prefer to keep using the flashlight during captures.'**
  String get pickMethodPreferFlashlightOnDescription;

  /// No description provided for @pickMethodForegroundBuilderName.
  ///
  /// In en, this message translates to:
  /// **'Foreground builder'**
  String get pickMethodForegroundBuilderName;

  /// No description provided for @pickMethodForegroundBuilderDescription.
  ///
  /// In en, this message translates to:
  /// **'Build your widgets with the given CameraController on the top of the camera preview.'**
  String get pickMethodForegroundBuilderDescription;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
