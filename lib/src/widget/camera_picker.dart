///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/13 11:08
///
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

import '../constants/constants.dart';
import '../widget/circular_progress_bar.dart';

import 'builder/slide_page_transition_builder.dart';
import 'camera_picker_viewer.dart';
import 'exposure_point_widget.dart';

const Color _lockedColor = Colors.amber;
const Duration _kRouteDuration = Duration(milliseconds: 300);

/// Create a camera picker integrate with [CameraDescription].
/// 通过 [CameraDescription] 整合的拍照选择
///
/// The picker provides create an [AssetEntity] through the camera.
/// 该选择器可以通过拍照创建 [AssetEntity]。
class CameraPicker extends StatefulWidget {
  CameraPicker({
    Key? key,
    this.enableRecording = false,
    this.onlyEnableRecording = false,
    this.enableAudio = true,
    this.enableSetExposure = true,
    this.enableExposureControlOnPoint = true,
    this.enablePinchToZoom = true,
    this.enablePullToZoomInRecord = true,
    this.shouldDeletePreviewFile = false,
    this.shouldLockPortrait = true,
    this.maximumRecordingDuration = const Duration(seconds: 15),
    this.theme,
    this.resolutionPreset = ResolutionPreset.max,
    this.imageFormatGroup = ImageFormatGroup.unknown,
    this.cameraQuarterTurns = 0,
    this.foregroundBuilder,
    this.onEntitySaving,
    CameraPickerTextDelegate? textDelegate,
  })  : assert(
          enableRecording == true || onlyEnableRecording != true,
          'Recording mode error.',
        ),
        super(key: key) {
    Constants.textDelegate = textDelegate ??
        (enableRecording
            ? DefaultCameraPickerTextDelegateWithRecording()
            : DefaultCameraPickerTextDelegate());
  }

  /// The number of clockwise quarter turns the camera view should be rotated.
  /// 摄像机视图顺时针旋转次数，每次90度
  final int cameraQuarterTurns;

  /// Whether the picker can record video.
  /// 选择器是否可以录像
  final bool enableRecording;

  /// Whether the picker can record video.
  /// 选择器是否可以录像
  final bool onlyEnableRecording;

  /// Whether the picker should record audio.
  /// 选择器录像时是否需要录制声音
  final bool enableAudio;

  /// Whether users can set the exposure point by tapping.
  /// 用户是否可以在界面上通过点击设定曝光点
  final bool enableSetExposure;

  /// Whether users can adjust exposure according to the set point.
  /// 用户是否可以根据已经设置的曝光点调节曝光度
  final bool enableExposureControlOnPoint;

  /// Whether users can zoom the camera by pinch.
  /// 用户是否可以在界面上双指缩放相机对焦
  final bool enablePinchToZoom;

  /// Whether users can zoom by pulling up when recording video.
  /// 用户是否可以在录制视频时上拉缩放
  final bool enablePullToZoomInRecord;

  /// Whether the preview file will be delete when pop.
  /// 返回页面时是否删除预览文件
  final bool shouldDeletePreviewFile;

  /// Whether the orientation should be set to portrait.
  /// 相机是否需要强制竖屏
  final bool shouldLockPortrait;

  /// The maximum duration of the video recording process.
  /// 录制视频最长时长
  ///
  /// Defaults to 15 seconds, allow `null` for unrestricted video recording.
  /// 默认为 15 秒，可以使用 `null` 来设置无限制的视频录制
  final Duration? maximumRecordingDuration;

  /// Theme data for the picker.
  /// 选择器的主题
  final ThemeData? theme;

  /// Present resolution for the camera.
  /// 相机的分辨率预设
  final ResolutionPreset resolutionPreset;

  /// The [ImageFormatGroup] describes the output of the raw image format.
  /// 输出图像的格式描述
  final ImageFormatGroup imageFormatGroup;

  /// The foreground widget builder which will cover the whole camera preview.
  /// 覆盖在相机预览上方的前景构建
  final Widget Function(CameraValue)? foregroundBuilder;

  /// {@macro wechat_camera_picker.SaveEntityCallback}
  final EntitySaveCallback? onEntitySaving;

