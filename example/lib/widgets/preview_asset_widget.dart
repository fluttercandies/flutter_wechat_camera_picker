// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class PreviewAssetWidget extends StatefulWidget {
  const PreviewAssetWidget(this.asset, {super.key});

  final AssetEntity asset;

  @override
  State<PreviewAssetWidget> createState() => _PreviewAssetWidgetState();
}

class _PreviewAssetWidgetState extends State<PreviewAssetWidget> {
  bool get _isVideo => widget.asset.type == AssetType.video;
  Object? _error;
  VideoPlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    if (_isVideo) {
      _initializeController();
    }
  }

  @override
  void dispose() {
    _playerController?.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    final String? url = await widget.asset.getMediaUrl();
    if (url == null) {
      _error = StateError('The media URL of the preview asset is null.');
      return;
    }
    final VideoPlayerController controller;
    final Uri uri = Uri.parse(url);
    if (Platform.isAndroid) {
      controller = VideoPlayerController.contentUri(uri);
    } else {
      controller = VideoPlayerController.networkUrl(uri);
    }
    _playerController = controller;
    try {
      await controller.initialize();
      controller
        ..setLooping(true)
        ..play();
    } catch (e) {
      _error = e;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildImage(BuildContext context) {
    return AssetEntityImage(widget.asset);
  }

  Widget _buildVideo(BuildContext context) {
    final VideoPlayerController? controller = _playerController;
    if (controller == null) {
      return const CircularProgressIndicator();
    }
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Text('$_error', style: const TextStyle(color: Colors.white));
    }
    if (_isVideo) {
      return _buildVideo(context);
    }
    return _buildImage(context);
  }
}
