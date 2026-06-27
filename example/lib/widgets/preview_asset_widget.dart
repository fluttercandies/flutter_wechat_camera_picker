// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
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
  BetterPlayerController? _playerController;

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
      if (mounted) {
        setState(() {});
      }
      return;
    }
    try {
      final betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        videoFormat: BetterPlayerVideoFormat.other,
      );
      final betterPlayerConfiguration = BetterPlayerConfiguration(
        autoPlay: true,
        looping: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage ?? 'Failed to load video',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      _playerController = BetterPlayerController(
        betterPlayerConfiguration,
        betterPlayerDataSource: betterPlayerDataSource,
      );
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
    final BetterPlayerController? controller = _playerController;
    if (controller == null) {
      return const CircularProgressIndicator();
    }
    return BetterPlayer(
      controller: controller,
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
