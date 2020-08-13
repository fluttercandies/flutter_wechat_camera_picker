///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/16 22:02
///
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../constants/constants.dart';

import 'camera_picker.dart';

/// Two types for the viewer: image and video.
/// 两种预览类型：图片和视频
enum CameraPickerViewType { image, video }

class CameraPickerViewer extends StatefulWidget {
  const CameraPickerViewer({
    Key key,
    @required this.pickerState,
    @required this.pickerType,
    @required this.previewFile,
    @required this.previewFilePath,
    @required this.theme,
  })  : assert(
          theme != null && previewFile != null && pickerState != null,
        ),
        super(key: key);

  /// State of the picker.
  /// 选择器的状态实例
  final CameraPickerState pickerState;

  /// The type of the viewer. (Image | Video)
  /// 预览的类型（图片或视频）
  final CameraPickerViewType pickerType;

  /// The [File] of the preview file.
  /// 预览文件的 [File] 实例
  final File previewFile;

  /// The file path of the preview file.
  /// 预览文件的文件路径
  final String previewFilePath;

  /// The [ThemeData] which the picker is using.
  /// 选择器使用的主题
  final ThemeData theme;

  /// Static method to push with the navigator.
  /// 跳转至选择预览的静态方法
  static Future<AssetEntity> pushToViewer(
    BuildContext context, {
    @required CameraPickerState pickerState,
    @required CameraPickerViewType pickerType,
    @required File previewFile,
    @required String previewFilePath,
    @required ThemeData theme,
  }) async {
    try {
      final Widget viewer = CameraPickerViewer(
        pickerState: pickerState,
        pickerType: pickerType,
        previewFile: previewFile,
        previewFilePath: previewFilePath,
        theme: theme,
      );
      final PageRouteBuilder<AssetEntity> pageRoute =
          PageRouteBuilder<AssetEntity>(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return viewer;
        },
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
      final AssetEntity result =
          await Navigator.of(context).push<AssetEntity>(pageRoute);
      return result;
    } catch (e) {
      realDebugPrint('Error when calling camera picker viewer: $e');
      return null;
    }
  }

  @override
  _CameraPickerViewerState createState() => _CameraPickerViewerState();
}

class _CameraPickerViewerState extends State<CameraPickerViewer> {
  /* Start of widget getter */
  CameraPickerState get pickerState => widget.pickerState;

  CameraPickerViewType get pickerType => widget.pickerType;

  File get previewFile => widget.previewFile;

  String get previewFilePath => widget.previewFilePath;

  ThemeData get theme => widget.theme;
  /* End of widget getter */

  /// Controller for the video player.
  /// 视频播放的控制器
  VideoPlayerController videoController;

  /// Whether the player is playing.
  /// 播放器是否在播放
  bool isPlaying = false;

  /// Whether the controller is playing.
  /// 播放控制器是否在播放
  bool get isControllerPlaying => videoController?.value?.isPlaying ?? false;

  /// Whether there's any error when initialize the video controller.
  /// 初始化视频控制器时是否发生错误
  bool hasErrorWhenInitializing = false;

  @override
  void initState() {
    super.initState();
    if (pickerType == CameraPickerViewType.video) {
      initializeVideoPlayerController();
    }
  }

  @override
  void dispose() {
    /// Remove listener from the controller and dispose it when widget dispose.
    /// 部件销毁时移除控制器的监听并销毁控制器。
    videoController?.removeListener(videoPlayerListener);
    videoController?.pause();
    videoController?.dispose();
    super.dispose();
  }