  /// Static method to create [AssetEntity] through camera.
  /// 通过相机创建 [AssetEntity] 的静态方法
  static Future<AssetEntity?> pickFromCamera(
    BuildContext context, {
    bool enableRecording = false,
    bool onlyEnableRecording = false,
    bool enableAudio = true,
    bool enableSetExposure = true,
    bool enableExposureControlOnPoint = true,
    bool enablePinchToZoom = true,
    bool shouldDeletePreviewFile = false,
    bool shouldLockPortrait = true,
    Duration maximumRecordingDuration = const Duration(seconds: 15),
    ThemeData? theme,
    int cameraQuarterTurns = 0,
    CameraPickerTextDelegate? textDelegate,
    ResolutionPreset resolutionPreset = ResolutionPreset.max,
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
    Widget Function(CameraValue)? foregroundBuilder,
    EntitySaveCallback? onEntitySaving,
  }) async {
    if (enableRecording != true && onlyEnableRecording == true) {
      throw ArgumentError('Recording mode error.');
    }
    final AssetEntity? result = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<AssetEntity>(
      SlidePageTransitionBuilder<AssetEntity>(
        builder: CameraPicker(
          enableRecording: enableRecording,
          onlyEnableRecording: onlyEnableRecording,
          enableAudio: enableAudio,
          enableSetExposure: enableSetExposure,
          enableExposureControlOnPoint: enableExposureControlOnPoint,
          enablePinchToZoom: enablePinchToZoom,
          shouldDeletePreviewFile: shouldDeletePreviewFile,
          shouldLockPortrait: shouldLockPortrait,
          maximumRecordingDuration: maximumRecordingDuration,
          theme: theme,
          cameraQuarterTurns: cameraQuarterTurns,
          textDelegate: textDelegate,
          resolutionPreset: resolutionPreset,
          imageFormatGroup: imageFormatGroup,
          foregroundBuilder: foregroundBuilder,
          onEntitySaving: onEntitySaving,
        ),
        transitionCurve: Curves.easeIn,
        transitionDuration: _kRouteDuration,
      ),
    );
    return result;
  }

  /// Build a dark theme according to the theme color.
  /// 通过主题色构建一个默认的暗黑主题
  static ThemeData themeData(Color themeColor) {
    return ThemeData.dark().copyWith(
      buttonColor: themeColor,
      primaryColor: Colors.grey[900],
      primaryColorBrightness: Brightness.dark,
      primaryColorLight: Colors.grey[900],
      primaryColorDark: Colors.grey[900],
      accentColor: themeColor,
      accentColorBrightness: Brightness.dark,
      canvasColor: Colors.grey[850],
      scaffoldBackgroundColor: Colors.grey[900],
      bottomAppBarColor: Colors.grey[900],
      cardColor: Colors.grey[900],
      highlightColor: Colors.transparent,
      toggleableActiveColor: themeColor,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: themeColor,
        selectionColor: themeColor.withAlpha(100),
        selectionHandleColor: themeColor,
      ),
      indicatorColor: themeColor,
      appBarTheme: const AppBarTheme(brightness: Brightness.dark, elevation: 0),
      colorScheme: ColorScheme(
        primary: Colors.grey[900]!,
        primaryVariant: Colors.grey[900]!,
        secondary: themeColor,
        secondaryVariant: themeColor,
        background: Colors.grey[900]!,
        surface: Colors.grey[900]!,
        brightness: Brightness.dark,
        error: const Color(0xffcf6679),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
      ),
    );
  }

  @override
  CameraPickerState createState() => CameraPickerState();
}

