// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wechat_picker_library/wechat_picker_library.dart';

import '../constants/config.dart';
import '../internals/singleton.dart';
import '../constants/enums.dart';
import '../delegates/camera_picker_text_delegate.dart';
import '../internals/methods.dart';
import '../widgets/camera_focus_point.dart';
import '../widgets/camera_picker.dart';
import '../widgets/camera_picker_viewer.dart';
import '../widgets/camera_progress_button.dart';

const Color _lockedColor = Colors.orangeAccent;
const Duration _kDuration = Duration(milliseconds: 300);

class CameraPickerState extends State<CameraPicker>
    with WidgetsBindingObserver {
  /// The [Duration] for record detection. (200ms)
  /// 检测是否开始录制的时长 (200毫秒)
  final Duration recordDetectDuration = const Duration(milliseconds: 200);

  /// The last exposure point offset on the screen.
  /// 最后一次手动聚焦的点坐标
  final ValueNotifier<Offset?> lastExposurePoint = ValueNotifier<Offset?>(null);

  /// The last pressed position on the shooting button before starts recording.
  /// 在开始录像前，最后一次在拍照按钮按下的位置
  Offset? lastShootingButtonPressedPosition;

  /// Whether the focus point is displaying.
  /// 是否正在展示当前的聚焦点
  final ValueNotifier<bool> isFocusPointDisplays = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isFocusPointFadeOut = ValueNotifier<bool>(false);

  /// The controller for the current camera.
  /// 当前相机实例的控制器
  CameraController get controller => innerController!;
  CameraController? innerController;

  /// Available cameras.
  /// 可用的相机实例
  late List<CameraDescription> cameras;

  /// Whether the controller is handling method calls.
  /// 相机控制器是否在处理方法调用
  bool isControllerBusy = false;

  /// Current exposure offset.
  /// 当前曝光值
  final ValueNotifier<double> currentExposureOffset = ValueNotifier<double>(0);
  final ValueNotifier<double> currentExposureSliderOffset =
      ValueNotifier<double>(0);
  double maxAvailableExposureOffset = 0;
  double minAvailableExposureOffset = 0;
  double exposureStep = 0;

  /// The maximum available value for zooming.
  /// 最大可用缩放值
  double maxAvailableZoom = 1;

  /// The minimum available value for zooming.
  /// 最小可用缩放值
  double minAvailableZoom = 1;

  /// Counting pointers (number of user fingers on screen).
  /// 屏幕上的触摸点计数
  int pointers = 0;
  double currentZoom = 1;
  double baseZoom = 1;

  /// The index of the current cameras. Defaults to `0`.
  /// 当前相机的索引。默认为0
  int currentCameraIndex = 0;

  /// Whether the [buildCaptureButton] should animate according to the gesture.
  /// 拍照按钮是否需要执行动画
  ///
  /// This happens when the [buildCaptureButton] is being long pressed.
  /// It will animate for video recording state.
  /// 当长按拍照按钮时，会进入准备录制视频的状态，此时需要执行动画。
  bool isShootingButtonAnimate = false;

  /// The [Timer] for keep the [lastExposurePoint] displays.
  /// 用于控制上次手动聚焦点显示的计时器
  Timer? exposurePointDisplayTimer;
  Timer? exposureModeDisplayTimer;
  Timer? exposureFadeOutTimer;

  /// The [Timer] for record start detection.
  /// 用于检测是否开始录制的计时器
  ///
  /// When the [buildCaptureButton] started animate, this [Timer] will start
  /// at the same time. When the time is more than [recordDetectDuration],
  /// which means we should start recoding, the timer finished.
  /// 当拍摄按钮开始执行动画时，定时器会同时启动。时长超过检测时长时，定时器完成。
  Timer? recordDetectTimer;

  /// The [Timer] for record countdown.
  /// 用于录制视频倒计时的计时器
  ///
  /// Stop record When the record time reached the [maximumRecordingDuration].
  /// However, if there's no limitation on record time, this will be useless.
  /// 当录像时间达到了最大时长，将通过定时器停止录像。
  /// 但如果录像时间没有限制，定时器将不会起作用。
  Timer? recordCountdownTimer;

  /// The [Stopwatch] to monitor if the record has reached
  /// the minimum record duration requirement.
  /// 录像时长计时器，用来检测是否达到了最短录制时长。
  final Stopwatch recordStopwatch = Stopwatch();

  /// Initialized with all the flash modes for each camera. If a flash mode is
  /// not valid, it is removed from the list.
  /// 使用每个相机的所有闪光灯模式进行初始化。
  /// 如果闪光灯模式无效，则将其从列表中删除。
  final Map<CameraDescription, List<FlashMode>> validFlashModes =
      <CameraDescription, List<FlashMode>>{};

  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////// Global Getters //////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  CameraPickerConfig get pickerConfig => widget.pickerConfig;

  /// Whether the camera preview should be scaled during captures.
  /// 拍摄过程中相机预览是否需要缩放
  bool get enableScaledPreview => pickerConfig.enableScaledPreview;

  /// Whether the picker can record video.
  /// 选择器是否可以录像
  bool get enableRecording => pickerConfig.enableRecording;

  /// Whether the picker only enables video recording.
  /// 选择器是否只可以录像
  bool get onlyEnableRecording =>
      enableRecording && pickerConfig.onlyEnableRecording;

  /// Whether allow the record can start with single tap.
  /// 选择器是否可以单击录像
  bool get enableTapRecording =>
      onlyEnableRecording && pickerConfig.enableTapRecording;

  /// No audio integration required when it's only for camera.
  /// 在仅允许拍照时不需要启用音频
  bool get enableAudio => enableRecording && pickerConfig.enableAudio;

  /// Whether the picker needs to prepare for video recording on iOS.
  /// 是否需要为 iOS 的录制视频执行准备操作
  bool get shouldPrepareForVideoRecording =>
      enableRecording && enableAudio && Platform.isIOS;

  bool get enablePullToZoomInRecord =>
      enableRecording && pickerConfig.enablePullToZoomInRecord;

  /// Whether the recording restricted to a specific duration.
  /// 录像是否有限制的时长
  bool get isRecordingRestricted =>
      pickerConfig.maximumRecordingDuration != null;

  /// The minimum recording duration limit.
  /// 录制视频的最短时长限制。
  ///
  /// If the maximum duration is less than the minimum, use the maximum instead.
  /// 如果最大时长大于最小时长，则使用最大时长。
  Duration get minimumRecordingDuration {
    if (pickerConfig.maximumRecordingDuration != null &&
        pickerConfig.maximumRecordingDuration! <
            pickerConfig.minimumRecordingDuration) {
      return pickerConfig.maximumRecordingDuration!;
    }
    return pickerConfig.minimumRecordingDuration;
  }

  /// Whether the capture button is displaying.
  bool get shouldCaptureButtonDisplay =>
      isControllerBusy ||
      (innerController?.value.isRecordingVideo ?? false) &&
          isRecordingRestricted;

  /// Whether the camera preview should be rotated.
  bool get isCameraRotated => pickerConfig.cameraQuarterTurns % 4 != 0;

  int get cameraQuarterTurns => pickerConfig.cameraQuarterTurns;

  /// A getter to the current [CameraDescription].
  /// 获取当前相机实例
  CameraDescription get currentCamera => cameras.elementAt(currentCameraIndex);

  /// If there's no theme provided from the user, use [CameraPicker.themeData] .
  /// 如果用户未提供主题，通过 [CameraPicker.themeData] 创建。
  late final ThemeData theme =
      pickerConfig.theme ?? CameraPicker.themeData(defaultThemeColorWeChat);

  CameraPickerTextDelegate get textDelegate => Singleton.textDelegate;

  /// If controller methods were failed to called for camera descriptions,
  /// it will be recorded as invalid and never gets called again.
  ///
  /// 如果相机实例的某个方法调用失败，该方法会被记录并且不会再被调用。
  final invalidControllerMethods = <CameraDescription, Set<String>>{};
  bool retriedAfterInvalidInitialize = false;

  /// Subscribe to the accelerometer.
  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;

  /// The locked capture orientation of the current camera instance.
  DeviceOrientation? lockedCaptureOrientation;

  @override
  void initState() {
    super.initState();
    ambiguate(WidgetsBinding.instance)?.addObserver(this);
    Singleton.textDelegate = widget.pickerConfig.textDelegate ??
        cameraPickerTextDelegateFromLocale(widget.locale);
    initCameras();
    initAccelerometerSubscription();
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    final c = innerController;
    innerController = null;
    c?.dispose();
    currentExposureOffset.dispose();
    currentExposureSliderOffset.dispose();
    lastExposurePoint.dispose();
    isFocusPointDisplays.dispose();
    isFocusPointFadeOut.dispose();
    exposurePointDisplayTimer?.cancel();
    exposureModeDisplayTimer?.cancel();
    exposureFadeOutTimer?.cancel();
    recordDetectTimer?.cancel();
    recordCountdownTimer?.cancel();
    accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? c = innerController;
    if (state == AppLifecycleState.resumed) {
      initCameras(currentCamera);
    } else if (c == null || !c.value.isInitialized) {
      // App state changed before we got the chance to initialize.
      return;
    } else if (state == AppLifecycleState.inactive) {
      c.dispose();
      innerController = null;
      isControllerBusy = false;
    }
  }

  /// Adjust the proper scale type according to the [constraints].
  /// 根据 [constraints] 获取相机预览适用的缩放。
  double effectiveCameraScale(
    BoxConstraints constraints,
    CameraController? controller,
  ) {
    if (controller == null) {
      return 1;
    }
    final int turns = cameraQuarterTurns;
    final String orientation = controller.value.deviceOrientation.toString();
    // Fetch the biggest size from the constraints.
    Size size = constraints.biggest;
    // Flip the size when the preview needs to turn with an odd count of quarters.
    if ((turns.isOdd && orientation.contains('portrait')) ||
        (turns.isEven && orientation.contains('landscape'))) {
      size = size.flipped;
    }
    // Calculate scale depending on the size and camera ratios.
    double scale = size.aspectRatio * controller.value.aspectRatio;
    // Prevent scaling down.
    if (scale < 1) {
      scale = 1 / scale;
    }
    return scale;
  }

  /// Wraps [CameraController] methods with invalid controls.
  /// Returns the [fallback] value if invalid and [T] is non-void.
  ///
  /// 对于 [CameraController] 的方法增加是否无效的控制。
  /// 如果 [T] 是非 void 且方法无效，返回 [fallback]。
  Future<T> wrapControllerMethod<T>(
    String key,
    Future<T> Function() method, {
    CameraDescription? description,
    VoidCallback? onError,
    T? fallback,
  }) async {
    description ??= currentCamera;
    if (invalidControllerMethods[description]!.contains(key)) {
      return fallback!;
    }
    try {
      return await method();
    } catch (e) {
      invalidControllerMethods[description]!.add(key);
      onError?.call();
      rethrow;
    }
  }

  /// Initialize cameras instances.
  /// 初始化相机实例
  Future<void> initCameras([CameraDescription? cameraDescription]) async {
    // Save the current controller to a local variable.
    final CameraController? c = innerController;
    // Dispose at last to avoid disposed usage with assertions.
    if (c != null) {
      innerController = null;
      await c.dispose();
    }
    // Then request a new frame to unbind the controller from elements.
    safeSetState(() {
      maxAvailableZoom = 1;
      minAvailableZoom = 1;
      currentZoom = 1;
      baseZoom = 1;
      // Meanwhile, cancel the existed exposure point and mode display.
      exposurePointDisplayTimer?.cancel();
      exposureModeDisplayTimer?.cancel();
      exposureFadeOutTimer?.cancel();
      isFocusPointDisplays.value = false;
      isFocusPointFadeOut.value = false;
      lastExposurePoint.value = null;
      currentExposureOffset.value = 0;
      currentExposureSliderOffset.value = 0;
      lockedCaptureOrientation = pickerConfig.lockCaptureOrientation;
    });
    // **IMPORTANT**: Push methods into a post frame callback, which ensures the
    // controller has already unbind from widgets.
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      // When the [cameraDescription] is null, which means this is the first
      // time initializing cameras, so available cameras should be fetched.
      if (cameraDescription == null) {
        cameras = await availableCameras();
      }

      // After cameras fetched, judge again with the list is empty or not to
      // ensure there is at least an available camera for use.
      if (cameraDescription == null && cameras.isEmpty) {
        handleErrorWithHandler(
          CameraException(
            'No CameraDescription found.',
            'No cameras are available in the controller.',
          ),
          StackTrace.current,
          pickerConfig.onError,
        );
        return;
      }

      initFlashModesForCameras();
      final int preferredIndex = cameras.indexWhere(
        (CameraDescription e) =>
            e.lensDirection == pickerConfig.preferredLensDirection,
      );
      final int index;
      if (preferredIndex != -1 && c == null) {
        index = preferredIndex;
        currentCameraIndex = preferredIndex;
      } else {
        index = currentCameraIndex;
      }
      // Initialize the controller with the given resolution preset.
      final description = cameraDescription ?? cameras[index];
      invalidControllerMethods[description] ??= <String>{};
      final CameraController newController = CameraController(
        description,
        pickerConfig.resolutionPreset,
        enableAudio: enableAudio,
        imageFormatGroup: pickerConfig.imageFormatGroup,
      );

      try {
        final Stopwatch stopwatch = Stopwatch()..start();
        await newController.initialize();
        stopwatch.stop();
        realDebugPrint("${stopwatch.elapsed} for controller's initialization.");
        // Call recording preparation first.
        if (shouldPrepareForVideoRecording) {
          stopwatch
            ..reset()
            ..start();
          await newController.prepareForVideoRecording();
          stopwatch.stop();
          realDebugPrint("${stopwatch.elapsed} for recording's preparation.");
        }
        // Then call other asynchronous methods.
        stopwatch
          ..reset()
          ..start();
        await Future.wait(
          <Future<void>>[
            wrapControllerMethod(
              'getExposureOffsetStepSize',
              () => newController.getExposureOffsetStepSize(),
              description: description,
              fallback: exposureStep,
            ).then((value) => exposureStep = value),
            wrapControllerMethod(
              'getMaxExposureOffset',
              () => newController.getMaxExposureOffset(),
              description: description,
              fallback: maxAvailableExposureOffset,
            ).then((value) => maxAvailableExposureOffset = value),
            wrapControllerMethod(
              'getMinExposureOffset',
              () => newController.getMinExposureOffset(),
              description: description,
              fallback: minAvailableExposureOffset,
            ).then((value) => minAvailableExposureOffset = value),
            wrapControllerMethod(
              'getMaxZoomLevel',
              () => newController.getMaxZoomLevel(),
              description: description,
              fallback: maxAvailableZoom,
            ).then((value) => maxAvailableZoom = value),
            wrapControllerMethod(
              'getMinZoomLevel',
              () => newController.getMinZoomLevel(),
              description: description,
              fallback: minAvailableZoom,
            ).then((value) => minAvailableZoom = value),
            wrapControllerMethod(
              'getMinZoomLevel',
              () => newController.getMinZoomLevel(),
              description: description,
              fallback: minAvailableZoom,
            ).then((value) => minAvailableZoom = value),
            if (pickerConfig.lockCaptureOrientation != null)
              wrapControllerMethod<void>(
                'lockCaptureOrientation',
                () => newController.lockCaptureOrientation(
                  pickerConfig.lockCaptureOrientation,
                ),
                description: description,
              ),
            // Do not set flash modes for the front camera.
            if (description.lensDirection != CameraLensDirection.front &&
                pickerConfig.preferredFlashMode != FlashMode.auto)
              wrapControllerMethod<void>(
                'setFlashMode',
                () => newController.setFlashMode(
                  pickerConfig.preferredFlashMode,
                ),
                description: description,
                onError: () {
                  validFlashModes[description]?.remove(
                    pickerConfig.preferredFlashMode,
                  );
                },
              ),
          ],
          eagerError: false,
        );
        stopwatch.stop();
        realDebugPrint("${stopwatch.elapsed} for config's update.");
        innerController = newController;
      } catch (e, s) {
        handleErrorWithHandler(e, s, pickerConfig.onError);
        if (!retriedAfterInvalidInitialize) {
          retriedAfterInvalidInitialize = true;
          Future.delayed(Duration.zero, initCameras);
        } else {
          retriedAfterInvalidInitialize = false;
        }
      } finally {
        safeSetState(() {});
      }
    });
  }

  /// Starts to listen on accelerometer events.
  void initAccelerometerSubscription() {
    try {
      final stream = accelerometerEventStream();
      accelerometerSubscription = stream.listen(handleAccelerometerEvent);
    } catch (e, s) {
      realDebugPrint(
        'The device does not seem to support accelerometer. '
        'The captured files orientation might be incorrect.',
      );
      handleErrorWithHandler(e, s, pickerConfig.onError);
    }
  }

  /// Lock capture orientation according to the current status of the device,
  /// which enables the captured file stored the correct orientation.
  void handleAccelerometerEvent(AccelerometerEvent event) {
    if (!mounted ||
        pickerConfig.lockCaptureOrientation != null ||
        innerController == null ||
        !controller.value.isInitialized ||
        controller.value.isPreviewPaused ||
        controller.value.isRecordingVideo ||
        controller.value.isTakingPicture) {
      return;
    }
    final x = event.x, y = event.y, z = event.z;
    final DeviceOrientation? newOrientation;
    if (x.abs() > y.abs() && x.abs() > z.abs()) {
      if (x > 0) {
        newOrientation = DeviceOrientation.landscapeLeft;
      } else {
        newOrientation = DeviceOrientation.landscapeRight;
      }
    } else if (y.abs() > x.abs() && y.abs() > z.abs()) {
      if (y > 0) {
        newOrientation = DeviceOrientation.portraitUp;
      } else {
        newOrientation = DeviceOrientation.portraitDown;
      }
    } else {
      newOrientation = null;
    }
    // Throttle.
    if (newOrientation != null && lockedCaptureOrientation != newOrientation) {
      lockedCaptureOrientation = newOrientation;
      realDebugPrint('Locking new capture orientation: $newOrientation');
      controller.lockCaptureOrientation(newOrientation);
    }
  }

  /// Initializes the flash modes in [validFlashModes] for each
  /// [CameraDescription].
  /// 为每个 [CameraDescription] 在 [validFlashModes] 中初始化闪光灯模式。
  void initFlashModesForCameras() {
    for (final CameraDescription camera in cameras) {
      if (!validFlashModes.containsKey(camera)) {
        // Mind the order of this list as it has an impact on the switch cycle.
        // Do not use FlashMode.values.
        validFlashModes[camera] = <FlashMode>[
          FlashMode.auto,
          FlashMode.always,
          FlashMode.torch,
          FlashMode.off,
        ];
      }
    }
  }

  /// Switch cameras in order. When the [currentCameraIndex] reached the length
  /// of cameras, start from the beginning.
  /// 按顺序切换相机。当达到相机数量时从头开始。
  void switchCameras() {
    // Skip switching when taking picture or recording video.
    if (controller.value.isTakingPicture || controller.value.isRecordingVideo) {
      return;
    }
    ++currentCameraIndex;
    if (currentCameraIndex == cameras.length) {
      currentCameraIndex = 0;
    }
    initCameras(currentCamera);
  }

  /// Obtain the next camera description for semantics.
  CameraDescription get nextCameraDescription {
    final int nextIndex = currentCameraIndex + 1;
    if (nextIndex == cameras.length) {
      return cameras[0];
    }
    return cameras[nextIndex];
  }

  /// The method to switch between flash modes.
  /// 切换闪光灯模式的方法
  Future<void> switchFlashesMode(CameraValue value) async {
    final List<FlashMode> flashModes = validFlashModes[currentCamera]!;
    if (flashModes.isEmpty) {
      // Unlikely event that no flash mode is valid for current camera.
      handleErrorWithHandler(
        CameraException(
          'No FlashMode found.',
          'No flash modes are available with the camera.',
        ),
        StackTrace.current,
        pickerConfig.onError,
      );
      return;
    }
    final int currentFlashModeIndex = flashModes.indexOf(value.flashMode);
    final int nextFlashModeIndex;
    if (currentFlashModeIndex + 1 >= flashModes.length) {
      nextFlashModeIndex = 0;
    } else {
      nextFlashModeIndex = currentFlashModeIndex + 1;
    }
    final FlashMode nextFlashMode = flashModes[nextFlashModeIndex];
    try {
      await controller.setFlashMode(nextFlashMode);
    } catch (e, s) {
      // Remove the flash mode that throws an exception.
      validFlashModes[currentCamera]!.remove(nextFlashMode);
      switchFlashesMode(value);
      handleErrorWithHandler(e, s, pickerConfig.onError);
    }
  }

  Future<void> zoom(double scale) async {
    if (maxAvailableZoom == minAvailableZoom) {
      return;
    }
    if (recordDetectTimer?.isActive ?? false) {
      return;
    }
    final double zoom = (baseZoom * scale).clamp(
      minAvailableZoom,
      maxAvailableZoom,
    );
    if (zoom == currentZoom) {
      return;
    }
    currentZoom = zoom;
    try {
      await controller.setZoomLevel(currentZoom);
    } catch (e, s) {
      handleErrorWithHandler(e, s, pickerConfig.onError);
    }
  }

  /// Handle when the scale gesture start.
  /// 处理缩放开始的手势
  void handleScaleStart(ScaleStartDetails details) {
    baseZoom = currentZoom;
  }

  /// Handle when the double tap scale details is updating.
  /// 处理双指缩放更新
  Future<void> handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (pointers != 2) {
      return;
    }
    zoom(details.scale);
  }

  void restartExposurePointDisplayTimer() {
    exposurePointDisplayTimer?.cancel();
    exposurePointDisplayTimer = Timer(const Duration(seconds: 5), () {
      lastExposurePoint.value = null;
    });
  }

  void restartExposureModeDisplayTimer() {
    exposureModeDisplayTimer?.cancel();
    exposureModeDisplayTimer = Timer(const Duration(seconds: 2), () {
      isFocusPointDisplays.value = false;
    });
  }

  void restartExposureFadeOutTimer() {
    isFocusPointFadeOut.value = false;
    exposureFadeOutTimer?.cancel();
    exposureFadeOutTimer = Timer(const Duration(seconds: 2), () {
      isFocusPointFadeOut.value = true;
    });
  }

  /// Use the specific [mode] to update the exposure mode.
  /// 设置曝光模式
  Future<void> switchExposureMode() async {
    final ExposureMode mode = controller.value.exposureMode;
    final ExposureMode newMode;
    if (mode == ExposureMode.auto) {
      newMode = ExposureMode.locked;
    } else {
      newMode = ExposureMode.auto;
    }
    exposurePointDisplayTimer?.cancel();
    if (newMode == ExposureMode.auto) {
      exposurePointDisplayTimer = Timer(const Duration(seconds: 5), () {
        lastExposurePoint.value = null;
      });
    }
    try {
      await controller.setExposureMode(newMode);
    } catch (e, s) {
      handleErrorWithHandler(e, s, pickerConfig.onError);
    } finally {
      restartExposureModeDisplayTimer();
      restartExposureFadeOutTimer();
    }
  }

  /// Use the [position] to set exposure and focus.
  /// 通过点击点的 [position] 设置曝光和对焦。
  Future<void> setExposureAndFocusPoint(
    Offset position,
    BoxConstraints constraints,
  ) async {
    isFocusPointDisplays.value = false;
    if (enableScaledPreview) {
      // Ignore point update when the new point is less than 8% and higher than
      // 92% of the screen's height.
      if (position.dy < constraints.maxHeight / 12 ||
          position.dy > constraints.maxHeight / 12 * 11) {
        return;
      }
    }
    realDebugPrint(
      'Setting new exposure point (x: ${position.dx}, y: ${position.dy})',
    );
    lastExposurePoint.value = position;
    restartExposurePointDisplayTimer();
    currentExposureOffset.value = 0;
    currentExposureSliderOffset.value = 0;
    restartExposureFadeOutTimer();
    isFocusPointFadeOut.value = false;
    try {
      await Future.wait(<Future<void>>[
        wrapControllerMethod<void>(
          'setExposureOffset',
          () => controller.setExposureOffset(0),
        ),
        controller.setExposureOffset(0),
        if (controller.value.exposureMode == ExposureMode.locked)
          wrapControllerMethod<void>(
            'setExposureMode',
            () => controller.setExposureMode(ExposureMode.auto),
          ),
      ]);
      final Offset newPoint = lastExposurePoint.value!.scale(
        1 / constraints.maxWidth,
        1 / constraints.maxHeight,
      );
      await Future.wait(<Future<void>>[
        if (controller.value.exposurePointSupported)
          controller.setExposurePoint(newPoint),
        if (controller.value.focusPointSupported)
          controller.setFocusPoint(newPoint),
      ]);
    } catch (e, s) {
      handleErrorWithHandler(e, s, pickerConfig.onError);
    }
  }

  /// Update the exposure offset using the exposure controller.
  /// 使用曝光控制器更新曝光值
  Future<void> updateExposureOffset(double value) async {
    final previousSliderOffsetValue = currentExposureSliderOffset.value;
    currentExposureSliderOffset.value = value;
    // Normalize the new exposure value if exposures have steps.
    if (exposureStep > 0) {
      final double inv = 1.0 / exposureStep;
      double roundedOffset = (value * inv).roundToDouble() / inv;
      if (roundedOffset > maxAvailableExposureOffset) {
        roundedOffset = (value * inv).floorToDouble() / inv;
      } else if (roundedOffset < minAvailableExposureOffset) {
        roundedOffset = (value * inv).ceilToDouble() / inv;
      }
      value = roundedOffset;
    }
    if (value == currentExposureOffset.value ||
        value < minAvailableExposureOffset ||
        value > maxAvailableExposureOffset) {
      return;
    }
    final previousOffsetValue = currentExposureOffset.value;
    currentExposureOffset.value = value;
    bool hasError = false;
    try {
      realDebugPrint('Updating the exposure offset value: $value');
      // Use [CameraPlatform] explicitly to reduce channel calls.
      await wrapControllerMethod(
        'setExposureOffset',
        () => CameraPlatform.instance.setExposureOffset(
          controller.cameraId,
          value,
        ),
      );
    } catch (e, s) {
      hasError = true;
      currentExposureSliderOffset.value = previousSliderOffsetValue;
      currentExposureOffset.value = previousOffsetValue;
      handleErrorWithHandler(e, s, pickerConfig.onError);
    } finally {
      if (!hasError && !isFocusPointDisplays.value) {
        isFocusPointDisplays.value = true;
      }
      restartExposurePointDisplayTimer();
      restartExposureModeDisplayTimer();
      restartExposureFadeOutTimer();
    }
  }

  /// Request to set the focus and the exposure point on the [localPosition],
  /// [lock] to lock the exposure mode at the same time.
  /// 将对焦和曝光设置为给定的点 [localPosition]，[lock] 控制是否同时锁定曝光模式。
  Future<void> requestFocusAndExposureOnPosition(
    Offset localPosition,
    BoxConstraints constraints, {
    bool lock = false,
  }) async {
    // Only call exposure point updates when the controller is initialized.
    if (innerController?.value.isInitialized ?? false) {
      Feedback.forTap(context);
      await setExposureAndFocusPoint(localPosition, constraints);
      if (lock) {
        await switchExposureMode();
      }
    }
  }

  /// Update the scale value while the user is shooting.
  /// 用户在录制时通过滑动更新缩放
  void onShootingButtonMove(
    PointerMoveEvent event,
    BoxConstraints constraints,
  ) {
    lastShootingButtonPressedPosition ??= event.position;
    if (controller.value.isRecordingVideo) {
      // First calculate relative offset.
      final Offset offset = event.position - lastShootingButtonPressedPosition!;
      // Then turn negative,
      // multiply double with 10 * 1.5 - 1 = 14,
      // plus 1 to ensure always scale.
      final double scale = offset.dy / constraints.maxHeight * -14 + 1;
      zoom(scale);
    }
  }

  /// The picture will only taken when [CameraValue.isInitialized],
  /// and the camera is not taking pictures.
  /// 仅当初始化成功且相机未在拍照时拍照。
  Future<void> takePicture() async {
    if (!controller.value.isInitialized) {
      handleErrorWithHandler(
        StateError('Camera has not initialized.'),
        StackTrace.current,
        pickerConfig.onError,
      );
    }
    if (isControllerBusy) {
      return;
    }
    setState(() {
      isControllerBusy = true;
      isShootingButtonAnimate = true;
    });
    final ExposureMode previousExposureMode = controller.value.exposureMode;
    try {
      await Future.wait(<Future<void>>[
        wrapControllerMethod<void>(
          'setFocusMode',
          () => controller.setFocusMode(FocusMode.locked),
        ).catchError((e, s) {
          handleErrorWithHandler(e, s, pickerConfig.onError);
        }),
        if (previousExposureMode != ExposureMode.locked)
          wrapControllerMethod<void>(
            'setExposureMode',
            () => controller.setExposureMode(ExposureMode.locked),
          ).catchError((e, s) {
            handleErrorWithHandler(e, s, pickerConfig.onError);
          }),
      ]);
      final XFile file = await controller.takePicture();
      await controller.pausePreview();
      final bool? isCapturedFileHandled = pickerConfig.onXFileCaptured?.call(
        file,
        CameraPickerViewType.image,
      );
      if (isCapturedFileHandled ?? false) {
        return;
      }
      final AssetEntity? entity = await pushToViewer(
        file: file,
        viewType: CameraPickerViewType.image,
      );
      if (entity != null) {
        Navigator.of(context).pop(entity);
        return;
      }
      await Future.wait(<Future<void>>[
        wrapControllerMethod<void>(
          'setFocusMode',
          () => controller.setFocusMode(FocusMode.auto),
        ),
        if (previousExposureMode != ExposureMode.locked)
          wrapControllerMethod<void>(
            'setExposureMode',
            () => controller.setExposureMode(previousExposureMode),
          ),
      ]);
      await controller.resumePreview();
    } catch (e, s) {
      handleErrorWithHandler(e, s, pickerConfig.onError);
    } finally {
      safeSetState(() {
        isControllerBusy = false;
        isShootingButtonAnimate = false;
      });
    }
  }

  /// When the [buildCaptureButton]'s `onLongPress` called,
  /// the [recordDetectTimer] will be initialized for the press time detection.
  /// If the duration reached to same as [recordDetectDuration] and the timer is
  /// still active, start recording video.
  /// 当 [buildCaptureButton] 触发了长按，初始化一个定时器来实现时间检测。如果长按时间
  /// 达到了 [recordDetectDuration] 且定时器未被销毁，则开始录制视频。
  void recordDetection() {
    recordDetectTimer = Timer(recordDetectDuration, () {
      startRecordingVideo();
      safeSetState(() {});
    });
    setState(() {
      isShootingButtonAnimate = true;
    });
  }

  /// This will be given to the [Listener] in the [buildCaptureButton]. When it's
  /// called, which means no more pressing on the button, cancel the timer and
  /// reset the status.
  /// 这个方法会赋值给 [buildCaptureButton] 中的 [Listener]。当按钮释放了点击后，定时器
  /// 将被取消，并且状态会重置。
  void recordDetectionCancel(PointerUpEvent event) {
    recordDetectTimer?.cancel();
    if (innerController?.value.isRecordingVideo == true) {
      stopRecordingVideo();
    }
  }

  /// Set record file path and start recording.
  /// 设置拍摄文件路径并开始录制视频
  Future<void> startRecordingVideo() async {
    if (isControllerBusy) {
      return;
    }
    isControllerBusy = true;
    try {
      await controller.startVideoRecording();
      if (isRecordingRestricted) {
        recordCountdownTimer = Timer(
          pickerConfig.maximumRecordingDuration!,
          stopRecordingVideo,
        );
      }
      recordStopwatch
        ..reset()
        ..start();
    } catch (e, s) {
      if (!controller.value.isRecordingVideo) {
        handleErrorWithHandler(e, s, pickerConfig.onError);
        return;
      }
      try {
        await controller.stopVideoRecording();
      } catch (e, s) {
        recordCountdownTimer?.cancel();
        isShootingButtonAnimate = false;
        handleErrorWithHandler(e, s, pickerConfig.onError);
      } finally {
        recordStopwatch.stop();
      }
    } finally {
      safeSetState(() {
        isControllerBusy = false;
      });
    }
  }

  /// Stop the recording process.
  /// 停止录制视频
  Future<void> stopRecordingVideo() async {
    if (isControllerBusy) {
      return;
    }

    recordStopwatch.stop();
    if (innerController == null || !controller.value.isRecordingVideo) {
      recordCountdownTimer?.cancel();
      safeSetState(() {
        isControllerBusy = false;
        isShootingButtonAnimate = false;
      });
      return;
    }
    safeSetState(() {
      isControllerBusy = true;
      lastShootingButtonPressedPosition = null;
    });
    try {
      final XFile file = await controller.stopVideoRecording();
      if (recordStopwatch.elapsed < minimumRecordingDuration) {
        pickerConfig.onMinimumRecordDurationNotMet?.call();
        return;
      }
      controller.pausePreview();
      final bool? isCapturedFileHandled = pickerConfig.onXFileCaptured?.call(
        file,
        CameraPickerViewType.video,
      );
      if (isCapturedFileHandled ?? false) {
        return;
      }
      final AssetEntity? entity = await pushToViewer(
        file: file,
        viewType: CameraPickerViewType.video,
      );
      if (entity != null) {
        Navigator.of(context).pop(entity);
      } else {
        await controller.resumePreview();
      }
    } catch (e, s) {
      recordCountdownTimer?.cancel();
      initCameras();
      handleErrorWithHandler(e, s, pickerConfig.onError);
    } finally {
      safeSetState(() {
        isControllerBusy = false;
        isShootingButtonAnimate = false;
      });
    }
  }

  Future<AssetEntity?> pushToViewer({
    required XFile file,
    required CameraPickerViewType viewType,
  }) async {
    if (viewType == CameraPickerViewType.image) {
      await precacheImage(FileImage(File(file.path)), context);
    }
    return CameraPickerViewer.pushToViewer(
      context,
      pickerConfig: pickerConfig,
      viewType: viewType,
      previewXFile: file,
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  /////////////////////////// Just a line breaker ////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  PointerUpEventListener? get onPointerUp {
    if (innerController != null && enableRecording && !enableTapRecording) {
      return recordDetectionCancel;
    }
    return null;
  }

  PointerMoveEventListener? onPointerMove(BoxConstraints c) {
    if (innerController != null &&
        enablePullToZoomInRecord &&
        controller.value.isRecordingVideo) {
      return (PointerMoveEvent e) => onShootingButtonMove(e, c);
    }
    return null;
  }

  GestureTapCallback? get onTap {
    if (innerController == null || isControllerBusy) {
      return null;
    }
    if (enableTapRecording) {
      if (controller.value.isRecordingVideo) {
        return stopRecordingVideo;
      }
      return () {
        startRecordingVideo();
        setState(() {
          isShootingButtonAnimate = true;
        });
      };
    }
    if (!onlyEnableRecording) {
      return takePicture;
    }
    return null;
  }

  String? get onTapHint {
    if (innerController == null || isControllerBusy) {
      return null;
    }
    if (enableTapRecording) {
      if (innerController?.value.isRecordingVideo ?? false) {
        return textDelegate.sActionStopRecordingHint;
      }
      return textDelegate.sActionRecordHint;
    }
    if (!onlyEnableRecording) {
      return textDelegate.sActionShootHint;
    }
    return null;
  }

  GestureLongPressCallback? get onLongPress {
    if (innerController == null || isControllerBusy) {
      return null;
    }
    if (enableRecording && !enableTapRecording) {
      return recordDetection;
    }
    return null;
  }

  String? get onLongPressHint {
    if (innerController == null || isControllerBusy) {
      return null;
    }
    if (enableRecording && !enableTapRecording) {
      return textDelegate.sActionRecordHint;
    }
    return null;
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
  Widget buildSettingActions(BuildContext context) {
    return buildInitializeWrapper(
      builder: (CameraValue v, __) {
        if (v.isRecordingVideo) {
          return const SizedBox.shrink();
        }
        Widget backButton = buildBackButton(context);
        Widget flashModeSwitch = buildFlashModeSwitch(context, v);
        if (isCameraRotated && !enableScaledPreview) {
          backButton = RotatedBox(
            quarterTurns: cameraQuarterTurns,
            child: backButton,
          );
          flashModeSwitch = RotatedBox(
            quarterTurns: cameraQuarterTurns,
            child: flashModeSwitch,
          );
        }
        final isPortrait = v.deviceOrientation.toString().contains('portrait');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Flex(
            direction: isPortrait ? Axis.horizontal : Axis.vertical,
            children: <Widget>[
              if (!v.isRecordingVideo) backButton,
              const Spacer(),
              flashModeSwitch,
            ],
          ),
        );
      },
    );
  }

  /// The button to switch between cameras.
  /// 切换相机的按钮
  Widget buildCameraSwitch(BuildContext context) {
    return MergeSemantics(
      child: IconButton(
        tooltip: textDelegate.sSwitchCameraLensDirectionLabel(
          nextCameraDescription.lensDirection,
        ),
        onPressed: () => switchCameras(),
        icon: Icon(
          Platform.isIOS
              ? Icons.flip_camera_ios_outlined
              : Icons.flip_camera_android_outlined,
          size: 24,
        ),
      ),
    );
  }

  /// The button to switch flash modes.
  /// 切换闪光灯模式的按钮
  Widget buildFlashModeSwitch(BuildContext context, CameraValue value) {
    final IconData icon;
    switch (value.flashMode) {
      case FlashMode.off:
        icon = Icons.flash_off;
        break;
      case FlashMode.auto:
        icon = Icons.flash_auto;
        break;
      case FlashMode.always:
        icon = Icons.flash_on;
        break;
      case FlashMode.torch:
        icon = Icons.flashlight_on;
        break;
    }
    return IconButton(
      onPressed: () => switchFlashesMode(value),
      tooltip: textDelegate.sFlashModeLabel(value.flashMode),
      icon: Icon(icon, size: 24),
    );
  }

  /// Text widget for shooting tips.
  /// 拍摄的提示文字
  Widget buildCaptureTips(CameraController? controller) {
    final String tips;
    if (pickerConfig.enableRecording) {
      if (pickerConfig.onlyEnableRecording) {
        if (pickerConfig.enableTapRecording) {
          tips = textDelegate.shootingTapRecordingTips;
        } else {
          tips = textDelegate.shootingOnlyRecordingTips;
        }
      } else {
        tips = textDelegate.shootingWithRecordingTips;
      }
    } else {
      tips = textDelegate.shootingTips;
    }
    return AnimatedOpacity(
      duration: recordDetectDuration,
      opacity: controller?.value.isRecordingVideo ?? false ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          tips,
          style: const TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Capture action's widget.
  /// 拍照操作区
  ///
  /// This displayed at the top of the screen.
  /// 该区域显示在屏幕下方。
  Widget buildCaptureActions({
    required BuildContext context,
    required BoxConstraints constraints,
    CameraController? controller,
  }) {
    final orientation = controller?.value.deviceOrientation ??
        MediaQuery.of(context).orientation;
    final isPortrait = orientation.toString().contains('portrait');
    return SizedBox(
      width: isPortrait ? null : 118,
      height: isPortrait ? 118 : null,
      child: Flex(
        direction: isPortrait ? Axis.horizontal : Axis.vertical,
        verticalDirection: orientation == DeviceOrientation.landscapeLeft
            ? VerticalDirection.up
            : VerticalDirection.down,
        children: <Widget>[
          const Spacer(),
          Expanded(
            child: Center(
              child: buildCaptureButton(context, constraints),
            ),
          ),
          if (innerController != null && cameras.length > 1)
            Expanded(
              child: RotatedBox(
                quarterTurns: !enableScaledPreview ? cameraQuarterTurns : 0,
                child: buildCameraSwitch(context),
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  /// The back button.
  /// 返回键
  Widget buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: const Icon(Icons.clear),
    );
  }

  /// The shooting button.
  /// 拍照按钮
  Widget buildCaptureButton(BuildContext context, BoxConstraints constraints) {
    const Size outerSize = Size.square(115);
    const Size innerSize = Size.square(82);
    return MergeSemantics(
      child: Semantics(
        label: textDelegate.sActionShootingButtonTooltip,
        onTap: onTap,
        onTapHint: onTapHint,
        onLongPress: onLongPress,
        onLongPressHint: onLongPressHint,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerUp: onPointerUp,
          onPointerMove: onPointerMove(constraints),
          child: GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: SizedBox.fromSize(
              size: outerSize,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  AnimatedContainer(
                    duration: kThemeChangeDuration,
                    width: isShootingButtonAnimate
                        ? outerSize.width
                        : innerSize.width,
                    height: isShootingButtonAnimate
                        ? outerSize.height
                        : innerSize.height,
                    padding: EdgeInsets.all(isShootingButtonAnimate ? 41 : 11),
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor.withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  if (shouldCaptureButtonDisplay)
                    RotatedBox(
                      quarterTurns:
                          !enableScaledPreview ? cameraQuarterTurns : 0,
                      child: CameraProgressButton(
                        isAnimating: isShootingButtonAnimate,
                        isBusy: isControllerBusy,
                        duration: pickerConfig.maximumRecordingDuration!,
                        size: outerSize,
                        ringsColor: theme.indicatorColor,
                        ringsWidth: 3,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildExposureSlider({
    required ExposureMode mode,
    required double size,
    required double height,
    required double gap,
  }) {
    final bool isLocked = mode == ExposureMode.locked;
    final Color? color = isLocked ? _lockedColor : theme.iconTheme.color;
    final Widget lineWidget = ValueListenableBuilder<bool>(
      valueListenable: isFocusPointDisplays,
      builder: (_, bool value, Widget? child) => AnimatedOpacity(
        duration: _kDuration,
        opacity: value ? 1 : 0,
        child: child,
      ),
      child: Center(child: Container(width: 1.5, color: color)),
    );

    return ValueListenableBuilder<double>(
      valueListenable: currentExposureSliderOffset,
      builder: (_, double exposure, __) {
        final double topByCurrentExposure =
            (minAvailableExposureOffset.abs() - exposure) *
                (height - size * 3) /
                (maxAvailableExposureOffset - minAvailableExposureOffset);
        final double lineTop = size + topByCurrentExposure;
        final double lineBottom = height - lineTop - size;
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(top: lineTop + gap, child: lineWidget),
            Positioned.fill(bottom: lineBottom + gap, child: lineWidget),
            Positioned(
              top: topByCurrentExposure - gap,
              child: Transform.rotate(
                angle: exposure,
                child: Icon(Icons.wb_sunny_outlined, size: size, color: color),
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
                      min: minAvailableExposureOffset,
                      max: maxAvailableExposureOffset,
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
  Widget buildFocusingPoint({
    required CameraValue cameraValue,
    required BoxConstraints constraints,
    int quarterTurns = 0,
  }) {
    Widget buildControls(double size, double height) {
      const double verticalGap = 3;
      final ExposureMode exposureMode = cameraValue.exposureMode;
      final bool isLocked = exposureMode == ExposureMode.locked;
      return Column(
        children: <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: isFocusPointDisplays,
            builder: (_, bool value, Widget? child) => AnimatedOpacity(
              duration: _kDuration,
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
          const SizedBox(height: verticalGap),
          Expanded(
            child: buildExposureSlider(
              mode: exposureMode,
              size: size,
              height: height,
              gap: verticalGap,
            ),
          ),
          const SizedBox(height: verticalGap),
          SizedBox.fromSize(size: Size.square(size)),
        ],
      );
    }

    Widget buildFromPoint(Offset point) {
      const double controllerWidth = 20;
      final double pointWidth =
          math.min(constraints.maxWidth, constraints.maxHeight) / 5;
      final double lineHeight = pointWidth * 2.5;
      final double exposureControlWidth =
          pickerConfig.enableExposureControlOnPoint ? controllerWidth : 0;
      final double width = pointWidth + exposureControlWidth + 2;
      final bool shouldReverseLayout = cameraQuarterTurns.isEven &&
          enableScaledPreview &&
          point.dx > constraints.maxWidth / 4 * 3;
      final double effectiveLeft, effectiveTop, effectiveWidth, effectiveHeight;
      if (cameraQuarterTurns.isOdd && !enableScaledPreview) {
        effectiveLeft = math.min(
          constraints.maxWidth - lineHeight,
          math.max(0, point.dx - lineHeight / 2),
        );
        effectiveTop = math.min(
          constraints.maxHeight - width,
          math.max(0, point.dy - width / 2),
        );
        effectiveWidth = lineHeight;
        effectiveHeight = width;
      } else {
        effectiveLeft = math.min(
          constraints.maxWidth - width,
          math.max(0, point.dx - width / 2),
        );
        effectiveTop = math.min(
          constraints.maxHeight - lineHeight,
          math.max(0, point.dy - lineHeight / 2),
        );
        effectiveWidth = width;
        effectiveHeight = lineHeight;
      }
      return Positioned(
        left: effectiveLeft,
        top: effectiveTop,
        width: effectiveWidth,
        height: effectiveHeight,
        child: ExcludeSemantics(
          child: ValueListenableBuilder<bool>(
            valueListenable: isFocusPointFadeOut,
            builder: (BuildContext context, bool isFadeOut, Widget? child) {
              Widget body = AnimatedOpacity(
                curve: Curves.ease,
                duration: _kDuration,
                opacity: isFadeOut ? .5 : 1,
                child: Row(
                  textDirection: shouldReverseLayout
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  children: <Widget>[
                    child!,
                    if (pickerConfig.enableExposureControlOnPoint)
                      const SizedBox(width: 2),
                    if (pickerConfig.enableExposureControlOnPoint)
                      SizedBox.fromSize(
                        size: Size(exposureControlWidth, lineHeight),
                        child: buildControls(controllerWidth, lineHeight),
                      ),
                  ],
                ),
              );
              if (quarterTurns != 0) {
                body = RotatedBox(quarterTurns: quarterTurns, child: body);
              }
              return body;
            },
            child: CameraFocusPoint(
              key: ValueKey<Offset>(point),
              size: pointWidth,
              color: cameraValue.exposureMode == ExposureMode.locked
                  ? _lockedColor
                  : theme.iconTheme.color!,
            ),
          ),
        ),
      );
    }

    return ValueListenableBuilder<Offset?>(
      valueListenable: lastExposurePoint,
      builder: (_, Offset? point, __) {
        if (point == null) {
          return const SizedBox.shrink();
        }
        return buildFromPoint(point);
      },
    );
  }

  /// The [GestureDetector] widget for setting exposure point manually.
  /// 用于手动设置曝光点的 [GestureDetector]
  Widget buildExposureDetector(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    return Semantics(
      label: textDelegate.sCameraPreviewLabel(
        innerController?.description.lensDirection,
      ),
      image: true,
      onTap: () {
        // Focus on the center point when using semantics tap.
        final Size size = MediaQuery.of(context).size;
        final TapUpDetails details = TapUpDetails(
          kind: PointerDeviceKind.touch,
          globalPosition: Offset(size.width / 2, size.height / 2),
        );
        requestFocusAndExposureOnPosition(details.localPosition, constraints);
      },
      onTapHint: textDelegate.sActionManuallyFocusHint,
      sortKey: const OrdinalSortKey(1),
      hidden: innerController == null,
      excludeSemantics: true,
      child: GestureDetector(
        onTapUp: (TapUpDetails d) {
          requestFocusAndExposureOnPosition(
            d.localPosition,
            constraints,
          );
        },
        onLongPressStart: (LongPressStartDetails d) {
          requestFocusAndExposureOnPosition(
            d.localPosition,
            constraints,
            lock: true,
          );
        },
        behavior: HitTestBehavior.translucent,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget buildCameraPreview({
    required BuildContext context,
    required CameraValue cameraValue,
    required BoxConstraints constraints,
  }) {
    Widget preview = const SizedBox.shrink();
    if (innerController != null) {
      preview = CameraPreview(controller);
      preview = ValueListenableBuilder<CameraValue>(
        valueListenable: controller,
        builder: (_, CameraValue value, Widget? child) {
          final lockedOrientation = value.lockedCaptureOrientation;
          int? quarterTurns = lockedOrientation?.index;
          if (quarterTurns == null) {
            return child!;
          }
          if (value.deviceOrientation == DeviceOrientation.landscapeLeft) {
            quarterTurns--;
          } else if (value.deviceOrientation ==
              DeviceOrientation.landscapeRight) {
            quarterTurns++;
          }
          return RotatedBox(quarterTurns: quarterTurns, child: child);
        },
        child: preview,
      );
    }
    preview = Listener(
      onPointerDown: (_) => pointers++,
      onPointerUp: (_) => pointers--,
      child: GestureDetector(
        onScaleStart: pickerConfig.enablePinchToZoom ? handleScaleStart : null,
        onScaleUpdate:
            pickerConfig.enablePinchToZoom ? handleScaleUpdate : null,
        // Enabled cameras switching by default if we have multiple cameras.
        onDoubleTap: cameras.length > 1 ? switchCameras : null,
        child: preview,
      ),
    );

    // Make a transformed widget if it's defined.
    final Widget? transformedWidget =
        pickerConfig.previewTransformBuilder?.call(
      context,
      controller,
      preview,
    );
    if (!enableScaledPreview) {
      preview = Stack(
        children: <Widget>[
          preview,
          Positioned.fill(
            child: ExcludeSemantics(
              child: RotatedBox(
                quarterTurns: cameraQuarterTurns,
                child: Align(
                  alignment: {
                    DeviceOrientation.portraitUp: Alignment.bottomCenter,
                    DeviceOrientation.portraitDown: Alignment.topCenter,
                    DeviceOrientation.landscapeLeft: Alignment.centerRight,
                    DeviceOrientation.landscapeRight: Alignment.centerLeft,
                  }[cameraValue.deviceOrientation]!,
                  child: buildCaptureTips(innerController),
                ),
              ),
            ),
          ),
          if (pickerConfig.enableSetExposure)
            buildExposureDetector(context, constraints),
          buildFocusingPoint(
            cameraValue: cameraValue,
            constraints: constraints,
            quarterTurns: cameraQuarterTurns,
          ),
          if (pickerConfig.foregroundBuilder != null)
            Positioned.fill(
              child: pickerConfig.foregroundBuilder!(
                context,
                innerController,
              ),
            ),
        ],
      );
    }
    // Scale the preview if the config is enabled.
    if (enableScaledPreview) {
      preview = Transform.scale(
        scale: effectiveCameraScale(constraints, innerController),
        child: Center(child: transformedWidget ?? preview),
      );
      // Rotated the preview if the turns is valid.
      if (isCameraRotated) {
        preview = RotatedBox(
          quarterTurns: -cameraQuarterTurns,
          child: preview,
        );
      }
    }
    return RepaintBoundary(child: preview);
  }

  Widget buildInitializeWrapper({
    required Widget Function(CameraValue, Widget?) builder,
    bool Function()? isInitialized,
    Widget? child,
  }) {
    if (innerController == null) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<CameraValue>(
      valueListenable: controller,
      builder: (_, CameraValue value, Widget? w) {
        if (isInitialized?.call() ?? value.isInitialized) {
          return builder(value, w);
        }
        return const SizedBox.shrink();
      },
      child: child,
    );
  }

  Widget buildForegroundBody(
    BuildContext context,
    BoxConstraints constraints,
    DeviceOrientation? deviceOrientation,
  ) {
    final orientation = deviceOrientation ?? MediaQuery.of(context).orientation;
    final isPortrait = orientation.toString().contains('portrait');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Flex(
          direction: isPortrait ? Axis.vertical : Axis.horizontal,
          textDirection: orientation == DeviceOrientation.landscapeRight
              ? TextDirection.rtl
              : TextDirection.ltr,
          verticalDirection: orientation == DeviceOrientation.portraitDown
              ? VerticalDirection.up
              : VerticalDirection.down,
          children: <Widget>[
            Semantics(
              sortKey: const OrdinalSortKey(0),
              hidden: innerController == null,
              child: buildSettingActions(context),
            ),
            const Spacer(),
            if (enableScaledPreview)
              ExcludeSemantics(child: buildCaptureTips(innerController)),
            Semantics(
              sortKey: const OrdinalSortKey(2),
              hidden: innerController == null,
              child: buildCaptureActions(
                context: context,
                constraints: constraints,
                controller: innerController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Widget previewWidget = ExcludeSemantics(
          child: buildInitializeWrapper(
            builder: (CameraValue v, Widget? w) {
              if (enableScaledPreview) {
                return buildCameraPreview(
                  context: context,
                  cameraValue: v,
                  constraints: constraints,
                );
              }
              return Align(
                alignment: {
                  DeviceOrientation.portraitUp: Alignment.topCenter,
                  DeviceOrientation.portraitDown: Alignment.bottomCenter,
                  DeviceOrientation.landscapeLeft: Alignment.centerLeft,
                  DeviceOrientation.landscapeRight: Alignment.centerRight,
                }[v.deviceOrientation]!,
                child: AspectRatio(
                  aspectRatio:
                      v.deviceOrientation.toString().contains('portrait')
                          ? 1 / v.aspectRatio
                          : v.aspectRatio,
                  child: LayoutBuilder(
                    builder: (BuildContext c, BoxConstraints constraints) {
                      return buildCameraPreview(
                        context: c,
                        cameraValue: v,
                        constraints: constraints,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
        if (!enableScaledPreview) {
          previewWidget = Semantics(
            label: textDelegate.sCameraPreviewLabel(
              innerController?.description.lensDirection,
            ),
            image: true,
            onTap: () {
              // Focus on the center point when using semantics tap.
              final Size size = MediaQuery.of(context).size;
              final TapUpDetails details = TapUpDetails(
                kind: PointerDeviceKind.touch,
                globalPosition: Offset(size.width / 2, size.height / 2),
              );
              requestFocusAndExposureOnPosition(
                details.localPosition,
                constraints,
              );
            },
            onTapHint: textDelegate.sActionManuallyFocusHint,
            sortKey: const OrdinalSortKey(1),
            hidden: innerController == null,
            excludeSemantics: true,
            child: previewWidget,
          );
        }
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: <Widget>[
            previewWidget,
            if (enableScaledPreview) ...<Widget>[
              if (pickerConfig.enableSetExposure)
                buildExposureDetector(context, constraints),
              buildInitializeWrapper(
                builder: (CameraValue v, _) => buildFocusingPoint(
                  cameraValue: v,
                  constraints: constraints,
                ),
              ),
              if (pickerConfig.foregroundBuilder != null)
                Positioned.fill(
                  child:
                      pickerConfig.foregroundBuilder!(context, innerController),
                ),
            ],
            if (innerController == null)
              buildForegroundBody(context, constraints, null)
            else
              buildInitializeWrapper(
                builder: (CameraValue v, _) => buildForegroundBody(
                  context,
                  constraints,
                  v.deviceOrientation,
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Builder(builder: buildBody);
    if (isCameraRotated && enableScaledPreview) {
      final MediaQueryData mq = MediaQuery.of(context);
      body = RotatedBox(
        quarterTurns: pickerConfig.cameraQuarterTurns,
        child: MediaQuery(
          data: mq.copyWith(
            size: pickerConfig.cameraQuarterTurns.isOdd
                ? mq.size.flipped
                : mq.size,
          ),
          child: body,
        ),
      );
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: theme,
        child: Material(
          color: Colors.black,
          child: body,
        ),
      ),
    );
  }
}
