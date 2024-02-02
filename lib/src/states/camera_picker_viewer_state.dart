// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import 'package:wechat_picker_library/wechat_picker_library.dart';

import '../internals/singleton.dart';
import '../constants/enums.dart';
import '../constants/type_defs.dart';
import '../internals/methods.dart';
import '../widgets/camera_picker.dart';
import '../widgets/camera_picker_viewer.dart';

class CameraPickerViewerState extends State<CameraPickerViewer> {
  /// Whether the player is playing.
  /// 播放器是否在播放
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  late final ThemeData theme = widget.pickerConfig.theme ??
      CameraPicker.themeData(defaultThemeColorWeChat);

  /// Construct an [File] instance through [previewXFile].
  /// 通过 [previewXFile] 构建 [File] 实例。
  late final File previewFile = File(widget.previewXFile.path);

  /// Controller for the video player.
  /// 视频播放的控制器
  late final VideoPlayerController videoController =
      VideoPlayerController.file(previewFile);

  /// Whether the controller is playing.
  /// 播放控制器是否在播放
  bool get isControllerPlaying => videoController.value.isPlaying;

  /// Whether the controller has initialized.
  /// 控制器是否已初始化
  late bool hasLoaded = widget.viewType == CameraPickerViewType.image;

  /// Whether there's any error when initialize the video controller.
  /// 初始化视频控制器时是否发生错误
  bool hasErrorWhenInitializing = false;

  /// Whether the saving process is ongoing.
  bool isSavingEntity = false;

  CameraErrorHandler? get onError => widget.pickerConfig.onError;

  @override
  void initState() {
    super.initState();
    if (widget.viewType == CameraPickerViewType.video) {
      initializeVideoPlayerController();
    }
  }

  @override
  void dispose() {
    videoController
      ..removeListener(videoControllerListener)
      ..pause()
      ..dispose();
    super.dispose();
  }

  Future<void> initializeVideoPlayerController() async {
    try {
      await videoController.initialize();
      videoController.addListener(videoControllerListener);
      hasLoaded = true;
      if (widget.pickerConfig.shouldAutoPreviewVideo) {
        videoController.play();
      }
    } catch (e, s) {
      hasErrorWhenInitializing = true;
      realDebugPrint('Error when initializing video controller: $e');
      handleErrorWithHandler(e, s, onError);
    } finally {
      safeSetState(() {});
    }
  }

  /// Listener for the video player.
  /// 播放器的监听方法
  void videoControllerListener() {
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
    try {
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
    } catch (e, s) {
      handleErrorWithHandler(e, s, onError);
    }
  }

