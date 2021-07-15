///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/16 22:02
///
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

import '../constants/constants.dart';

import 'camera_picker.dart';

/// Two types for the viewer: image and video.
/// 两种预览类型：图片和视频
enum CameraPickerViewType { image, video }

/// {@template wechat_camera_picker.SaveEntityCallback}
/// The callback type define for saving entity in the viewer.
/// 在查看器中保存图片时的回调
///
/// ### Notice about the implementation
///  * After the callback is implemented, the default saving method
///    won't called anymore.
///  * Don't call `Navigator.of(context).pop/maybePop` without popping `null` or
///    `AssetEntity`, otherwise there will be a type cast error occurred.
///
/// ### 在实现时需要注意
///  * 实现该方法后，原本的保存方法不会再被调用；
///  * 不要使用 `Navigator.of(context).pop/maybePop` 返回 `null` 或 `AssetEntity`
///    以外类型的内容，否则会抛出类型转换异常。
/// {@endtemplate}
typedef EntitySaveCallback = FutureOr<dynamic> Function({
  BuildContext context,
  CameraPickerViewType viewType,
  File file,
});

class CameraPickerViewer extends StatefulWidget {
  const CameraPickerViewer({
    Key? key,
    required this.pickerState,
    required this.pickerType,
    required this.previewXFile,
    required this.theme,
    this.shouldDeletePreviewFile = false,
    this.onEntitySaving,
  }) : super(key: key);

  /// State of the picker.
  /// 选择器的状态实例
  final CameraPickerState pickerState;

  /// The type of the viewer. (Image | Video)
  /// 预览的类型（图片或视频）
  final CameraPickerViewType pickerType;

  /// The [XFile] of the preview file.
  /// 预览文件的 [XFile] 实例
  final XFile previewXFile;

  /// The [ThemeData] which the picker is using.
  /// 选择器使用的主题
  final ThemeData theme;

  /// Whether the preview file will be delete when pop.
  /// 返回页面时是否删除预览文件
  final bool shouldDeletePreviewFile;

  /// {@macro wechat_camera_picker.SaveEntityCallback}
  final EntitySaveCallback? onEntitySaving;

