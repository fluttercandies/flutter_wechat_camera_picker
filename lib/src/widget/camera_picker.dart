///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/13 11:08
///
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/constants.dart';
import '../widget/circular_progress_bar.dart';

import 'builder/slide_page_transition_builder.dart';
import 'camera_picker_viewer.dart';

/// Create a camera picker integrate with [CameraDescription].
/// 通过 [CameraDescription] 整合的拍照选择
///
/// The picker provides create an [AssetEntity] through the camera.
/// However, this might failed (high probability) if there're any steps
/// went wrong during the process.
///
/// 该选择器可以通过拍照创建 [AssetEntity] ，但由于过程中有的步骤随时会出现问题，
/// 使用时有较高的概率会遇到失败。
class CameraPicker extends StatefulWidget {
  CameraPicker({
    Key key,
    this.isAllowRecording = false,
    this.isOnlyAllowRecording = false,
    this.enableAudio = true,
    this.maximumRecordingDuration = const Duration(seconds: 15),
    this.theme,
    this.resolutionPreset = ResolutionPreset.max,
    this.cameraQuarterTurns = 0,
    CameraPickerTextDelegate textDelegate,
  })  : assert(
          isAllowRecording == true || isOnlyAllowRecording != true,
          'Recording mode error.',
        ),
        assert(
          resolutionPreset != null,
          'Resolution preset must not be null.',
        ),
        super(key: key) {
    Constants.textDelegate = textDelegate ??
        (isAllowRecording
            ? DefaultCameraPickerTextDelegateWithRecording()
            : DefaultCameraPickerTextDelegate());
  }

  /// The number of clockwise quarter turns the camera view should be rotated.
  /// 摄像机视图顺时针旋转次数，每次90度
  final int cameraQuarterTurns;

  /// Whether the picker can record video.
  /// 选择器是否可以录像
  final bool isAllowRecording;

  /// Whether the picker can record video.
  /// 选择器是否可以录像
  final bool isOnlyAllowRecording;

  /// Whether the picker should record audio.
  /// 选择器录像时是否需要录制声音
  final bool enableAudio;

  /// The maximum duration of the video recording process.
  /// 录制视频最长时长
  ///
  /// This is 15 seconds by default.
  /// Also allow `null` for unrestricted video recording.
  final Duration maximumRecordingDuration;

  /// Theme data for the picker.
  /// 选择器的主题
  final ThemeData theme;

  /// Present resolution for the camera.
  /// 相机的分辨率预设
  final ResolutionPreset resolutionPreset;