  /// When users confirm to use the taken file, create the [AssetEntity].
  /// While the entity might returned null, there's no side effects if popping `null`
  /// because the parent picker will ignore it.
  Future<void> createAssetEntityAndPop() async {
    if (isSavingEntity) {
      return;
    }
    setState(() {
      isSavingEntity = true;
    });

    // Handle the explicitly entity saving method.
    if (widget.pickerConfig.onEntitySaving != null) {
      try {
        await widget.pickerConfig.onEntitySaving!(
          context,
          widget.viewType,
          File(widget.previewXFile.path),
        );
      } catch (e, s) {
        handleErrorWithHandler(e, s, onError);
      } finally {
        safeSetState(() {
          isSavingEntity = false;
        });
      }
      return;
    }

    AssetEntity? entity;
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (ps == PermissionState.authorized || ps == PermissionState.limited) {
        switch (widget.viewType) {
          case CameraPickerViewType.image:
            final String filePath = previewFile.path;
            entity = await PhotoManager.editor.saveImageWithPath(
              filePath,
              title: path.basename(previewFile.path),
            );
            break;
          case CameraPickerViewType.video:
            entity = await PhotoManager.editor.saveVideo(
              previewFile,
              title: path.basename(previewFile.path),
            );
            break;
        }
        if (widget.pickerConfig.shouldDeletePreviewFile &&
            previewFile.existsSync()) {
          previewFile.delete().catchError((e, s) {
            handleErrorWithHandler(e, s, onError);
            return previewFile;
          });
        }
        return;
      }
      handleErrorWithHandler(
        StateError(
          'Permission is not fully granted to save the captured file.',
        ),
        StackTrace.current,
        onError,
      );
    } catch (e, s) {
      realDebugPrint('Saving entity failed: $e');
      handleErrorWithHandler(e, s, onError);
    } finally {
      safeSetState(() {
        isSavingEntity = false;
      });
      if (mounted) {
        Navigator.of(context).pop(entity);
      }
    }
  }

  /// The back button for the preview section.
  /// 预览区的返回按钮
  Widget buildBackButton(BuildContext context) {
    return Semantics(
      sortKey: const OrdinalSortKey(0),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: IconButton(
          onPressed: () {
            if (isSavingEntity) {
              return;
            }
            if (previewFile.existsSync()) {
              previewFile.delete();
            }
            Navigator.of(context).pop();
          },
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tight(const Size.square(28)),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          iconSize: 18,
          icon: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.keyboard_return_rounded,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPreview(BuildContext context) {
    final Widget builder;
    if (widget.viewType == CameraPickerViewType.video) {
      builder = Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: videoController.value.aspectRatio,
              child: VideoPlayer(videoController),
            ),
          ),
          buildPlayControlButton(context),
        ],
      );
    } else {
      builder = Image.file(previewFile);
    }
    return MergeSemantics(
      child: Semantics(
        label: Singleton.textDelegate.sActionPreviewHint,
        image: true,
        onTapHint: Singleton.textDelegate.sActionPreviewHint,
        sortKey: const OrdinalSortKey(1),
        child: builder,
      ),
    );
  }

  /// The confirm button for the preview section.
  /// 预览区的确认按钮
  Widget buildConfirmButton(BuildContext context) {
    return MaterialButton(
      minWidth: 20,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: theme.colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      onPressed: createAssetEntityAndPop,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Text(
        Singleton.textDelegate.confirm,
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontSize: 17,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  /// A play control button the video playing process.
  /// 控制视频播放的按钮
  Widget buildPlayControlButton(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPlaying,
      builder: (_, bool value, Widget? child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: value ? playButtonCallback : null,
        child: Center(
          child: AnimatedOpacity(
            duration: kThemeAnimationDuration,
            opacity: value ? 0 : 1,
            child: GestureDetector(
              onTap: playButtonCallback,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  boxShadow: <BoxShadow>[BoxShadow(color: Colors.black12)],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value ? Icons.pause_circle_outline : Icons.play_circle_filled,
                  size: 70,
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
  Widget buildForeground(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Semantics(
              sortKey: const OrdinalSortKey(0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: buildBackButton(context),
              ),
            ),
            Semantics(
              sortKey: const OrdinalSortKey(2),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: buildConfirmButton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoading(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: kThemeAnimationDuration,
        opacity: isSavingEntity ? 1 : 0,
        child: _WechatLoading(tip: Singleton.textDelegate.saving),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hasErrorWhenInitializing) {
      return Center(
        child: Text(
          Singleton.textDelegate.loadFailed,
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
        fit: StackFit.expand,
        children: <Widget>[
          buildPreview(context),
          buildForeground(context),
          if (isSavingEntity) buildLoading(context),
        ],
      ),
    );
  }
}

class _WechatLoading extends StatefulWidget {
  // ignore: unused_element
  const _WechatLoading({super.key, required this.tip});

  final String tip;

  @override
  State<_WechatLoading> createState() => _WechatLoadingState();
}

class _WechatLoadingState extends State<_WechatLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildContent(BuildContext context, double minWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox.fromSize(
          size: Size.square(minWidth / 3),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, Widget? child) => Transform.rotate(
              angle: math.pi * 2 * _controller.value,
              child: child,
            ),
            child: CustomPaint(
              painter: _LoadingPainter(
                Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ),
        SizedBox(height: minWidth / 10),
        Text(
          widget.tip,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double minWidth = MediaQuery.of(context).size.shortestSide / 3;
    return Container(
      color: Colors.black38,
      alignment: Alignment.center,
      child: RepaintBoundary(
        child: Container(
          constraints: BoxConstraints(minWidth: minWidth),
          padding: EdgeInsets.all(minWidth / 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).canvasColor,
          ),
          child: _buildContent(context, minWidth),
        ),
      ),
    );
  }
}

class _LoadingPainter extends CustomPainter {
  const _LoadingPainter(this.activeColor);

  final Color? activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Color color = activeColor ?? Colors.white;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..shader = SweepGradient(
        colors: <Color>[color.withOpacity(0), color],
      ).createShader(rect);
    canvas.drawArc(rect, 0.1, math.pi * 2 * 0.9, false, paint);
  }

  @override
  bool shouldRepaint(_LoadingPainter oldDelegate) => false;
}