class CameraPickerState extends State<CameraPicker>
    with WidgetsBindingObserver {
  /// The [Duration] for record detection. (200ms)
  /// 检测是否开始录制的时长 (200毫秒)
  final Duration recordDetectDuration = const Duration(milliseconds: 200);

  /// The last exposure point offset on the screen.
  /// 最后一次手动聚焦的点坐标
  final ValueNotifier<Offset?> _lastExposurePoint =
      ValueNotifier<Offset?>(null);

  /// The last pressed position on the shooting button before starts recording.
  /// 在开始录像前，最后一次在拍照按钮按下的位置
  Offset? _lastShootingButtonPressedPosition;

  /// Current exposure mode.
  /// 当前曝光模式
  final ValueNotifier<ExposureMode> _exposureMode =
      ValueNotifier<ExposureMode>(ExposureMode.auto);

  final ValueNotifier<bool> _isExposureModeDisplays =
      ValueNotifier<bool>(false);

  /// The [ValueNotifier] to keep the [CameraController].
  /// 用于保持 [CameraController] 的 [ValueNotifier]
  final ValueNotifier<CameraController?> _controllerNotifier =
      ValueNotifier<CameraController?>(null);

  /// The controller for the current camera.
  /// 当前相机实例的控制器
  CameraController get controller => _controllerNotifier.value!;

  /// Available cameras.
  /// 可用的相机实例
  late final List<CameraDescription> cameras;

  /// Current exposure offset.
  /// 当前曝光值
  final ValueNotifier<double> _currentExposureOffset = ValueNotifier<double>(0);

  /// The maximum available value for exposure.
  /// 最大可用曝光值
  double _maxAvailableExposureOffset = 0;

  /// The minimum available value for exposure.
  /// 最小可用曝光值
  double _minAvailableExposureOffset = 0;

  /// The maximum available value for zooming.
  /// 最大可用缩放值
  double _maxAvailableZoom = 1;

  /// The minimum available value for zooming.
  /// 最小可用缩放值
  double _minAvailableZoom = 1;

  /// Counting pointers (number of user fingers on screen).
  /// 屏幕上的触摸点计数
  int _pointers = 0;
  double _currentZoom = 1;
  double _baseZoom = 1;

  /// The index of the current cameras. Defaults to `0`.
  /// 当前相机的索引。默认为0
  int currentCameraIndex = 0;

  /// Whether the [shootingButton] should animate according to the gesture.
  /// 拍照按钮是否需要执行动画
  ///
  /// This happens when the [shootingButton] is being long pressed.
  /// It will animate for video recording state.
  /// 当长按拍照按钮时，会进入准备录制视频的状态，此时需要执行动画。
  bool isShootingButtonAnimate = false;

  /// The [Timer] for keep the [_lastExposurePoint] displays.
  /// 用于控制上次手动聚焦点显示的计时器
  Timer? _exposurePointDisplayTimer;

  Timer? _exposureModeDisplayTimer;

  /// The [Timer] for record start detection.
  /// 用于检测是否开始录制的计时器
  ///
  /// When the [shootingButton] started animate, this [Timer] will start
  /// at the same time. When the time is more than [recordDetectDuration],
  /// which means we should start recoding, the timer finished.
  /// 当拍摄按钮开始执行动画时，定时器会同时启动。时长超过检测时长时，定时器完成。
  Timer? _recordDetectTimer;

  /// The [Timer] for record countdown.
  /// 用于录制视频倒计时的计时器
  ///
  /// Stop record When the record time reached the [maximumRecordingDuration].
  /// However, if there's no limitation on record time, this will be useless.
  /// 当录像时间达到了最大时长，将通过定时器停止录像。
  /// 但如果录像时间没有限制，定时器将不会起作用。
  Timer? _recordCountdownTimer;

  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////// Global Getters //////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  bool get enableRecording => widget.enableRecording;

  bool get onlyEnableRecording => widget.onlyEnableRecording;

  /// No audio integration required when it's only for camera.
  /// 在仅允许拍照时不需要启用音频
  bool get enableAudio => enableRecording && widget.enableAudio;

  bool get enableSetExposure => widget.enableSetExposure;

  bool get enableExposureControlOnPoint => widget.enableExposureControlOnPoint;

  bool get enablePinchToZoom => widget.enablePinchToZoom;

  bool get enablePullToZoomInRecord => widget.enablePullToZoomInRecord;

  bool get shouldDeletePreviewFile => widget.shouldDeletePreviewFile;

  Duration? get maximumRecordingDuration => widget.maximumRecordingDuration;

  /// Whether the recording restricted to a specific duration.
  /// 录像是否有限制的时长
  bool get isRecordingRestricted => maximumRecordingDuration != null;

  /// A getter to the current [CameraDescription].
  /// 获取当前相机实例
  CameraDescription get currentCamera => cameras.elementAt(currentCameraIndex);

  /// If there's no theme provided from the user, use [CameraPicker.themeData] .
  /// 如果用户未提供主题，
  late final ThemeData _theme =
      widget.theme ?? CameraPicker.themeData(C.themeColor);

  /// Get [ThemeData] of the [AssetPicker] through [Constants.pickerKey].
  /// 通过常量全局 Key 获取当前选择器的主题
  ThemeData get theme => _theme;

  @override
  void initState() {
    super.initState();
    if (widget.shouldLockPortrait) {
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    WidgetsBinding.instance?.removeObserver(this);

    // TODO(Alex): Currently hide status bar will cause the viewport shaking on Android.
    /// Hide system status bar automatically when the platform is not Android.
    /// 在非 Android 设备上自动隐藏状态栏
    if (!Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
    }

    Future<void>.delayed(_kRouteDuration, () {
      if (mounted) {
        try {
          initCameras();
        } catch (e) {
          realDebugPrint('Error when initializing: $e');
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    if (widget.shouldLockPortrait) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    if (!Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
    WidgetsBinding.instance?.removeObserver(this);
    controller.dispose();
    _controllerNotifier.dispose();
    _currentExposureOffset.dispose();
    _lastExposurePoint.dispose();
    _exposureMode.dispose();
    _isExposureModeDisplays.dispose();
    _exposurePointDisplayTimer?.cancel();
    _exposureModeDisplayTimer?.cancel();
    _recordDetectTimer?.cancel();
    _recordCountdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_controllerNotifier.value == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCameras(currentCamera);
    }
  }

  /// Turn camera preview according to the camera's orientation.
  /// 根据相机的旋转调整预览的旋转角度
  ///
  /// Note: turns only takes effect when the orientation is locked.
  /// 注意：仅在设备自动旋转锁定的情况下生效。
  int _previewQuarterTurns(
    DeviceOrientation orientation,
    BoxConstraints constraints,
  ) {
    int turns = -widget.cameraQuarterTurns;
    if (!widget.shouldLockPortrait) {
      return turns;
    }
    switch (orientation) {
      case DeviceOrientation.landscapeLeft:
        turns += -1;
        break;
      case DeviceOrientation.landscapeRight:
        turns += 1;
        break;
      case DeviceOrientation.portraitDown:
        turns += 2;
        break;
      default:
        break;
    }
    return turns;
  }

  /// Adjust the proper scale type according to the [controller].
  /// 通过 [controller] 的预览大小，判断相机预览适用的缩放类型。
  _PreviewScaleType _effectiveScaleType(BoxConstraints constraints) {
    final Size _size = controller.value.previewSize!;
    final Size _scaledSize =
        _size * constraints.maxWidth * Screens.scale / _size.height;
    if (_scaledSize.width > constraints.maxHeight * Screens.scale) {
      return _PreviewScaleType.width;
    } else if (_scaledSize.width < constraints.maxHeight * Screens.scale) {
      return _PreviewScaleType.height;
    } else {
      return _PreviewScaleType.none;
    }
  }

  /// Initialize cameras instances.
  /// 初始化相机实例
  void initCameras([CameraDescription? cameraDescription]) {
    // Save the current controller to a local variable.
    final CameraController? _c = _controllerNotifier.value;
    // Then unbind the controller from widgets, which requires a build frame.
    setState(() {
      _maxAvailableZoom = 1;
      _minAvailableZoom = 1;
      _currentZoom = 1;
      _baseZoom = 1;
      _controllerNotifier.value = null;
      // Meanwhile, cancel the existed exposure point and mode display.
      _exposureModeDisplayTimer?.cancel();
      _exposurePointDisplayTimer?.cancel();
      _lastExposurePoint.value = null;
      if (_currentExposureOffset.value != 0) {
        _currentExposureOffset.value = 0;
      }
    });
    // **IMPORTANT**: Push methods into a post frame callback, which ensures the
    // controller has already unbind from widgets.
    SchedulerBinding.instance?.addPostFrameCallback((_) async {
      // Dispose at last to avoid disposed usage with assertions.
      await _c?.dispose();

      // When the [cameraDescription] is null, which means this is the first
      // time initializing cameras, so available cameras should be fetched.
      if (cameraDescription == null) {
        cameras = await availableCameras();
      }

      // After cameras fetched, judge again with the list is empty or not to
      // ensure there is at least an available camera for use.
      if (cameraDescription == null && (cameras.isEmpty)) {
        realDebugPrint('No cameras found.');
        return;
      }

      // Initialize the controller with the given resolution preset.
      _controllerNotifier.value = CameraController(
        cameraDescription ?? cameras[0],
        widget.resolutionPreset,
        enableAudio: enableAudio,
        imageFormatGroup: widget.imageFormatGroup,
      )..addListener(() {
          if (controller.value.hasError) {
            realDebugPrint('Camera error ${controller.value.errorDescription}');
          }
        });

      try {
        await controller.initialize();
        Future.wait<void>(<Future<dynamic>>[
          (() async => _maxAvailableExposureOffset =
              await controller.getMaxExposureOffset())(),
          (() async => _minAvailableExposureOffset =
              await controller.getMinExposureOffset())(),
          (() async =>
              _maxAvailableZoom = await controller.getMaxZoomLevel())(),
          (() async =>
              _minAvailableZoom = await controller.getMinZoomLevel())(),
        ]);
      } on CameraException catch (e) {
        realDebugPrint('CameraException: $e');
      } finally {
        safeSetState(() {});
      }
    });
  }

  /// The method to switch cameras.
  /// 切换相机的方法
  ///
  /// Switch cameras in order. When the [currentCameraIndex] reached the length
  /// of cameras, start from the beginning.
  /// 按顺序切换相机。当达到相机数量时从头开始。
  void switchCameras() {
    ++currentCameraIndex;
    if (currentCameraIndex == cameras.length) {
      currentCameraIndex = 0;
    }
    initCameras(currentCamera);
  }

  /// The method to switch between flash modes.
  /// 切换闪光灯模式的方法
  Future<void> switchFlashesMode() async {
    try {
      switch (controller.value.flashMode) {
        case FlashMode.off:
          await controller.setFlashMode(FlashMode.auto);
          break;
        case FlashMode.auto:
          await controller.setFlashMode(FlashMode.always);
          break;
        case FlashMode.always:
        case FlashMode.torch:
          await controller.setFlashMode(FlashMode.off);
          break;
      }
    } catch (e) {
      realDebugPrint('Error when switch flash mode: $e');
    }
  }

  Future<void> zoom(double scale) async {
    final double _zoom = (_baseZoom * scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom)
        .toDouble();
    if (_zoom == _currentZoom) {
      return;
    }
    _currentZoom = _zoom;

    await controller.setZoomLevel(_currentZoom);
  }

  /// Handle when the scale gesture start.
  /// 处理缩放开始的手势
  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoom = _currentZoom;
  }

  /// Handle when the double tap scale details is updating.
  /// 处理双指缩放更新
  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }

    zoom(details.scale);
  }

  void _restartPointDisplayTimer() {
    _exposurePointDisplayTimer?.cancel();
    _exposurePointDisplayTimer = Timer(const Duration(seconds: 5), () {
      _lastExposurePoint.value = null;
    });
  }

  void _restartModeDisplayTimer() {
    _exposureModeDisplayTimer?.cancel();
    _exposureModeDisplayTimer = Timer(const Duration(seconds: 2), () {
      _isExposureModeDisplays.value = false;
    });
  }

  /// Use the specific [mode] to update the exposure mode.
  /// 设置曝光模式
  void switchExposureMode() {
    if (_exposureMode.value == ExposureMode.auto) {
      _exposureMode.value = ExposureMode.locked;
    } else {
      _exposureMode.value = ExposureMode.auto;
    }
    _exposurePointDisplayTimer?.cancel();
    if (_exposureMode.value == ExposureMode.auto) {
      _exposurePointDisplayTimer = Timer(const Duration(seconds: 5), () {
        _lastExposurePoint.value = null;
      });
    }
    controller.setExposureMode(_exposureMode.value);
    _restartModeDisplayTimer();
  }

  /// Use the [details] point to set exposure and focus.
  /// 通过点击点的 [details] 设置曝光和对焦。
  Future<void> setExposureAndFocusPoint(
    TapUpDetails details,
    BoxConstraints constraints,
  ) async {
    _isExposureModeDisplays.value = false;
    // Ignore point update when the new point is less than 8% and higher than
    // 92% of the screen's height.
    if (details.globalPosition.dy < constraints.maxHeight / 12 ||
        details.globalPosition.dy > constraints.maxHeight / 12 * 11) {
      return;
    }
    realDebugPrint(
      'Setting new exposure point ('
      'x: ${details.globalPosition.dx}, '
      'y: ${details.globalPosition.dy}'
      ')',
    );
    _lastExposurePoint.value = Offset(
      details.globalPosition.dx,
      details.globalPosition.dy,
    );
    _restartPointDisplayTimer();
    _currentExposureOffset.value = 0;
    await controller.setExposureOffset(0);
    if (_exposureMode.value == ExposureMode.locked) {
      await controller.setExposureMode(ExposureMode.auto);
      _exposureMode.value = ExposureMode.auto;
    }
    controller.setExposurePoint(
      _lastExposurePoint.value!.scale(
        1 / constraints.maxWidth,
        1 / constraints.maxHeight,
      ),
    );
    if (controller.value.focusPointSupported == true) {
      controller.setFocusPoint(
        _lastExposurePoint.value!.scale(
          1 / constraints.maxWidth,
          1 / constraints.maxHeight,
        ),
      );
    }
  }

  /// Update the exposure offset using the exposure controller.
  /// 使用曝光控制器更新曝光值
  void updateExposureOffset(double value) {
    if (value == _currentExposureOffset.value) {
      return;
    }
    _currentExposureOffset.value = value;
    controller.setExposureOffset(value);
    if (!_isExposureModeDisplays.value) {
      _isExposureModeDisplays.value = true;
    }
    _restartModeDisplayTimer();
    _restartPointDisplayTimer();
  }

  /// Update the scale value while the user is shooting.
  /// 用户在录制时通过滑动更新缩放
  void onShootingButtonMove(
    PointerMoveEvent event,
    BoxConstraints constraints,
  ) {
    _lastShootingButtonPressedPosition ??= event.position;
    if (controller.value.isRecordingVideo) {
      // First calculate relative offset.
      final Offset _offset =
          event.position - _lastShootingButtonPressedPosition!;
      // Then turn negative,
      // multiply double with 10 * 1.5 - 1 = 14,
      // plus 1 to ensure always scale.
      final double _scale = _offset.dy / constraints.maxHeight * -14 + 1;
      zoom(_scale);
    }
  }

  /// The method to take a picture.
  /// 拍照方法
  ///
  /// The picture will only taken when [isInitialized], and the camera is not
  /// taking pictures.
  /// 仅当初始化成功且相机未在拍照时拍照。
  Future<void> takePicture() async {
    if (controller.value.isInitialized && !controller.value.isTakingPicture) {
      try {
        final AssetEntity? entity = await CameraPickerViewer.pushToViewer(
          context,
          pickerState: this,
          pickerType: CameraPickerViewType.image,
          previewXFile: await controller.takePicture(),
          theme: theme,
          shouldDeletePreviewFile: shouldDeletePreviewFile,
          onEntitySaving: widget.onEntitySaving,
        );
        if (entity != null) {
          Navigator.of(context).pop(entity);
        } else {
          safeSetState(() {});
        }
      } catch (e) {
        realDebugPrint('Error when taking pictures: $e');
      }
    }
  }

  /// When the [shootingButton]'s `onLongPress` called, the [_recordDetectTimer]
  /// will be initialized to achieve press time detection. If the duration
  /// reached to same as [recordDetectDuration], and the timer still active,
  /// start recording video.
  /// 当 [shootingButton] 触发了长按，初始化一个定时器来实现时间检测。如果长按时间
  /// 达到了 [recordDetectDuration] 且定时器未被销毁，则开始录制视频。
  void recordDetection() {
    _recordDetectTimer = Timer(recordDetectDuration, () {
      startRecordingVideo();
      safeSetState(() {});
    });
    setState(() {
      isShootingButtonAnimate = true;
    });
  }

  /// This will be given to the [Listener] in the [shootingButton]. When it's
  /// called, which means no more pressing on the button, cancel the timer and
  /// reset the status.
  /// 这个方法会赋值给 [shootingButton] 中的 [Listener]。当按钮释放了点击后，定时器
  /// 将被取消，并且状态会重置。
  void recordDetectionCancel(PointerUpEvent event) {
    _recordDetectTimer?.cancel();
    if (controller.value.isRecordingVideo) {
      _lastShootingButtonPressedPosition = null;
      stopRecordingVideo();
      safeSetState(() {});
    }
    if (isShootingButtonAnimate) {
      safeSetState(() {
        isShootingButtonAnimate = false;
      });
    }
  }

  /// Set record file path and start recording.
  /// 设置拍摄文件路径并开始录制视频
  void startRecordingVideo() {
    if (!controller.value.isRecordingVideo) {
      controller.startVideoRecording().then((dynamic _) {
        safeSetState(() {});
        if (isRecordingRestricted) {
          _recordCountdownTimer = Timer(maximumRecordingDuration!, () {
            stopRecordingVideo();
          });
        }
      }).catchError((dynamic e) {
        realDebugPrint('Error when recording video: $e');
        if (controller.value.isRecordingVideo) {
          controller.stopVideoRecording().catchError((dynamic e) {
            realDebugPrint('Error when stop recording video: $e');
          });
        }
      });
    }
  }

  /// Stop the recording process.
  /// 停止录制视频
  Future<void> stopRecordingVideo() async {
    if (controller.value.isRecordingVideo) {
      controller.stopVideoRecording().then((XFile file) async {
        final AssetEntity? entity = await CameraPickerViewer.pushToViewer(
          context,
          pickerState: this,
          pickerType: CameraPickerViewType.video,
          previewXFile: file,
          theme: theme,
          shouldDeletePreviewFile: shouldDeletePreviewFile,
        );
        if (entity != null) {
          Navigator.of(context).pop(entity);
        } else {
          safeSetState(() {});
        }
      }).catchError((dynamic e) {
        realDebugPrint('Error when stop recording video: $e');
      }).whenComplete(() {
        isShootingButtonAnimate = false;
      });
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  /////////////////////////// Just a line breaker ////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  /// Settings action section widget.
  /// 设置操作区
  ///
  /// This displayed at the top of the screen.
  /// 该区域显示在屏幕上方。
  Widget get settingsAction {
    return _initializeWrapper(
      builder: (CameraValue v, __) {
        if (v.isRecordingVideo) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: <Widget>[
              if (cameras.length > 1) switchCamerasButton,
              const Spacer(),
              switchFlashesButton(v),
            ],
          ),
        );
      },
    );
  }

  /// The button to switch between cameras.
  /// 切换相机的按钮
  Widget get switchCamerasButton {
    return IconButton(
      onPressed: switchCameras,
      icon: Icon(
        Platform.isIOS
            ? Icons.flip_camera_ios_outlined
            : Icons.flip_camera_android_outlined,
        size: 24,
      ),
    );
  }

  /// The button to switch flash modes.
  /// 切换闪光灯模式的按钮
  Widget switchFlashesButton(CameraValue value) {
    IconData icon;
    switch (value.flashMode) {
      case FlashMode.off:
        icon = Icons.flash_off;
        break;
      case FlashMode.auto:
        icon = Icons.flash_auto;
        break;
      case FlashMode.always:
      case FlashMode.torch:
        icon = Icons.flash_on;
        break;
    }
    return IconButton(
      onPressed: switchFlashesMode,
      icon: Icon(icon, size: 24),
    );
  }

  /// Text widget for shooting tips.
  /// 拍摄的提示文字
  Widget tipsTextWidget(CameraController? controller) {
    return AnimatedOpacity(
      duration: recordDetectDuration,
      opacity: controller?.value.isRecordingVideo == true ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
        ),
        child: Text(
          Constants.textDelegate.shootingTips,
          style: const TextStyle(fontSize: 15.0),
        ),
      ),
    );
  }

  /// Shooting action section widget.
  /// 拍照操作区
  ///
  /// This displayed at the top of the screen.
  /// 该区域显示在屏幕下方。
  Widget shootingActions(
    BuildContext context,
    CameraController? controller,
    BoxConstraints constraints,
  ) {
    return SizedBox(
      height: 118,
      child: Row(
        children: <Widget>[
          Expanded(
            child: controller?.value.isRecordingVideo == true
                ? const SizedBox.shrink()
                : Center(child: backButton(context, constraints)),
          ),
          Expanded(child: Center(child: shootingButton(constraints))),
          const Spacer(),
        ],
      ),
    );
  }

  /// The back button near to the [shootingButton].
  /// 靠近拍照键的返回键
  Widget backButton(BuildContext context, BoxConstraints constraints) {
    return InkWell(
      borderRadius: maxBorderRadius,
      onTap: Navigator.of(context).pop,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        width: 27,
        height: 27,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// The shooting button.
  /// 拍照按钮
  Widget shootingButton(BoxConstraints constraints) {
    const Size outerSize = Size.square(115);
    const Size innerSize = Size.square(82);
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerUp: enableRecording ? recordDetectionCancel : null,
      onPointerMove: enablePullToZoomInRecord
          ? (PointerMoveEvent e) => onShootingButtonMove(e, constraints)
          : null,
      child: InkWell(
        borderRadius: maxBorderRadius,
        onTap: !onlyEnableRecording ? takePicture : null,
        onLongPress: enableRecording ? recordDetection : null,
        child: SizedBox.fromSize(
          size: outerSize,
          child: Stack(
            children: <Widget>[
              Center(
                child: AnimatedContainer(
                  duration: kThemeChangeDuration,
                  width: isShootingButtonAnimate
                      ? outerSize.width
                      : innerSize.width,
                  height: isShootingButtonAnimate
                      ? outerSize.height
                      : innerSize.height,
                  padding: EdgeInsets.all(isShootingButtonAnimate ? 41 : 11),
                  decoration: BoxDecoration(
                    color: theme.canvasColor.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              _initializeWrapper(
                isInitialized: () =>
                    controller.value.isRecordingVideo && isRecordingRestricted,
                builder: (_, __) => CircleProgressBar(
                  duration: maximumRecordingDuration!,
                  outerRadius: outerSize.width,
                  ringsWidth: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exposureSlider(
    ExposureMode mode,
    double size,
    double height,
    double gap,
  ) {
    final bool isLocked = mode == ExposureMode.locked;
    final Color? color = isLocked ? _lockedColor : theme.iconTheme.color;

    Widget _line() {
      return ValueListenableBuilder<bool>(
        valueListenable: _isExposureModeDisplays,
        builder: (_, bool value, Widget? child) => AnimatedOpacity(
          duration: _kRouteDuration,
          opacity: value ? 1 : 0,
          child: child,
        ),
        child: Center(child: Container(width: 1, color: color)),
      );
    }

    return ValueListenableBuilder<double>(
      valueListenable: _currentExposureOffset,
      builder: (_, double exposure, __) {
        final double _effectiveTop = (size + gap) +
            (_minAvailableExposureOffset.abs() - exposure) *
                (height - size * 3) /
                (_maxAvailableExposureOffset - _minAvailableExposureOffset);
        final double _effectiveBottom = height - _effectiveTop - size;
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(
              top: _effectiveTop + gap,
              child: _line(),
            ),
            Positioned.fill(
              bottom: _effectiveBottom + gap,
              child: _line(),
            ),
            Positioned(
              top: (_minAvailableExposureOffset.abs() - exposure) *
                  (height - size * 3) /
                  (_maxAvailableExposureOffset - _minAvailableExposureOffset),
              child: Transform.rotate(
                angle: exposure,
                child: Icon(
                  Icons.wb_sunny_outlined,
                  size: size,
                  color: color,
                ),
              ),
            ),
            Positioned.fill(
              top: -10,
              bottom: -10,
              child: RotatedBox(
                quarterTurns: 3,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Opacity(
                    opacity: 0,
                    child: Slider(
                      value: exposure,
                      min: _minAvailableExposureOffset,
                      max: _maxAvailableExposureOffset,
                      onChanged: updateExposureOffset,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// The area widget for the last exposure point that user manually set.
  /// 用户手动设置的曝光点的区域显示
  Widget _focusingAreaWidget(BoxConstraints constraints) {
    Widget _buildControl(double size, double height) {
      const double _verticalGap = 3;
      return ValueListenableBuilder<ExposureMode>(
        valueListenable: _exposureMode,
        builder: (_, ExposureMode mode, __) {
          final bool isLocked = mode == ExposureMode.locked;
          return Column(
            children: <Widget>[
              ValueListenableBuilder<bool>(
                valueListenable: _isExposureModeDisplays,
                builder: (_, bool value, Widget? child) => AnimatedOpacity(
                  duration: _kRouteDuration,
                  opacity: value ? 1 : 0,
                  child: child,
                ),
                child: GestureDetector(
                  onTap: switchExposureMode,
                  child: SizedBox.fromSize(
                    size: Size.square(size),
                    child: Icon(
                      isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                      size: size,
                      color: isLocked ? _lockedColor : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _verticalGap),
              Expanded(
                child: _exposureSlider(mode, size, height, _verticalGap),
              ),
              const SizedBox(height: _verticalGap),
              SizedBox.fromSize(size: Size.square(size)),
            ],
          );
        },
      );
    }

    Widget _buildFromPoint(Offset point) {
      const double _controllerWidth = 20;
      final double _pointWidth = constraints.maxWidth / 5;
      final double _exposureControlWidth =
          enableExposureControlOnPoint ? _controllerWidth : 0;
      final double _width = _pointWidth + _exposureControlWidth + 2;

      final bool _shouldReverseLayout = point.dx > constraints.maxWidth / 4 * 3;

      final double _effectiveLeft = math.min(
        constraints.maxWidth - _width,
        math.max(0, point.dx - _width / 2),
      );
      final double _effectiveTop = math.min(
        constraints.maxHeight - _pointWidth * 3,
        math.max(0, point.dy - _pointWidth * 3 / 2),
      );

      return Positioned(
        left: _effectiveLeft,
        top: _effectiveTop,
        width: _width,
        height: _pointWidth * 3,
        child: Row(
          textDirection:
              _shouldReverseLayout ? TextDirection.rtl : TextDirection.ltr,
          children: <Widget>[
            ExposurePointWidget(
              key: ValueKey<int>(currentTimeStamp),
              size: _pointWidth,
              color: theme.iconTheme.color!,
            ),
            if (enableExposureControlOnPoint) const SizedBox(width: 2),
            if (enableExposureControlOnPoint)
              SizedBox.fromSize(
                size: Size(_exposureControlWidth, _pointWidth * 3),
                child: _buildControl(_controllerWidth, _pointWidth * 3),
              ),
          ],
        ),
      );
    }

    return ValueListenableBuilder<Offset?>(
      valueListenable: _lastExposurePoint,
      builder: (_, Offset? point, __) {
        if (point == null) {
          return const SizedBox.shrink();
        }
        return _buildFromPoint(point);
      },
    );
  }

  /// The [GestureDetector] widget for setting exposure point manually.
  /// 用于手动设置曝光点的 [GestureDetector]
  Widget _exposureDetectorWidget(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    return Positioned.fill(
      child: GestureDetector(
        onTapUp: (TapUpDetails d) => setExposureAndFocusPoint(d, constraints),
        behavior: HitTestBehavior.translucent,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _cameraPreview(
    BuildContext context, {
    required DeviceOrientation orientation,
    required BoxConstraints constraints,
  }) {
    Widget _preview = Listener(
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,
      child: GestureDetector(
        onScaleStart: enablePinchToZoom ? _handleScaleStart : null,
        onScaleUpdate: enablePinchToZoom ? _handleScaleUpdate : null,
        // Enabled cameras switching by default if we have multiple cameras.
        onDoubleTap: cameras.length > 1 ? switchCameras : null,
        child: CameraPreview(controller),
      ),
    );

    final _PreviewScaleType scale = _effectiveScaleType(constraints);
    if (scale == _PreviewScaleType.none) {
      return _preview;
    }

    double _width;
    double _height;
    switch (scale) {
      case _PreviewScaleType.width:
        _width = constraints.maxWidth;
        if (constraints.maxWidth <= constraints.maxHeight) {
          _height = constraints.maxWidth * controller.value.aspectRatio;
        } else {
          _height = constraints.maxWidth / controller.value.aspectRatio;
        }
        break;
      case _PreviewScaleType.height:
        _width = constraints.maxHeight / controller.value.aspectRatio;
        _height = constraints.maxHeight;
        break;
      default:
        _width = constraints.maxWidth;
        _height = constraints.maxHeight;
        break;
    }
    final double _offsetHorizontal = (_width - constraints.maxWidth).abs() / -2;
    final double _offsetVertical = (_height - constraints.maxHeight).abs() / -2;
    if (widget.shouldLockPortrait) {
      _preview = RotatedBox(
        quarterTurns: _previewQuarterTurns(orientation, constraints),
        child: _preview,
      );
    }
    _preview = Stack(
      children: <Widget>[
        Positioned(
          left: _offsetHorizontal,
          right: _offsetHorizontal,
          top: _offsetVertical,
          bottom: _offsetVertical,
          child: _preview,
        ),
      ],
    );
    return _preview;
  }

  Widget _initializeWrapper({
    required Widget Function(CameraValue, Widget?) builder,
    bool Function()? isInitialized,
    Widget? child,
  }) {
    return ValueListenableBuilder<CameraController?>(
      valueListenable: _controllerNotifier,
      builder: (_, CameraController? controller, __) {
        if (controller != null) {
          return ValueListenableBuilder<CameraValue>(
            valueListenable: controller,
            builder: (_, CameraValue value, Widget? w) {
              return isInitialized?.call() ?? value.isInitialized
                  ? builder(value, w)
                  : const SizedBox.shrink();
            },
            child: child,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _cameraBuilder({
    required BuildContext context,
    required CameraValue value,
    required BoxConstraints constraints,
  }) {
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: RepaintBoundary(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: _cameraPreview(
                context,
                orientation: value.deviceOrientation,
                constraints: constraints,
              ),
            ),
            if (widget.foregroundBuilder != null)
              Positioned.fill(child: widget.foregroundBuilder!(value)),
          ],
        ),
      ),
    );
  }

  Widget _contentBuilder(BoxConstraints constraints) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: ValueListenableBuilder<CameraController?>(
          valueListenable: _controllerNotifier,
          builder: (
            BuildContext context,
            CameraController? controller,
            _,
          ) =>
              Column(
            children: <Widget>[
              settingsAction,
              const Spacer(),
              tipsTextWidget(controller),
              shootingActions(context, controller, constraints),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: theme,
        child: Material(
          color: Colors.black,
          child: RotatedBox(
            quarterTurns: widget.cameraQuarterTurns,
            child: LayoutBuilder(
              builder: (BuildContext c, BoxConstraints constraints) => Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: <Widget>[
                  _initializeWrapper(
                    builder: (CameraValue value, __) {
                      if (value.isInitialized) {
                        return _cameraBuilder(
                          context: c,
                          value: value,
                          constraints: constraints,
                        );
                      }
                      return const SizedBox.expand();
                    },
                  ),
                  if (enableSetExposure)
                    _exposureDetectorWidget(c, constraints),
                  _initializeWrapper(
                    builder: (_, __) => _focusingAreaWidget(constraints),
                  ),
                  _contentBuilder(constraints),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _PreviewScaleType { none, width, height }