  /// Get media url from the asset, then initialize the controller and add with a listener.
  /// 从资源获取媒体url后初始化，并添加监听。
  Future<void> initializeVideoPlayerController() async {
    videoController = VideoPlayerController.file(previewFile);
    try {
      await videoController.initialize();
      videoController.addListener(videoPlayerListener);
    } catch (e) {
      realDebugPrint('Error when initialize video controller: $e');
      hasErrorWhenInitializing = true;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Listener for the video player.
  /// 播放器的监听方法
  void videoPlayerListener() {
    if (isControllerPlaying != isPlaying) {
      isPlaying = isControllerPlaying;
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Callback for the play button.
  /// 播放按钮的回调
  ///
  /// Normally it only switches play state for the player. If the video reaches the end,
  /// then click the button will make the video replay.
  /// 一般来说按钮只切换播放暂停。当视频播放结束时，点击按钮将从头开始播放。
  Future<void> playButtonCallback() async {
    if (videoController.value != null) {
      if (isPlaying) {
        videoController.pause();
      } else {
        if (videoController.value.duration == videoController.value.position) {
          videoController
            ..seekTo(Duration.zero)
            ..play();
        } else {
          videoController.play();
        }
      }
    }
  }

  /// When users confirm to use the taken file, create the [AssetEntity].
  /// While the entity might returned null, there's no side effects if popping `null`
  /// because the parent picker will ignore it.
  Future<void> createAssetEntityAndPop() async {
    try {
      Future<AssetEntity> saveFuture;

      switch (pickerType) {
        case CameraPickerViewType.image:
          final Uint8List data = await previewFile.readAsBytes();
          saveFuture = PhotoManager.editor.saveImage(
            data,
            title: previewFilePath,
          );
          break;
        case CameraPickerViewType.video:
          saveFuture = PhotoManager.editor.saveVideo(
            previewFile,
            title: previewFilePath,
          );
          break;
      }

      saveFuture.then((AssetEntity entity) {
        if (Platform.isAndroid) {
          if (!DeviceUtils.isLowerThanAndroidQ && previewFile.existsSync()) {
            previewFile.delete();
          }
        } else {
          if (previewFile.existsSync()) {
            previewFile.delete();
          }
        }
        Navigator.of(context).pop(entity);
      });
    } catch (e) {
      realDebugPrint('Error when creating entity: $e');
    }
  }

  /// The back button for the preview section.
  /// 预览区的返回按钮
  Widget get previewBackButton {
    return InkWell(
      borderRadius: maxBorderRadius,
      onTap: () {
        if (previewFile.existsSync()) {
          previewFile.delete();
        }
        Navigator.of(context).pop();
      },
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
            Icons.close,
            color: Colors.black,
            size: 18.0,
          ),
        ),
      ),
    );
  }

  /// The confirm button for the preview section.
  /// 预览区的确认按钮
  Widget get previewConfirmButton {
    return MaterialButton(
      minWidth: 20.0,
      height: 32.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      color: theme.colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Text(
        Constants.textDelegate.confirm,
        style: TextStyle(
          color: theme.textTheme.bodyText1.color,
          fontSize: 17.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      onPressed: createAssetEntityAndPop,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// A play control button the video playing process.
  /// 控制视频播放的按钮
  Widget get playControlButton {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isPlaying ? playButtonCallback : null,
      child: Center(
        child: AnimatedOpacity(
          duration: kThemeAnimationDuration,
          opacity: isControllerPlaying ? 0.0 : 1.0,
          child: GestureDetector(
            onTap: playButtonCallback,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                boxShadow: <BoxShadow>[BoxShadow(color: Colors.black12)],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isControllerPlaying
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_filled,
                size: 70.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Actions section for the viewer. Including 'back' and 'confirm' button.
  /// 预览的操作区。包括"返回"和"确定"按钮。
  Widget get viewerActions {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 20.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                previewBackButton,
                const Spacer(),
              ],
            ),
            Row(
              children: <Widget>[
                const Spacer(),
                previewConfirmButton,
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          /// Place the specific widget according to the view type.
          if (pickerType == CameraPickerViewType.image)
            Positioned.fill(child: Image.file(previewFile))
          else if (pickerType == CameraPickerViewType.video)
            if (videoController?.value?.initialized ?? false)
              Positioned.fill(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: videoController.value.aspectRatio,
                    child: VideoPlayer(videoController),
                  ),
                ),
              ),

          /// Place the button before the actions to ensure it's not blocking.
          if (pickerType == CameraPickerViewType.video &&
              videoController != null)
            playControlButton,

          viewerActions,
        ],
      ),
    );
  }
}