  /// Static method to push with the navigator.
  /// 跳转至选择预览的静态方法
  static Future<AssetEntity?> pushToViewer(
    BuildContext context, {
    required CameraPickerState pickerState,
    required CameraPickerViewType pickerType,
    required XFile previewXFile,
    required ThemeData theme,
    bool shouldDeletePreviewFile = false,
    EntitySaveCallback? onEntitySaving,
  }) {
    return Navigator.of(context).push<AssetEntity?>(
      PageRouteBuilder<AssetEntity?>(
        pageBuilder: (_, __, ___) => CameraPickerViewer(
          pickerState: pickerState,
          pickerType: pickerType,
          previewXFile: previewXFile,
          theme: theme,
          shouldDeletePreviewFile: shouldDeletePreviewFile,
          onEntitySaving: onEntitySaving,
        ),
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  _CameraPickerViewerState createState() => _CameraPickerViewerState();
}

class _CameraPickerViewerState extends State<CameraPickerViewer> {
  /// Controller for the video player.
  /// 视频播放的控制器
  late final VideoPlayerController videoController =
      VideoPlayerController.file(previewFile);

  /// Whether the controller has initialized.
  /// 控制器是否已初始化
  late bool hasLoaded = pickerType == CameraPickerViewType.image;

  /// Whether there's any error when initialize the video controller.
  /// 初始化视频控制器时是否发生错误
  bool hasErrorWhenInitializing = false;

  /// Whether the player is playing.
  /// 播放器是否在播放
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  /// Whether the controller is playing.
  /// 播放控制器是否在播放
  bool get isControllerPlaying => videoController.value.isPlaying;

  CameraPickerState get pickerState => widget.pickerState;

  CameraPickerViewType get pickerType => widget.pickerType;

  XFile get previewXFile => widget.previewXFile;

  /// Construct an [File] instance through [previewXFile].
  /// 通过 [previewXFile] 构建 [File] 实例。
  File get previewFile => File(previewXFile.path);

  ThemeData get theme => widget.theme;

  bool get shouldDeletePreviewFile => widget.shouldDeletePreviewFile;

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
    videoController.removeListener(videoPlayerListener);
    videoController.pause();
    videoController.dispose();
    super.dispose();
  }

  /// Get media url from the asset, then initialize the controller and add with
  /// a listener.
  /// 从资源获取媒体url后初始化，并添加监听。
  Future<void> initializeVideoPlayerController() async {
    try {
      await videoController.initialize();
      videoController.addListener(videoPlayerListener);
      hasLoaded = true;
    } catch (e) {
      hasErrorWhenInitializing = true;
      realDebugPrint('Error when initializing video controller: $e');
      rethrow;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Listener for the video player.
  /// 播放器的监听方法
  void videoPlayerListener() {
    if (isControllerPlaying != isPlaying.value) {
      isPlaying.value = isControllerPlaying;
    }
  }

  /// Callback for the play button.
  /// 播放按钮的回调
  ///
  /// Normally it only switches play state for the player. If the video reaches
  /// the end, then click the button will make the video replay.
  /// 一般来说按钮只切换播放暂停。当视频播放结束时，点击按钮将从头开始播放。
  Future<void> playButtonCallback() async {
    if (isPlaying.value) {
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

  /// When users confirm to use the taken file, create the [AssetEntity].
  /// While the entity might returned null, there's no side effects if popping `null`
  /// because the parent picker will ignore it.
  Future<void> createAssetEntityAndPop() async {
    if (widget.onEntitySaving != null) {
      await widget.onEntitySaving!(
        context: context,
        viewType: pickerType,
        file: previewFile,
      );
      return;
    }
    Future<AssetEntity?> saveFuture;

    switch (pickerType) {
      case CameraPickerViewType.image:
        final Uint8List data = await previewFile.readAsBytes();
        saveFuture = PhotoManager.editor.saveImage(
          data,
          title: path.basename(previewFile.path),
        );
        break;
      case CameraPickerViewType.video:
        saveFuture = PhotoManager.editor.saveVideo(
          previewFile,
          title: path.basename(previewFile.path),
        );
        break;
    }

    saveFuture.then((AssetEntity? entity) {
      if (shouldDeletePreviewFile && previewFile.existsSync()) {
        previewFile.delete();
      }
      Navigator.of(context).pop(entity);
    });
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
            Icons.keyboard_return_rounded,
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
          color: theme.textTheme.bodyText1?.color,
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
    return ValueListenableBuilder<bool>(
      valueListenable: isPlaying,
      builder: (_, bool value, Widget? child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: value ? playButtonCallback : null,
        child: Center(
          child: AnimatedOpacity(
            duration: kThemeAnimationDuration,
            opacity: value ? 0.0 : 1.0,
            child: GestureDetector(
              onTap: playButtonCallback,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  boxShadow: <BoxShadow>[BoxShadow(color: Colors.black12)],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value ? Icons.pause_circle_outline : Icons.play_circle_filled,
                  size: 70.0,
                  color: Colors.white,
                ),
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
    if (hasErrorWhenInitializing) {
      return Center(
        child: Text(
          Constants.textDelegate.loadFailed,
          style: const TextStyle(inherit: false),
        ),
      );
    }
    if (!hasLoaded) {
      return const SizedBox.shrink();
    }
    return Material(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          // Place the specific widget according to the view type.
          if (pickerType == CameraPickerViewType.image)
            Positioned.fill(child: Image.file(previewFile))
          else if (pickerType == CameraPickerViewType.video)
            Positioned.fill(
              child: Center(
                child: AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
              ),
            ),
          // Place the button before the actions to ensure it's not blocking.
          if (pickerType == CameraPickerViewType.video) playControlButton,
          viewerActions,
        ],
      ),
    );
  }
}