  /// Static method to create [AssetEntity] through camera.
  /// 通过相机创建 [AssetEntity] 的静态方法
  static Future<AssetEntity> pickFromCamera(
    BuildContext context, {
    bool isAllowRecording = false,
    bool isOnlyAllowRecording = false,
    bool enableAudio = true,
    Duration maximumRecordingDuration = const Duration(seconds: 15),
    ThemeData theme,
    int cameraQuarterTurns = 0,
    CameraPickerTextDelegate textDelegate,
    ResolutionPreset resolutionPreset = ResolutionPreset.max,
  }) async {
    if (isAllowRecording != true && isOnlyAllowRecording == true) {
      throw ArgumentError('Recording mode error.');
    }
    if (resolutionPreset == null) {
      throw ArgumentError('Resolution preset must not be null.');
    }
    final AssetEntity result = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<AssetEntity>(
      SlidePageTransitionBuilder<AssetEntity>(
        builder: CameraPicker(
          isAllowRecording: isAllowRecording,
          isOnlyAllowRecording: isOnlyAllowRecording,
          enableAudio: enableAudio,
          maximumRecordingDuration: maximumRecordingDuration,
          theme: theme,
          cameraQuarterTurns: cameraQuarterTurns,
          textDelegate: textDelegate,
          resolutionPreset: resolutionPreset,
        ),
        transitionCurve: Curves.easeIn,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    return result;
  }

  /// Build a dark theme according to the theme color.
  /// 通过主题色构建一个默认的暗黑主题
  static ThemeData themeData(Color themeColor) => ThemeData.dark().copyWith(
        buttonColor: themeColor,
        brightness: Brightness.dark,
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
        cursorColor: themeColor,
        textSelectionColor: themeColor.withAlpha(100),
        textSelectionHandleColor: themeColor,
        indicatorColor: themeColor,
        appBarTheme: const AppBarTheme(
          brightness: Brightness.dark,
          elevation: 0,
        ),
        colorScheme: ColorScheme(
          primary: Colors.grey[900],
          primaryVariant: Colors.grey[900],
          secondary: themeColor,
          secondaryVariant: themeColor,
          background: Colors.grey[900],
          surface: Colors.grey[900],
          brightness: Brightness.dark,
          error: const Color(0xffcf6679),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.black,
        ),
      );

  @override
  CameraPickerState createState() => CameraPickerState();
}

class CameraPickerState extends State<CameraPicker> {
  /// The [Duration] for record detection. (200ms)
  /// 检测是否开始录制的时长 (200毫秒)
  final Duration recordDetectDuration = const Duration(milliseconds: 200);

  /// Available cameras.
  /// 可用的相机实例
  List<CameraDescription> cameras;

  /// The controller for the current camera.
  /// 当前相机实例的控制器
  CameraController cameraController;

  /// The index of the current cameras. Defaults to `0`.
  /// 当前相机的索引。默认为0
  int currentCameraIndex = 0;

  /// The path which the temporary file will be stored.
  /// 临时文件会存放的目录
  String cacheFilePath;

  /// Whether the [shootingButton] should animate according to the gesture.
  /// 拍照按钮是否需要执行动画
  ///
  /// This happens when the [shootingButton] is being long pressed. It will animate
  /// for video recording state.
  ///
  /// 当长按拍照按钮时，会进入准备录制视频的状态，此时需要执行动画。
  bool isShootingButtonAnimate = false;

  /// Whether the recording progress started.
  /// 是否已开始录制视频
  ///
  /// After [shootingButton] animated, the [CircleProgressBar] will become visible.
  ///
  /// 当拍照按钮动画执行结束后，进度将变为可见状态并开始更新其状态。
  bool get isRecording => cameraController?.value?.isRecordingVideo ?? false;

  /// The [Timer] for record start detection.
  /// 用于检测是否开始录制的定时器
  ///
  /// When the [shootingButton] started animate, this [Timer] will start at the same
  /// time. When the time is more than [recordDetectDuration], which means we should
  /// start recoding, the timer finished.
  ///
  /// 当拍摄按钮开始执行动画时，定时器会同时启动。时长超过检测时长时，定时器完成。
  Timer recordDetectTimer;

  /// The [Timer] for record countdown.
  /// 用于录制视频倒计时的计时器
  ///
  /// When the record time reached the [maximumRecordingDuration], stop the recording.
  /// However, if there's no limitation on record time, this will be useless.
  ///
  /// 当录像时间达到了最大时长，将通过定时器停止录像。
  /// 但如果录像时间没有限制，定时器将不会起作用。
  Timer recordCountdownTimer;

  /// Whether the current [CameraDescription] initialized.
  /// 当前的相机实例是否已完成初始化
  bool get isInitialized => cameraController?.value?.isInitialized ?? false;

  /// Whether the picker can record video. (A non-null wrapper)
  /// 选择器是否可以录像（非空包装）
  bool get isAllowRecording => widget.isAllowRecording ?? false;

  /// Whether the picker can only record video. (A non-null wrapper)
  /// 选择器是否仅可以录像（非空包装）
  bool get isOnlyAllowRecording => widget.isOnlyAllowRecording ?? false;

  /// Whether the picker should record audio. (A non-null wrapper)
  /// 选择器录制视频时，是否需要录制音频（非空包装）
  bool get enableAudio => isAllowRecording && (widget.enableAudio ?? true);

  /// Getter for `widget.maximumRecordingDuration` .
  Duration get maximumRecordingDuration => widget.maximumRecordingDuration;

  /// Whether the recording restricted to a specific duration.
  /// 录像是否有限制的时长
  ///
  /// It's **NON-GUARANTEE** for stability if there's no limitation on the record duration.
  /// This is still an experimental control.
  ///
  /// 如果拍摄时长没有限制，不保证稳定性。它仍然是一项实验性的控制。
  bool get isRecordingRestricted => maximumRecordingDuration != null;

  /// The path of the taken picture file.
  /// 拍照文件的路径
  String takenPictureFilePath;

  /// The path of the taken video file.
  /// 录制文件的路径
  String takenVideoFilePath;

  /// The [File] instance of the taken picture.
  /// 拍照文件的 [File] 实例
  File get takenPictureFile => File(takenPictureFilePath);

  /// The [File] instance of the taken video.
  /// 录制文件的 [File] 实例
  File get takenVideoFile => File(takenVideoFilePath);

  /// A getter to the current [CameraDescription].
  /// 获取当前相机实例
  CameraDescription get currentCamera => cameras?.elementAt(currentCameraIndex);

  /// If there's no theme provided from the user, use [CameraPicker.themeData] .
  /// 如果用户未提供主题，
  ThemeData _theme;

  /// Get [ThemeData] of the [AssetPicker] through [Constants.pickerKey].
  /// 通过常量全局 Key 获取当前选择器的主题
  ThemeData get theme => _theme;

  @override
  void initState() {
    super.initState();
    _theme = widget.theme ?? CameraPicker.themeData(C.themeColor);

    // TODO(Alex): Currently hide status bar will cause the viewport shaking on Android.
    /// Hide system status bar automatically on iOS.
    /// 在iOS设备上自动隐藏状态栏
    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
    }

    try {
      initStorePath();
      initCameras();
    } catch (e) {
      realDebugPrint('Error when initializing: $e');
      if (context == null) {
        SchedulerBinding.instance.addPostFrameCallback((Duration _) {
          Navigator.of(context).pop();
        });
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    cameraController?.dispose();
    recordDetectTimer?.cancel();
    recordCountdownTimer?.cancel();
    super.dispose();
  }

  /// Defined the path with platforms specification.
  /// 根据平台存储规范及特性确定存储路径。
  ///
  /// * When the platform is not Android, use [getApplicationDocumentsDirectory] .
  /// * When [Platform.isAndroid] :
  ///   * SDK < 29: /sdcard/DCIM/camera .
  ///   * SDK >= 29: ${cacheDir}/ .
  Future<void> initStorePath() async {
    try {
      /// Get device info before the path initialized.
      await DeviceUtils.getDeviceInfo();

      if (Platform.isAndroid) {
        if (DeviceUtils.isLowerThanAndroidQ) {
          cacheFilePath =
          '${(await getExternalStorageDirectory()).path}/DCIM/Camera/';
        } else {
          cacheFilePath = (await getTemporaryDirectory()).path;
        }
      } else {
        cacheFilePath = (await getApplicationDocumentsDirectory()).path;
      }
      if (cacheFilePath != null) {
        cacheFilePath += '/cameraPicker';

        /// Check if the directory is exist.
        final Directory directory = Directory(cacheFilePath);
        if (!directory.existsSync()) {
          /// Create the directory recursively.
          await directory.create(recursive: true);
        }
      } else {
        realDebugPrint('Failed to initialize path: Still null.');
      }
    } catch (e) {
      realDebugPrint('Error when initializing store path: $e');
    }
  }

  /// Initialize cameras instances.
  /// 初始化相机实例
  Future<void> initCameras({CameraDescription cameraDescription}) async {
    await cameraController?.dispose();

    /// When it's null, which means this is the first time initializing the cameras.
    /// So cameras should fetch.
    if (cameraDescription == null) {
      cameras = await availableCameras();
    }

    /// After cameras fetched, judge again with the list is empty or not to ensure
    /// there is at least an available camera for use.
    if (cameraDescription == null && (cameras?.isEmpty ?? true)) {
      realDebugPrint('No cameras found.');
      return;
    }

    /// Initialize the controller with the max resolution preset.
    /// - No one want the lower resolutions. :)
    cameraController = CameraController(
      cameraDescription ?? cameras[0],
      widget.resolutionPreset,
      enableAudio: enableAudio,
    );
    cameraController.initialize().then((dynamic _) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  /// The method to switch cameras.
  /// 切换相机的方法
  ///
  /// Switch cameras in order. When the [currentCameraIndex] reached the length
  /// of cameras, start from the beginning.
  ///
  /// 按顺序切换相机。当达到相机数量时从头开始。
  void switchCameras() {
    ++currentCameraIndex;
    if (currentCameraIndex == cameras.length) {
      currentCameraIndex = 0;
    }
    initCameras(cameraDescription: currentCamera);
  }

  /// The method to take a picture.
  /// 拍照方法
  ///
  /// The picture will only taken when [isInitialized], and the camera is not
  /// taking pictures.
  ///
  /// 仅当初始化成功且相机未在拍照时拍照。
  Future<void> takePicture() async {
    if (isInitialized && !cameraController.value.isTakingPicture) {
      try {
        final String path = '${cacheFilePath}_$currentTimeStamp.jpg';
        await cameraController.takePicture(path);
        takenPictureFilePath = path;

        final AssetEntity entity = await CameraPickerViewer.pushToViewer(
          context,
          pickerState: this,
          pickerType: CameraPickerViewType.image,
          previewFile: takenPictureFile,
          previewFilePath: takenPictureFilePath,
          theme: theme,
        );
        if (entity != null) {
          Navigator.of(context).pop(entity);
        } else {
          takenPictureFilePath = null;
          if (mounted) {
            setState(() {});
          }
        }
      } catch (e) {
        realDebugPrint('Error when taking pictures: $e');
        takenPictureFilePath = null;
      }
    }
  }

  /// When the [shootingButton]'s `onLongPress` called, the timer [recordDetectTimer]
  /// will be initialized to achieve press time detection. If the duration
  /// reached to same as [recordDetectDuration], and the timer still active,
  /// start recording video.
  ///
  /// 当 [shootingButton] 触发了长按，初始化一个定时器来实现时间检测。如果长按时间
  /// 达到了 [recordDetectDuration] 且定时器未被销毁，则开始录制视频。
  void recordDetection() {
    recordDetectTimer = Timer(recordDetectDuration, () {
      startRecordingVideo();
      if (mounted) {
        setState(() {});
      }
    });
    setState(() {
      isShootingButtonAnimate = true;
    });
  }

  /// This will be given to the [Listener] in the [shootingButton]. When it's
  /// called, which means no more pressing on the button, cancel the timer and
  /// reset the status.
  ///
  /// 这个方法会赋值给 [shootingButton] 中的 [Listener]。当按钮释放了点击后，定时器
  /// 将被取消，并且状态会重置。
  void recordDetectionCancel(PointerUpEvent event) {
    recordDetectTimer?.cancel();
    if (isRecording) {
      stopRecordingVideo();
      if (mounted) {
        setState(() {});
      }
    }
    if (isShootingButtonAnimate) {
      isShootingButtonAnimate = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Set record file path and start recording.
  /// 设置拍摄文件路径并开始录制视频
  void startRecordingVideo() {
    final String filePath = '${cacheFilePath}_$currentTimeStamp.mp4';
    takenVideoFilePath = filePath;
    if (!cameraController.value.isRecordingVideo) {
      cameraController.startVideoRecording(filePath).then((dynamic _) {
        if (mounted) {
          setState(() {});
        }
        if (isRecordingRestricted) {
          recordCountdownTimer = Timer(maximumRecordingDuration, () {
            stopRecordingVideo();
          });
        }
      }).catchError((dynamic e) {
        takenVideoFilePath = null;
        realDebugPrint('Error when recording video: $e');
        if (cameraController.value.isRecordingVideo) {
          cameraController.stopVideoRecording().catchError((dynamic e) {
            realDebugPrint('Error when stop recording video: $e');
          });
        }
      });
    }
  }

  /// Stop the recording process.
  /// 停止录制视频
  Future<void> stopRecordingVideo() async {
    if (cameraController.value.isRecordingVideo) {
      cameraController.stopVideoRecording().then((dynamic result) async {
        final AssetEntity entity = await CameraPickerViewer.pushToViewer(
          context,
          pickerState: this,
          pickerType: CameraPickerViewType.video,
          previewFile: takenVideoFile,
          previewFilePath: takenVideoFilePath,
          theme: theme,
        );
        if (entity != null) {
          Navigator.of(context).pop(entity);
        } else {
          takenVideoFilePath = null;
          if (mounted) {
            setState(() {});
          }
        }
      }).catchError((dynamic e) {
        realDebugPrint('Error when stop recording video: $e');
      }).whenComplete(() {
        isShootingButtonAnimate = false;
        takenVideoFilePath = null;
      });
    }
  }

  /// Settings action section widget.
  /// 设置操作区
  ///
  /// This displayed at the top of the screen.
  /// 该区域显示在屏幕上方。
  Widget get settingsAction {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: <Widget>[
          const Spacer(),
          // TODO(Alex): There's an issue tracking NPE of the camera plugin, so switching is temporary disabled .
          if ((cameras?.length ?? 0) > 1) switchCamerasButton,
        ],
      ),
    );
  }

  /// The button to switch between cameras.
  /// 切换相机的按钮
  Widget get switchCamerasButton {
    return InkWell(
      onTap: switchCameras,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(
          Icons.switch_camera,
          color: Colors.white,
          size: 30.0,
        ),
      ),
    );
  }

  /// Text widget for shooting tips.
  /// 拍摄的提示文字
  Widget get tipsTextWidget {
    return AnimatedOpacity(
      duration: recordDetectDuration,
      opacity: isRecording ? 0.0 : 1.0,
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
  Widget get shootingActions {
    return SizedBox(
      height: Screens.width / 3.5,
      child: Row(
        children: <Widget>[
          Expanded(
            child: !isRecording
                ? Center(child: backButton)
                : const SizedBox.shrink(),
          ),
          Expanded(child: Center(child: shootingButton)),
          const Spacer(),
        ],
      ),
    );
  }

  /// The back button near to the [shootingButton].
  /// 靠近拍照键的返回键
  Widget get backButton {
    return InkWell(
      borderRadius: maxBorderRadius,
      onTap: Navigator.of(context).pop,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        width: Screens.width / 15,
        height: Screens.width / 15,
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
  // TODO(Alex): Need further integration with video recording.
  Widget get shootingButton {
    final Size outerSize = Size.square(Screens.width / 3.5);
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerUp: isAllowRecording ? recordDetectionCancel : null,
      child: InkWell(
        borderRadius: maxBorderRadius,
        onTap: !isOnlyAllowRecording ? takePicture : null,
        onLongPress: isAllowRecording ? recordDetection : null,
        child: SizedBox.fromSize(
          size: outerSize,
          child: Stack(
            children: <Widget>[
              Center(
                child: AnimatedContainer(
                  duration: kThemeChangeDuration,
                  width: isShootingButtonAnimate
                      ? outerSize.width
                      : (Screens.width / 5),
                  height: isShootingButtonAnimate
                      ? outerSize.height
                      : (Screens.width / 5),
                  padding: EdgeInsets.all(
                    Screens.width / (isShootingButtonAnimate ? 10 : 35),
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white30,
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
              if (isRecording && isRecordingRestricted)
                CircleProgressBar(
                  duration: maximumRecordingDuration,
                  outerRadius: outerSize.width,
                  ringsWidth: 2.0,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Material(
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            if (isInitialized)
              Center(
                child: RotatedBox(
                  quarterTurns: widget.cameraQuarterTurns ?? 0,
                  child: AspectRatio(
                    aspectRatio: cameraController.value.aspectRatio,
                    child: CameraPreview(cameraController),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: <Widget>[
                    settingsAction,
                    const Spacer(),
                    tipsTextWidget,
                    shootingActions,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
