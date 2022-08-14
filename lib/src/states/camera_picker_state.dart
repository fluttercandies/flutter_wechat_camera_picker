// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../constants/config.dart';
import '../constants/constants.dart';
import '../constants/enums.dart';
import '../constants/styles.dart';
import '../delegates/camera_picker_text_delegate.dart';
import '../internals/extensions.dart';
import '../internals/methods.dart';
import '../widgets/camera_focus_point.dart';
import '../widgets/camera_picker.dart';
import '../widgets/camera_picker_viewer.dart';
import '../widgets/camera_progress_button.dart';

const Color _lockedColor = Colors.amber;
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

  /// The controller for the current camera.
  /// 当前相机实例的控制器
  CameraController get controller => innerController!;
  CameraController? innerController;

  /// Available cameras.
  /// 可用的相机实例
  late final List<CameraDescription> cameras;

  /// Current exposure offset.
  /// 当前曝光值
  final ValueNotifier<double> currentExposureOffset = ValueNotifier<double>(0);

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

  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////// Global Getters //////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  CameraPickerConfig get pickerConfig => widget.pickerConfig;

  bool get enableRecording => pickerConfig.enableRecording;

  bool get onlyEnableRecording =>
      enableRecording && pickerConfig.onlyEnableRecording;

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

  /// A getter to the current [CameraDescription].
  /// 获取当前相机实例
  CameraDescription get currentCamera => cameras.elementAt(currentCameraIndex);

  /// If there's no theme provided from the user, use [CameraPicker.themeData] .
  /// 如果用户未提供主题，通过 [CameraPicker.themeData] 创建。
  late final ThemeData theme =
      pickerConfig.theme ?? CameraPicker.themeData(wechatThemeColor);

  CameraPickerTextDelegate get textDelegate => Constants.textDelegate;

  @override
  void initState() {
    super.initState();
    ambiguate(WidgetsBinding.instance)?.addObserver(this);
    Constants.textDelegate = widget.pickerConfig.textDelegate ??
        cameraPickerTextDelegateFromLocale(widget.locale);

    // TODO(Alex): Currently hide status bar will cause the viewport shaking on Android.
    /// Hide system status bar automatically when the platform is not Android.
    /// 在非 Android 设备上自动隐藏状态栏
    if (!Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
    }

    initCameras();
  }

  @override
  void dispose() {
    if (!Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
    ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    innerController?.dispose();
    currentExposureOffset.dispose();
    lastExposurePoint.dispose();
    isFocusPointDisplays.dispose();
    exposurePointDisplayTimer?.cancel();
    exposureModeDisplayTimer?.cancel();
    recordDetectTimer?.cancel();
    recordCountdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? c = innerController;
    // App state changed before we got the chance to initialize.
    if (c == null || !c.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCameras(currentCamera);
    }
  }

  /// Adjust the proper scale type according to the [constraints].
  /// 根据 [constraints] 获取相机预览适用的缩放。
  double effectiveCameraScale(
    BoxConstraints constraints,
    CameraController controller,
  ) {
    final int turns = pickerConfig.cameraQuarterTurns;
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
      exposureModeDisplayTimer?.cancel();
      exposurePointDisplayTimer?.cancel();
      lastExposurePoint.value = null;
      if (currentExposureOffset.value != 0) {
        currentExposureOffset.value = 0;
      }
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
          pickerConfig.onError,
        );
      }

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
      final CameraController newController = CameraController(
        cameraDescription ?? cameras[index],
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
            if (pickerConfig.lockCaptureOrientation != null)
              newController
                  .lockCaptureOrientation(pickerConfig.lockCaptureOrientation),
            newController
                .getExposureOffsetStepSize()
                .then((double value) => exposureStep = value),
            newController
                .getMaxExposureOffset()
                .then((double value) => maxAvailableExposureOffset = value),
            newController
                .getMinExposureOffset()
                .then((double value) => minAvailableExposureOffset = value),
            newController
                .getMaxZoomLevel()
                .then((double value) => maxAvailableZoom = value),
            newController
                .getMinZoomLevel()
                .then((double value) => minAvailableZoom = value),
          ],
          eagerError: true,
        );
        stopwatch.stop();
        realDebugPrint("${stopwatch.elapsed} for config's update.");
        innerController = newController;
      } catch (e, s) {
        handleErrorWithHandler(e, pickerConfig.onError, s: s);
      } finally {
        safeSetState(() {});
      }
    });
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
  Future<void> switchFlashesMode() async {
    final FlashMode newFlashMode;
    switch (controller.value.flashMode) {
      case FlashMode.off:
        newFlashMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newFlashMode = FlashMode.always;
        break;
      case FlashMode.always:
      case FlashMode.torch:
        newFlashMode = FlashMode.off;
        break;
    }
    try {
      await controller.setFlashMode(newFlashMode);
    } catch (e, s) {
      handleErrorWithHandler(e, pickerConfig.onError, s: s);
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
      handleErrorWithHandler(e, pickerConfig.onError, s: s);
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

  void restartDisplayModeDisplayTimer() {
    exposureModeDisplayTimer?.cancel();
    exposureModeDisplayTimer = Timer(const Duration(seconds: 2), () {
      isFocusPointDisplays.value = false;
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
      handleErrorWithHandler(e, pickerConfig.onError, s: s);
    }
    restartDisplayModeDisplayTimer();
  }

  /// Use the [position] to set exposure and focus.
  /// 通过点击点的 [position] 设置曝光和对焦。
  Future<void> setExposureAndFocusPoint(
    Offset position,
    BoxConstraints constraints,
  ) async {
    isFocusPointDisplays.value = false;
    // Ignore point update when the new point is less than 8% and higher than
    // 92% of the screen's height.
    if (position.dy < constraints.maxHeight / 12 ||
        position.dy > constraints.maxHeight / 12 * 11) {
      return;
    }
    realDebugPrint(
      'Setting new exposure point (x: ${position.dx}, y: ${position.dy})',
    );
    lastExposurePoint.value = position;
    restartExposurePointDisplayTimer();
    currentExposureOffset.value = 0;
    try {
      if (controller.value.exposureMode == ExposureMode.locked) {
        await controller.setExposureMode(ExposureMode.auto);
      }
      final Offset newPoint = lastExposurePoint.value!.scale(
        1 / constraints.maxWidth,
        1 / constraints.maxHeight,
      );
      if (controller.value.exposurePointSupported) {
        controller.setExposurePoint(newPoint);
      }
      if (controller.value.focusPointSupported) {
        controller.setFocusPoint(newPoint);
      }
    } catch (e, s) {
      handleErrorWithHandler(e, pickerConfig.onError, s: s);
    }
  }

  /// Update the exposure offset using the exposure controller.
  /// 使用曝光控制器更新曝光值
  Future<void> updateExposureOffset(double value) async {
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
    currentExposureOffset.value = value;
    try {
      // Use [CameraPlatform] explicitly to reduce channel calls.
      await CameraPlatform.instance.setExposureOffset(
        controller.cameraId,
        value,
      );
    } catch (e, s) {
      handleErrorWithHandler(e, pickerConfig.onError, s: s);
    }
    if (!isFocusPointDisplays.value) {
      isFocusPointDisplays.value = true;
    }
    restartDisplayModeDisplayTimer();
    restartExposurePointDisplayTimer();
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
        pickerConfig.onError,
      );
    }
    if (controller.value.isTakingPicture) {
      return;
    }
    try {
      final XFile file = await controller.takePicture();
      // Delay disposing the controller to hold the preview.
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        innerController?.dispose();
        safeSetState(() {
          innerController = null;
        });
      });
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
      initCameras(currentCamera);
      safeSetState(() {});
    } catch (e) {
      realDebugPrint('Error when preview the captured file: $e');
      handleErrorWithHandler(e, pickerConfig.onError);
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
    if (isShootingButtonAnimate) {
      safeSetState(() {
        isShootingButtonAnimate = false;
      });
    }
    if (controller.value.isRecordingVideo) {
      lastShootingButtonPressedPosition = null;
      safeSetState(() {});
      stopRecordingVideo();
    }
  }

  /// Set record file path and start recording.
  /// 设置拍摄文件路径并开始录制视频
  Future<void> startRecordingVideo() async {
    if (controller.value.isRecordingVideo) {
      return;
    }
    try {
      await controller.startVideoRecording();
      if (isRecordingRestricted) {
        recordCountdownTimer =
            Timer(pickerConfig.maximumRecordingDuration!, () {
          stopRecordingVideo();
        });
      }
    } catch (e, s) {
      realDebugPrint('Error when start recording video: $e');
      if (!controller.value.isRecordingVideo) {
        handleErrorWithHandler(e, pickerConfig.onError, s: s);
        return;
      }
      try {
        await controller.stopVideoRecording();
      } catch (e, s) {
        realDebugPrint(
          'Error when stop recording video after an error start: $e',
        );
        recordCountdownTimer?.cancel();
        isShootingButtonAnimate = false;
        handleErrorWithHandler(e, pickerConfig.onError, s: s);
      }
    } finally {
      safeSetState(() {});
    }
  }

  /// Stop the recording process.
  /// 停止录制视频
  Future<void> stopRecordingVideo() async {
    void handleError() {
      recordCountdownTimer?.cancel();
      isShootingButtonAnimate = false;
      safeSetState(() {});
    }

    if (!controller.value.isRecordingVideo) {
      handleError();
      return;
    }
    try {
      final XFile file = await controller.stopVideoRecording();
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
      }
    } catch (e, s) {
      realDebugPrint('Error when stop recording video: $e');
      realDebugPrint('Try to initialize a new CameraController...');
      initCameras();
      handleError();
      handleErrorWithHandler(e, pickerConfig.onError, s: s);
    } finally {
      isShootingButtonAnimate = false;
      safeSetState(() {});
    }
  }

  Future<AssetEntity?> pushToViewer({
    required XFile file,
    required CameraPickerViewType viewType,
  }) {
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
    if (enableRecording && !enableTapRecording) {
      return recordDetectionCancel;
    }
    return null;
  }

  PointerMoveEventListener? onPointerMove(BoxConstraints c) {
    if (enablePullToZoomInRecord) {
      return (PointerMoveEvent e) => onShootingButtonMove(e, c);
    }
    return null;
  }

  GestureTapCallback? get onTap {
    if (enableTapRecording) {
      if (innerController?.value.isRecordingVideo ?? false) {
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
    if (enableRecording && !enableTapRecording) {
      return recordDetection;
    }
    return null;
  }

  String? get onLongPressHint {
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: <Widget>[
              if (cameras.length > 1) buildCameraSwitch(context),
              const Spacer(),
              buildFlashModeSwitch(context, v),
            ],
          ),
        );
      },
    );
  }

  /// The button to switch between cameras.
  /// 切换相机的按钮
  Widget buildCameraSwitch(BuildContext context) {
    return IconButton(
      tooltip: textDelegate.sSwitchCameraLensDirectionLabel(
        nextCameraDescription.lensDirection,
      ),
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
  Widget buildFlashModeSwitch(BuildContext context, CameraValue value) {
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
        child: Text(tips, style: const TextStyle(fontSize: 15)),
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
    return SizedBox(
      height: 118,
      child: Row(
        children: <Widget>[
          if (controller?.value.isRecordingVideo != true)
            Expanded(child: buildBackButton(context, constraints))
          else
            const Spacer(),
          Expanded(
            child: Center(
              child: MergeSemantics(child: buildCaptureButton(constraints)),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  /// The back button near to the [buildCaptureButton].
  /// 靠近拍照键的返回键
  Widget buildBackButton(BuildContext context, BoxConstraints constraints) {
    return IconButton(
      onPressed: Navigator.of(context).pop,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: Container(
        alignment: Alignment.center,
        width: 27,
        height: 27,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
      ),
    );
  }

  /// The shooting button.
  /// 拍照按钮
  Widget buildCaptureButton(BoxConstraints constraints) {
    const Size outerSize = Size.square(115);
    const Size innerSize = Size.square(82);
    return Semantics(
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
                if ((innerController?.value.isRecordingVideo ?? false) &&
                    isRecordingRestricted)
                  CameraProgressButton(
                    duration: pickerConfig.maximumRecordingDuration!,
                    outerRadius: outerSize.width,
                    ringsColor: theme.indicatorColor,
                    ringsWidth: 2,
                  ),
              ],
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
      child: Center(child: Container(width: 1, color: color)),
    );

    return ValueListenableBuilder<double>(
      valueListenable: currentExposureOffset,
      builder: (_, double exposure, __) {
        final double effectiveTop = (size + gap) +
            (minAvailableExposureOffset.abs() - exposure) *
                (height - size * 3) /
                (maxAvailableExposureOffset - minAvailableExposureOffset);
        final double effectiveBottom = height - effectiveTop - size;
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(top: effectiveTop + gap, child: lineWidget),
            Positioned.fill(bottom: effectiveBottom + gap, child: lineWidget),
            Positioned(
              top: (minAvailableExposureOffset.abs() - exposure) *
                  (height - size * 3) /
                  (maxAvailableExposureOffset - minAvailableExposureOffset),
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
      final double pointWidth = constraints.maxWidth / 5;
      final double exposureControlWidth =
          pickerConfig.enableExposureControlOnPoint ? controllerWidth : 0;
      final double width = pointWidth + exposureControlWidth + 2;
      final bool shouldReverseLayout = point.dx > constraints.maxWidth / 4 * 3;
      final double effectiveLeft = math.min(
        constraints.maxWidth - width,
        math.max(0, point.dx - width / 2),
      );
      final double effectiveTop = math.min(
        constraints.maxHeight - pointWidth * 3,
        math.max(0, point.dy - pointWidth * 3 / 2),
      );
      return Positioned(
        left: effectiveLeft,
        top: effectiveTop,
        width: width,
        height: pointWidth * 3,
        child: ExcludeSemantics(
          child: Row(
            textDirection:
                shouldReverseLayout ? TextDirection.rtl : TextDirection.ltr,
            children: <Widget>[
              CameraFocusPoint(
                key: ValueKey<int>(DateTime.now().millisecondsSinceEpoch),
                size: pointWidth,
                color: theme.iconTheme.color!,
              ),
              if (pickerConfig.enableExposureControlOnPoint)
                const SizedBox(width: 2),
              if (pickerConfig.enableExposureControlOnPoint)
                SizedBox.fromSize(
                  size: Size(exposureControlWidth, pointWidth * 3),
                  child: buildControls(controllerWidth, pointWidth * 3),
                ),
            ],
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
    void focus(TapUpDetails d) {
      // Only call exposure point updates when the controller is initialized.
      if (innerController?.value.isInitialized ?? false) {
        Feedback.forTap(context);
        setExposureAndFocusPoint(d.globalPosition, constraints);
      }
    }

    return Positioned.fill(
      child: Semantics(
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
          focus(details);
        },
        onTapHint: textDelegate.sActionManuallyFocusHint,
        sortKey: const OrdinalSortKey(1),
        hidden: innerController == null,
        excludeSemantics: true,
        child: GestureDetector(
          onTapUp: focus,
          behavior: HitTestBehavior.translucent,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Widget buildCameraPreview({
    required BuildContext context,
    required DeviceOrientation orientation,
    required BoxConstraints constraints,
  }) {
    Widget preview = Listener(
      onPointerDown: (_) => pointers++,
      onPointerUp: (_) => pointers--,
      child: GestureDetector(
        onScaleStart: pickerConfig.enablePinchToZoom ? handleScaleStart : null,
        onScaleUpdate:
            pickerConfig.enablePinchToZoom ? handleScaleUpdate : null,
        // Enabled cameras switching by default if we have multiple cameras.
        onDoubleTap: cameras.length > 1 ? switchCameras : null,
        child: innerController != null
            ? CameraPreview(controller)
            : const SizedBox.shrink(),
      ),
    );

    // Make a transformed widget if it's defined.
    final Widget? transformedWidget =
        pickerConfig.previewTransformBuilder?.call(
      context,
      controller,
      preview,
    );
    preview = Center(child: transformedWidget ?? preview);
    // Scale the preview if the config is enabled.
    if (pickerConfig.enableScaledPreview) {
      preview = Transform.scale(
        scale: effectiveCameraScale(constraints, controller),
        child: preview,
      );
    }
    // Rotated the preview if the turns is valid.
    if (pickerConfig.cameraQuarterTurns % 4 != 0) {
      preview = RotatedBox(
        quarterTurns: -pickerConfig.cameraQuarterTurns,
        child: preview,
      );
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

  Widget buildForegroundBody(BuildContext context, BoxConstraints constraints) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: <Widget>[
            Semantics(
              sortKey: const OrdinalSortKey(0),
              hidden: innerController == null,
              child: buildSettingActions(context),
            ),
            const Spacer(),
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
      builder: (BuildContext context, BoxConstraints constraints) => Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: <Widget>[
          ExcludeSemantics(
            child: buildInitializeWrapper(
              builder: (CameraValue v, Widget? w) => buildCameraPreview(
                context: context,
                orientation: v.deviceOrientation,
                constraints: constraints,
              ),
            ),
          ),
          if (pickerConfig.enableSetExposure)
            buildExposureDetector(context, constraints),
          buildInitializeWrapper(
            builder: (CameraValue v, _) => buildFocusingPoint(
              cameraValue: v,
              constraints: constraints,
            ),
          ),
          buildForegroundBody(context, constraints),
          if (pickerConfig.foregroundBuilder != null)
            Positioned.fill(
              child: pickerConfig.foregroundBuilder!(context, innerController),
            ),
        ],
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
            quarterTurns: pickerConfig.cameraQuarterTurns,
            child: buildBody(context),
          ),
        ),
      ),
    );
  }
}
